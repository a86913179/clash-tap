@echo off

cd /d %~dp0

setlocal

set DEVICE_NAME=clash-tap

set PATH=%PATH%;%SystemRoot%\system32;%SystemRoot%\system32\wbem;%SystemRoot%\system32\WindowsPowerShell/v1.0

netsh interface show interface name=%DEVICE_NAME% >nul
if %errorlevel% equ 0 (
  echo TAP network device already exists.
  goto :configure
)

set BEFORE_DEVICES=%tmp%\tap-devices-before.txt
set AFTER_DEVICES=%tmp%\tap-devices-after.txt

echo Storing current network device list...
wmic nic where "netconnectionid is not null" get netconnectionid > "%BEFORE_DEVICES%"
if %errorlevel% neq 0 (
  echo Could not store network device list. >&2
  exit /b 1
)
type "%BEFORE_DEVICES%"

echo Creating TAP network device...
for /f "skip=1 delims=." %%i in ('wmic os get version') do (
  if %%i==10 tap-windows6\tap-windows-9.24.2-I601-Win10.exe /S
  if %%i==6 tap-windows6\tap-windows-9.24.2-I601-Win7.exe /S
)
if %errorlevel% neq 0 (
  echo Could not create TAP network device. >&2
  exit /b 1
)

echo Storing new network device list...
wmic nic where "netconnectionid is not null" get netconnectionid > "%AFTER_DEVICES%"
if %errorlevel% neq 0 (
  echo Could not store network device list. >&2
  exit /b 1
)
type "%AFTER_DEVICES%"

echo Searching for new TAP network device name...
powershell "(compare-object (cat \"%BEFORE_DEVICES%\" | foreach-object {$_.trim()}) (cat \"%AFTER_DEVICES%\" | foreach-object {$_.trim()}) | format-wide -autosize | out-string).trim() | set-variable NEW_DEVICE; write-host \"New TAP device name: ${NEW_DEVICE}\"; netsh interface set interface name=\"${NEW_DEVICE}\" newname=\"%DEVICE_NAME%\"" <nul
if %errorlevel% neq 0 (
  echo Could not find or rename new TAP network device. >&2
  exit /b 1
)

echo Testing that the new TAP network device is visible to netsh...
netsh interface ip show interfaces | find "%DEVICE_NAME%" >nul
if %errorlevel% equ 0 goto :configure

:loop
echo waiting...
waitfor /t 10 thisisnotarealsignalname >nul 2>&1
netsh interface ip show interfaces | find "%DEVICE_NAME%" >nul
if %errorlevel% neq 0 goto :loop

:configure
echo (Re-)enabling TAP network device...
netsh interface set interface "%DEVICE_NAME%" admin=enabled

echo Configuring TAP device subnet...
netsh interface ip set address %DEVICE_NAME% static 10.0.0.2 255.255.255.0
netsh interface ipv6 set address %DEVICE_NAME% fdfe:dcba:9876::2/127
if %errorlevel% neq 0 (
  echo Could not set TAP network device subnet. >&2
  exit /b 1
)

echo Set all adapters metric to auto.
for /f "delims=," %%a in ('Getmac /v /nh /fo csv') do (
  netsh interface ip set interface %%a metric=automatic
  netsh interface ipv6 set interface %%a metric=automatic
)

echo Set TAP adapter metric to 0.
netsh interface ip set interface %DEVICE_NAME% metric=0
netsh interface ipv6 set interface %DEVICE_NAME% metric=0
if %errorlevel% neq 0 (
  echo Could not set interface metric. >&2
  exit /b 1
)

echo TAP network device added and configured successfully 
exit /b 0
