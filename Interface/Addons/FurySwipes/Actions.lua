-- Secure buttons, one per broadcast key.
-- OpenMultiBoxing posts the key into every window. The binding clicks the button
-- in that window. Forever does not run /click from a macro, so the binding has
-- to click the button directly (same finding as the MAMA addon on this client).
--
-- Heal targeting runs in a secure PreClick snippet so it can still change the
-- target during combat. The snippet uses health and UnitGroupRolesAssigned only.
-- It does not read character names: on current clients those values are secret
-- in combat and cannot be concatenated.

FurySwipes = FurySwipes or {}

FurySwipes.KEYS = {
	{ key = "1", button = "FurySwipesBuff", what = "Buff / setup" },
	{ key = "2", button = "FurySwipesPrimary", what = "Single target (heal if needed, otherwise attack)" },
	{ key = "3", button = "FurySwipesCleave", what = "Cleave or group heal" },
	{ key = "4", button = "FurySwipesAssist", what = "Assist the leader" },
	{ key = "5", button = "FurySwipesAoe", what = "Area attack or area heal" },
	{ key = "0", button = "FurySwipesInvite", what = "Leader invites; other windows accept" },
	{ key = "SHIFT-1", button = "FurySwipesUtil", what = "Taunt, dispel, or interrupt" },
	{ key = "ALT-1", button = "FurySwipesFollow", what = "Follow the leader" },
	{ key = "ALT-4", button = "FurySwipesStick", what = "Follow and assist the leader" },
	{ key = "CTRL-I", button = "FurySwipesInit", what = "Run setup again on this character" },
}

-- Compiled once. No function definitions and no return: the secure environment
-- rejects both, and a return from PreClick can swallow the click.
-- Picks the lowest health group member. No tank or party1 preference:
-- party1 on a follower is the group leader, and a party-order /cast hits them first.
FurySwipes.HEAL_SNIPPET = [[
local heal = self:GetAttribute("healspell")
if self:GetAttribute("selfcast") then
  local hm = self:GetAttribute("healmacro")
  if hm and hm ~= "" then
    self:SetAttribute("type", "macro")
    self:SetAttribute("macrotext", hm)
  end
elseif heal and heal ~= "" then
  local best, bestPct
  local u, hp, maxh, pct
  for i = 0, 44 do
    if i == 0 then
      u = "player"
    elseif i < 5 then
      u = "party" .. i
    else
      u = "raid" .. (i - 4)
    end
    if UnitExists(u) then
      if UnitIsConnected(u) then
        if not UnitIsDeadOrGhost(u) then
          hp = UnitHealth(u)
          maxh = UnitHealthMax(u)
          if hp ~= nil then
            if maxh ~= nil then
              if maxh > 0 then
                if hp > 0 then
                  pct = hp / maxh
                  if bestPct == nil then
                    best = u
                    bestPct = pct
                  elseif pct < bestPct then
                    best = u
                    bestPct = pct
                  end
                end
              end
            end
          end
        end
      end
    end
  end
  if best then
    if self:GetAttribute("alwaysheal") then
      self:SetAttribute("type", "spell")
      self:SetAttribute("unit", best)
      self:SetAttribute("spell", heal)
    elseif bestPct ~= nil then
      if bestPct < 1 then
        self:SetAttribute("type", "spell")
        self:SetAttribute("unit", best)
        self:SetAttribute("spell", heal)
      else
        self:SetAttribute("type", "macro")
        self:SetAttribute("macrotext", self:GetAttribute("dpsmacro") or "")
      end
    end
  else
    self:SetAttribute("type", "macro")
    self:SetAttribute("macrotext", self:GetAttribute("dpsmacro") or "")
  end
end
]]

local MACRO_ICON = 134400
local wrapWarned = false

local function clickAction(buttonName)
	return "CLICK " .. buttonName .. ":LeftButton"
end

local function newSecure(name)
	local button = CreateFrame("Button", name, UIParent, "SecureActionButtonTemplate")
	button:SetAttribute("type", "macro")
	button:SetAttribute("macrotext", "")
	button:SetAttribute("useOnKeyDown", false)
	button:RegisterForClicks("AnyUp", "AnyDown")
	button:Hide()
	return button
end

local function newPlain(name, handler)
	local button = CreateFrame("Button", name, UIParent)
	button:RegisterForClicks("AnyUp")
	button:SetScript("OnClick", handler)
	button:Hide()
	return button
end

local function ensureWrap(button)
	if button._wrapTried then return button._wrapOK end
	button._wrapTried = true
	local ok, err
	-- Forever addons call header:WrapScript(frame, script, body). Wrapping the
	-- button with itself is button:WrapScript(button, "PreClick", body).
	if button.WrapScript then
		ok, err = pcall(button.WrapScript, button, button, "PreClick", FurySwipes.HEAL_SNIPPET)
	elseif SecureHandlerWrapScript then
		ok, err = pcall(SecureHandlerWrapScript, button, "PreClick", button, FurySwipes.HEAL_SNIPPET)
	else
		ok, err = false, "WrapScript is missing on this client"
	end
	button._wrapOK = ok and true or false
	if not ok and not wrapWarned then
		wrapWarned = true
		FurySwipes.Print("Smart heal targeting failed (" .. tostring(err) .. "). Healers will use party order instead.")
	end
	return button._wrapOK
end

function FurySwipes.AttackMacro(spell, opts)
	opts = opts or {}
	local lines = { "#showtooltip" .. ((spell and spell ~= "") and (" " .. spell) or "") }
	local leader = FurySwipes.SafeName(FurySwipes.LeaderName())
	if leader and not FurySwipes.IsLeader() then
		lines[#lines + 1] = "/assist " .. leader
		-- Stop on a friendly assist. Do not test noexists/noharm: self-cast AoE
		-- such as Arcane Explosion still has to run when nothing is targeted.
		lines[#lines + 1] = "/stopmacro [help]"
	end
	if opts.pet then lines[#lines + 1] = "/petattack" end
	if opts.startattack then lines[#lines + 1] = "/startattack" end
	if opts.sting then
		lines[#lines + 1] = "/cast [harm,nodebuff:" .. opts.sting .. "] " .. opts.sting
	end
	if spell and spell ~= "" then
		lines[#lines + 1] = "/cast " .. (opts.bang and "!" or "") .. spell
	end
	return table.concat(lines, "\n")
end

function FurySwipes.BuffMacro(entries)
	local tip = entries[1] and (entries[1].aura or entries[1].spell)
	local lines = { "#showtooltip" .. (tip and (" " .. tip) or "") }
	for i = 1, #entries do
		local entry = entries[i]
		local aura = entry.aura or entry.spell
		if entry.nopet then
			lines[#lines + 1] = "/cast [nopet] " .. entry.spell
		elseif entry.group then
			-- One person per press. SyncBuffButton rewrites this onto the next
			-- group member. No nobuff test: a failed aura check was skipping the cast.
			lines[#lines + 1] = "/cast [@player] " .. entry.spell
		else
			-- @player so an enemy target does not eat a self buff.
			lines[#lines + 1] = "/cast [@player,nobuff:" .. aura .. "] " .. entry.spell
		end
	end
	if #lines == 1 then
		lines[1] = "#showtooltip"
		lines[#lines + 1] = "# FurySwipes: no self buff for this class"
	end
	return table.concat(lines, "\n")
end

local function utilityMacro(spell, kind)
	if not spell then return "#showtooltip\n# FurySwipes: no taunt, dispel, or interrupt for this class" end
	if kind == "dispel" then
		return "#showtooltip " .. spell .. "\n/cast [@mouseover,help,nodead][@party1,help,nodead][@party2,help,nodead][@party3,help,nodead][@party4,help,nodead][@player] " .. spell
	end
	return FurySwipes.AttackMacro(spell, { startattack = false })
end

local function attackOptions(role, class, spells)
	local opts = {
		startattack = role == "tank" or role == "melee" or role == "hunter",
		pet = role == "hunter" or class == "WARLOCK",
	}
	if role == "hunter" then
		opts.sting = spells.hunterSting
		opts.bang = true
	end
	return opts
end

local function setMacroButton(button, text)
	if InCombatLockdown and InCombatLockdown() then return false end
	button:SetAttribute("type", "macro")
	button:SetAttribute("macrotext", text or "")
	return true
end

local function setSmartButton(button, role, healSpell, alwaysHeal, selfCast, dpsMacro, tankAt, partyAt, selfAt)
	if InCombatLockdown and InCombatLockdown() then return false end
	button:SetAttribute("role", role or "")
	button:SetAttribute("healspell", healSpell or "")
	button:SetAttribute("alwaysheal", alwaysHeal and true or false)
	button:SetAttribute("selfcast", selfCast and true or false)
	button:SetAttribute("dpsmacro", dpsMacro or "")
	button:SetAttribute("tankat", tankAt)
	button:SetAttribute("partyat", partyAt)
	button:SetAttribute("selfat", selfAt)
	-- Single-target heals go through the snippet, which picks the lowest health
	-- member. A party-order macro always hits party1, and that is the leader.
	local healMacro = ""
	if role == "healer" and healSpell and selfCast then
		healMacro = "#showtooltip " .. healSpell .. "\n/cast " .. healSpell
	end
	button:SetAttribute("healmacro", healMacro)
	button:SetAttribute("tankunit", (FurySwipes.TankToken and FurySwipes.TankToken()) or "")
	if role == "healer" and healSpell and not selfCast and ensureWrap(button) then
		button:SetAttribute("type", "spell")
		button:SetAttribute("spell", healSpell)
		button:SetAttribute("unit", "player")
		if not alwaysHeal then
			button:SetAttribute("type", "macro")
			button:SetAttribute("macrotext", dpsMacro or "")
		end
		return true
	end
	if healMacro ~= "" then return setMacroButton(button, healMacro) end
	if role == "healer" and healSpell and not selfCast then
		button:SetAttribute("type", "spell")
		button:SetAttribute("spell", healSpell)
		button:SetAttribute("unit", "player")
		return true
	end
	return setMacroButton(button, dpsMacro or "")
end

local function auraPresent(unit, name)
	if not UnitExists(unit) then return false end
	if UnitIsConnected and not UnitIsConnected(unit) then return true end
	if C_UnitAuras and C_UnitAuras.GetAuraDataBySpellName then
		local ok, aura = pcall(C_UnitAuras.GetAuraDataBySpellName, unit, name, "HELPFUL")
		if not ok then return nil end
		if aura and issecretvalue and issecretvalue(aura) then return nil end
		return aura ~= nil
	end
	return nil
end

local function castMacro(unit, spell)
	return "#showtooltip " .. spell .. "\n/cast [@" .. unit .. "] " .. spell
end

local function partyUnits(walk)
	if not walk then return { "player" } end
	local units = { "player" }
	if IsInRaid and IsInRaid() then
		local count = GetNumGroupMembers and GetNumGroupMembers() or 0
		for i = 1, count do
			local unit = "raid" .. i
			if UnitExists(unit) and not UnitIsUnit(unit, "player") then
				units[#units + 1] = unit
			end
		end
	else
		for i = 1, 4 do
			local unit = "party" .. i
			if UnitExists(unit) then units[#units + 1] = unit end
		end
	end
	local live = {}
	for i = 1, #units do
		local unit = units[i]
		local dead = UnitIsDeadOrGhost and UnitIsDeadOrGhost(unit)
		local offline = UnitIsConnected and not UnitIsConnected(unit)
		if not dead and not offline then live[#live + 1] = unit end
	end
	if #live == 0 then live[1] = "player" end
	return live
end

function FurySwipes.WarnIfPartyBuffUntrained()
	local button = _G.FurySwipesBuff
	if not button or button:GetAttribute("partyknown") ~= "0" then return end
	local now = GetTime and GetTime() or 0
	if FurySwipes._partyWarnAt and (now - FurySwipes._partyWarnAt) < 3 then return end
	FurySwipes._partyWarnAt = now
	local msg = button:GetAttribute("partywarn")
	if type(msg) ~= "string" or msg == "" then
		local spell = button:GetAttribute("partybuff") or "That buff"
		msg = spell .. " is not trained. Buy it from a trainer, then press 1 again."
	end
	FurySwipes.Print(msg)
end

function FurySwipes.SyncBuffButton(advance)
	if InCombatLockdown and InCombatLockdown() then return end
	local button = _G.FurySwipesBuff
	if not button then return end
	local spell = button:GetAttribute("partybuff")
	if type(spell) ~= "string" or spell == "" then return end
	local aura = button:GetAttribute("partyaura")
	if type(aura) ~= "string" or aura == "" then aura = spell end
	local units = partyUnits(button:GetAttribute("partywalk") == "1")
	local index = tonumber(button:GetAttribute("buffindex")) or 1
	local allPresent = true
	local anyUnknown = false
	local firstMissing
	for i = 1, #units do
		local has = auraPresent(units[i], aura)
		if has == nil then
			anyUnknown = true
			allPresent = false
		elseif not has then
			allPresent = false
			if not firstMissing then firstMissing = i end
		end
	end
	local targetIndex
	if allPresent then
		local armor = button:GetAttribute("armorspell")
		if type(armor) == "string" and armor ~= "" and auraPresent("player", armor) ~= true then
			button:SetAttribute("type", "macro")
			button:SetAttribute("macrotext", castMacro("player", armor))
			return
		end
		targetIndex = 1
	elseif anyUnknown then
		if advance then index = index + 1 end
		if index < 1 or index > #units then index = 1 end
		targetIndex = index
	else
		targetIndex = firstMissing or 1
	end
	button:SetAttribute("buffindex", targetIndex)
	button:SetAttribute("type", "macro")
	button:SetAttribute("macrotext", castMacro(units[targetIndex], spell))
end

function FurySwipes.SyncPrimaryHeal()
	if InCombatLockdown and InCombatLockdown() then return end
	local ok, hurt = pcall(FurySwipes.HurtTarget)
	local function apply(button)
		if not button or button:GetAttribute("role") ~= "healer" then return end
		if button:GetAttribute("selfcast") then return end
		local heal = button:GetAttribute("healspell")
		if not heal or heal == "" then return end
		if not ok or hurt == "secret" then return end
		if hurt then
			button:SetAttribute("type", "spell")
			button:SetAttribute("spell", heal)
			button:SetAttribute("unit", hurt)
			return
		end
		if button:GetAttribute("alwaysheal") then
			button:SetAttribute("type", "spell")
			button:SetAttribute("spell", heal)
			button:SetAttribute("unit", "player")
			return
		end
		button:SetAttribute("type", "macro")
		button:SetAttribute("macrotext", button:GetAttribute("dpsmacro") or "")
	end
	apply(_G.FurySwipesPrimary)
	apply(_G.FurySwipesCleave)
	apply(_G.FurySwipesAoe)
end

local function macroSlots()
	local accountMax = (Constants and Constants.MacroConsts and Constants.MacroConsts.MAX_ACCOUNT_MACROS) or 120
	local charMax = (Constants and Constants.MacroConsts and Constants.MacroConsts.MAX_CHARACTER_MACROS) or 18
	return accountMax, charMax
end

local function findMacro(name)
	local accountMax, charMax = macroSlots()
	for i = accountMax + 1, accountMax + charMax do
		if GetMacroInfo(i) == name then return i end
	end
end

local macroFailed = {}

local function upsertMacro(name, body)
	if not CreateMacro or not body then return end
	local index = findMacro(name)
	if index then
		local _, _, current = GetMacroInfo(index)
		if current ~= body then EditMacro(index, nil, nil, body) end
		return
	end
	local ok, err = pcall(CreateMacro, name, MACRO_ICON, body, true)
	if not ok and not macroFailed[name] then
		macroFailed[name] = true
		FurySwipes.Print("Could not create macro " .. name .. " (" .. tostring(err) .. "). The key still works.")
	end
end

local buttons = {}

local function createButtons()
	if buttons.primary then return end
	buttons.buff = newSecure("FurySwipesBuff")
	buttons.buff:HookScript("PreClick", function()
		FurySwipes.WarnIfPartyBuffUntrained()
	end)
	buttons.buff:HookScript("PostClick", function()
		FurySwipes.SyncBuffButton(true)
	end)
	buttons.primary = newSecure("FurySwipesPrimary")
	buttons.cleave = newSecure("FurySwipesCleave")
	buttons.aoe = newSecure("FurySwipesAoe")
	buttons.assist = newSecure("FurySwipesAssist")
	buttons.follow = newSecure("FurySwipesFollow")
	buttons.stick = newSecure("FurySwipesStick")
	buttons.util = newSecure("FurySwipesUtil")
	buttons.invite = newPlain("FurySwipesInvite", function()
		FurySwipes.InviteOrAccept()
	end)
	buttons.init = newPlain("FurySwipesInit", function()
		FurySwipes.Init()
	end)
end

function FurySwipes.RefreshActions()
	createButtons()
	if InCombatLockdown and InCombatLockdown() then
		FurySwipes.pendingRefresh = true
		return
	end
	local _, class = UnitClass("player")
	local role = FurySwipes.Role()
	local spells = FurySwipes.SpellsFor(class, role)
	local tankAt, partyAt, selfAt = FurySwipes.HealFractions()
	local opts = attackOptions(role, class, spells)
	local singleMacro = FurySwipes.AttackMacro(role == "hunter" and (spells.autoShot or spells.single) or spells.single, opts)
	local cleaveOpts = attackOptions(role, class, spells)
	cleaveOpts.sting = nil
	cleaveOpts.bang = false
	local cleaveMacro = FurySwipes.AttackMacro(spells.cleave, cleaveOpts)
	local aoeMacro = FurySwipes.AttackMacro(spells.aoe, cleaveOpts)
	local healerDamage = FurySwipes.AttackMacro(spells.damage, { startattack = false })

	local buffs = FurySwipes.KnownBuffs(class)
	local armorSpell = ""
	local partySpell = ""
	local partyAura = ""
	local partyWalk = "0"
	local partyKnown = "1"
	local partyWarn = ""
	for i = 1, #buffs do
		local entry = buffs[i]
		if entry.party then
			partySpell = entry.spell or ""
			partyAura = entry.aura or entry.spell or ""
			partyWalk = entry.group and "1" or "0"
			partyKnown = entry.trained == false and "0" or "1"
			partyWarn = entry.warn or ""
		elseif not entry.nopet and not entry.group then
			armorSpell = entry.spell
		end
	end
	setMacroButton(buttons.buff, FurySwipes.BuffMacro(buffs))
	buttons.buff:SetAttribute("armorspell", armorSpell)
	buttons.buff:SetAttribute("partybuff", partySpell)
	buttons.buff:SetAttribute("partyaura", partyAura)
	buttons.buff:SetAttribute("partywalk", partyWalk)
	buttons.buff:SetAttribute("partyknown", partyKnown)
	buttons.buff:SetAttribute("partywarn", partyWarn)
	FurySwipes.SyncBuffButton()
	setMacroButton(buttons.assist, FurySwipes.AttackMacro(nil, { startattack = false }))
	setMacroButton(buttons.follow, FurySwipes.FollowMacro(false))
	setMacroButton(buttons.stick, FurySwipes.FollowMacro(true))
	setMacroButton(buttons.util, utilityMacro(spells.utility, spells.utilityKind))

	if role == "healer" then
		setSmartButton(buttons.primary, role, spells.heal, false, false, healerDamage, tankAt, partyAt, selfAt)
		setSmartButton(buttons.cleave, role, spells.groupHeal or spells.heal, true, false, healerDamage, tankAt, partyAt, selfAt)
		local selfAoe = spells.selfAoe
		if selfAoe then
			setSmartButton(buttons.aoe, role, selfAoe, true, true, aoeMacro, tankAt, partyAt, selfAt)
		else
			setSmartButton(buttons.aoe, role, spells.groupHeal or spells.heal, true, false, aoeMacro, tankAt, partyAt, selfAt)
		end
		FurySwipes.SyncPrimaryHeal()
	else
		setSmartButton(buttons.primary, role, nil, false, false, singleMacro, tankAt, partyAt, selfAt)
		setSmartButton(buttons.cleave, role, nil, false, false, cleaveMacro, tankAt, partyAt, selfAt)
		setSmartButton(buttons.aoe, role, nil, false, false, aoeMacro, tankAt, partyAt, selfAt)
	end

	local aoeName = spells.aoe
	if role == "healer" then aoeName = spells.selfAoe or spells.groupHeal or spells.heal end
	FurySwipes.current = {
		role = role,
		class = class,
		single = spells.single,
		heal = spells.heal,
		cleave = spells.cleave,
		aoe = aoeName,
		utility = spells.utility,
		utilityKind = spells.utilityKind,
	}

	upsertMacro("FS_Buff", buttons.buff:GetAttribute("macrotext"))
	upsertMacro("FS_Single", role == "healer" and buttons.primary:GetAttribute("dpsmacro") or singleMacro)
	upsertMacro("FS_Cleave", buttons.cleave:GetAttribute("macrotext"))
	upsertMacro("FS_AoE", buttons.aoe:GetAttribute("macrotext"))
	upsertMacro("FS_Assist", buttons.assist:GetAttribute("macrotext"))
	upsertMacro("FS_Follow", buttons.follow:GetAttribute("macrotext"))
	upsertMacro("FS_Stick", buttons.stick:GetAttribute("macrotext"))
	upsertMacro("FS_Util", buttons.util:GetAttribute("macrotext"))
end

function FurySwipes.ApplyBindings(force)
	createButtons()
	if InCombatLockdown and InCombatLockdown() then
		FurySwipes.Print("Leave combat before changing keybinds.")
		return
	end
	local changed = 0
	for i = 1, #FurySwipes.KEYS do
		local spec = FurySwipes.KEYS[i]
		local want = clickAction(spec.button)
		local current = GetBindingAction(spec.key) or ""
		if force or current == "" or current == want then
			SetBinding(spec.key, want)
			changed = changed + 1
		end
	end
	local set = (GetCurrentBindingSet and GetCurrentBindingSet()) or 1
	SaveBindings(set)
	return changed
end

function FurySwipes.ClearBindings()
	if InCombatLockdown and InCombatLockdown() then
		FurySwipes.Print("Leave combat before changing keybinds.")
		return
	end
	for i = 1, #FurySwipes.KEYS do
		local spec = FurySwipes.KEYS[i]
		local want = clickAction(spec.button)
		if (GetBindingAction(spec.key) or "") == want then
			SetBinding(spec.key)
		end
	end
	SaveBindings((GetCurrentBindingSet and GetCurrentBindingSet()) or 1)
end
