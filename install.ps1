# =============================================================================
# SUPER-CRAB-V1 - PowerShell Installation Script
# Author: Ian Carter Kulani, MSc
# Version: 1.0.0
# =============================================================================

#Requires -Version 5.1

[CmdletBinding()]
param(
    [switch]$NoVenv,
    [switch]$NoDeps,
    [switch]$InstallSystemTools,
    [switch]$All,
    [switch]$Help
)

# =============================================================================
# CONFIGURATION
# =============================================================================
$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$VenvDir = Join-Path $ScriptDir "venv"
$PythonCmd = $null
$SkipVenv = $NoVenv
$SkipDeps = $NoDeps

# =============================================================================
# COLORS
# =============================================================================
function Write-Info { param($Message) Write-Host "[INFO] $Message" -ForegroundColor Green }
function Write-Warn { param($Message) Write-Host "[WARN] $Message" -ForegroundColor Yellow }
function Write-ErrorMsg { param($Message) Write-Host "[ERROR] $Message" -ForegroundColor Red }
function Write-Step { param($Message) Write-Host "`n[STEP] $Message" -ForegroundColor Cyan }
function Write-Success { param($Message) Write-Host $Message -ForegroundColor Green }

# =============================================================================
# BANNER
# =============================================================================
function Show-Banner {
    Write-Host @"

================================================================================

   ███████╗██╗   ██╗██████╗ ███████╗██████╗      ██████╗██████╗  █████╗ ██████╗
   ██╔════╝██║   ██║██╔══██╗██╔════╝██╔══██╗    ██╔════╝██╔══██╗██╔══██╗██╔══██╗
   ███████╗██║   ██║██████╔╝█████╗  ██████╔╝    ██║     ██████╔╝███████║██████╔╝
   ╚════██║██║   ██║██╔═══╝ ██╔══╝  ██╔══██╗    ██║     ██╔══██╗██╔══██║██╔══██╗
   ███████║╚██████╔╝██║     ███████╗██║  ██║    ╚██████╗██║  ██║██║  ██║██████╔╝
   ╚══════╝ ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═╝     ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝

                    SUPER-CRAB-V1 - Installation Script
                         Author: Ian Carter Kulani, MSc
                              Version: 1.0.0

================================================================================

"@ -ForegroundColor Cyan
}

# =============================================================================
# PYTHON DETECTION
# =============================================================================
function Find-Python {
    Write-Step "Detecting Python installation..."
    
    $pythonCommands = @("python3.12", "python3.11", "python3.10", "python3.9", "python3.8", "python3", "python")
    
    foreach ($cmd in $pythonCommands) {
        try {
            $result = & $cmd --version 2>&1
            if ($result -match "Python (\d+)\.(\d+)") {
                $major = [int]$Matches[1]
                $minor = [int]$Matches[2]
                
                if ($major -ge 3 -and $minor -ge 7) {
                    $script:PythonCmd = $cmd
                    Write-Info "Found $cmd ($result)"
                    return $true
                }
            }
        }
        catch {
            continue
        }
    }
    
    Write-ErrorMsg "Python 3.7+ not found. Please install Python 3.7 or higher."
    Write-Host "Download from: https://www.python.org/downloads/" -ForegroundColor Yellow
    return $false
}

# =============================================================================
# SYSTEM DEPENDENCIES
# =============================================================================
function Install-SystemDeps {
    Write-Step "Checking system dependencies..."
    
    # Check for Chocolatey
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Warn "Chocolatey not found. Installing..."
        
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    }
    
    # Install tools via Chocolatey
    $tools = @(
        @{Name="nmap"; Package="nmap"},
        @{Name="curl"; Package="curl"},
        @{Name="wget"; Package="wget"},
        @{Name="git"; Package="git"},
        @{Name="netcat"; Package="netcat"},
        @{Name="hashcat"; Package="hashcat"}
    )
    
    foreach ($tool in $tools) {
        if (-not (Get-Command $tool.Name -ErrorAction SilentlyContinue)) {
            Write-Info "Installing $($tool.Name)..."
            choco install $tool.Package -y
        }
        else {
            Write-Info "$($tool.Name) already installed"
        }
    }
    
    Write-Info "System dependencies installed"
}

# =============================================================================
# VIRTUAL ENVIRONMENT
# =============================================================================
function Create-Venv {
    if ($SkipVenv) {
        Write-Info "Skipping virtual environment creation"
        return
    }
    
    Write-Step "Creating virtual environment..."
    
    if (Test-Path $VenvDir) {
        Write-Warn "Virtual environment already exists at $VenvDir"
        $recreate = Read-Host "Recreate? (y/n)"
        
        if ($recreate -eq "y") {
            Remove-Item -Recurse -Force $VenvDir
        }
        else {
            Write-Info "Using existing virtual environment"
            & "$VenvDir\Scripts\Activate.ps1"
            return
        }
    }
    
    & $script:PythonCmd -m venv $VenvDir
    & "$VenvDir\Scripts\Activate.ps1"
    
    Write-Info "Virtual environment created at $VenvDir"
}

# =============================================================================
# PYTHON DEPENDENCIES
# =============================================================================
function Install-PythonDeps {
    if ($SkipDeps) {
        Write-Info "Skipping Python dependencies"
        return
    }
    
    Write-Step "Installing Python dependencies..."
    
    # Upgrade pip
    python -m pip install --upgrade pip setuptools wheel
    
    # Install requirements
    $requirementsFile = Join-Path $ScriptDir "requirements.txt"
    
    if (Test-Path $requirementsFile) {
        Write-Info "Installing from requirements.txt..."
        pip install -r $requirementsFile
    }
    else {
        Write-Warn "requirements.txt not found. Installing core packages..."
        
        $packages = @(
            "colorama", "psutil", "requests", "cryptography", "paramiko",
            "scapy", "dnspython", "whois", "flask", "flask-socketio",
            "flask-cors", "discord.py", "telethon", "slack-sdk",
            "selenium", "webdriver-manager", "reportlab", "pynput",
            "pyperclip", "pyautogui", "qrcode", "pillow",
            "beautifulsoup4", "numpy", "matplotlib", "tqdm", "tabulate", "rich"
        )
        
        foreach ($pkg in $packages) {
            Write-Info "Installing $pkg..."
            pip install $pkg
        }
    }
    
    Write-Info "Python dependencies installed"
}

# =============================================================================
# VERIFICATION
# =============================================================================
function Verify-Installation {
    Write-Step "Verifying installation..."
    
    $checkerFile = Join-Path $ScriptDir "requirements-check.py"
    
    if (Test-Path $checkerFile) {
        python $checkerFile
    }
    else {
        Write-Info "Checking core imports..."
        
        $checkScript = @"
import sys
packages = ['colorama', 'psutil', 'requests', 'cryptography', 'paramiko', 'scapy', 'flask']
missing = []
for pkg in packages:
    try:
        __import__(pkg)
        print(f'  OK {pkg}')
    except ImportError:
        missing.append(pkg)
        print(f'  FAIL {pkg}')

if missing:
    print(f'\nMissing packages: {" ".join(missing)}')
    sys.exit(1)
else:
    print('\nAll core packages installed successfully!')
"@
        
        $checkScript | python -
    }
}

# =============================================================================
# CREATE LAUNCHER
# =============================================================================
function Create-Launcher {
    Write-Step "Creating launcher script..."
    
    $launcherContent = @"
@echo off
REM SUPER-CRAB-V1 Launcher

set "SCRIPT_DIR=%~dp0"
set "VENV_DIR=%SCRIPT_DIR%venv"

if exist "%VENV_DIR%" (
    call "%VENV_DIR%\Scripts\activate.bat"
)

python "%SCRIPT_DIR%super_crab_v1.py" %*
"@
    
    $launcherPath = Join-Path $ScriptDir "run.bat"
    $launcherContent | Out-File -FilePath $launcherPath -Encoding ASCII
    
    Write-Info "Launcher created at $launcherPath"
}

# =============================================================================
# USAGE
# =============================================================================
function Show-Usage {
    Write-Host @"
Usage: .\install.ps1 [OPTIONS]

Options:
  -Help                   Show this help message
  -NoVenv                 Skip virtual environment creation
  -NoDeps                 Skip Python dependencies installation
  -InstallSystemTools     Install system tools via Chocolatey
  -All                    Install everything

Examples:
  .\install.ps1                   # Standard installation
  .\install.ps1 -NoVenv           # Install in system Python
  .\install.ps1 -All              # Install everything

"@
}

# =============================================================================
# MAIN
# =============================================================================
function Main {
    if ($Help) {
        Show-Usage
        return
    }
    
    Show-Banner
    
    Write-Info "Starting SUPER-CRAB-V1 installation..."
    Write-Info "Installation directory: $ScriptDir"
    
    # Detect Python
    if (-not (Find-Python)) {
        exit 1
    }
    
    # Install system dependencies if requested
    if ($InstallSystemTools -or $All) {
        Install-SystemDeps
    }
    
    # Create virtual environment
    Create-Venv
    
    # Install Python dependencies
    Install-PythonDeps
    
    # Create launcher
    Create-Launcher
    
    # Verify installation
    Verify-Installation
    
    # Success message
    Write-Host ""
    Write-Success @"
================================================================================
                     INSTALLATION COMPLETE!
================================================================================

To run SUPER-CRAB-V1:
  cd $ScriptDir
  .\run.bat

Or manually:
"@
    
    if (-not $SkipVenv) {
        Write-Host "  .\venv\Scripts\Activate.ps1" -ForegroundColor Green
    }
    Write-Host "  python super_crab_v1.py" -ForegroundColor Green
    Write-Host ""
}

# Run main
Main
