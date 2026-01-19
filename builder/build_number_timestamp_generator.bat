@echo off
setlocal ENABLEDELAYEDEXPANSION

rem === CONFIGURATION ===
set "OUTPUT_FILE=01-version-aliases.filter"

rem === GET CURRENT BUILD NUMBER FROM EXISTING FILE OR START AT 1 ===
if exist "%OUTPUT_FILE%" (
    for /f "tokens=3" %%i in ('findstr "FILTER_BUILDNUM" "%OUTPUT_FILE%"') do set CURRENT_BUILDNUM=%%i
    if "%CURRENT_BUILDNUM%"=="" set CURRENT_BUILDNUM=0
) else (
    set CURRENT_BUILDNUM=0
)

set /a NEW_BUILDNUM=CURRENT_BUILDNUM+1

rem === GET FORMATTED TIMESTAMP LIKE Nov/25th/25 ===
for /f "usebackq delims=" %%T in (`
    powershell -NoLogo -NoProfile -Command ^
      "$now = Get-Date; " ^
      "$day = $now.Day; " ^
      "if ($day -ge 11 -and $day -le 13) { $suffix = 'th' } " ^
      "else { " ^
      "  switch ($day %% 10) { " ^
      "    1 { $suffix = 'st'; break } " ^
      "    2 { $suffix = 'nd'; break } " ^
      "    3 { $suffix = 'rd'; break } " ^
      "    default { $suffix = 'th' } " ^
      "  } " ^
      "} " ^
      "$month = $now.ToString('MMM'); " ^
      "$year = $now.ToString('yy'); " ^
      "Write-Output ('{0}/{1}{2}/{3}' -f $month, $day, $suffix, $year)"
`) do (
    set "TIMESTAMP=%%T"
)

rem === DO REPLACEMENT AND WRITE OUTPUT ===
(
    echo #define FILTER_TIMESTAMP %TIMESTAMP%
    echo #define FILTER_BUILDNUM %NEW_BUILDNUM%
) > "%OUTPUT_FILE%"

echo Done.
echo Timestamp: %TIMESTAMP%
echo Build #:   %NEW_BUILDNUM%

endlocal
