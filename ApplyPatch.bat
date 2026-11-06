@echo off
setlocal
set "ROOT=%~dp0"
set "ROOT=%ROOT:~0,-1%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%\gameupdate\apply-deltas.ps1" -Root "%ROOT%"
if errorlevel 1 (
    echo Patch failed. Your game files were not changed unless listed above.
) else (
    echo Done. The originals are kept as Data\*.wolf.bak
)
pause
