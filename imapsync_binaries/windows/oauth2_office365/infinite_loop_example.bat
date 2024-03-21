
@REM $Id: infinite_loop_example.bat,v 1.2 2023/09/18 20:18:35 gilles Exp gilles $

@REM An infinite loop with a sleep of 3600 seconds between each run

@REM First let's go in the directory this batch is
@REM CD /D %~dp0
@PUSHD %~dp0

@REM How many seconds to sleep at each run inside the loop is set in the variable %sleep%
@REM If TIMEOUT command is not available then the sleep is done with a PING command.

SET sleep=1800

:loop

@ECHO %date% %time%
CALL .\oauth2_office365_with_imap.exe  gilles.lamiral@outlook.com

@ECHO %date% %time% 
@ECHO Now sleeping for %sleep% seconds
TIMEOUT /T %sleep% || PING 127.0.0.1 -n %sleep%

GOTO loop

@POPD
@PAUSE


