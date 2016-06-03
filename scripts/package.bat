@echo off

SET PACKAGED_NODE_VERSION=v4.4.4

FOR /F "delims=" %%i in ('node --version') do call SET NODE_VERSION=%%i
FOR /F "delims=" %%i in ('node scripts/details.js COMMIT') do call SET COMMIT=%%i
FOR /F "delims=" %%i in ('node scripts/details.js NAME') do call SET PACKAGE_NAME=%%i
FOR /F "delims=" %%i in ('node scripts/details.js VERSION') do call SET PACKAGE_VERSION=%%i

:: Clean the build directory
RMDIR /S /Q build
MKDIR build
MKDIR build\%PACKAGE_VERSION%

if /I NOT %NODE_VERSION% == %PACKAGED_NODE_VERSION% (
	echo Packaging only done on %PACKAGED_NODE_VERSION%
	EXIT /B
)

SET FILE_NAME=%PACKAGE_NAME%-windows-%PACKAGE_VERSION%-%COMMIT%.zip
SET CLEAN_FILE_NAME=%PACKAGE_NAME%-windows.zip
ECHO %FILE_NAME%

:: Do a git archive and a production install
:: to have cleanest output
git archive --format=zip %COMMIT% -o build\%PACKAGE_VERSION%\temp.zip

CD build\%PACKAGE_VERSION%
7z e temp.zip -o%cd%\%PACKAGE_NAME%

CD %PACKAGE_NAME%
call npm install --production
ECHO 'Installed NPM Dependencies'

ECHO 'Creating artificat'
7z a ..\%FILE_NAME% .

CD ..
COPY %cd%\%FILE_NAME% %cd%\%CLEAN_FILE_NAME%

:: Cleanup
RMDIR /S /Q %PACKAGE_NAME%
DEL /Q temp.zip

ECHO 'Done'

cd ../..