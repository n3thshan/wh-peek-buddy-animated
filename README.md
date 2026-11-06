# Peek Buddy Animated

A Windhawk mod that shows an animated character GIF in the bottom corner of your
screen at the top of every hour (or at times you pick).

The character stands on the taskbar edge for a few seconds, says a line in a
dialogue box, and leaves. The clock is 12-hour by default; you can switch it
to 24-hour in settings.

## File

- `peek-buddy-animated.wh.cpp` - the whole mod. The GIFs are embedded in this
  one file, so there is nothing else to install.

## Install in Windhawk

1. Open Windhawk.
2. Click **Create new mod**.
3. Open `peek-buddy-animated.wh.cpp` in Notepad, select all, copy, and paste
   it into the Windhawk editor.
4. Click **Compile mod**, then **Install**.
5. Press **Save** once to see a preview.

## Characters

Characters are organized into packs. Choose which pack **Random** picks from in
settings. If you pick a specific character, it is shown no matter which pack is
selected:

- **Final Fantasy VII** pack:
  - Cloud 1 - battle stance
  - Cloud 2 - standing pose
  - Cloud 3 - another variant
  - Sephiroth 1 - wide pose with a long sword
  - Sephiroth 2 - standing with a coat
  - Tifa - battle stance
  - Random - a different character from the selected pack each time

More packs can be added in future updates.

## What is it?

- Real animated GIF characters, not drawn shapes.
- No bouncy animations. The character slides up smoothly and fades out.
  No springs, no overshoot, no wiggling.
- 12-hour clock with AM/PM, or 24-hour — your choice in settings.
- Dialogue box with character quotes.
- The box shows the time and a quote, or just the time, or your own message.

## When does it show up?

- At the top of every hour (can be turned off).
- Every N minutes, counted from midnight (for example 15 means :00, :15, :30
  and :45; 0 turns this off).
- At exact times of your choice, for example `9:30 AM, 1:15 PM, 5:45 PM`.
  You can also write bare hours (`9`, `21`), dots (`9.30`), `a.m.`/`p.m.`
  (`9:30 a.m.`), `noon`, `midnight`, or separate entries with spaces,
  semicolons, or the word `and`. Both 12-hour and 24-hour input work.
  Invalid entries are logged, shown in the preview bubble when you save, and
  never scheduled.
- Quiet hours: it stays away between the two hours you choose (for example from
  23 to 8). Using the same value for both turns quiet hours off.
- Optional: skip it while a full-screen game, video or presentation is active.

## Preview

Windhawk settings cannot have a button, so the preview works like this:

- **Preview when settings are saved** (on by default): every time you press
  *Save*, the character shows up once with your new settings.

## Notes

- The mod runs in its own `windhawk.exe` process and does not inject into
  other programs. It does not change any system or registry setting.
- The GIFs are embedded in the mod file, so there is nothing to download.
- The character window never takes the keyboard focus. If **Click to dismiss**
  is off, the character is click-through and the mouse goes straight to the
  app below.
- It appears above the taskbar edge (the work area), as if it stands on it.
- The character stands right against the corner edge. The dialogue box opens
  inwards, into the screen.

## Credits

This is a non-commercial fan project. Character sprites are from various
sources and belong to their respective creators. This mod is not affiliated
with or endorsed by any game company.

The original Hourly Peek Buddy mod is by DahaSakinOlamazdim.
