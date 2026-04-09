@echo off
SETLOCAL

REM Define the directory path and file pattern
SET "SearchDir=D:\Anovo\Projects\Misc\36760\CT1\Tokenization"
SET "FilePattern=datavant_tokenize_*.log"
SET "NewestFile="

REM Use FOR /F to parse the output of DIR
REM Options used in DIR:
REM /A-D : Only files (no directories)
REM /B   : Bare format (just filenames)
REM /O-D : Order by Date/Time, newest first
REM /TW  : Use file Last Write Time for sorting
FOR /F "eol=| delims=" %%I IN ('DIR "%SearchDir%\%FilePattern%" /A-D /B /O-D /TW 2^>nul') DO (
    SET "NewestFile=%%I"
    GOTO FoundFile
)

:FoundFile

	SET "log_file = %SearchDir%\%NewestFile%"
	
	ECHO Newest log file is: "%LogFile%"
	
	REM set "log_file=D:\Anovo\Projects\Misc\36760\CT1\Tokenization\datavant_tokenize_20260310T183914.log"
	set "search_string=ERROR"

	FINDSTR /C:"%search_string%" "%log_file%" >nul
	if %ERRORLEVEL% equ 0 (
		echo An error string was found in the log file.
		REM Add commands here to handle the error condition
	) else (
		echo The specified string was not found.
		REM Add commands here for no error condition
	)


ENDLOCAL
