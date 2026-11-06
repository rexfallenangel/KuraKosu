# Apply Patch
1. Click Code
2. Click Download ZIP
3. Extract to the game folder and Replace All.
4. Run **`ApplyPatch.bat`**. It patches `BasicData.wolf`, `MapData.wolf` and `scenario.wolf` from the `.xdelta` files in `gameupdate/deltas` and keeps the originals as `.wolf.bak`. It needs game version 2.01 and changes nothing if the files do not match.

## Future Patching
Run **`GameUpdate.bat`** (Windows) or **`GameUpdate_linux.sh`** (Linux) from the game folder to auto patch.

If the game warns at startup that a newer patch is available, close it and run GameUpdate, or patch manually from the link in the warning.
After patching manually, reopen the game and choose **I installed this update manually**.

# Troubleshooting
**GameUpdate.bat doesn't update and closes immediately**
1. Make sure your path doesn't contain any Japanese characters or lots of whitespace.
2. Make sure you actually have permissions in the folder.
3. GameUpdate only needs internet access to this public repository; no account is required.
4. On Linux, if GameUpdate says Git is not installed, install it with the command it shows, then run GameUpdate again.

# Wolf Games
WOLF RPG games from DLsite often ship a `Data.wolf` archive that the game loads instead of the translated files.
GameUpdate unpacks it once with the bundled `UberWolfCli.exe` ([UberWolf](https://github.com/Sinflower/UberWolf), MIT) and renames `Data.wolf` to `Data.wolf.bak`, so the translation loads.
No separate UberWolf download is needed; on Linux, GameUpdate runs it with Wine.

If unpacking fails (rare, on protected builds), unpack the game once with [UberWolf](https://github.com/Sinflower/UberWolf/releases) so a loose `Data` folder exists, rename or remove `Data.wolf`, delete `gameupdate/previous_patch_sha.txt` and run GameUpdate again.
