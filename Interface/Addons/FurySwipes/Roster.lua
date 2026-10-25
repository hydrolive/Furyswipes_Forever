-- Shared team list. Every Forever window loads this file from the same AddOns folder,
-- so edit it once and /reload (or log in again) on each client.
--
-- Names are character names, not account names. No passwords go here.
-- Roles: tank, healer, melee, caster, hunter.
-- leader is the character you play on the main OpenMultiBoxing window.
-- The others assist and follow that name.
--
-- Key 2 heals the lowest health group member who is missing health.
-- It does not prefer the tank or the group leader.

FurySwipesRoster = {
	leader = "Grim Reaper",
	autoAccept = true,
	heal = {
		tank = 0.50,
		party = 1,
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
