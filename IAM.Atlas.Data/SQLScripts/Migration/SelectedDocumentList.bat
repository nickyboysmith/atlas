@Echo Off

REM for /r %%A in (documents\*) do (
REM  if "%%~tA" GTR "2017-06-20 17:57" echo %%~tA %%A
REM )

forfiles /P documents /M * /D "20/06/2017" /C "cmd /c echo ~ @fdate @ftime ~ ,  ~ @fsize ~ , @fname"
REM 27/06/2017  10:03



forfiles /P documents /M * /D "27/06/2017 10:03" /C "cmd /c echo ~ @fdate @ftime ~ ,  ~ @fsize ~ , @fname"