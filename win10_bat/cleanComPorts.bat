@echo off
REM ========================================
REM Windows COM Port Counter Reset Script
REM Clears COM port counter by deleting ComDB registry entry
REM Auto-elevate to Administrator privileges
REM ========================================

REM Auto-elevate to Administrator
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit
cd /d "%~dp0"

echo Administrator privileges obtained, starting COM port counter reset...

echo.
echo ========================================
echo Windows COM Port Counter Reset Tool
echo ========================================
echo.
echo This will reset the COM port counter by deleting ComDB registry entry
echo.


echo Deleting ComDB registry entry to reset COM port counter...
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\COM Name Arbiter" /v ComDB /f >nul 2>&1
if %errorLevel% == 0 (
    echo ComDB registry entry deleted successfully
) else (
    echo WARNING: Failed to delete ComDB registry entry
)

echo.
echo ========================================
echo COM Port Counter Reset Completed!
echo ========================================
echo.
pause
