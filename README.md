# FurySwipes for WoW Forever

FurySwipes is a multibox helper for the WoW Forever client (Interface 16001). One key does a different job on each character: a healer heals, a tank or DPS attacks. **OpenMultiBoxing** broadcasts that key to the other windows. The addon does not send keys itself.

This is for private and local servers. It is not a retail Blizzard setup.

HotkeyNet is not used. Do not install it for this version.

## What you need

- The WoW Forever client
- [OpenMultiBoxing](https://openmultiboxing.org/help.html) ([releases](https://github.com/OpenMultiBoxing/OpenMultiBoxing/releases))
- The `FurySwipes` addon

OpenMultiBoxing is a separate program. Close it when you are done. It is the piece that copies keypresses into each game window.

## Install the addon

The addon folder is `Interface\AddOns\FurySwipes`.

On this machine it is already copied to:

`D:\WoW\World of Warcraft\_forever_\Interface\AddOns\FurySwipes`

If you set up another client, copy that folder into that client's `Interface\AddOns`. Enable **FurySwipes** at the character screen. The addon has no extra libraries.

## Set the team

Edit `Interface\AddOns\FurySwipes\Roster.lua`. Every window reads that same file.

- `leader` is the character on the main OpenMultiBoxing window. The others assist and follow this name.
- `members` is each character and a role: `tank`, `healer`, `melee`, `caster`, or `hunter`.
- `heal` fractions are from 0 to 1. `self` is when a healer heals themselves first. `tank` is when a group-role tank is healed first. `party` is when anyone is hurt enough to heal. Above those, a healer casts a damage spell instead.

The sample roster matches the old `toonlist.txt` names. Change them to your characters. No account names or passwords belong in this file.

`/reload` after editing, on each logged-in window.

A single character can override the file with `/fs role healer` (or `tank`, `melee`, `caster`, `hunter`). `/fs role clear` uses the file again. That override is saved for that character only.

If your name is missing from the roster, the addon guesses from your class. Paladin, shaman, and druid guess healer. Set them in the roster when that guess is wrong.

## OpenMultiBoxing

1. Install OpenMultiBoxing from the release zip. Extract it to a normal folder, not Program Files.
2. Start the Forever clients, or start them from OpenMultiBoxing if you prefer.
3. Game menu, **Add game window title…**, and select the Forever windows. The shipped client is `Wow.exe`, so the title is often `World of Warcraft`. The dialog lists the titles it can see. Use a `*` wildcard only if the title changes.
4. Run the window layout wizard. Put the **leader** in the main window, the one you look at and target from.
5. Turn **key broadcasting** on with **Ctrl-Shift-R** (the default).
6. Leave the default exclusions **W A S D** so only the main window walks. Do not exclude `1`, `2`, `3`, `4`, `5`, or `0`. Do not remap those keys.
7. Leave mouse-click broadcasting off. Clicks are aimed at one window's UI and would miss on the others.
8. **Ctrl-Shift-E** skips specific windows if one of them should not receive keys. The overlay toggle is **Ctrl-Shift-O**.

OpenMultiBoxing's own hotkeys (Ctrl-F1, Ctrl-Shift-N, and the rest) are not game keys. They switch which window you are typing into. Full list: <https://openmultiboxing.org/help.html>.

## Startup

1. Edit `Roster.lua`.
2. Start OpenMultiBoxing and arrange the windows.
3. Log each character into Forever.
4. On **each** character, type `/fs init`. Bindings are saved per account, so each client needs this once. Broadcasting can be off while you do it. After that, **Ctrl-I** runs setup again, and a broadcast Ctrl-I hits every window.
5. Turn broadcasting on (**Ctrl-Shift-R**).
6. On the leader, press **0** to invite the roster by name. They have to be online. They do not have to stand next to you. Other windows accept invites from roster members automatically when `autoAccept` is true.
7. Press **Alt-4** so the others follow and assist the leader.
8. Target a mob on the leader and press **2**.

`/fs raid` converts the party to a raid when you are the leader and the roster is larger than 5. A full party of 5 is left as a party.

## Keys

`/fs init` binds these. They replace the default action bar keys for `1`–`5` and `0`.

| Key | What happens |
| --- | --- |
| 1 | Self buffs, one missing buff per press. Warlocks and hunters also summon a pet. |
| 2 | Main action. Damage roles assist the leader and cast. Healers heal if someone is under the roster thresholds, otherwise they cast a damage spell. |
| 3 | Cleave, or a group heal on a healer. |
| 4 | Assist the leader. |
| 5 | Area spell, or an area heal on a healer. |
| 0 | Leader invites the roster. Other windows accept. |
| Shift-1 | Tank taunts, healer dispels, everyone else interrupts. |
| Alt-1 | Follow the leader. |
| Alt-4 | Assist the leader, then follow. |
| Ctrl-I | Run `/fs init` again. |

Pressing an attack or heal key stops following, because a cast breaks `/follow`. Press **Alt-4** again to follow.

Healer dispel (Shift-1) tries your mouseover, then party members, then you. Mouseover is not broadcast, so on the clones it lands on party order.

Tank heal priority uses the Blizzard group role `TANK` when the client accepts it. `/fs init` tries to set your own role. If that role never sticks, healers heal the lowest health person instead of preferring the tank.

## Slash commands

| Command | Effect |
| --- | --- |
| `/fs` | Command list |
| `/fs init` | Bind keys and rebuild this character's macros |
| `/fs who` | Role, leader, and chosen spells |
| `/fs role tank` | Save a role for this character |
| `/fs role clear` | Use Roster.lua or the class default |
| `/fs invite` | Same as key 0 |
| `/fs follow` | Follow the leader if they are in the group |
| `/fs assist` | Assist the leader if they are in the group |
| `/fs leave` | Leave the group |
| `/fs raid` | Convert to a raid |
| `/fs status` | Hide or show the line at the top of the screen |
| `/fs unbind` | Remove the FurySwipes keys and stop reapplying them |

The secure keys (follow, assist, attack, heal) are reliable from the keybinds. The slash versions of follow and assist only work once that character is in your group.

Character macros named `FS_Buff`, `FS_Single`, `FS_Cleave`, `FS_AoE`, `FS_Assist`, `FS_Follow`, `FS_Stick`, and `FS_Util` are created so you can read them under Esc → Macros. The keys click secure buttons, not those macro slots. Dragging a macro to a bar is optional.

## What changed from the old 5-minute pack

The old pack was Vanilla 1.12. SuperMacro ran long `/script` rotations, and HotkeyNet injected the keys. Forever's addon API does not work that way, and `/script` inside a macro is not how this client casts spells.

Removed from this repo, because FurySwipes does not use them:

Bag_Sort, BeanCounter, BonusScanner, Decursive, DPSMate, EnhTooltip, EzDismount, Postal, QuickHeal, Stubby, SuperMacro, WIM, and _LazyPig.

The Forever client already has its own modern Decursive. That copy was left installed. It is not part of FurySwipes.

`5mmb_vanilla.tcl`, `toonlist.txt`, and the HotkeyNet helper files are still in the folder from the old project. Nothing in the new setup reads them.

## Still needs a pass in game

Checked here: the addon is one folder, the TOC says Interface 16001, and the Lua files balance. There is no Lua interpreter on this machine, so this was not a load test. These still need a logged-in character:

- Secure heal targeting (the PreClick snippet). If it fails, key 2 falls back to a party-order heal and the chat frame says so.
- Spell names on this server. Unknown spell ids are skipped. `/fs who` shows the spell that was chosen.
- `UnitSetRole`, if you want tank priority rather than "lowest health".
- Group invite and auto-accept against your realm.
- OpenMultiBoxing's window title for the Forever client, if it is not `World of Warcraft`.

## Tracking

Work on this repo is recorded in three files:

- `docs/FEATURES.md` lists each feature and whether it is confirmed.
- `docs/PROGRESS.md` is the current milestone and the log of what landed.
- `docs/MEMORY.md` holds paths, API choices, and constraints that should survive the next session.

`AGENTS.md` tells an agent to update those files, commit, and push to GitHub after every change.
