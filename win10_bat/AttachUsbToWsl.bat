@ECHO OFF

%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit
cd /d "%~dp0"

for /f "tokens=1" %%i in ('
    usbipd list ^| find "10c4:ea60" ^| find "Not shared"
') do (
    usbipd bind --force --busid %%i && echo bind %%i to wsl
    usbipd attach --wsl --busid %%i  && echo attach %%i to wsl
)

Timeout /T 3 /NOBREAK
%pause%
