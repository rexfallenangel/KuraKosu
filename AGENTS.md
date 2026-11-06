# Kuran Hime's Cosplay RPG - notes for assistants

Engine: Wolf RPG Editor (2013), split archives in `Data/*.wolf` (no `Data.wolf`). Translate to English; GameUpdate is installed, so the patch ships loose files in `Data/<ArchiveName>/` (the engine reads loose files before the archive).

## Where the text lives
- `Data/BasicData.wolf`: CommonEvent.dat, DataBase/CDataBase/SysDatabase (.project+.dat), Game.dat. `Data/MapData.wolf`: ~100 `.mps` maps.
- `Data/scenario.wolf`: 42 `.txt` scripts in **Shift-JIS (cp932)**, CRLF. Lines starting with `/` are commands (`/evcg,001`, `/v00c001`, `/bgm`...) and must stay untouched; text blocks are separated by blank lines and normally start with a `Name：` line. English must be ASCII only (cp932 round trip).
- In events, a message's first line is usually the nameplate `Name：`; a leading `@N` line is the window style (kept outside the translation).
- Images: only `Picture/kaisou.png` and `Picture/kaisou_bg.jpg` carry readable text (translated); `Picture/title_00.jpg` title logo is left Japanese (artwork-integrated, no clean layer). Other pictures, SystemFile and SystemGraphic have no text.

## Tools (kept in `.dazedtl/len-method/work`, local only; rewrite from this description if lost)
- Unpack: `wolf unpack Data/<X>.wolf -o <dir>` with DazedTL's bundled `wolf.exe` (`backend/dazedtl/engine/util/wolfdawn/bin/windows/`). Unpacked text archives are in `work/un/{BasicData,MapData,scenario}`, images in `work/img/`.
- `strings-extract` each file to `work/out/*.json` (plus `names-extract` -> `names.json`); `extract.py` turns them (and the scenario blocks) into `units.json` and `side.json` (id -> file/cmd/str location for injection). Unit ids: `<file>/i<sceneIndex>_e<event>[/p<page>]#c<cmd>s<str>`, `DataBase.project#t<type>r<row>f<field>`, `names#<index>`, `scn/<file>#L<line>`. Scene index (not event number) keeps ids unique because some events share numbers. Name categories excluded from translation (asset/editor labels) are listed in `EXCL_NAME_NOTES`.
- `inject.py <translations.json {id: text}> <outdir> --en-punct`: writes translations into the JSON copies, runs `strings-inject` per file and `names-inject` in place, and rebuilds the scenario `.txt` files; then `wolf relayout` (measured JP geometry: width 58, 4 rows; use a more conservative width for English) reflows messages. Copy the staged `BasicData/MapData/scenario` into `Data/`.
- Canary (done once): injected 5 strings, read them back with `strings-extract`, then deleted the loose folders; the game folder hashes matched the pre-canary hashes.
- Scope rules (`work/scope-rules.json`): only the `Game.ini` comment line is set aside.

## Standing choices
- Names: Kuran, Sherry, Arc Doyle, Toona (see `.dazedtl/glossary.txt`). Sherry's gender is unstated: avoid gendered pronouns.
- Never translate or rename scenario file names or `/` command lines.
- Do not edit `.dazedtl/.git` (a stray nested repo made by an early progress report was removed; the game's real history is in the top-level `.git`).

## State notes
- Ruby `\r[kanji,kana]` is stripped from units at extraction (the translating model kept breaking it); injected text has no ruby.
- Fit: `wolf relayout en_stage -o relay --width 52 --width-face 52 --max-rows 4 --orig un` then `wrap_scn.py` (wraps scenario lines to 56 chars). Widths are estimates from the JP corpus (58); not checked on screen.
- Four requests (57 units, e.g. the item-count suffix event, two sample-map lines with ruby, one database row) still failed in the Live runs and remain Japanese until retried or translated by another model.
