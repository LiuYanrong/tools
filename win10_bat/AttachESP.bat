@ECHO OFF

%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit
cd /d "%~dp0"

usbipd list | find "USB JTAG/serial debug unit" | find "Not shared" > usb.tmp
for /f "delims= " %%i in (usb.tmp) do (usbipd bind --force --busid %%i  && echo bind %%i to wsl)

usbipd list | find "USB JTAG/serial debug unit" | find "Shared" > usb.tmp
for /f "delims= " %%i in (usb.tmp) do (usbipd attach --wsl --busid %%i  && echo attach %%i to wsl)
del  usb.tmp
Timeout /T 3 /NOBREAK
%pause%
