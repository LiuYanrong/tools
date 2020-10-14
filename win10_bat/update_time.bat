@echo off
::choice /t 5 /d y /n >nul
w32tm /config /manualpeerlist:ntp5.aliyun.com,0x8 /syncfromflags:MANUAL
net stop w32time
net start w32time
w32tm /resync