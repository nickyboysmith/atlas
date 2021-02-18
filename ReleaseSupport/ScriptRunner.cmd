
REM   Log the start date and time.
REM ECHO ScriptRunner.cmd: >> "%TEMP%\ScriptRunnerLog.txt" 2>&1
REM ECHO Start Current date and time: >> "%TEMP%\ScriptRunnerLog.txt" 2>&1
REM DATE /T >> "%TEMP%\ScriptRunnerLog.txt" 2>&1
REM TIME /T >> "%TEMP%\ScriptRunnerLog.txt" 2>&1

ECHO MyFile_%date:~6,4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%.txt

@Echo Off
FOR /f %%i IN ('DIR C:\Scripts\ScriptsDir\*.Sql /B /On') do call :RunScript %%i
GOTO :END

:RunScript
Echo Executing Script: %1

REM - YES SQLCMD -S IAMVSQL02 -D ScriptRunner -U ScriptRunner -P scr1ptrunn3r -i %1 >> %TEMP%\ScriptRunnerLog.txt
REM - YES SQLCMD -S IAMVSQL02 -D ScriptRunner -U ScriptRunner -P scr1ptrunn3r -i %1 -o MyFile_%date:~6,4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%.txt

REM - NO SQLCMD -S tcp:IAMVSQL02\ScriptRunner,1433 -U ScriptRunner -P scr1ptrunn3r -i %1 -o MyFile_%date:~6,4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%.txt
REM - NO SQLCMD -S tcp:192.168.0.66\ScriptRunner,1433 -U ScriptRunner -P scr1ptrunn3r -i %1 -o MyFile_%date:~6,4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%.txt

REM SQLCMD -S tcp:ymw3trna08.database.windows.net,1433 -D Atlas_Dev -U AtlasDev@ymw3trna08 -P IAM2015dev~! -i %1 -o MyFile_%date:~6,4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%.txt

REM SQLCMD -S tcp:ymw3trna08.database.windows.net,1433\Atlas_Dev -U ScriptRunner@ymw3trna08 -P 5cr1ptRunn3r! -i %1 -o MyFile_%date:~6,4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%.txt

REM - YES SQLCMD -S tcp:ymw3trna08.database.windows.net,1433 -d Atlas_Dev -U ScriptRunner@ymw3trna08 -P 5cr1ptRunn3r! -l 300 -i %1 -o MyFile_%date:~6,4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%.txt

SQLCMD -S tcp:ymw3trna08.database.windows.net,1433 -d Atlas_Dev -U ScriptRunner@ymw3trna08 -P 5cr1ptRunn3r! -l 300 -i %1 -o MyFile_%date:~6,4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%.txt


Echo Completed Script: %1
:END

REM $(ProjectDir) - The full path directory of the project you are working on. for instance "C:\builds\myproject"

REM $(ProjectPath) - The full path name of the vcproj you are working on. for instance "C:\builds\myproject\foo.vcproj"

REM $(ProjectName) - The name of the project. for instance "foo"

REM $(SolutionDir) - The full path directory of the solution that is currently loaded. for instance "C:\builds\mysolution"