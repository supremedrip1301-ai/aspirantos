@echo off
REM ============================================================
REM  AspirantOS - command-line compile check (Windows)
REM  Eclipse users do NOT need this: Run As -> Run on Server.
REM  1. Compiles src\main\java with javac --release 21 into build\cli
REM     classpath = Tomcat lib (Servlet/JSP API) + WEB-INF\lib jars
REM  2. Copies the webapp + classes into build\cli\web
REM  3. Packs build\AspirantOS.war with the jar tool
REM  Usage:  tools\build.cmd          (from the project folder)
REM ============================================================
setlocal
set "ROOT=%~dp0.."
if "%CATALINA_HOME%"=="" (
    echo CATALINA_HOME is not set. Set it to your Tomcat 11 folder.
    exit /b 1
)
set "SRC=%ROOT%\src\main\java"
set "WEB=%ROOT%\src\main\webapp"
REM build\classes belongs to Eclipse - this script only uses build\cli and the WAR
set "OUT=%ROOT%\build\cli"
set "WAR=%ROOT%\build\AspirantOS.war"

if exist "%OUT%" rmdir /s /q "%OUT%"
if exist "%WAR%" del /q "%WAR%"
mkdir "%OUT%\classes"

REM list every .java file into a sources file for javac
dir /s /b "%SRC%\*.java" > "%OUT%\sources.txt" 2>nul
for %%A in ("%OUT%\sources.txt") do if %%~zA==0 goto nojava

javac --release 21 -encoding UTF-8 -Xlint:unchecked -d "%OUT%\classes" ^
      -cp "%CATALINA_HOME%\lib\*;%WEB%\WEB-INF\lib\*" @"%OUT%\sources.txt"
if errorlevel 1 (
    echo COMPILE FAILED
    exit /b 1
)
:nojava

REM assemble the web folder: webapp files + compiled classes
xcopy "%WEB%" "%OUT%\web\" /e /i /q /y >nul
mkdir "%OUT%\web\WEB-INF\classes" 2>nul
xcopy "%OUT%\classes" "%OUT%\web\WEB-INF\classes\" /e /i /q /y >nul

jar --create --file "%WAR%" -C "%OUT%\web" .
if errorlevel 1 (
    echo WAR FAILED
    exit /b 1
)
echo BUILD OK: %WAR%
endlocal
