# FurySwipes agent rules

Read `docs/MEMORY.md`, `docs/FEATURES.md`, and `docs/PROGRESS.md` before changing this repo. Usage for players lives in `README.md`. Do not copy that guide into these files.

## After every change

A change is one logical piece of work: one feature, one fix, or one documentation update. Do not batch unrelated work into one commit.

Before you say the work is finished:

1. Update the tracker files this change affects. Include those edits in the same commit.
2. Commit that change by itself on the current branch.
3. Push to `origin` so the commit is on GitHub. This branch tracks `main` at `https://github.com/hydrolive/Furyswipes_Forever.git`.

If the push fails, say so. Leave the commit in place. Do not force-push.

Only commit files that belong to the change. Leave unrelated dirt unstaged.

## Tracker files

| File | What it holds | Update it when |
| --- | --- | --- |
| `docs/FEATURES.md` | Each feature and its status | Behavior is added, removed, or changes status |
| `docs/PROGRESS.md` | Current milestone, next step, and a newest-first log | Any landed change, deploy, or verification |
| `docs/MEMORY.md` | Durable facts: paths, API choices, constraints | A decision or constraint should survive the next session |

Statuses in `docs/FEATURES.md` are only `done`, `unverified`, `partial`, `unused`, or `next`.

`unverified` means the code is written and has not been confirmed on a logged-in Forever character. Do not mark a feature `done` until an in-game check says so. Record that check in `docs/PROGRESS.md`.

Do not put passwords, account names, session transcripts, or HotkeyNet auth notes in these files.

## Git

- Subject line: one sentence that says why the change exists.
- Body: what changed, only when the subject is not enough.
- Do not commit new credentials. `toonlist.txt` is a leftover HotkeyNet file. Do not copy its passwords into the addon or the docs.
- Do not commit `smart-garage.apk`, `turtle.zip`, or new binaries unless the user asks.

## Project constraints

Details are in `docs/MEMORY.md`. These rules stay in force:

- One addon folder: `Interface/AddOns/FurySwipes`. No SuperMacro, no `_LazyPig`, no extra library addon.
- Interface 16001. WoW Lua 5.1: no `goto`, no `//`, no `continue`.
- OpenMultiBoxing broadcasts keys. This addon does not send input to other windows. Do not add HotkeyNet scripts.
- When addon files change, copy `Interface/AddOns/FurySwipes` onto the Forever client path in `docs/MEMORY.md`. Do not overwrite unrelated addons there. Leave the client's modern Decursive installed.
- The secure heal snippet must not define functions, must not `return`, and must not call `UnitName`.

## When you finish

Name the commit and confirm it was pushed, or say that the push failed.
