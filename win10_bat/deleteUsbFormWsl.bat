@ECHO OFF

%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit
cd /d "%~dp0"

usbipd list | find "Silicon Labs CP210x USB to UART Bridge" | find "Attached" > usb.tmp
for /f "delims= " %%i in (usb.tmp) do (usbipd detach --busid %%i  && echo detach %%i)

usbipd list | find "Silicon Labs CP210x USB to UART Bridge" | find "Shared" > usb.tmp
for /f "delims= " %%i in (usb.tmp) do (usbipd unbind --busid %%i  && echo unbind %%i)
del  usb.tmp
Timeout /T 3 /NOBREAK
%pause%
