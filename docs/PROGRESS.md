# Progress

## Now

The Forever addon is written, committed, and copied to `D:\WoWMB\World of Warcraft\_forever_\Interface\AddOns\FurySwipes`. It has not been loaded on a logged-in character.

**Next:** log each character in, run `/fs init`, and check the unverified rows in `docs/FEATURES.md`. Update a row to `done` only after that check. Record the result in the log below.

## In-game checks still open

- Secure heal targeting (PreClick on key 2). If install fails, party-order heal is the fallback and chat says so.
- Spell names from the ids in `Spells.lua`. `/fs who` shows the spell that was chosen.
- `UnitSetRole` / `UnitGroupRolesAssigned`, if tank priority should beat "lowest health".
- Invite and auto-accept on this realm.
- `CLICK` keybinds actually fire the secure buttons.
- A cast stops `/follow`. Alt-4 starts it again.
- OpenMultiBoxing's window title, if it is not `World of Warcraft`.

## Log

Newest first.

### 2026-10-24 — Key 1 casts Arcane Intellect on the mage, then the party

Glass Cannon's saved buff macro was still only Frost Armor, so key 1 did nothing once that armor was up. Arcane Intellect was not in that spellbook. Rank 1 is trained (10 copper), unlike free Frost Armor. Key 1 now casts Arcane Intellect on the mage and then on each party member, one press per person, and says so when the spell is not trained. Needs a `/reload`.

### 2026-10-24 — Mage key 1 skipped Arcane Intellect

Glass Cannon's buff macro only cast Frost Armor. Arcane Intellect is single-target on this client, and a bare `/cast` hits the current target, so an enemy target also blocks it. Key 1 now reads the spellbook and casts Arcane Intellect on the first party member who lacks it, then the mage. The next press applies armor. Needs a `/reload`.

### 2026-10-24 — Key 2 healed at full health

The healer's key 2 rested on a party heal that cannot see health, so full health still cast a heal. Key 2 now rests on the damage macro. A heal is chosen only when someone is at or under the roster thresholds (self 30%, tank 50%, anyone 33%). Keys 3 and 5 still heal on purpose. Needs a `/reload`, then key 2 at full health should attack.

### 2026-10-24 — Invites ignored spaced names

Pressing 0 on Grim Reaper printed "Waiting for an invite from Grim Reaper" and sent nothing. `UnitName("player")` on this client is `Grim`, so the addon did not treat that window as the leader and did not match the roster. Name checks now use `GetUnitName(unit, true)`. The live roster (Grim Reaper, Glass Cannon, Free Range, Bad Omen, Im Oom) is in the repo. Needs a `/reload` on each window, then 0 on the leader. The leader's chat should say `Inviting 4 character(s).`

### 2026-10-24 — Deploy path is WoWMB

The Forever client to update is `D:\WoWMB\World of Warcraft\_forever_`, not `D:\WoW\World of Warcraft\_forever_`. Copied `FurySwipes` into `D:\WoWMB\World of Warcraft\_forever_\Interface\AddOns\FurySwipes`. The six files matched the repo by hash. Other addons in that folder were left as they were. An earlier copy under `D:\WoW\...` is not the client to maintain.

### 2026-10-24 — Tracker and commit rule

`AGENTS.md` now requires a commit and a push to GitHub after every change, and these three files are the record of features, progress, and memory.

### 2026-10-24 — FurySwipes addon (`27aa31e`)

Replaced the Vanilla 1.12 HotkeyNet pack with one Forever addon.

- Added `Interface/AddOns/FurySwipes` (Roster, Spells, Group, Actions, Core) and `README.md`.
- Removed Bag_Sort, BeanCounter, BonusScanner, Decursive, DPSMate, EnhTooltip, EzDismount, Postal, QuickHeal, Stubby, SuperMacro, WIM, and `_LazyPig` from the repo.
- Left the modern Decursive already installed on the Forever client in place.
- Copied the addon to `D:\WoW\World of Warcraft\_forever_\Interface\AddOns\FurySwipes`. The copy matched the repo by hash at the end of that session.
- Checked TOC interface 16001 and Lua delimiter balance. No Lua interpreter was available. No in-game load.

The local client copy is not a git remote. Later addon commits still need that folder copied again.
