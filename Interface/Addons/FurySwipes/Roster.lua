-- Shared team list. Every Forever window loads this file from the same AddOns folder,
-- so edit it once and /reload (or log in again) on each client.
--
-- Names are character names, not account names. No passwords go here.
-- Roles: tank, healer, melee, caster, hunter.
-- leader is the character you play on the main OpenMultiBoxing window.
-- The others assist and follow that name.
--
-- heal fractions are 0 to 1:
--   self  - a healer heals themselves first at or below this
--   tank  - a character whose group role is TANK is healed first at or below this
--   party - anyone at or below this is healed before the healer switches to damage

FurySwipesRoster = {
	leader = "Grim Reaper",
	autoAccept = true,
	heal = {
		tank = 0.50,
		party = 0.33,
		self = 0.30,
	},
	members = {
		{ name = "Grim Reaper", role = "tank" },
		{ name = "Glass Cannon", role = "caster" },
		{ name = "Free Range", role = "hunter" },
		{ name = "Bad Omen", role = "melee" },
		{ name = "Im Oom", role = "healer" },
	},
}
