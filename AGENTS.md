# Peek Buddy Animated — AGENTS.md

For AI agents. Read it before you touch this project.

## What this is

A Windhawk tool mod: animated FF7 character GIFs pop from the bottom screen corner at the top of the hour (or at times the user picks). One file: `peek-buddy-animated.wh.cpp`, running in its own `windhawk.exe`. GitHub-only for now: `n3thshan/wh-peek-buddy-animated`. Installed and working on the user's PC. The user publishes to the Windhawk collection himself, when he decides — see "Publishing" at the bottom.

## How the user works

- The user is a non-developer. His first language is not English. Use plain words and short sentences.
- Ask a lot of questions. Work in small steps. Do not guess on big things.
- Never verify with screenshots. Ask the user — he tests in Windhawk after changes and tells you how it went. Never claim something works or looks right. Checks passing does not mean it works.
- Do not use OpenChamber project knowledge (notes/todos) for this project.

## Hard rules

- One file, always: `peek-buddy-animated.wh.cpp`. English only.
- Do not run the build checks (syntax/link) unless the user asks.
- Never commit and never push. The user git adds, commits and pushes himself. Work on `main` only.
- Never touch GitHub issues. The user handles them himself.
- Bump `@version` only when the user asks. Keep numbering simple (1.0 → 1.1).
- When GIFs change, run `re-embed-gifs.ps1` automatically — no need to ask.
- GPL-3.0. Non-commercial fan project.

## Project structure

| File | Purpose |
|------|---------|
| `peek-buddy-animated.wh.cpp` | Single-file mod: metadata, settings, embedded GIF base64, decode, render, scheduler, tool-mod boilerplate. |
| `README.md` | Install and feature guide. |
| `gifs/` | Source GIFs, embedded as base64 into the .wh.cpp. |
| `docs/` | Demo GIFs for the readmes (Cloud, Sephiroth, Tifa), 220 px tall. |
| `re-embed-gifs.ps1` | Re-encodes `gifs/` to base64 and rewrites matching arrays. New GIFs get a new array; prints the `kGifs` line to paste. |
| `tools/whstub.cpp` | Stub for Windhawk's runtime API, link check only. Not the mod. |
| `reference/template.txt` | The original mod this forks from. Read-only. Not compiled. |
| `.gitattributes` | LF line endings; images are binary. |

## Environment and paths

- Compiler: `C:\Program Files\Windhawk\Compiler\bin\clang++.exe`
- Flags file `%TEMP%\whflags-peek-buddy-animated.txt` (3 lines): `-DWIN32_LEAN_AND_MEAN`, `-UWH_EDITING`, `-DWH_MOD_ID=L"peek-buddy-animated"` (`WH_MOD_ID` must match the `@id` in the metadata)
- ffmpeg (demo GIFs only): ships with File Converter at `C:\Program Files\File Converter\ffmpeg.exe`. Do not install anything.
- Windhawk docs: live wiki at https://github.com/ramensoftware/windhawk/wiki (no vendored copy).

## Build (only when the user asks)

Syntax check:
`"C:\Program Files\Windhawk\Compiler\bin\clang++.exe" "@C:\Program Files\Windhawk\Compiler\compile_flags.txt" "@%TEMP%\whflags-peek-buddy-animated.txt" -Wall -Wextra -fsyntax-only peek-buddy-animated.wh.cpp`

Link check (throwaway DLL):
`"C:\Program Files\Windhawk\Compiler\bin\clang++.exe" "@C:\Program Files\Windhawk\Compiler\compile_flags.txt" "@%TEMP%\whflags-peek-buddy-animated.txt" -shared -O2 -o %TEMP%\peek-buddy-check.dll peek-buddy-animated.wh.cpp tools\whstub.cpp -lole32 -lgdiplus -luser32 -lgdi32 -lshell32`

The two warnings (`MONITORINFO`, `STARTUPINFO`; both `-Wmissing-*-initializers`) are harmless and expected.

## Key design decisions

- **Single file**: GIFs are base64 string arrays. Nothing is downloaded.
- **GIF decode**: GDI+ (`Image` from `CreateStreamOnHGlobal`, `SelectActiveFrame`, `PropertyTagFrameDelay`). Delays clamped 20–1000 ms; missing/zero plays as 100 ms.
- **Uniform body height**: body height measured from top of head to feet on the first frame (thin swords above the head ignored). Every character is ~200 px tall at 100%. Targets clamp to 40–2000 px (300% Size works).
- **GIF cache**: decoded frames cached (`g_gifCache` / `GetDecodedGif`), once per session. `ClearGifCache()` on worker exit and unload.
- **Corner alignment**: window's outer edge sits exactly at the work-area corner. The character is drawn ~8 px inside the window by design. The dialogue box floats above the head and only expands into the screen.
- **Uniform dialogue box**: box scale comes from the Size setting, never from the GIF canvas. Same box size for every character.
- **Animation**: cubic ease-out slide-up + fade in; fade + slide on exit. No bounce or springs.
- **Dialogue box**: FF7-style gradient, beveled border, shadowed text (credits to a CodePen by Kaizzo). A per-pack themed box is a possible future direction — not decided yet.
- **Clock**: English only. 12-hour with AM/PM by default, or 24-hour via `timeFormat`.
- **Packs**: Random picks only from the selected pack; a specific character is always shown. Only the `ff7` pack has GIFs; the `future` placeholder is kept on purpose. Random with an empty pack falls back to all GIFs — intended.
- **Tool mod**: its own `windhawk.exe`, topmost layered window, worker thread + message loop, cleaned up on unload. Reports failure instead of claiming success when init failed.

## Known quirks — do not touch

- `gifs/sephiroth 1.gif` — spelled correctly. Do not rename it.
- The `.wh.cpp` readme image links point at `raw.githubusercontent.com/n3thshan/wh-peek-buddy-animated/main/docs/...`. Rename the repo = update the three links. Only i.imgur.com and raw.githubusercontent.com images are allowed there.
- The ~8 px inner margin on the character is intentional. No outer margin on the window.
- Empty `future` pack Random falls back to all GIFs. Intended.
- Exact-times parser (`ParseTimes` / `ParseOneTime` / `ParseAmPm`): never turn bad input into a time. Invalid tokens go to `g_badTimes` (logged, shown in the preview bubble) and are never scheduled. Keep `25:00`, `9:75`, `13 pm`, `0 am` in `g_badTimes` if you touch the parser.
- `kQuotesEn`: every row needs exactly six quotes. The code picks a random index using the first row's length; a shorter row reads past its end — garbage or crash. Keep six quotes per row. (`quoteSet` is bounds-checked and falls back to row 0.)
- `re-embed-gifs.ps1` edits the .wh.cpp in place; git is the safety net. It only sees files in `gifs/`; a GIF deleted from `gifs/` leaves its embedded array behind — remove it by hand if ever needed.
- The .wh.cpp readme is the source of truth. `README.md` is the same text plus an Install section and relative image paths, but no Issues link.

## Adding a GIF to an existing pack

1. Drop the .gif into `gifs/`.
2. Run `.\re-embed-gifs.ps1` (run it without asking). A new GIF gets a new array; the script prints the line to add.
3. Add a `kGifs` entry with `id`, `quoteSet` (0 = Cloud set, 1 = Sephiroth, 2 = Tifa), and `pack`. No `bodyScale` — fixed at runtime.
4. It shows up in Random under that pack automatically. To also offer it as a preset character, add it to the `character` setting options.
5. The script does not edit `kGifs` — paste the printed line and adjust it.

## Adding a new character pack

1. GIFs into `gifs/`; run `.\re-embed-gifs.ps1`.
2. Add the `kGifs` entries with `pack` set to the new pack id.
3. Add the pack as an option in the `pack` setting block.
4. If the pack needs its own quotes, add a row to `kQuotesEn` with exactly six quotes; set the entries' `quoteSet` to the new row index.
5. Build checks only if the user asks.

## Publishing (later — the user does it)

The user submits to the Windhawk collection himself, manually, when he is ready. Agents must not prepare PRs, changelogs, or submission material unless the user asks. For later reference: official repo `ramensoftware/windhawk-mods`; a submission is a single `mods/<id>.wh.cpp`; `@github` must match the author; `@version` must increase; PRs go through `/ai-review` then `/ready-for-reviewer`. Wiki: https://github.com/ramensoftware/windhawk/wiki
