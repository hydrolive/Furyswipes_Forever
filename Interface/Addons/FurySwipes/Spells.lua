-- Spell ids are tried in order. Unknown ids are skipped, so a classic spell and a
-- later spell can share a list. Names passed to /cast come from C_Spell so they
-- match the client locale. Ground-targeted AoE is avoided: broadcast keys cannot
-- aim a reticle on every window.

FurySwipes = FurySwipes or {}

FurySwipes.ClassRole = {
	WARRIOR = "tank",
	ROGUE = "melee",
	HUNTER = "hunter",
	MAGE = "caster",
	WARLOCK = "caster",
	PRIEST = "healer",
	PALADIN = "healer",
	SHAMAN = "healer",
	DRUID = "healer",
	DEATHKNIGHT = "melee",
	MONK = "melee",
	DEMONHUNTER = "melee",
	EVOKER = "healer",
}

local HEAL = {
	PRIEST = { 2061, 2054, 2050, 139 },
	DRUID = { 5185, 8936, 774 },
	SHAMAN = { 8004, 331, 1064 },
	PALADIN = { 19750, 82326, 635 },
	MONK = { 116670, 115175 },
	EVOKER = { 355913, 361469 },
}

local GROUP_HEAL = {
	PRIEST = { 596, 34861 },
	DRUID = { 48438 },
	SHAMAN = { 1064 },
	PALADIN = { 82327, 19750 },
	MONK = { 115310 },
	EVOKER = { 367226 },
}

-- Cast on the player, not on the injured unit (nova, consecration, tranquility).
local SELF_AOE_HEAL = {
	PRIEST = { 15237 },
	DRUID = { 740 },
	PALADIN = { 85222, 26573 },
	MONK = { 115098 },
}

local DAMAGE = {
	PRIEST = { 585, 589 },
	DRUID = { 5176, 8921 },
	SHAMAN = { 403, 188389, 8050 },
	PALADIN = { 20271, 35395 },
	MAGE = { 133, 116 },
	WARLOCK = { 686, 172 },
	HUNTER = { 1978, 3044, 75 },
	WARRIOR = { 78, 772 },
	ROGUE = { 1752 },
	DEATHKNIGHT = { 49998, 45477 },
	MONK = { 100780, 100784 },
	DEMONHUNTER = { 162794, 162243 },
	EVOKER = { 361469, 357208 },
}

local TANK = {
	WARRIOR = { 78, 23922, 6572 },
	DRUID = { 6807, 33917 },
	PALADIN = { 53595, 20271, 35395 },
	DEATHKNIGHT = { 49998, 45477 },
	MONK = { 100780, 121253 },
	DEMONHUNTER = { 203782, 162794 },
}

local MELEE = {
	WARRIOR = { 78, 772, 845 },
	ROGUE = { 1752, 2098 },
	DRUID = { 5221, 1082, 6807 },
	PALADIN = { 20271, 35395, 53385 },
	DEATHKNIGHT = { 49998, 45477 },
	MONK = { 100780, 100784 },
	DEMONHUNTER = { 162794, 162243 },
	SHAMAN = { 17364, 73899, 403 },
	HUNTER = { 3044, 1978, 75 },
}

local CLEAVE = {
	WARRIOR = { 845, 6343 },
	ROGUE = { 51723, 13877, 1752 },
	DRUID = { 106785, 779, 62078 },
	PALADIN = { 53385, 26573, 20271 },
	DEATHKNIGHT = { 50842, 43265 },
	MONK = { 101546, 107270 },
	DEMONHUNTER = { 188499, 185123 },
	HUNTER = { 2643, 3044 },
	MAGE = { 1449, 122 },
	WARLOCK = { 27243, 1949 },
	SHAMAN = { 421, 188443 },
	PRIEST = { 8092, 589 },
	EVOKER = { 357208 },
}

local AOE = {
	MAGE = { 1449, 122 },
	WARLOCK = { 1949, 27243 },
	HUNTER = { 2643 },
	WARRIOR = { 1680, 6343 },
	ROGUE = { 51723 },
	DRUID = { 106785, 779 },
	PALADIN = { 26573, 53385 },
	SHAMAN = { 421 },
	PRIEST = { 15237, 8092 },
	DEATHKNIGHT = { 43265, 50842 },
	MONK = { 101546 },
	DEMONHUNTER = { 188499 },
	EVOKER = { 357208 },
}

local TAUNT = {
	WARRIOR = { 355 },
	DRUID = { 6795 },
	PALADIN = { 62124, 31789 },
	DEATHKNIGHT = { 56222 },
	MONK = { 115546 },
	DEMONHUNTER = { 185245 },
}

local DISPEL = {
	PRIEST = { 527, 528 },
	PALADIN = { 4987, 1152 },
	DRUID = { 88423, 2782 },
	MAGE = { 475 },
	SHAMAN = { 51886, 2870 },
	MONK = { 115450 },
	EVOKER = { 360823, 365585 },
}

local INTERRUPT = {
	ROGUE = { 1766 },
	WARRIOR = { 6552 },
	MAGE = { 2139 },
	SHAMAN = { 57994 },
	PRIEST = { 15487 },
	PALADIN = { 96231 },
	DRUID = { 106839, 5211 },
	DEATHKNIGHT = { 47528 },
	MONK = { 116705 },
	DEMONHUNTER = { 183752 },
	HUNTER = { 147362, 19386 },
	WARLOCK = { 19647 },
	EVOKER = { 351338 },
}

-- Self buffs, highest rank first. On this client Arcane Intellect is
-- single-target, so the macro aims it at each party member. Arcane Brilliance
-- is the one-cast group version. Armor is only the best one the mage knows.
local BUFF = {
	MAGE = { 23028, 10157, 10156, 1461, 1460, 1459, 22783, 22782, 6117, 10220, 10219, 7320, 7302, 7301, 7300, 168 },
	PRIEST = { 1243, 17 },
	DRUID = { 1126 },
	SHAMAN = { 324 },
	PALADIN = { 465, 19740 },
	WARRIOR = { 6673 },
	WARLOCK = { 28176, 706, 687 },
	HUNTER = { 13165 },
	MONK = { 115921 },
	DEATHKNIGHT = { 57330 },
}

local PET = {
	WARLOCK = { 688 },
	HUNTER = { 883 },
}

local function known(spellId)
	local bank = Enum and Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Player
	if C_SpellBook then
		if bank and C_SpellBook.IsSpellInSpellBook then
			local ok, yes = pcall(C_SpellBook.IsSpellInSpellBook, spellId, bank, false)
			if ok and yes then return true end
		end
		if C_SpellBook.IsSpellKnown then
			if bank then
				local ok, yes = pcall(C_SpellBook.IsSpellKnown, spellId, bank)
				if ok and yes then return true end
			end
			local ok, yes = pcall(C_SpellBook.IsSpellKnown, spellId)
			if ok and yes then return true end
		end
	end
	if IsPlayerSpell then
		local ok, yes = pcall(IsPlayerSpell, spellId)
		if ok and yes then return true end
	end
	if IsSpellKnown then
		local ok, yes = pcall(IsSpellKnown, spellId)
		if ok and yes then return true end
	end
	return false
end

local function spellName(spellId)
	if C_Spell and C_Spell.GetSpellName then
		local name = C_Spell.GetSpellName(spellId)
		if name and name ~= "" then return name end
	end
	if C_Spell and C_Spell.GetSpellInfo then
		local info = C_Spell.GetSpellInfo(spellId)
		if info and info.name and info.name ~= "" then return info.name end
	end
	if GetSpellInfo then
		local name = GetSpellInfo(spellId)
		if name and name ~= "" then return name end
	end
end

local function request(spellId)
	if C_Spell and C_Spell.RequestLoadSpellData then
		C_Spell.RequestLoadSpellData(spellId)
	end
end

function FurySwipes.CleanSpellName(name)
	if type(name) ~= "string" or name == "" then return nil end
	return (name:gsub("%s*%([Rr]ank%s+%d+%)", ""):gsub("%s+$", ""))
end

function FurySwipes.PickSpell(ids)
	if not ids then return nil end
	for i = 1, #ids do
		local id = ids[i]
		request(id)
		if known(id) then
			local name = FurySwipes.CleanSpellName(spellName(id))
			if name then return name end
		end
	end
end

local function playerSpellBook()
	local names = {}
	local ids = {}
	local function add(name)
		name = FurySwipes.CleanSpellName(name)
		if name then names[name] = true end
	end
	local function addId(spellId)
		if type(spellId) == "number" then ids[spellId] = true end
	end
	pcall(function()
		if not (C_SpellBook and C_SpellBook.GetNumSpellBookSkillLines and C_SpellBook.GetSpellBookSkillLineInfo and C_SpellBook.GetSpellBookItemInfo) then
			return
		end
		local bank = Enum and Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Player
		if not bank then return end
		local future = Enum.SpellBookItemType and Enum.SpellBookItemType.FutureSpell
		local spellType = Enum.SpellBookItemType and Enum.SpellBookItemType.Spell
		local lines = C_SpellBook.GetNumSpellBookSkillLines() or 0
		for line = 1, lines do
			local info = C_SpellBook.GetSpellBookSkillLineInfo(line)
			if type(info) == "table" and not info.shouldHide and not info.offSpecID then
				local off = info.itemIndexOffset or 0
				local count = info.numSpellBookItems or 0
				for slot = off + 1, off + count do
					local item = C_SpellBook.GetSpellBookItemInfo(slot, bank)
					if type(item) == "table" and not item.isPassive and not item.isOffSpec then
						local unlearned = future and item.itemType == future
						local castable = (not spellType) or item.itemType == nil or item.itemType == spellType
						if not unlearned and castable then
							add(item.name)
							if C_SpellBook.GetSpellBookItemName then
								local ok, bookName = pcall(C_SpellBook.GetSpellBookItemName, slot, bank)
								if ok then add(bookName) end
							end
							-- actionID is the base spell. spellID can be an override.
							addId(item.actionID)
							addId(item.spellID)
						end
					end
				end
			end
		end
	end)
	return names, ids
end

local function pushBuff(spells, seen, name, kind, aura)
	name = FurySwipes.CleanSpellName(name)
	if not name or seen[name] then return end
	seen[name] = true
	spells[#spells + 1] = { spell = name, group = kind == "group", aura = aura or name }
end

local INTELLECT_RANKS = { 10157, 10156, 1461, 1460, 1459 }

local function idListed(ids, spellId)
	return ids[spellId] or known(spellId)
end

function FurySwipes.KnownBuffs(class)
	local spells = {}
	local seen = {}
	local pet = FurySwipes.PickSpell(PET[class])
	if pet then spells[#spells + 1] = { spell = pet, nopet = true } end
	local book, bookIds = playerSpellBook()
	local haveBook = next(book) ~= nil
	if class == "MAGE" then
		-- Key 1 must try the cast even when the name scan misses it. On this
		-- client the saved buff macro was only Frost Armor, which is free at
		-- level 1. Arcane Intellect rank 1 is trained and costs 10 copper.
		local brilliance = book["Arcane Brilliance"] or idListed(bookIds, 23028)
		if brilliance then
			spells[#spells + 1] = {
				spell = "Arcane Brilliance",
				aura = "Arcane Intellect",
				intellect = true,
				trained = true,
			}
			seen["Arcane Brilliance"] = true
		else
			local trained = book["Arcane Intellect"]
			if not trained then
				for i = 1, #INTELLECT_RANKS do
					if idListed(bookIds, INTELLECT_RANKS[i]) then
						trained = true
						break
					end
				end
			end
			spells[#spells + 1] = {
				spell = "Arcane Intellect",
				group = true,
				aura = "Arcane Intellect",
				intellect = true,
				trained = trained or not haveBook,
			}
			seen["Arcane Intellect"] = true
		end
		if book["Mage Armor"] then
			pushBuff(spells, seen, "Mage Armor", "self")
		elseif book["Ice Armor"] then
			pushBuff(spells, seen, "Ice Armor", "self")
		elseif book["Frost Armor"] or not haveBook then
			pushBuff(spells, seen, "Frost Armor", "self")
		end
		return spells
	end
	local ids = BUFF[class]
	local haveArmor = false
	local haveIntellect = false
	if ids then
		for i = 1, #ids do
			request(ids[i])
			local name = FurySwipes.CleanSpellName(spellName(ids[i]))
			local inBook = name and book[name]
			if name and (known(ids[i]) or inBook) then
				if name == "Arcane Brilliance" then
					pushBuff(spells, seen, name, "self", "Arcane Intellect")
					haveIntellect = true
				elseif name == "Arcane Intellect" and not haveIntellect then
					pushBuff(spells, seen, name, "group", "Arcane Intellect")
					haveIntellect = true
				elseif name == "Mage Armor" or name == "Ice Armor" or name == "Frost Armor" then
					if not haveArmor then
						pushBuff(spells, seen, name, "self")
						haveArmor = true
					end
				else
					pushBuff(spells, seen, name, "self")
				end
			end
		end
	end
	return spells
end

function FurySwipes.SpellsFor(class, role)
	local single
	if role == "healer" then
		single = FurySwipes.PickSpell(HEAL[class]) or FurySwipes.PickSpell(DAMAGE[class])
	elseif role == "tank" then
		single = FurySwipes.PickSpell(TANK[class]) or FurySwipes.PickSpell(MELEE[class]) or FurySwipes.PickSpell(DAMAGE[class])
	elseif role == "melee" then
		single = FurySwipes.PickSpell(MELEE[class]) or FurySwipes.PickSpell(DAMAGE[class])
	elseif role == "hunter" then
		single = FurySwipes.PickSpell(DAMAGE.HUNTER)
	else
		single = FurySwipes.PickSpell(DAMAGE[class]) or FurySwipes.PickSpell(MELEE[class])
	end

	local cleave = FurySwipes.PickSpell(CLEAVE[class]) or single
	local aoe = FurySwipes.PickSpell(AOE[class]) or cleave
	local heal = FurySwipes.PickSpell(HEAL[class])
	local groupHeal = FurySwipes.PickSpell(GROUP_HEAL[class]) or heal
	local selfAoe = FurySwipes.PickSpell(SELF_AOE_HEAL[class])
	local damage = FurySwipes.PickSpell(DAMAGE[class]) or single

	local utility, utilityKind
	if role == "tank" then
		utility = FurySwipes.PickSpell(TAUNT[class])
		utilityKind = utility and "taunt"
	elseif role == "healer" then
		utility = FurySwipes.PickSpell(DISPEL[class])
		utilityKind = utility and "dispel"
	else
		utility = FurySwipes.PickSpell(INTERRUPT[class])
		utilityKind = utility and "interrupt"
	end

	return {
		single = single,
		cleave = cleave,
		aoe = aoe,
		heal = heal,
		groupHeal = groupHeal,
		selfAoe = selfAoe,
		damage = damage,
		utility = utility,
		utilityKind = utilityKind,
		hunterSting = role == "hunter" and FurySwipes.PickSpell({ 1978 }) or nil,
		autoShot = role == "hunter" and FurySwipes.PickSpell({ 75 }) or nil,
	}
end
