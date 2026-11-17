# Testing Moru Mode

For people and agents who test the mod in the game. Check `logs\rqmod.log` for `Loading moru-mode`
first.

## What it adds

- **A page in Config's Mods tab**, **Moru Mode** (`rq.config.settings`, kept in the save). In
  `rqmod-ctl ui`, on that page: `check-on` (Moru Mode), `stepper-talent` (2 to 100, with
  `button-talent-dec` and `button-talent-inc`), `check-reserve`, `check-fallen`, `check-level`,
  `button-reset`. The last four rows are greyed while Moru Mode is off. Before a save is loaded the
  page asks for one.
- **A row at Alice's support menu** (quest 13, Alice's Mansion, the menu "Please choose an entry."):
  `[OFF] Moru Mode` or `[ON] Moru Mode` under Change difficulty (`select-off-moru-mode`,
  `select-on-moru-mode`; the game's Change difficulty and Adjust character data are `yes` and `no`,
  their choice ids 1 and 2). A pick turns Moru Mode over, Alice says so (a message to click
  through), and the menu shows again with the same rows. It shows only in that menu.

No other `rq.agent.control` ids. Do not invent controls for it.

## How to check it

1. Turn Moru Mode on with Talent growth 3. Give the weapon of a character in the party a Talent
   (`Ｉ機能` 39) and win a fight: the log says `Moru Mode: Talent rolled 3x for ...`, and the Talent
   rose by 3 to 90 (below 500; one roll is 1 to 30 there).
2. Each time the value passes a hundred, the game's log says "has risen in rank" and the weapon's
   attack (effects 2 and 14; an armor's 4 and 12; HP twice) rises by 5, 10 or 20 by the item's kind
   rank.
3. With a switch off (the game's way), a downed character, a reserve character or one over the
   level limit in the first world does not grow; with it on, it grows N times.
4. Moru Mode off: one roll per character, only those the game grows.

## Forcing it for a test

`rq.mod.get("moru-mode")` returns `on()`, `rolls()`, `get(key)` and `set(key, value)` for the
page's keys (`on`, `talent`, `reserve`, `fallen`, `level`), `last()` (the last fight with Moru Mode
on: `rolls`, `game`, the characters the game grew, and `extra`, `{ iic, why }` for those the
switches added, `why` being `"fallen"`, `"level"` or `"reserve"`) and `row_id` (the support menu
row's choice id). Put back what you set: the values stay in the save.

## Test Lab

`test-lab/scenarios/moru-mode.lua`: fights with Moru Mode off and on, each switch off and on, the
rolls counted per item, a rank's stats, the caps, the page, and the support menu's row.
