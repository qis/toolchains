@echo off
if "%__VS_VCVARS64%"=="1" goto :call

set __VS_LOCATION=%ProgramFiles(x86)%\Microsoft Visual Studio\2019
set __VS_EDITIONS=Enterprise,Professional,Community

for %%i in (%__VS_EDITIONS%) do (
  if exist "%__VS_LOCATION%\%%i\VC\Auxiliary\Build\vcvarsall.bat" (
    call "%__VS_LOCATION%\%%i\VC\Auxiliary\Build\vcvarsall.bat" x64
    set __VS_VCVARS64=1
    goto :done
  )
)

:done
set __VS_LOCATION=
set __VS_EDITIONS=

:call
pushd %~dp0
nmake /nologo system=windows %*
popd

:exit
