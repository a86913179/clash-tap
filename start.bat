@echo off

cd /d %~dp0

setlocal

set DEVICE_NAME=clash-tap

set PATH=%PATH%;%SystemRoot%\system32;%SystemRoot%\system32\wbem;%SystemRoot%\system32\WindowsPowerShell/v1.0

start clash.vbs
start tun2socks.vbs

netsh interface ip add route 0.0.0.0/0 %DEVICE_NAME% 10.0.0.1 metric=0 store=active
netsh interface ipv6 add route ::/0 %DEVICE_NAME% fdfe:dcba:9876::1 metric=0 store=active
for /f "delims=," %%a in ('Getmac /v /nh /fo csv') do (
  netsh interface ip set dnsservers %%a static 10.0.0.2 validate=no
  netsh interface ipv6 set dnsservers %%a static fdfe:dcba:9876::2 validate=no
)
ipconfig /flushdns
