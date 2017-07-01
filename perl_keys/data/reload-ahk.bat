cd %~dp0
taskkill /IM ahkout.exe
Ahk2Exe.exe /in autohotkeys.ahk /out ahkout.exe
start ahkout.exe
