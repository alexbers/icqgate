@echo off
call asm.bat icqgate

call obj.bat icqgate
if errorlevel 0 goto OK

:FAULT
ECHO FAULT
goto EXIT

:OK
ECHO OK

rem icqgate.exe

:EXIT
@echo on