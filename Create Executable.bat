
@echo off
powershell -Command "& {Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-PS2EXE "$PWD\NetCon.ps1" "$PWD\NetCon.exe" -noConsole -requireAdmin}"

echo Created Executable
Exit

