@echo off
REM =============================================================================
REM SUPER-CRAB-V1 - Windows Batch Installation Script
REM Author: Ian Carter Kulani, MSc
REM Version: 1.0.0
REM =============================================================================

setlocal EnableDelayedExpansion

REM Configuration
set "SCRIPT_DIR=%~dp0"
set "VENV_DIR=%SCRIPT_DIR%venv"
set "PYTHON_CMD="
set "SKIP_VENV=false"
set "SKIP_DEPS=false"

REM =============================================================================
REM BANNER
REM =============================================================================
echo.
echo ================================================================================
echo.
echo    ███████╗██╗   ██╗██████╗ ███████╗██████╗      ██████╗██████╗  █████╗ ██████╗
echo    ██╔════╝██║   ██║██╔══██╗██╔════╝██╔══██╗    ██╔════╝██╔══██╗██╔══██╗██╔══██╗
echo    ███████╗██║   ██║██████╔╝█████╗  ██████╔╝    ██║     ██████╔╝███████║██████╔╝
echo    ╚════██║██║   ██║██╔═══╝ ██╔══╝  ██╔══██╗    ██║     ██╔══██╗██╔══██║██╔══██╗
echo    ███████║╚██████╔╝██║     ███████╗██║  ██║    ╚██████╗██║  ██║██║  ██║██████╔╝
echo    ╚══════╝ ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═╝     ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝
echo.
echo                     SUPER-CRAB-V1 - Installation Script
echo                          Author: Ian Carter Kulani, MSc
echo                               Version: 1.0.0
echo.
echo ================================================================================
echo.

REM =============================================================================
REM UTILITY FUNCTIONS
REM =============================================================================
:log_info
echo [INFO] %~1
goto :eof

:log_warn
echo [WARN] %~1
goto :eof

:log_error
echo [ERROR] %~1
goto :eof

:log_step
echo.
echo [STEP] %~1
goto :eof

REM =============================================================================
REM PYTHON DETECTION
REM =============================================================================
:find_python
call :log_step "Detecting Python installation..."

for %%p in (python3.12 python3.11 python3.10 python3.9 python3.8 python3 python) do (
    where %%p >nul 2>&1
    if !errorlevel! equ 0 (
        for /f "tokens=2" %%v in ('%%p --version 2^>^&1') do set "PY_VERSION=%%v"
        set "PYTHON_CMD=%%p"
        call :log_info "Found %%p (version !PY_VERSION!)"
        goto :python_found
    )
)

call :log_error "Python 3.7+ not found. Please install Python 3.7 or higher."
echo.
echo Download from: https://www.python.org/downloads/
echo.
pause
exit /b 1

:python_found
goto :eof

REM =============================================================================
REM VIRTUAL ENVIRONMENT
REM =============================================================================
:create_venv
if "%SKIP_VENV%"=="true" (
    call :log_info "Skipping virtual environment creation"
    goto :eof
)

call :log_step "Creating virtual environment..."

if exist "%VENV_DIR%" (
    call :log_warn "Virtual environment already exists at %VENV_DIR%"
    set /p "RECREATE=Recreate? (y/n): "
    if /i "!RECREATE!"=="y" (
        rmdir /s /q "%VENV_DIR%"
    ) else (
        call :log_info "Using existing virtual environment"
        call "%VENV_DIR%\Scripts\activate.bat"
        goto :eof
    )
)

%PYTHON_CMD% -m venv "%VENV_DIR%"
call "%VENV_DIR%\Scripts\activate.bat"

call :log_info "Virtual environment created at %VENV_DIR%"
goto :eof

REM =============================================================================
REM PYTHON DEPENDENCIES
REM =============================================================================
:install_python_deps
if "%SKIP_DEPS%"=="true" (
    call :log_info "Skipping Python dependencies"
    goto :eof
)

call :log_step "Installing Python dependencies..."

REM Upgrade pip
python -m pip install --upgrade pip setuptools wheel

REM Install requirements
if exist "%SCRIPT_DIR%requirements.txt" (
    call :log_info "Installing from requirements.txt..."
    pip install -r "%SCRIPT_DIR%requirements.txt"
) else (
    call :log_warn "requirements.txt not found. Installing core packages..."
    pip install ^
        colorama ^
        psutil ^
        requests ^
        cryptography ^
        paramiko ^
        scapy ^
        dnspython ^
        whois ^
        flask ^
        flask-socketio ^
        flask-cors ^
        discord.py ^
        telethon ^
        slack-sdk ^
        selenium ^
        webdriver-manager ^
        reportlab ^
        pynput ^
        pyperclip ^
        pyautogui ^
        qrcode ^
        pillow ^
        beautifulsoup4 ^
        numpy ^
        matplotlib ^
        tqdm ^
        tabulate ^
        rich
)

call :log_info "Python dependencies installed"
goto :eof

REM =============================================================================
REM VERIFICATION
REM =============================================================================
:verify_installation
call :log_step "Verifying installation..."

if exist "%SCRIPT_DIR%requirements-check.py" (
    python "%SCRIPT_DIR%requirements-check.py"
) else (
    call :log_info "Checking core imports..."
    
    python -c "import colorama; import psutil; import requests; import cryptography; import paramiko; import scapy; import flask; print('All core packages imported successfully!')"
    
    if !errorlevel! neq 0 (
        call :log_error "Some packages failed to import"
        goto :eof
    )
    
    call :log_info "All core packages installed successfully!"
)
goto :eof

REM =============================================================================
REM CREATE LAUNCHER
REM =============================================================================
:create_launcher
call :log_step "Creating launcher script..."

(
echo @echo off
echo REM SUPER-CRAB-V1 Launcher
echo.
echo set "SCRIPT_DIR=%%~dp0"
echo set "VENV_DIR=%%SCRIPT_DIR%%venv"
echo.
echo if exist "%%VENV_DIR%%" (
echo     call "%%VENV_DIR%%\Scripts\activate.bat"
echo ^)
echo.
echo python "%%SCRIPT_DIR%%super_crab_v1.py" %%*
) > "%SCRIPT_DIR%run.bat"

call :log_info "Launcher created at %SCRIPT_DIR%run.bat"
goto :eof

REM =============================================================================
REM USAGE
REM =============================================================================
:usage
echo Usage: %~nx0 [OPTIONS]
echo.
echo Options:
echo   -h, --help              Show this help message
echo   --no-venv               Skip virtual environment creation
echo   --no-deps               Skip Python dependencies installation
echo.
echo Examples:
echo   %~nx0                   # Standard installation
echo   %~nx0 --no-venv         # Install in system Python
echo.
goto :eof

REM =============================================================================
REM MAIN
REM =============================================================================

REM Parse arguments
:parse_args
if "%~1"=="" goto :start_install
if /i "%~1"=="-h" goto :show_usage
if /i "%~1"=="--help" goto :show_usage
if /i "%~1"=="--no-venv" set "SKIP_VENV=true"
if /i "%~1"=="--no-deps" set "SKIP_DEPS=true"
shift
goto :parse_args

:show_usage
call :usage
pause
exit /b 0

:start_install
call :log_info "Starting SUPER-CRAB-V1 installation..."
call :log_info "Installation directory: %SCRIPT_DIR%"

REM Detect Python
call :find_python

REM Create virtual environment
call :create_venv

REM Install Python dependencies
call :install_python_deps

REM Create launcher
call :create_launcher

REM Verify installation
call :verify_installation

REM Success message
echo.
echo ================================================================================
echo                     INSTALLATION COMPLETE!
echo ================================================================================
echo.
echo To run SUPER-CRAB-V1:
echo   cd %SCRIPT_DIR%
echo   run.bat
echo.
echo Or manually:
if "%SKIP_VENV%"=="false" (
    echo   venv\Scripts\activate.bat
)
echo   python super_crab_v1.py
echo.

pause
exit /b 0
