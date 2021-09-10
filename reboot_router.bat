@echo off

set HOST=https://192.168.1.1
set TEMPFILE=%TEMP%\login_status
set COOKIE=%TEMP%\cookies.txt

CALL :Reboot
EXIT /B %ERRORLEVEL%

:Login
echo Logging in...

set USER=admin
set PASSWORD=R....1!

curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:91.0) Gecko/20100101 Firefox/91.0" ^
	-H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" ^
	-H "Accept-Language: en-US,en;q=0.5" ^
	-H "Accept-Encoding: gzip, deflate, br" ^
	-H "Origin: %HOST%" ^
	-H "Connection: keep-alive" ^
	-H "Referer: %HOST%/login_pldt.asp" ^
	-H "Upgrade-Insecure-Requests: 1" ^
	-c %COOKIE% ^
	-d "User=%USER%&Passwd=%PASSWORD%" ^
	-k -L %HOST%/goform/webLogin 

curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:91.0) Gecko/20100101 Firefox/91.0" ^
	-H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" ^
	-H "Accept-Language: en-US,en;q=0.5" ^
	-H "Accept-Encoding: gzip, deflate, br" ^
	-H "Connection: Close" ^
	-H "Referer: %HOST%/login.html" ^
	-H "Upgrade-Insecure-Requests: 1" ^
	-H "Host: 192.168.1.1" ^
	-o %TEMPFILE% -k %HOST%/login_pldt.asp

findstr /r /N /X /C:"^.*var login_error = '';.*$" %TEMPFILE%
if %ERRORLEVEL%==0 GOTO LoggedInSuccessfully

findstr /r /N /X /C:"^.*var login_error = '1';.*$" %TEMPFILE%
if %ERRORLEVEL%==0 GOTO UserPwdIncorrect

findstr /r /N /X /C:"^.*var login_error = '8';.*$" %TEMPFILE%
if %ERRORLEVEL%==0 GOTO AlreadyLoggedIn

EXIT /B 0

:LoggedInSuccessfully
echo Logged in successfully.
EXIT /B 0

:UserPwdIncorrect
echo Username / Password is incorrect.
EXIT /B 0

:AlreadyLoggedIn
echo User is currently logged in somewhere. Please wait 5 mins and try again.
EXIT /B 0

:Logout
echo Logging out...

curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:91.0) Gecko/20100101 Firefox/91.0" ^
	-H "Referer: %HOST%/menu_pldt.asp" ^
	-H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" ^
	-H "Upgrade-Insecure-Requests: 1" ^
	-H "Host: 192.168.1.1" ^
	-b %COOKIE% -c %COOKIE% -k  -L %HOST%/goform/webLogout

del %TEMPFILE%
del %COOKIE%

EXIT /B 0

:Reboot
CALL :Login
echo Rebooting...
findstr fhstamp %COOKIE% > tmp
set /P TOKEN=<tmp
del tmp

set TOKEN=%TOKEN:#HttpOnly_192.168.1.1	FALSE	/	TRUE	0	fhstamp	=%

curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:91.0) Gecko/20100101 Firefox/91.0" ^
     -H "Referer: %HOST%/menu_pldt.asp" ^
     -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" ^
     -H "Upgrade-Insecure-Requests: 1" ^
     -H "Host: 192.168.1.1" ^
     -d "n/a=&x-csrftoken=%TOKEN%" ^
     -b %COOKIE% -X POST -k %HOST%/goform/reboot

del %COOKIE%

EXIT /B 0
