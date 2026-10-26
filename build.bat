@echo off
setlocal
cd /d "%~dp0"
set "TEMP=%CD%\build\temp"
set "TMP=%TEMP%"
set "STREAMLINE_SDK=external\streamline-2.14.16"
set "NVAPI_SDK=external\nvapi\nvapi-main"
if not exist build\temp mkdir build\temp
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-dependencies.ps1"
if errorlevel 1 exit /b 1
where cl >nul 2>&1
if not errorlevel 1 goto compile
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%VSWHERE%" exit /b 1
for /f "usebackq tokens=*" %%i in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "VS_PATH=%%i"
if not defined VS_PATH exit /b 1
call "%VS_PATH%\VC\Auxiliary\Build\vcvars64.bat"
if errorlevel 1 exit /b %errorlevel%
:compile
if not exist bin mkdir bin
cl /Fo:build\ /LD /EHsc /std:c++17 /O2 ^
    /DUNICODE /D_UNICODE /DWIN32_LEAN_AND_MEAN /DNOMINMAX ^
    /I. ^
    /I"local_headers" ^
    /I"%STREAMLINE_SDK%\include" ^
    /I"%NVAPI_SDK%" ^
    /I"external\imgui" ^
    /Fe:bin\dxgi.dll ^
    main.cpp ^
    src\proxy.cpp ^
    src\dxgi_wrappers.cpp ^
    src\d3d12_wrappers.cpp ^
    src\streamline_integration.cpp ^
    src\resource_detector.cpp ^
    src\crash_handler.cpp ^
    src\config_manager.cpp ^
    src\imgui_overlay.cpp ^
    src\hooks.cpp ^
    src\input_handler.cpp ^
    src\pattern_scanner.cpp ^
    src\iat_utils.cpp ^
    external\imgui\imgui.cpp ^
    external\imgui\imgui_draw.cpp ^
    external\imgui\imgui_tables.cpp ^
    external\imgui\imgui_widgets.cpp ^
    external\imgui\imgui_demo.cpp ^
    external\imgui\backends\imgui_impl_dx12.cpp ^
    external\imgui\backends\imgui_impl_win32.cpp ^
    /link ^
    d3d12.lib dxgi.lib dxguid.lib user32.lib dbghelp.lib gdi32.lib shell32.lib Advapi32.lib ^
    "%STREAMLINE_SDK%\lib\x64\sl.interposer.lib" ^
    "%NVAPI_SDK%\amd64\nvapi64.lib" ^
    /DEF:dxgi.def ^
    /DLL


if errorlevel 1 exit /b 1
copy /y "%STREAMLINE_SDK%\bin\x64\sl.*.dll" bin\ >nul
if errorlevel 1 exit /b 1
copy /y "%STREAMLINE_SDK%\bin\x64\nvngx_*.dll" bin\ >nul
if errorlevel 1 exit /b 1
copy /y "%STREAMLINE_SDK%\license.txt" bin\Streamline-LICENSE.txt >nul
copy /y "%STREAMLINE_SDK%\3rd-party-licenses.md" bin\Streamline-3rd-party-licenses.md >nul
copy /y "external\nvapi\nvapi-main\License.txt" bin\NVAPI-LICENSE.txt >nul
copy /y LICENSE bin\Mod-LICENSE.txt >nul
copy /y "%STREAMLINE_SDK%\bin\x64\*.license.txt" bin\ >nul
echo Build complete: bin\dxgi.dll. Game files and registry were not changed.
exit /b 0
