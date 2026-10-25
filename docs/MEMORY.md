# Memory

Durable facts for the next session. Change a fact here when the code or the setup changes. The timeline of work is `docs/PROGRESS.md`. The feature checklist is `docs/FEATURES.md`.

## What this is

FurySwipes is a multibox helper for the WoW Forever private-server client. One key does a different job on each character. OpenMultiBoxing copies the key into each window. The addon never sends input itself.

HotkeyNet is not part of this version. Do not generate HotkeyNet scripts or try to repair HotkeyNet's login check.

## Paths

| What | Path |
| --- | --- |
| Repo | `D:\Furyswipes_Forever` |
| GitHub | `https://github.com/hydrolive/Furyswipes_Forever.git` (`main`) |
| Addon in the repo | `Interface/AddOns/FurySwipes` |
| Forever client | `D:\WoWMB\World of Warcraft\_forever_` |
| Forever AddOns | `D:\WoWMB\World of Warcraft\_forever_\Interface\AddOns` |
| Deployed addon | `D:\WoWMB\World of Warcraft\_forever_\Interface\AddOns\FurySwipes` |

`Interface\Addons` and `Interface\AddOns` are the same directory on Windows.

After any edit under the addon folder, copy those files onto the deployed path. Copy only `FurySwipes`. Do not delete or overwrite other Forever addons. The client already has a modern Decursive (Ace3, Interface 16001). Leave it.

Mama (`MAMA`) is installed on that client and is a useful API reference. Do not edit it and do not depend on it. Its follow keys (Alt-F, Alt-T, Alt-L) are different from ours.

## Addon shape

Load order in `FurySwipes.toc`: `Roster.lua`, `Spells.lua`, `Group.lua`, `Actions.lua`, `Core.lua`. Interface 16001. Version 1.0.0. Saved variables: `FurySwipesDB` (account), `FurySwipesChar` (character). Namespace: `FurySwipes`. User roster table: `FurySwipesRoster`.

`Roster.lua` is the same file on every window. The sample leader is Glarnk. Members: Glarnk tank, Broink caster, Sklerg hunter, Brunko melee, Furykipes healer. Heal fractions: self 0.30, tank 0.50, party 0.33. Replace the names before real use. No passwords in this file.

Role precedence: `FurySwipesChar.role`, then a roster name match, then `FurySwipes.ClassRole`. Name match ignores a realm suffix on one side only.

Class defaults: warrior tank; rogue, death knight, monk, demon hunter melee; hunter hunter; mage and warlock caster; priest, paladin, shaman, druid, evoker healer.

## API choices that were easy to get wrong

- `/click Button` from a macro does nothing on this client. Bind `CLICK ButtonName:LeftButton` with `SetBinding`, then `SaveBindings`.
- `header:WrapScript(frame, script, body)` is the method form used by Forever addons. Wrapping a button with itself is `button:WrapScript(button, "PreClick", body)`. The global form is `SecureHandlerWrapScript(frame, script, header, body)`.
- The secure PreClick snippet cannot define a function, cannot `return` (that can swallow the click), and cannot call `UnitName` (secret strings). Heal the lowest health with `UnitExists`, `UnitHealth`, `UnitHealthMax`, and `UnitIsDead`. Tank priority uses `UnitGroupRolesAssigned(unit) == "TANK"` when that call exists. Compare with `== nil`, because `0` is a valid health fraction.
- If `WrapScript` fails, the healer button keeps a party-order `/cast` macro.
- Do not test `[noexists]` or `[noharm]` on attack macros. Untargeted self-cast AoE must still fire. `/stopmacro [help]` is the friendly-assist stop.
- Ground-targeted spells are omitted. A broadcast key cannot place a reticle in every window.
- A `/cast` stops `/follow`.
- Invites use `C_PartyInfo.InviteUnit`. Accept uses `AcceptGroup` and `StaticPopup_Hide("PARTY_INVITE")`. The important accept path is `PARTY_INVITE_REQUEST`, because key 0 is pressed on every window before the invite arrives.
- `C_PartyInfo.SetLootMethod("freeforall")` matches Mama on this client. Call it with `pcall`.
- Character macros start after `Constants.MacroConsts.MAX_ACCOUNT_MACROS` (fallback 120). Icon file id `134400`.
- Spell names come from `C_Spell` / `C_SpellBook`, with older fallbacks. Unknown ids are skipped.
- Bindings are per account. The first `/fs init` on each account has to be typed, because the bind does not exist yet. Later, Ctrl-I can be broadcast. `/fs init` uses force and replaces `1`–`5` and `0`. Login reapplies only when `FurySwipesDB.autoBind` is set.

## Keys

`1` buff, `2` primary, `3` cleave or group heal, `4` assist, `5` area, `0` invite or accept, `SHIFT-1` utility, `ALT-1` follow, `ALT-4` follow and assist, `CTRL-I` init.

OpenMultiBoxing defaults to leave alone: Ctrl-F1, Ctrl-Shift-N, Ctrl-Shift-P, Ctrl-Shift-O, Ctrl-Shift-R (broadcast toggle), Ctrl-Shift-E, Ctrl-OEM3. Keep W A S D excluded. Do not exclude or remap `1` `2` `3` `4` `5` `0`. Mouse-click broadcast stays off.

Slash commands: `/fs` and `/furyswipes`.

## Do not

- Do not bring back SuperMacro, `_LazyPig`, or the removed Vanilla addon folders.
- Do not put a second multibox brain in another addon.
- Do not place actions onto occupied action-bar slots. Keys click secure buttons. The `FS_*` macros exist so a player can read them.
- Do not treat the local Forever AddOns folder as the source of truth. Edit the repo, then copy.
