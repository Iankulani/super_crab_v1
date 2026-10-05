#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║   SUPER-CRAB-V1 - Requirements Checker                                       ║
║   Author: Ian Carter Kulani, MSc                                             ║
║   Version: 1.0.0                                                             ║
║                                                                              ║
║   This script checks all required dependencies and system tools              ║
║   for SUPER-CRAB-V1 to function properly.                                    ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
"""

import os
import sys
import shutil
import subprocess
import platform
import importlib
from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass, field
from enum import Enum

# =====================
# VERSION INFO
# =====================
VERSION = "1.0.0"
NAME = "SUPER-CRAB-V1"

# =====================
# COLORS
# =====================
class Colors:
    RESET = '\033[0m'
    BOLD = '\033[1m'
    DIM = '\033[2m'
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    MAGENTA = '\033[95m'
    CYAN = '\033[96m'
    WHITE = '\033[97m'

# =====================
# DEPENDENCY DEFINITIONS
# =====================
@dataclass
class PythonPackage:
    name: str
    import_name: str
    min_version: Optional[str] = None
    required: bool = True
    description: str = ""
    category: str = "General"

@dataclass
class SystemTool:
    name: str
    command: str
    required: bool = True
    description: str = ""
    install_hint: Dict[str, str] = field(default_factory=dict)

# =====================
# PYTHON PACKAGES
# =====================
PYTHON_PACKAGES = [
    # Core
    PythonPackage("colorama", "colorama", "0.4.6", True, "Terminal colors", "Core"),
    PythonPackage("psutil", "psutil", "5.9.0", True, "System monitoring", "Core"),
    PythonPackage("requests", "requests", "2.31.0", True, "HTTP library", "Core"),
    PythonPackage("pyyaml", "yaml", "6.0", True, "YAML parser", "Core"),
    PythonPackage("python-dotenv", "dotenv", "1.0.0", True, "Environment variables", "Core"),
    
    # Cryptography
    PythonPackage("cryptography", "cryptography", "41.0.0", True, "Cryptography", "Security"),
    PythonPackage("pycryptodome", "Crypto", "3.19.0", True, "Cryptographic library", "Security"),
    PythonPackage("passlib", "passlib", "1.7.4", False, "Password hashing", "Security"),
    PythonPackage("bcrypt", "bcrypt", "4.0.1", False, "Bcrypt hashing", "Security"),
    
    # Networking
    PythonPackage("scapy", "scapy", "2.5.0", True, "Packet manipulation", "Network"),
    PythonPackage("paramiko", "paramiko", "3.3.0", True, "SSH library", "Network"),
    PythonPackage("dnspython", "dns", "2.4.0", True, "DNS toolkit", "Network"),
    PythonPackage("whois", "whois", "0.9.27", True, "WHOIS lookup", "Network"),
    PythonPackage("netaddr", "netaddr", "0.9.0", False, "Network address manipulation", "Network"),
    PythonPackage("pyshorteners", "pyshorteners", "1.0.1", False, "URL shortening", "Network"),
    
    # Web & API
    PythonPackage("flask", "flask", "2.3.0", True, "Web framework", "Web"),
    PythonPackage("flask-socketio", "flask_socketio", "5.3.0", True, "WebSocket support", "Web"),
    PythonPackage("flask-cors", "flask_cors", "4.0.0", True, "CORS support", "Web"),
    PythonPackage("gunicorn", "gunicorn", "21.2.0", False, "WSGI server", "Web"),
    
    # Bot Integrations
    PythonPackage("discord.py", "discord", "2.3.0", True, "Discord bot", "Bots"),
    PythonPackage("telethon", "telethon", "1.31.0", True, "Telegram client", "Bots"),
    PythonPackage("slack-sdk", "slack_sdk", "3.23.0", True, "Slack SDK", "Bots"),
    
    # Google
    PythonPackage("google-auth", "google.auth", "2.23.0", True, "Google authentication", "Google"),
    PythonPackage("google-api-python-client", "googleapiclient", "2.100.0", True, "Google API client", "Google"),
    
    # Selenium
    PythonPackage("selenium", "selenium", "4.15.0", True, "Browser automation", "Automation"),
    PythonPackage("webdriver-manager", "webdriver_manager", "4.0.0", True, "WebDriver manager", "Automation"),
    
    # Data Processing
    PythonPackage("numpy", "numpy", "1.24.0", True, "Numerical computing", "Data"),
    PythonPackage("pandas", "pandas", "2.0.0", False, "Data analysis", "Data"),
    PythonPackage("beautifulsoup4", "bs4", "4.12.0", True, "HTML parsing", "Data"),
    
    # Visualization
    PythonPackage("matplotlib", "matplotlib", "3.7.0", True, "Plotting library", "Visualization"),
    PythonPackage("seaborn", "seaborn", "0.12.0", False, "Statistical visualization", "Visualization"),
    
    # PDF & Documents
    PythonPackage("reportlab", "reportlab", "4.0.0", True, "PDF generation", "Documents"),
    PythonPackage("python-docx", "docx", "1.0.0", False, "Word documents", "Documents"),
    
    # Keylogger
    PythonPackage("pynput", "pynput", "1.7.6", True, "Keyboard/mouse control", "Keylogger"),
    PythonPackage("pyperclip", "pyperclip", "1.8.2", True, "Clipboard access", "Keylogger"),
    PythonPackage("pyautogui", "pyautogui", "0.9.54", True, "GUI automation", "Keylogger"),
    
    # QR & Barcode
    PythonPackage("qrcode", "qrcode", "7.4.2", False, "QR code generation", "Utilities"),
    PythonPackage("pillow", "PIL", "10.1.0", True, "Image processing", "Utilities"),
    
    # Database
    PythonPackage("sqlalchemy", "sqlalchemy", "2.0.0", False, "SQL toolkit", "Database"),
    PythonPackage("redis", "redis", "5.0.0", False, "Redis client", "Database"),
    
    # Security
    PythonPackage("pyjwt", "jwt", "2.8.0", False, "JWT tokens", "Security"),
    PythonPackage("pyotp", "pyotp", "2.9.0", False, "OTP generation", "Security"),
    
    # Utilities
    PythonPackage("tqdm", "tqdm", "4.66.0", True, "Progress bars", "Utilities"),
    PythonPackage("tabulate", "tabulate", "0.9.0", True, "Table formatting", "Utilities"),
    PythonPackage("rich", "rich", "13.7.0", True, "Rich text", "Utilities"),
    PythonPackage("click", "click", "8.1.0", True, "CLI framework", "Utilities"),
]

# =====================
# SYSTEM TOOLS
# =====================
SYSTEM_TOOLS = [
    SystemTool(
        "nmap", "nmap", True,
        "Network scanning tool",
        {
            "linux": "sudo apt-get install nmap",
            "darwin": "brew install nmap",
            "windows": "choco install nmap"
        }
    ),
    SystemTool(
        "curl", "curl", True,
        "HTTP client",
        {
            "linux": "sudo apt-get install curl",
            "darwin": "brew install curl",
            "windows": "choco install curl"
        }
    ),
    SystemTool(
        "wget", "wget", True,
        "File downloader",
        {
            "linux": "sudo apt-get install wget",
            "darwin": "brew install wget",
            "windows": "choco install wget"
        }
    ),
    SystemTool(
        "netcat", "nc", False,
        "Network utility",
        {
            "linux": "sudo apt-get install netcat",
            "darwin": "brew install netcat",
            "windows": "choco install netcat"
        }
    ),
    SystemTool(
        "dig", "dig", False,
        "DNS lookup utility",
        {
            "linux": "sudo apt-get install dnsutils",
            "darwin": "brew install bind",
            "windows": "choco install bind-toolsonly"
        }
    ),
    SystemTool(
        "traceroute", "traceroute", False,
        "Network path tracing",
        {
            "linux": "sudo apt-get install traceroute",
            "darwin": "brew install traceroute",
            "windows": "tracert (built-in)"
        }
    ),
    SystemTool(
        "nikto", "nikto", False,
        "Web vulnerability scanner",
        {
            "linux": "sudo apt-get install nikto",
            "darwin": "brew install nikto",
            "windows": "choco install nikto"
        }
    ),
    SystemTool(
        "docker", "docker", False,
        "Container platform",
        {
            "linux": "sudo apt-get install docker.io",
            "darwin": "brew install docker",
            "windows": "choco install docker-desktop"
        }
    ),
    SystemTool(
        "msfconsole", "msfconsole", False,
        "Metasploit Framework",
        {
            "linux": "curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && chmod 755 msfinstall && ./msfinstall",
            "darwin": "brew install metasploit",
            "windows": "Download from https://www.metasploit.com/download"
        }
    ),
    SystemTool(
        "hashcat", "hashcat", False,
        "Password recovery tool",
        {
            "linux": "sudo apt-get install hashcat",
            "darwin": "brew install hashcat",
            "windows": "choco install hashcat"
        }
    ),
    SystemTool(
        "signal-cli", "signal-cli", False,
        "Signal messaging CLI",
        {
            "linux": "Download from https://github.com/AsamK/signal-cli/releases",
            "darwin": "brew install signal-cli",
            "windows": "Download from https://github.com/AsamK/signal-cli/releases"
        }
    ),
    SystemTool(
        "openssl", "openssl", True,
        "SSL/TLS toolkit",
        {
            "linux": "sudo apt-get install openssl",
            "darwin": "brew install openssl",
            "windows": "choco install openssl"
        }
    ),
    SystemTool(
        "ssh", "ssh", True,
        "SSH client",
        {
            "linux": "sudo apt-get install openssh-client",
            "darwin": "Built-in",
            "windows": "choco install openssh"
        }
    ),
    SystemTool(
        "git", "git", True,
        "Version control",
        {
            "linux": "sudo apt-get install git",
            "darwin": "brew install git",
            "windows": "choco install git"
        }
    ),
]

# =====================
# CHECKER CLASS
# =====================
class RequirementsChecker:
    def __init__(self):
        self.system = platform.system().lower()
        self.python_version = sys.version_info
        self.results = {
            "python": {"status": "unknown", "details": ""},
            "packages": {"installed": [], "missing": [], "outdated": []},
            "tools": {"installed": [], "missing": []},
            "system": {"status": "unknown", "details": ""}
        }
    
    def print_banner(self):
        banner = f"""
{Colors.CYAN}╔══════════════════════════════════════════════════════════════════════════════╗
║{Colors.WHITE}                                                                              {Colors.CYAN}║
║{Colors.WHITE}   ███████╗██╗   ██╗██████╗ ███████╗██████╗      ██████╗██████╗  █████╗ ██████╗ {Colors.CYAN}║
║{Colors.WHITE}   ██╔════╝██║   ██║██╔══██╗██╔════╝██╔══██╗    ██╔════╝██╔══██╗██╔══██╗██╔══██╗{Colors.CYAN}║
║{Colors.WHITE}   ███████╗██║   ██║██████╔╝█████╗  ██████╔╝    ██║     ██████╔╝███████║██████╔╝{Colors.CYAN}║
║{Colors.WHITE}   ╚════██║██║   ██║██╔═══╝ ██╔══╝  ██╔══██╗    ██║     ██╔══██╗██╔══██║██╔══██╗{Colors.CYAN}║
║{Colors.WHITE}   ███████║╚██████╔╝██║     ███████╗██║  ██║    ╚██████╗██║  ██║██║  ██║██████╔╝{Colors.CYAN}║
║{Colors.WHITE}   ╚══════╝ ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═╝     ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ {Colors.CYAN}║
║{Colors.WHITE}                                                                              {Colors.CYAN}║
║{Colors.WHITE}                    SUPER-CRAB-V1 - Requirements Checker                      {Colors.CYAN}║
║{Colors.WHITE}                         Author: Ian Carter Kulani, MSc                       {Colors.CYAN}║
║{Colors.WHITE}                              Version: {VERSION}                                   {Colors.CYAN}║
║{Colors.WHITE}                                                                              {Colors.CYAN}║
╚══════════════════════════════════════════════════════════════════════════════╝{Colors.RESET}
"""
        print(banner)
    
    def check_python_version(self) -> bool:
        """Check Python version"""
        print(f"\n{Colors.BOLD}{Colors.CYAN}[*] Checking Python Version...{Colors.RESET}")
        
        version_str = f"{self.python_version.major}.{self.python_version.minor}.{self.python_version.micro}"
        
        if self.python_version >= (3, 7):
            print(f"  {Colors.GREEN}✓{Colors.RESET} Python {version_str} (Required: 3.7+)")
            self.results["python"]["status"] = "ok"
            self.results["python"]["details"] = version_str
            return True
        else:
            print(f"  {Colors.RED}✗{Colors.RESET} Python {version_str} (Required: 3.7+)")
            print(f"    {Colors.YELLOW}Please upgrade Python to 3.7 or higher{Colors.RESET}")
            self.results["python"]["status"] = "error"
            self.results["python"]["details"] = version_str
            return False
    
    def check_python_package(self, package: PythonPackage) -> Tuple[bool, str]:
        """Check if a Python package is installed"""
        try:
            module = importlib.import_module(package.import_name)
            version = getattr(module, '__version__', 'unknown')
            return True, version
        except ImportError:
            return False, ""
    
    def check_all_packages(self) -> Dict:
        """Check all Python packages"""
        print(f"\n{Colors.BOLD}{Colors.CYAN}[*] Checking Python Packages...{Colors.RESET}")
        print(f"  {Colors.DIM}Total packages to check: {len(PYTHON_PACKAGES)}{Colors.RESET}\n")
        
        installed = []
        missing = []
        outdated = []
        
        for package in PYTHON_PACKAGES:
            is_installed, version = self.check_python_package(package)
            
            if is_installed:
                installed.append({
                    "name": package.name,
                    "version": version,
                    "required": package.required,
                    "category": package.category
                })
                
                if package.required:
                    status = f"{Colors.GREEN}✓{Colors.RESET}"
                else:
                    status = f"{Colors.YELLOW}○{Colors.RESET}"
                
                print(f"  {status} {package.name:<25} {Colors.DIM}v{version}{Colors.RESET}")
            else:
                missing.append({
                    "name": package.name,
                    "required": package.required,
                    "category": package.category,
                    "description": package.description
                })
                
                if package.required:
                    status = f"{Colors.RED}✗{Colors.RESET}"
                    print(f"  {status} {package.name:<25} {Colors.RED}MISSING (Required){Colors.RESET}")
                else:
                    status = f"{Colors.YELLOW}○{Colors.RESET}"
                    print(f"  {status} {package.name:<25} {Colors.YELLOW}MISSING (Optional){Colors.RESET}")
        
        self.results["packages"]["installed"] = installed
        self.results["packages"]["missing"] = missing
        self.results["packages"]["outdated"] = outdated
        
        return {
            "installed": len(installed),
            "missing": len(missing),
            "required_missing": len([m for m in missing if m["required"]])
        }
    
    def check_system_tool(self, tool: SystemTool) -> bool:
        """Check if a system tool is installed"""
        return shutil.which(tool.command) is not None
    
    def check_all_tools(self) -> Dict:
        """Check all system tools"""
        print(f"\n{Colors.BOLD}{Colors.CYAN}[*] Checking System Tools...{Colors.RESET}")
        print(f"  {Colors.DIM}Total tools to check: {len(SYSTEM_TOOLS)}{Colors.RESET}\n")
        
        installed = []
        missing = []
        
        for tool in SYSTEM_TOOLS:
            is_installed = self.check_system_tool(tool)
            
            if is_installed:
                installed.append({
                    "name": tool.name,
                    "required": tool.required,
                    "path": shutil.which(tool.command)
                })
                
                if tool.required:
                    status = f"{Colors.GREEN}✓{Colors.RESET}"
                else:
                    status = f"{Colors.YELLOW}○{Colors.RESET}"
                
                print(f"  {status} {tool.name:<25} {Colors.DIM}{shutil.which(tool.command)}{Colors.RESET}")
            else:
                missing.append({
                    "name": tool.name,
                    "required": tool.required,
                    "description": tool.description,
                    "install_hint": tool.install_hint
                })
                
                if tool.required:
                    status = f"{Colors.RED}✗{Colors.RESET}"
                    print(f"  {status} {tool.name:<25} {Colors.RED}MISSING (Required){Colors.RESET}")
                else:
                    status = f"{Colors.YELLOW}○{Colors.RESET}"
                    print(f"  {status} {tool.name:<25} {Colors.YELLOW}MISSING (Optional){Colors.RESET}")
        
        self.results["tools"]["installed"] = installed
        self.results["tools"]["missing"] = missing
        
        return {
            "installed": len(installed),
            "missing": len(missing),
            "required_missing": len([m for m in missing if m["required"]])
        }
    
    def check_system_requirements(self) -> Dict:
        """Check system-level requirements"""
        print(f"\n{Colors.BOLD}{Colors.CYAN}[*] Checking System Requirements...{Colors.RESET}\n")
        
        # Check OS
        os_info = f"{platform.system()} {platform.release()}"
        print(f"  {Colors.GREEN}✓{Colors.RESET} Operating System: {os_info}")
        
        # Check architecture
        arch = platform.machine()
        print(f"  {Colors.GREEN}✓{Colors.RESET} Architecture: {arch}")
        
        # Check CPU cores
        import multiprocessing
        cpu_count = multiprocessing.cpu_count()
        print(f"  {Colors.GREEN}✓{Colors.RESET} CPU Cores: {cpu_count}")
        
        # Check memory
        try:
            import psutil
            mem = psutil.virtual_memory()
            mem_gb = mem.total / (1024**3)
            if mem_gb >= 4:
                print(f"  {Colors.GREEN}✓{Colors.RESET} Memory: {mem_gb:.1f} GB")
            else:
                print(f"  {Colors.YELLOW}⚠{Colors.RESET} Memory: {mem_gb:.1f} GB (4GB+ recommended)")
        except ImportError:
            print(f"  {Colors.YELLOW}⚠{Colors.RESET} Memory: Unable to check (psutil not installed)")
        
        # Check disk space
        try:
            import shutil as sh
            total, used, free = sh.disk_usage('/')
            free_gb = free / (1024**3)
            if free_gb >= 1:
                print(f"  {Colors.GREEN}✓{Colors.RESET} Disk Space: {free_gb:.1f} GB free")
            else:
                print(f"  {Colors.YELLOW}⚠{Colors.RESET} Disk Space: {free_gb:.1f} GB free (1GB+ recommended)")
        except:
            print(f"  {Colors.YELLOW}⚠{Colors.RESET} Disk Space: Unable to check")
        
        # Check network
        try:
            import socket
            socket.create_connection(("8.8.8.8", 53), timeout=3)
            print(f"  {Colors.GREEN}✓{Colors.RESET} Network: Connected")
        except:
            print(f"  {Colors.YELLOW}⚠{Colors.RESET} Network: Not connected")
        
        # Check admin/root
        is_admin = False
        if self.system == 'linux':
            is_admin = os.geteuid() == 0
        elif self.system == 'windows':
            try:
                import ctypes
                is_admin = ctypes.windll.shell32.IsUserAnAdmin() != 0
            except:
                pass
        
        if is_admin:
            print(f"  {Colors.GREEN}✓{Colors.RESET} Privileges: Administrator/Root")
        else:
            print(f"  {Colors.YELLOW}⚠{Colors.RESET} Privileges: User (Admin/Root recommended for full functionality)")
        
        self.results["system"]["status"] = "ok"
        
        return {
            "os": os_info,
            "arch": arch,
            "cpu": cpu_count,
            "is_admin": is_admin
        }
    
    def print_summary(self):
        """Print summary of all checks"""
        print(f"\n{Colors.BOLD}{Colors.CYAN}{'='*60}{Colors.RESET}")
        print(f"{Colors.BOLD}{Colors.CYAN}                    REQUIREMENTS SUMMARY{Colors.RESET}")
        print(f"{Colors.BOLD}{Colors.CYAN}{'='*60}{Colors.RESET}\n")
        
        # Python
        py_status = self.results["python"]["status"]
        py_icon = f"{Colors.GREEN}✓{Colors.RESET}" if py_status == "ok" else f"{Colors.RED}✗{Colors.RESET}"
        print(f"  {py_icon} Python: {self.results['python']['details']}")
        
        # Packages
        pkg_installed = len(self.results["packages"]["installed"])
        pkg_missing = self.results["packages"]["missing"]
        pkg_required_missing = len([m for m in pkg_missing if m["required"]])
        pkg_optional_missing = len([m for m in pkg_missing if not m["required"]])
        
        pkg_icon = f"{Colors.GREEN}✓{Colors.RESET}" if pkg_required_missing == 0 else f"{Colors.RED}✗{Colors.RESET}"
        print(f"\n  {pkg_icon} Python Packages:")
        print(f"      Installed: {pkg_installed}")
        print(f"      Missing (Required): {pkg_required_missing}")
        print(f"      Missing (Optional): {pkg_optional_missing}")
        
        # Tools
        tool_installed = len(self.results["tools"]["installed"])
        tool_missing = self.results["tools"]["missing"]
        tool_required_missing = len([m for m in tool_missing if m["required"]])
        tool_optional_missing = len([m for m in tool_missing if not m["required"]])
        
        tool_icon = f"{Colors.GREEN}✓{Colors.RESET}" if tool_required_missing == 0 else f"{Colors.YELLOW}⚠{Colors.RESET}"
        print(f"\n  {tool_icon} System Tools:")
        print(f"      Installed: {tool_installed}")
        print(f"      Missing (Required): {tool_required_missing}")
        print(f"      Missing (Optional): {tool_optional_missing}")
        
        # Overall status
        print(f"\n{Colors.BOLD}{Colors.CYAN}{'-'*60}{Colors.RESET}")
        
        if pkg_required_missing == 0 and tool_required_missing == 0:
            print(f"\n  {Colors.GREEN}{Colors.BOLD}✓ ALL REQUIRED DEPENDENCIES SATISFIED{Colors.RESET}")
            print(f"  {Colors.GREEN}SUPER-CRAB-V1 is ready to run!{Colors.RESET}")
        else:
            print(f"\n  {Colors.RED}{Colors.BOLD}✗ MISSING REQUIRED DEPENDENCIES{Colors.RESET}")
            print(f"  {Colors.YELLOW}Please install the missing dependencies listed above.{Colors.RESET}")
        
        print(f"\n{Colors.BOLD}{Colors.CYAN}{'='*60}{Colors.RESET}\n")
    
    def print_install_instructions(self):
        """Print installation instructions for missing dependencies"""
        missing_packages = [m for m in self.results["packages"]["missing"] if m["required"]]
        missing_tools = [m for m in self.results["tools"]["missing"] if m["required"]]
        
        if not missing_packages and not missing_tools:
            return
        
        print(f"\n{Colors.BOLD}{Colors.CYAN}INSTALLATION INSTRUCTIONS{Colors.RESET}")
        print(f"{Colors.CYAN}{'-'*60}{Colors.RESET}\n")
        
        if missing_packages:
            print(f"{Colors.BOLD}Missing Python Packages:{Colors.RESET}")
            print(f"  {Colors.GREEN}pip install {' '.join([p['name'] for p in missing_packages])}{Colors.RESET}\n")
            
            print(f"{Colors.BOLD}Or install all requirements:{Colors.RESET}")
            print(f"  {Colors.GREEN}pip install -r requirements.txt{Colors.RESET}\n")
        
        if missing_tools:
            print(f"{Colors.BOLD}Missing System Tools:{Colors.RESET}")
            
            for tool in missing_tools:
                install_cmd = tool["install_hint"].get(self.system, "See documentation")
                print(f"  {Colors.YELLOW}{tool['name']}{Colors.RESET}: {tool['description']}")
                print(f"    Install: {Colors.GREEN}{install_cmd}{Colors.RESET}\n")
    
    def save_report(self, filepath: str = "requirements_report.json"):
        """Save check results to a JSON file"""
        import json
        
        report = {
            "version": VERSION,
            "timestamp": __import__("datetime").datetime.now().isoformat(),
            "system": {
                "os": platform.system(),
                "release": platform.release(),
                "architecture": platform.machine(),
                "python_version": f"{self.python_version.major}.{self.python_version.minor}.{self.python_version.micro}"
            },
            "results": self.results
        }
        
        with open(filepath, 'w') as f:
            json.dump(report, f, indent=2)
        
        print(f"\n{Colors.GREEN}✓ Report saved to: {filepath}{Colors.RESET}")
    
    def run(self, save_report: bool = False):
        """Run all checks"""
        self.print_banner()
        
        # Run checks
        self.check_python_version()
        self.check_all_packages()
        self.check_all_tools()
        self.check_system_requirements()
        
        # Print summary
        self.print_summary()
        
        # Print install instructions
        self.print_install_instructions()
        
        # Save report if requested
        if save_report:
            self.save_report()
        
        # Return exit code
        missing_required = (
            len([m for m in self.results["packages"]["missing"] if m["required"]]) +
            len([m for m in self.results["tools"]["missing"] if m["required"]])
        )
        
        return 0 if missing_required == 0 else 1


# =====================
# MAIN
# =====================
def main():
    import argparse
    
    parser = argparse.ArgumentParser(
        description="SUPER-CRAB-V1 Requirements Checker",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python requirements-check.py              # Run all checks
  python requirements-check.py --save       # Run checks and save report
  python requirements-check.py --json       # Output results as JSON
        """
    )
    
    parser.add_argument("--save", "-s", action="store_true",
                       help="Save report to requirements_report.json")
    parser.add_argument("--json", "-j", action="store_true",
                       help="Output results as JSON")
    parser.add_argument("--version", "-v", action="version",
                       version=f"SUPER-CRAB-V1 Requirements Checker v{VERSION}")
    
    args = parser.parse_args()
    
    checker = RequirementsChecker()
    exit_code = checker.run(save_report=args.save)
    
    sys.exit(exit_code)


if __name__ == "__main__":
    main()
