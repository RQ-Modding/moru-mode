# Moru Mode

A mode of its own beside TADA mode: it speeds up what TADA mode leaves alone. For now, the growth of
**Talent** and **Talent R** equipment.

## What it changes

While Moru Mode is on in a save:

- **Talent growth.** A weapon or armor with Talent or Talent R rolls its growth several times after
  a fight (2 to 100, 2 at first) where the game rolls once. Each roll is the game's own (the same
  amounts, the same caps of 1000 and 5000), and each rank the item reaches gives its stats, as in
  the game.
- **The game's conditions**, each turned off on its own (all on, as in the game, at first):
  - **The reserve's too:** the first army and the characters switched out during the quest roll
    too. The game grows only the party in the fight.
  - **The fallen's too:** characters downed when the fight ends roll too.
  - **No level limit:** in the first world, the game grows only characters at most 5 levels over the
    quest's difficulty; with this on, any level.

Talent still grows only after a fight won, or ended with the actions run out, as in the game.

TADA mode is not touched: it doubles a fight's EXP and gold and a familiar's growth, never Talent.
The two modes are each on or off by themselves.

## Keys and settings

- **Config → Mods → Moru Mode:** the **Moru Mode** box, **Talent growth** (2 to 100; - and +,
  Shift for 10, or a click to type it) and the three conditions. The rows are greyed while Moru Mode
  is off. **Reset** turns Moru Mode off and puts back the rest.
- **Alice's support menu** (the Support quest): **[OFF] Moru Mode** or **[ON] Moru Mode**, under
  Change difficulty, turns it on or off, as the menu's own [OFF] and [ON] rows do.

Everything is kept in the save: another save has its own. Load a save to see the page's rows.

## Saves

The settings stay in `RanceQuestMagnum_NNN.rqmod.json` beside each save; the game ignores the file.
What grew stays on the items. Remove the mod and the game grows Talent as before.

## Works with

Custom TADA Mode (it changes TADA mode's numbers, not Talent).

## Install

Needs [RQ MOD](https://github.com/RQ-Modding/RQ-Mod) with loader **2.36.0** or newer. Extract the
release zip into the game's `mods` folder, so that you have `mods/moru-mode/mod.json`.

## License

MIT, see [LICENSE](LICENSE).
