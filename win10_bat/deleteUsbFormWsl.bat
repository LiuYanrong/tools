@ECHO OFF

%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit
cd /d "%~dp0"

for /f "tokens=1" %%i in ('
    usbipd list ^| find "10c4:ea60" ^| find "Attached"
') do (
    usbipd detach --busid %%i && echo detach %%i to wsl
    usbipd unbind --busid %%i  && echo unbind %%i
)

for /f "tokens=1" %%i in ('
    usbipd list ^| find "10c4:ea60" ^| find "Shared"
') do (
    usbipd unbind --busid %%i  && echo unbind %%i
)

Timeout /T 3 /NOBREAK
%pause%
