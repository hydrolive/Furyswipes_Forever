-- Events, slash commands, and the one-line status text.
-- Key broadcasts are OpenMultiBoxing's job. This addon never sends input
-- to another window.

FurySwipes = FurySwipes or {}

local ROLES = {
	tank = true,
	healer = true,
	melee = true,
	caster = true,
	hunter = true,
}

local PREFIX = "|cffd27b2dFurySwipes:|r "
local announced = false

function FurySwipes.Print(msg)
	print(PREFIX .. tostring(msg))
end

function FurySwipes.Role()
	local override = FurySwipesChar and FurySwipesChar.role
	if override and ROLES[override] then return override, "saved" end
	local rosterRole = FurySwipes.RosterRole(FurySwipes.UnitPlainName("player"))
	if rosterRole and ROLES[rosterRole] then return rosterRole, "roster" end
	if rosterRole and not ROLES[rosterRole] and not FurySwipes.roleWarned then
		FurySwipes.roleWarned = true
		FurySwipes.Print("Role \"" .. rosterRole .. "\" in Roster.lua is not valid. Use tank, healer, melee, caster, or hunter.")
	end
	local _, class = UnitClass("player")
	return (FurySwipes.ClassRole and FurySwipes.ClassRole[class]) or "melee", "class"
end

local function ensureDB()
	if type(FurySwipesDB) ~= "table" then FurySwipesDB = {} end
	if type(FurySwipesChar) ~= "table" then FurySwipesChar = {} end
end

function FurySwipes.Refresh()
	ensureDB()
	local role = FurySwipes.Role()
	FurySwipes.ApplyBlizzardRole(role)
	FurySwipes.RefreshActions()
	FurySwipes.UpdateStatus()
end

function FurySwipes.Init()
	ensureDB()
	if InCombatLockdown and InCombatLockdown() then
		FurySwipes.Print("Leave combat, then run /fs init again.")
		return
	end
	FurySwipesDB.autoBind = true
	FurySwipes.Refresh()
	FurySwipes.ApplyBindings(true)
	FurySwipes.PrintReady(true)
end

function FurySwipes.PrintReady(full)
	local role, source = FurySwipes.Role()
	local leader = FurySwipes.LeaderName() or "(none)"
	local who = FurySwipes.UnitPlainName("player") or "this character"
	FurySwipes.Print(who .. " is " .. role .. " (" .. source .. "). Leader is " .. leader .. ".")
	if not FurySwipesDB.autoBind then
		FurySwipes.Print("Run /fs init on this character to bind the multibox keys.")
	elseif full then
		FurySwipes.Print("Keys: 1 buff, 2 attack/heal, 3 cleave, 4 assist, 5 aoe, 0 invite, Shift-1 utility, Alt-1 follow, Alt-4 follow+assist.")
		FurySwipes.Print("Those keys replace the default action bar keys. /fs unbind gives them back. OpenMultiBoxing has to be broadcasting.")
	end
end

local statusText

function FurySwipes.UpdateStatus()
	if not statusText then return end
	if FurySwipesDB and FurySwipesDB.hideStatus then
		statusText:GetParent():Hide()
		return
	end
	statusText:GetParent():Show()
	local role, source = FurySwipes.Role()
	local leader = FurySwipes.LeaderName() or "none"
	local cur = FurySwipes.current or {}
	local spell = (role == "healer" and cur.heal) or cur.single or "?"
	statusText:SetText("FurySwipes  " .. role .. " (" .. source .. ")   lead " .. leader .. "   2: " .. spell)
end

local function toggleStatus()
	ensureDB()
	FurySwipesDB.hideStatus = not FurySwipesDB.hideStatus
	FurySwipes.UpdateStatus()
	FurySwipes.Print(FurySwipesDB.hideStatus and "Status line hidden." or "Status line shown.")
end

local function setRole(token)
	ensureDB()
	if token == "clear" then
		FurySwipesChar.role = nil
		FurySwipes.Print("Cleared the saved role. Using the roster or the class default.")
	elseif ROLES[token] then
		FurySwipesChar.role = token
		FurySwipes.Print("This character's role is now " .. token .. ". This is saved for this character only.")
	else
		FurySwipes.Print("Role must be tank, healer, melee, caster, hunter, or clear.")
		return
	end
	FurySwipes.Refresh()
end

local function tryFollow(andAssist)
	local leader = FurySwipes.LeaderName()
	if not leader or FurySwipes.IsLeader() then
		FurySwipes.Print("This character is the leader, so there is nobody to follow.")
		return
	end
	local token = FurySwipes.UnitToken(leader)
	if not token then
		FurySwipes.Print("Use Alt-" .. (andAssist and "4" or "1") .. ". " .. leader .. " is not in this group yet, and a slash command cannot press the secure key.")
		return
	end
	if andAssist and AssistUnit then AssistUnit(token) end
	if FollowUnit then FollowUnit(token) end
end

local function slash(msg)
	msg = (msg or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
	local cmd, rest = msg:match("^(%S+)%s*(.*)$")
	cmd = cmd or ""
	if cmd == "" or cmd == "help" then
		FurySwipes.Print("OpenMultiBoxing broadcasts keys. FurySwipes does not.")
		FurySwipes.Print("/fs init - bind keys and rebuild macros on this character.")
		FurySwipes.Print("/fs role <tank|healer|melee|caster|hunter|clear> - override Roster.lua for this character.")
		FurySwipes.Print("/fs invite, /fs follow, /fs assist, /fs leave, /fs raid, /fs who, /fs status, /fs unbind.")
		FurySwipes.Print("Edit Interface\\AddOns\\FurySwipes\\Roster.lua for the team, then /reload.")
		return
	end
	if cmd == "init" then
		FurySwipes.Init()
	elseif cmd == "role" then
		setRole(rest)
	elseif cmd == "invite" or cmd == "party" then
		FurySwipes.InviteOrAccept()
	elseif cmd == "follow" then
		tryFollow(false)
	elseif cmd == "assist" then
		local leader = FurySwipes.LeaderName()
		local token = leader and FurySwipes.UnitToken(leader)
		if token and AssistUnit and not FurySwipes.IsLeader() then
			AssistUnit(token)
		else
			FurySwipes.Print("Use key 4 to assist. A slash command can only assist a leader who is already in the group.")
		end
	elseif cmd == "leave" then
		FurySwipes.LeaveGroup()
	elseif cmd == "raid" then
		FurySwipes.ConvertToRaid()
	elseif cmd == "who" then
		FurySwipes.PrintReady(true)
		local cur = FurySwipes.current or {}
		FurySwipes.Print("Spells: single " .. tostring(cur.single) .. ", heal " .. tostring(cur.heal) .. ", cleave " .. tostring(cur.cleave) .. ", aoe " .. tostring(cur.aoe) .. ", utility " .. tostring(cur.utilityKind) .. " " .. tostring(cur.utility) .. ".")
	elseif cmd == "status" then
		toggleStatus()
	elseif cmd == "unbind" then
		ensureDB()
		FurySwipesDB.autoBind = false
		FurySwipes.ClearBindings()
		FurySwipes.Print("Removed FurySwipes keybinds. Action bar defaults return after you bind them again, or after /reload if the game restores them.")
	else
		FurySwipes.Print("Unknown command. /fs lists them.")
	end
end

SLASH_FURYSWIPES1 = "/fs"
SLASH_FURYSWIPES2 = "/furyswipes"
SlashCmdList.FURYSWIPES = slash

local frame = CreateFrame("Frame", "FurySwipesEventFrame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("PARTY_INVITE_REQUEST")
frame:RegisterEvent("SPELLS_CHANGED")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("UNIT_HEALTH")
frame:RegisterEvent("UNIT_MAXHEALTH")

frame:SetScript("OnEvent", function(_, event, arg1)
	if event == "ADDON_LOADED" then
		if arg1 ~= "FurySwipes" then return end
		ensureDB()
		return
	end
	if event == "PARTY_INVITE_REQUEST" then
		FurySwipes.OnPartyInvite(arg1)
		return
	end
	if event == "PLAYER_REGEN_ENABLED" then
		if FurySwipes.pendingRefresh then
			FurySwipes.pendingRefresh = nil
			FurySwipes.Refresh()
		else
			FurySwipes.SyncPrimaryHeal()
		end
		return
	end
	if event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" or event == "GROUP_ROSTER_UPDATE" then
		if not InCombatLockdown or not InCombatLockdown() then
			FurySwipes.SyncPrimaryHeal()
		end
		return
	end
	if event == "PLAYER_LOGIN" then
		ensureDB()
		local bar = CreateFrame("Frame", "FurySwipesStatus", UIParent)
		bar:SetSize(720, 18)
		bar:SetPoint("TOP", UIParent, "TOP", 0, -6)
		bar:SetFrameStrata("MEDIUM")
		bar:EnableMouse(false)
		statusText = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		statusText:SetAllPoints()
		FurySwipes.Refresh()
		if FurySwipesDB.autoBind then
			FurySwipes.ApplyBindings(true)
		end
		if not announced then
			announced = true
			FurySwipes.PrintReady(false)
			local name = FurySwipes.UnitPlainName("player")
			if name and not FurySwipes.OnRoster(name) then
				FurySwipes.Print(name .. " is not listed in Roster.lua. Role fell back to the class default.")
			end
		end
		if C_Timer and C_Timer.After then
			C_Timer.After(2, FurySwipes.Refresh)
		end
		return
	end
	-- PLAYER_ENTERING_WORLD and SPELLS_CHANGED: spellbook may not be ready at login.
	if not InCombatLockdown or not InCombatLockdown() then
		FurySwipes.Refresh()
	else
		FurySwipes.pendingRefresh = true
	end
end)
