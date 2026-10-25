# Features

Status values: `done` (confirmed in game), `unverified` (in the addon, not loaded on a character yet), `partial` (works with a known limit), `unused` (still in the repo, not part of the system), `next` (not started).

Nothing below is `done` yet. The addon has not been loaded on a logged-in Forever character.

## Multiboxing

| Feature | Status | Notes |
| --- | --- | --- |
| One addon, `FurySwipes`, Interface 16001 | unverified | `Interface/AddOns/FurySwipes`. No library dependencies. |
| OpenMultiBoxing broadcasts the keys | unverified | The addon does not send keys across windows. Setup is in `README.md`. |
| HotkeyNet scripts | unused | `5mmb_vanilla.tcl`, `5mmb_vanilla_fast.tcl`, `hkn_settings.txt`, `twapi/`, `toonlist.txt`. Nothing in the addon reads them. |
| Role from `Roster.lua` | unverified | `tank`, `healer`, `melee`, `caster`, `hunter`. |
| Per-character role override | unverified | `/fs role` saves `FurySwipesChar.role`. `/fs role clear` uses the roster again. |
| Class default when the name is missing | unverified | Paladin, shaman, and druid default to healer. |

## Keys

OpenMultiBoxing delivers the same key to every window. The secure button in that window does the role's action.

| Key | Feature | Status |
| --- | --- | --- |
| `/fs init` and Ctrl-I | Bind the keys and rebuild macros | unverified |
| 1 | Buffs. A mage casts Arcane Intellect on each unbuffed party member, then armor | unverified |
| 2 | Attack, or heal when someone is under the roster thresholds | unverified |
| 3 | Cleave, or a group heal on a healer | unverified |
| 4 | Assist the leader | unverified |
| 5 | Area attack, or an area heal on a healer | unverified |
| 0 | Leader invites the roster. Other windows accept | unverified |
| Shift-1 | Taunt, dispel, or interrupt | partial |
| Alt-1 | Follow the leader | unverified |
| Alt-4 | Assist, then follow | unverified |
| `/fs unbind` | Remove only bindings that are still ours | unverified |

Key 2 attacks when everyone is above the heal thresholds. If the secure health check cannot run, it still attacks rather than casting a heal at full health. Keys 3 and 5 still heal on purpose.

Shift-1 dispel is `partial` because mouseover is not broadcast. Clone windows dispel by party order.

## Group

| Feature | Status | Notes |
| --- | --- | --- |
| Invite by name, staggered | unverified | Leader only. Spaced names use `GetUnitName`, because `UnitName` drops everything after the first space. A second press of 0 cancels the previous queue. |
| Auto-accept roster invites | unverified | `autoAccept` in `Roster.lua`. |
| Convert to raid | unverified | Only when the roster is larger than 5 and the group is full. `/fs raid` converts on demand. |
| Free-for-all loot | unverified | Best-effort `C_PartyInfo.SetLootMethod`. |
| Follow and assist slash commands | partial | `/fs follow` and `/fs assist` work only after the leader is in the group. The keybinds do not have that limit. |

## Still to build

| Feature | Status | Notes |
| --- | --- | --- |
| In-game verification pass | next | See the list in `docs/PROGRESS.md`. |
| Real character names in `Roster.lua` | next | The file still has the sample names. |
