# Peek Buddy Animated — AGENTS.md

This project is a Windhawk mod that shows animated character GIFs in the bottom
corner of the screen at scheduled times. It is designed to be extended with new
character packs (e.g., non-FF7 packs) in the future.

## Project structure

| File | Purpose |
|------|---------|
| `peek-buddy-animated.wh.cpp` | Single-file Windhawk mod. Contains metadata, settings, embedded GIF base64 data, GIF decoding, dialogue box rendering, layout, animation, scheduler, and Windhawk tool-mod boilerplate. |
| `README.md` | Install and feature guide. |
| `gifs/` | Source GIF files (embedded as base64 into the .wh.cpp). |
| `docs/` | The three demo GIFs shown in the readme (`demo-1.gif` Cloud, `demo-2.gif` Sephiroth, `demo-3.gif` Tifa). Resized to 220 px tall so they fit in one row. |
| `re-embed-gifs.ps1` | PowerShell script that scans `gifs/`, re-encodes every `.gif` as base64, and rewrites the matching arrays in `.wh.cpp`. Existing arrays keep their names; new GIFs get a new array and the script prints the exact `kGifs` line to add. |
| `AGENTS.md` | This file. |
| `.gitattributes` | Keeps text files stored and checked out with LF line endings, and marks images as binary. |
| `LICENSE` | GPL-3.0 license text. |
| `tools/whstub.cpp` | Stub for Windhawk's runtime API, used by the link check. Not part of the mod. |
| `reference/` | Reference material: original `template.txt` and a copy of the Windhawk wiki. Not part of the build. |

## Build commands

The Windhawk compiler is at `C:\Program Files\Windhawk\Compiler\bin\clang++.exe`.
Before building, create the flags file with these three lines (one per line):

```
-DWIN32_LEAN_AND_MEAN
-UWH_EDITING
-DWH_MOD_ID=L"peek-buddy-animated"
```


Syntax check (no output file):
```
"C:\Program Files\Windhawk\Compiler\bin\clang++.exe" "@C:\Program Files\Windhawk\Compiler\compile_flags.txt" "@%TEMP%\whflags-peek-buddy-animated.txt" -Wall -Wextra -fsyntax-only peek-buddy-animated.wh.cpp
```

Link check (produces a throwaway DLL):
```
"C:\Program Files\Windhawk\Compiler\bin\clang++.exe" "@C:\Program Files\Windhawk\Compiler\compile_flags.txt" "@%TEMP%\whflags-peek-buddy-animated.txt" -shared -O2 -o %TEMP%\peek-buddy-check.dll peek-buddy-animated.wh.cpp tools\whstub.cpp -lole32 -lgdiplus -luser32 -lgdi32 -lshell32
```

The two warnings (`MONITORINFO` at `-Wmissing-field-initializers` and `STARTUPINFO` at `-Wmissing-designated-field-initializers`) are harmless and expected. `tools\whstub.cpp` is a stub for Windhawk's runtime API, tracked only for the link check; it is not part of the mod.

## Key design decisions

- **Single file**: All GIFs are embedded as base64 string arrays in the `.wh.cpp`. Nothing needs downloading.
- **GIF decode**: GDI+ (`Image` from `CreateStreamOnHGlobal`, `SelectActiveFrame`, `PropertyTagFrameDelay`). The `IStream` is kept alive until the `Image` is out of scope, so GDI+ can read it lazily. Frame delays are clamped to 20-1000 ms; a zero or missing delay plays as 100 ms.
- **Sprite pipeline**: Decode at source resolution → crop transparent borders → scale once in place to the target body height (nearest-neighbour) → premultiplied ARGB. Blitted directly (no rotation/scaling).
- **GIF cache**: decoded frames and delays are cached in memory (`g_gifCache`, handed out by `GetDecodedGif`), so a character is decoded only once per session. `ClearGifCache()` is called when the worker thread exits and on mod unload.
- **Uniform body height**: Each GIF is decoded at source resolution, then the actual body height is measured from the top of the head (first wide run of opaque pixels) to the feet on the first frame. Thin swords/effects above the head are ignored. If the body differs from the target, the decoded frames are scaled in place (no re-decode) so every character's body is ~200 px tall on screen at 100% size (target clamped to 40-2000 px, so 300% Size works). The `bodyScale` field is gone.
- **True corner alignment**: The character window sits flush against the work-area corner edge — there is no extra outer margin. The dialogue box floats above the head and is clamped so it only expands into the screen (right corner: box shifts/clamps left; left corner: mirrored). Characters with a wide canvas (e.g. Sephiroth 1) shift inwards so the box still fits.
- **Uniform dialogue box**: The bubble uses a fixed scale based on the Size (%) setting (`bodyTargetH / 200 * 1.1`), never the character canvas height. So every character gets the same bubble size, even when the GIF canvas is tall because of a sword swing.
- **Animation**: Smooth cubic slide-up + fade on entrance; fade/slide on exit. No bounce, springs, overshoot, or wiggling.
- **Dialogue box**: Generic rounded box with gradient fill, beveled border, and drop-shadowed text.
- **Clock**: 12-hour format with AM/PM by default, or 24-hour — pick in the `timeFormat` setting. English only.
- **Packs**: Characters belong to packs (stored in `GifAsset.pack`). Random selection only picks from the selected pack. A specific character is always shown — the pack setting never overrides it. Initially only the "ff7" pack exists; a "future" placeholder option is present but empty.
- **Tool mod**: Runs in a dedicated `windhawk.exe` process. Registers a topmost layered window, uses a worker thread with a message loop, and cleans up on unload. Startup failures (GDI+, window creation) are reported — the mod does not claim success when it failed to initialize.

## Adding a new character pack

1. Add the GIF files to `gifs/`.
2. Embed them as base64 string arrays in `peek-buddy-animated.wh.cpp` (use `re-embed-gifs.ps1`).
3. Add entries to the `kGifs` array with the `id`, `quoteSet`, and `pack`
   fields. (`bodyScale` is not needed — body height is corrected automatically
   at runtime.)
4. Add the pack as an option in the `pack` setting block.
5. If the new pack needs its own quote set, add a new row to `kQuotesEn` and
   set `quoteSet` to the matching index. `quoteSet` is bounds-checked; an
   out-of-range value falls back to 0.
   **Important:** every row in `kQuotesEn` must have the same number of quotes.
   The code always picks a random index from `0` to `n-1`, where `n` is the
   length of the first row (`ARRAYSIZE(kQuotesEn[0])`). If a new row is
   shorter, the code can read past its end and show garbage or crash. Keep all
   rows at exactly six quotes, or store a per-row count when adding a pack
   with a different number.
6. Recompile and verify with the syntax and link checks above.

## Adding a new GIF to an existing pack

1. Add the GIF file to `gifs/`.
2. Run `re-embed-gifs.ps1`. Existing arrays keep their names; a new GIF gets a
   new array (for example `barret.gif` -> `kGifBarretB64`) and the script
   prints the exact `kGifs` line to add.
3. Add an entry to `kGifs` with the appropriate `id`, `quoteSet`, and `pack`.
   (`bodyScale` is not needed.)
4. The new GIF appears in Random under its pack automatically. To also offer
   it as a preset character, add it to the `character` setting options in the
   metadata block.

## Notes

- **Exact times parser**: `ParseTimes` / `ParseOneTime` / `ParseAmPm` must never turn invalid input into a scheduled time (the old bug turned `25:00` into 5:00 AM). Invalid tokens are collected in `g_badTimes`, logged, and shown in the preview bubble — they are never scheduled. If you touch the parser, keep the unit tests in mind: `25:00`, `9:75`, `13 pm` and `0 am` must all end up in `g_badTimes`.
- **True corner layout**: `StartShow()` computes `CW`/`CH`/`charX`/`charY`/`bubX`/`bubY`/`winX`/`winY` so the character's outer edge sits exactly at the work-area corner edge. Do not re-add an outer margin around the window.
- The user does not want screenshot verification. If visual confirmation is needed, ask the user.
- **Readme images**: Windhawk only allows images from `https://i.imgur.com` and `https://raw.githubusercontent.com`. The `.wh.cpp` readme therefore uses full `raw.githubusercontent.com/n3thshan/wh-peek-buddy-animated/main/docs/...` links, while `README.md` uses relative `docs/...` paths (GitHub renders those). If the repo is renamed, update the three links in the `.wh.cpp`.
- **Keep the readmes in sync**: the `.wh.cpp` readme is the source of truth. `README.md` is the same text plus an `## Install in Windhawk` section and relative image paths.
- **Resizing demo GIFs**: ffmpeg ships with the File Converter app at `C:\Program Files\File Converter\ffmpeg.exe` (do not install anything). Command used: `ffmpeg -i in.gif -vf "scale=-2:220:flags=lanczos,split[a][b];[a]palettegen=stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=3" -loop 0 out.gif`.
- Compile flags: `-DWH_MOD_ID=L"peek-buddy-animated"` must match the `@id` in the mod metadata.
- All six GIFs in `gifs/` are verified to match their embedded base64. Run `re-embed-gifs.ps1` after replacing any GIF to keep them in sync.
- `gifs/sephiroth 1.gif` — filename is spelled correctly. Do not rename back to "spehiroth".
