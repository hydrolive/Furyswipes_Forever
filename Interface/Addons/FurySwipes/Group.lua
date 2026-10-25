-- Party invites, accept, and follow/assist text.
-- InviteUnit and AcceptGroup match the calls the Forever MAMA addon uses on this client.

FurySwipes = FurySwipes or {}

local inviteGen = 0

local function trim(name)
	if type(name) ~= "string" then return nil end
	name = name:gsub("^%s+", ""):gsub("%s+$", "")
	if name == "" then return nil end
	return name
end

-- UnitName() on this Forever client stops at the first space, so "Grim Reaper"
-- comes back as "Grim" and the roster match fails. GetUnitName(unit, true) is
-- the full character name, with "-Realm" appended for a cross-realm unit.
function FurySwipes.UnitPlainName(unit)
	local full = GetUnitName and GetUnitName(unit, true) or nil
	if type(full) ~= "string" or full == "" then
		full = UnitName(unit)
	end
	full = trim(full)
	if not full then return nil end
	local base = full:match("^(.-)%-[^%s%-]+$")
	if base and base ~= "" then return base end
	return full
end

local function me()
	return FurySwipes.UnitPlainName("player")
end

local function same(a, b)
	a, b = trim(a), trim(b)
	if not a or not b then return false end
	if a:lower() == b:lower() then return true end
	local function base(name)
		return name:match("^(.-)%-[^%s%-]+$") or name
	end
	a, b = base(a), base(b)
	if a:lower() == b:lower() then return true end
	-- One side is the truncated UnitName ("Grim") and the other is the full name.
	local aw, bw = a:match("^(%S+)"), b:match("^(%S+)")
	if aw and bw and aw:lower() == bw:lower() then
		local aSpaced = a:find("%s", 1, true) ~= nil
		local bSpaced = b:find("%s", 1, true) ~= nil
		if aSpaced ~= bSpaced then return true end
	end
	return false
end

function FurySwipes.LeaderName()
	local roster = FurySwipesRoster
	if not roster or not roster.leader or roster.leader == "" then return nil end
	return roster.leader
end

function FurySwipes.IsLeader()
	return same(FurySwipes.LeaderName(), me())
end

function FurySwipes.Members()
	local out = {}
	local roster = FurySwipesRoster
	if not roster or not roster.members then return out end
	for i = 1, #roster.members do
		local member = roster.members[i]
		if type(member) == "table" and type(member.name) == "string" and member.name ~= "" then
			local role = type(member.role) == "string" and member.role:lower() or nil
			out[#out + 1] = { name = member.name, role = role }
		end
	end
	return out
end

function FurySwipes.RosterRole(name)
	if not name then return nil end
	local members = FurySwipes.Members()
	for i = 1, #members do
		if same(members[i].name, name) then return members[i].role end
	end
end

function FurySwipes.OnRoster(name)
	return FurySwipes.RosterRole(name) ~= nil or same(FurySwipes.LeaderName(), name)
end

function FurySwipes.HealFractions()
	local heal = FurySwipesRoster and FurySwipesRoster.heal or nil
	heal = heal or {}
	return heal.tank or 0.50, heal.party or 1, heal.self or 0.30
end

function FurySwipes.InGroup(name)
	if not name then return false end
	if same(name, me()) then return true end
	if not IsInGroup or not IsInGroup() then return false end
	if IsInRaid() then
		for i = 1, GetNumGroupMembers() do
			if same(FurySwipes.UnitPlainName("raid" .. i), name) then return true end
		end
		return false
	end
	for i = 1, 4 do
		if same(FurySwipes.UnitPlainName("party" .. i), name) then return true end
	end
	return false
end

function FurySwipes.SafeName(name)
	if type(name) ~= "string" then return nil end
	-- Keep accented letters. Only strip characters that would break a /follow line.
	local clean = name:gsub("[\r\n|;]", "")
	if clean == "" then return nil end
	return clean
end

local function inviteOne(name)
	if C_PartyInfo and C_PartyInfo.InviteUnit then
		C_PartyInfo.InviteUnit(name)
		return true
	end
	if InviteUnit then
		InviteUnit(name)
		return true
	end
	return false
end

local function afterInvites()
	if not FurySwipes.IsLeader() or not IsInGroup or not IsInGroup() then return end
	if C_PartyInfo and C_PartyInfo.SetLootMethod then
		pcall(C_PartyInfo.SetLootMethod, "freeforall")
	elseif SetLootMethod then
		pcall(SetLootMethod, "freeforall", me())
	end
	local members = FurySwipes.Members()
	if #members <= 5 or IsInRaid() then return end
	if GetNumGroupMembers() >= 5 and UnitIsGroupLeader("player") and C_PartyInfo and C_PartyInfo.ConvertToRaid then
		C_PartyInfo.ConvertToRaid()
	end
end

function FurySwipes.InviteRoster()
	if not FurySwipes.IsLeader() then
		FurySwipes.Print("Only " .. (FurySwipes.LeaderName() or "the roster leader") .. " sends invites. This window accepts them.")
		return
	end
	if InCombatLockdown and InCombatLockdown() then
		FurySwipes.Print("Leave combat before inviting.")
		return
	end
	local pending = {}
	local members = FurySwipes.Members()
	for i = 1, #members do
		local name = FurySwipes.SafeName(members[i].name)
		if name and not same(name, me()) and not FurySwipes.InGroup(name) then
			pending[#pending + 1] = name
		end
	end
	if #pending == 0 then
		FurySwipes.Print("Everyone on the roster is already in the group, or the roster is empty.")
		afterInvites()
		return
	end
	inviteGen = inviteGen + 1
	local gen = inviteGen
	local index = 0
	local function step()
		if gen ~= inviteGen then return end
		index = index + 1
		local name = pending[index]
		if not name then
			afterInvites()
			if C_Timer and C_Timer.After then C_Timer.After(1.5, afterInvites) end
			return
		end
		if not FurySwipes.InGroup(name) then
			if inviteOne(name) then
				FurySwipes.Print("Inviting " .. name .. ".")
			else
				FurySwipes.Print("This client has no invite function.")
				return
			end
		end
		if C_Timer and C_Timer.After then
			C_Timer.After(0.35, step)
		else
			step()
		end
	end
	FurySwipes.Print("Inviting " .. #pending .. " character(s). They need to be online.")
	step()
end

function FurySwipes.AcceptInvite()
	if AcceptGroup then AcceptGroup() end
	if StaticPopup_Hide then StaticPopup_Hide("PARTY_INVITE") end
end

function FurySwipes.OnPartyInvite(inviter)
	local roster = FurySwipesRoster
	local allow = not roster or roster.autoAccept ~= false
	if allow and FurySwipes.OnRoster(inviter) then
		FurySwipes.AcceptInvite()
		FurySwipes.Print("Accepted a group invite from " .. tostring(inviter) .. ".")
	end
end

function FurySwipes.InviteOrAccept()
	if StaticPopup_Visible and StaticPopup_Visible("PARTY_INVITE") then
		FurySwipes.AcceptInvite()
		return
	end
	if FurySwipes.IsLeader() then
		FurySwipes.InviteRoster()
	else
		FurySwipes.AcceptInvite()
		FurySwipes.Print("Waiting for an invite from " .. (FurySwipes.LeaderName() or "the leader") .. ". Press 0 on the leader to send them.")
	end
end

function FurySwipes.LeaveGroup()
	if C_PartyInfo and C_PartyInfo.LeaveParty then
		C_PartyInfo.LeaveParty()
	elseif LeaveParty then
		LeaveParty()
	end
end

function FurySwipes.ConvertToRaid()
	if not UnitIsGroupLeader or not UnitIsGroupLeader("player") then
		FurySwipes.Print("You need to be the group leader to convert to a raid.")
		return
	end
	if C_PartyInfo and C_PartyInfo.ConvertToRaid then
		C_PartyInfo.ConvertToRaid()
	end
end

function FurySwipes.ApplyBlizzardRole(role)
	if not UnitSetRole then return end
	local map = {
		tank = "TANK",
		healer = "HEALER",
		melee = "DAMAGER",
		caster = "DAMAGER",
		hunter = "DAMAGER",
	}
	local token = map[role]
	if not token then return end
	-- Best-effort. Some builds only accept this inside a group, and some ignore it.
	-- Heal priority uses TANK from UnitGroupRolesAssigned when the client has it.
	pcall(UnitSetRole, "player", token)
end

function FurySwipes.UnitToken(name)
	if not name then return nil end
	if same(name, me()) then return "player" end
	if IsInRaid and IsInRaid() then
		for i = 1, GetNumGroupMembers() do
			if same(FurySwipes.UnitPlainName("raid" .. i), name) then return "raid" .. i end
		end
		return nil
	end
	for i = 1, 4 do
		if same(FurySwipes.UnitPlainName("party" .. i), name) then return "party" .. i end
	end
end

function FurySwipes.TankToken()
	local members = FurySwipes.Members()
	for i = 1, #members do
		if members[i].role == "tank" then
			return FurySwipes.UnitToken(members[i].name)
		end
	end
end

-- Unit id of the lowest health living member, nil when every living member is
-- full, or "secret" when this client will not let Lua compare health.
-- The group leader is not preferred. On a follower, party1 is that leader.
function FurySwipes.HurtTarget()
	local function pct(unit)
		if not UnitExists(unit) then return nil end
		if UnitIsConnected and not UnitIsConnected(unit) then return nil end
		if UnitIsDeadOrGhost and UnitIsDeadOrGhost(unit) then return nil end
		local hp, maxh = UnitHealth(unit), UnitHealthMax(unit)
		if issecretvalue and (issecretvalue(hp) or issecretvalue(maxh)) then
			return nil, true
		end
		if type(hp) ~= "number" or type(maxh) ~= "number" or maxh <= 0 or hp <= 0 then
			return nil
		end
		return hp / maxh
	end
	local units = { "player" }
	if IsInRaid and IsInRaid() then
		for i = 1, GetNumGroupMembers() do units[#units + 1] = "raid" .. i end
	else
		for i = 1, 4 do units[#units + 1] = "party" .. i end
	end
	local best, bestPct
	for i = 1, #units do
		local unit = units[i]
		if unit == "player" or not (UnitIsUnit and UnitIsUnit(unit, "player")) then
			local p, hidden = pct(unit)
			if hidden then return "secret" end
			if p and (bestPct == nil or p < bestPct) then
				best, bestPct = unit, p
			end
		end
	end
	if bestPct ~= nil and bestPct < 1 then return best end
end

function FurySwipes.FollowMacro(andAssist)
	local leader = FurySwipes.SafeName(FurySwipes.LeaderName())
	if not leader or FurySwipes.IsLeader() then
		return "#showtooltip\n/stopfollow"
	end
	if andAssist then
		return "#showtooltip\n/assist " .. leader .. "\n/follow " .. leader
	end
	return "#showtooltip\n/follow " .. leader
end
