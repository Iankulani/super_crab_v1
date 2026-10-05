#!/bin/bash
# =============================================================================
# SUPER-CRAB-V1 - Bash Installation Script
# Author: Ian Carter Kulani, MSc
# Version: 1.0.0
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="${SCRIPT_DIR}/venv"
PYTHON_CMD=""
INSTALL_SYSTEM_TOOLS=false
SKIP_VENV=false
SKIP_DEPS=false

# =============================================================================
# BANNER
# =============================================================================
print_banner() {
    echo -e "${CYAN}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║   ███████╗██╗   ██╗██████╗ ███████╗██████╗      ██████╗██████╗  █████╗ ██████╗ ║
║   ██╔════╝██║   ██║██╔══██╗██╔════╝██╔══██╗    ██╔════╝██╔══██╗██╔══██╗██╔══██╗║
║   ███████╗██║   ██║██████╔╝█████╗  ██████╔╝    ██║     ██████╔╝███████║██████╔╝║
║   ╚════██║██║   ██║██╔═══╝ ██╔══╝  ██╔══██╗    ██║     ██╔══██╗██╔══██║██╔══██╗║
║   ███████║╚██████╔╝██║     ███████╗██║  ██║    ╚██████╗██║  ██║██║  ██║██████╔╝║
║   ╚══════╝ ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═╝     ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ║
║                                                                              ║
║                    SUPER-CRAB-V1 - Installation Script                       ║
║                         Author: Ian Carter Kulani, MSc                       ║
║                              Version: 1.0.0                                  ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "\n${CYAN}${BOLD}[STEP]${NC} ${WHITE}$1${NC}"
}

check_command() {
    if command -v "$1" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/debian_version ]; then
            echo "debian"
        elif [ -f /etc/redhat-release ]; then
            echo "redhat"
        elif [ -f /etc/arch-release ]; then
            echo "arch"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# =============================================================================
# PYTHON DETECTION
# =============================================================================
find_python() {
    log_step "Detecting Python installation..."
    
    for cmd in python3.12 python3.11 python3.10 python3.9 python3.8 python3 python; do
        if check_command "$cmd"; then
            version=$($cmd --version 2>&1 | grep -oP '\d+\.\d+')
            major=$(echo $version | cut -d. -f1)
            minor=$(echo $version | cut -d. -f2)
            
            if [ "$major" -ge 3 ] && [ "$minor" -ge 7 ]; then
                PYTHON_CMD="$cmd"
                log_info "Found $cmd (version $version)"
                return 0
            fi
        fi
    done
    
    log_error "Python 3.7+ not found. Please install Python 3.7 or higher."
    exit 1
}

# =============================================================================
# SYSTEM DEPENDENCIES
# =============================================================================
install_system_deps() {
    local os_type=$(detect_os)
    
    log_step "Installing system dependencies..."
    
    case $os_type in
        debian)
            log_info "Detected Debian/Ubuntu-based system"
            sudo apt-get update
            sudo apt-get install -y \
                python3-pip \
                python3-venv \
                python3-dev \
                build-essential \
                libssl-dev \
                libffi-dev \
                libxml2-dev \
                libxslt1-dev \
                zlib1g-dev \
                libjpeg-dev \
                libpng-dev \
                curl \
                wget \
                git \
                nmap \
                netcat-openbsd \
                dnsutils \
                traceroute \
                whois \
                openssl \
                openssh-client
            ;;
        redhat)
            log_info "Detected RedHat/CentOS/Fedora-based system"
            sudo dnf install -y \
                python3-pip \
                python3-devel \
                gcc \
                gcc-c++ \
                make \
                openssl-devel \
                libffi-devel \
                libxml2-devel \
                libxslt-devel \
                zlib-devel \
                libjpeg-turbo-devel \
                libpng-devel \
                curl \
                wget \
                git \
                nmap \
                nc \
                bind-utils \
                traceroute \
                whois \
                openssl \
                openssh-clients
            ;;
        arch)
            log_info "Detected Arch Linux"
            sudo pacman -Sy --noconfirm \
                python-pip \
                python-virtualenv \
                base-devel \
                openssl \
                libffi \
                libxml2 \
                libxslt \
                zlib \
                libjpeg-turbo \
                libpng \
                curl \
                wget \
                git \
                nmap \
                gnu-netcat \
                bind \
                traceroute \
                whois \
                openssh
            ;;
        macos)
            log_info "Detected macOS"
            if ! check_command brew; then
                log_warn "Homebrew not found. Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            
            brew install \
                python3 \
                openssl \
                libffi \
                libxml2 \
                libxslt \
                zlib \
                jpeg \
                libpng \
                curl \
                wget \
                git \
                nmap \
                netcat \
                bind \
                traceroute \
                whois \
                openssh
            ;;
        *)
            log_warn "Unknown OS. Please install system dependencies manually."
            ;;
    esac
    
    log_info "System dependencies installed"
}

# =============================================================================
# VIRTUAL ENVIRONMENT
# =============================================================================
create_venv() {
    if [ "$SKIP_VENV" = true ]; then
        log_info "Skipping virtual environment creation"
        return 0
    fi
    
    log_step "Creating virtual environment..."
    
    if [ -d "$VENV_DIR" ]; then
        log_warn "Virtual environment already exists at $VENV_DIR"
        read -p "Recreate? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$VENV_DIR"
        else
            log_info "Using existing virtual environment"
            source "$VENV_DIR/bin/activate"
            return 0
        fi
    fi
    
    $PYTHON_CMD -m venv "$VENV_DIR"
    source "$VENV_DIR/bin/activate"
    
    log_info "Virtual environment created at $VENV_DIR"
}

# =============================================================================
# PYTHON DEPENDENCIES
# =============================================================================
install_python_deps() {
    if [ "$SKIP_DEPS" = true ]; then
        log_info "Skipping Python dependencies"
        return 0
    fi
    
    log_step "Installing Python dependencies..."
    
    # Upgrade pip
    pip install --upgrade pip setuptools wheel
    
    # Install requirements
    if [ -f "$SCRIPT_DIR/requirements.txt" ]; then
        log_info "Installing from requirements.txt..."
        pip install -r "$SCRIPT_DIR/requirements.txt"
    else
        log_warn "requirements.txt not found. Installing core packages..."
        pip install \
            colorama \
            psutil \
            requests \
            cryptography \
            paramiko \
            scapy \
            dnspython \
            whois \
            flask \
            flask-socketio \
            flask-cors \
            discord.py \
            telethon \
            slack-sdk \
            selenium \
            webdriver-manager \
            reportlab \
            pynput \
            pyperclip \
            pyautogui \
            qrcode \
            pillow \
            beautifulsoup4 \
            numpy \
            matplotlib \
            tqdm \
            tabulate \
            rich
    fi
    
    log_info "Python dependencies installed"
}

# =============================================================================
# OPTIONAL TOOLS
# =============================================================================
install_optional_tools() {
    log_step "Installing optional security tools..."
    
    local os_type=$(detect_os)
    
    # Nikto
    if ! check_command nikto; then
        log_info "Installing Nikto..."
        case $os_type in
            debian)
                sudo apt-get install -y nikto
                ;;
            macos)
                brew install nikto
                ;;
            *)
                log_warn "Please install Nikto manually"
                ;;
        esac
    fi
    
    # Hashcat
    if ! check_command hashcat; then
        log_info "Installing Hashcat..."
        case $os_type in
            debian)
                sudo apt-get install -y hashcat
                ;;
            macos)
                brew install hashcat
                ;;
            *)
                log_warn "Please install Hashcat manually"
                ;;
        esac
    fi
    
    # Docker
    if ! check_command docker; then
        log_info "Installing Docker..."
        case $os_type in
            debian)
                sudo apt-get install -y docker.io
                sudo systemctl start docker
                sudo systemctl enable docker
                sudo usermod -aG docker $USER
                ;;
            macos)
                brew install --cask docker
                ;;
            *)
                log_warn "Please install Docker manually"
                ;;
        esac
    fi
    
    log_info "Optional tools installation complete"
}

# =============================================================================
# VERIFICATION
# =============================================================================
verify_installation() {
    log_step "Verifying installation..."
    
    if [ -f "$SCRIPT_DIR/requirements-check.py" ]; then
        python "$SCRIPT_DIR/requirements-check.py"
    else
        log_info "Checking core imports..."
        
        python -c "
import sys
packages = ['colorama', 'psutil', 'requests', 'cryptography', 'paramiko', 'scapy', 'flask']
missing = []
for pkg in packages:
    try:
        __import__(pkg)
        print(f'  ✓ {pkg}')
    except ImportError:
        missing.append(pkg)
        print(f'  ✗ {pkg}')

if missing:
    print(f'\nMissing packages: {\" \".join(missing)}')
    sys.exit(1)
else:
    print('\n✓ All core packages installed successfully!')
"
    fi
}

# =============================================================================
# CREATE LAUNCHER
# =============================================================================
create_launcher() {
    log_step "Creating launcher script..."
    
    cat > "$SCRIPT_DIR/run.sh" << 'EOF'
#!/bin/bash
# SUPER-CRAB-V1 Launcher

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="${SCRIPT_DIR}/venv"

if [ -d "$VENV_DIR" ]; then
    source "$VENV_DIR/bin/activate"
fi

python "$SCRIPT_DIR/super_crab_v1.py" "$@"
EOF
    
    chmod +x "$SCRIPT_DIR/run.sh"
    log_info "Launcher created at $SCRIPT_DIR/run.sh"
}

# =============================================================================
# USAGE
# =============================================================================
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -v, --venv              Create virtual environment (default: true)"
    echo "  --no-venv               Skip virtual environment creation"
    echo "  -s, --system            Install system dependencies"
    echo "  --no-deps               Skip Python dependencies installation"
    echo "  -a, --all               Install everything (system + optional tools)"
    echo ""
    echo "Examples:"
    echo "  $0                      # Standard installation"
    echo "  $0 --no-venv            # Install in system Python"
    echo "  $0 -a                   # Install all dependencies and tools"
}

# =============================================================================
# MAIN
# =============================================================================
main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            --no-venv)
                SKIP_VENV=true
                shift
                ;;
            -s|--system)
                INSTALL_SYSTEM_TOOLS=true
                shift
                ;;
            --no-deps)
                SKIP_DEPS=true
                shift
                ;;
            -a|--all)
                INSTALL_SYSTEM_TOOLS=true
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    print_banner
    
    log_info "Starting SUPER-CRAB-V1 installation..."
    log_info "Installation directory: $SCRIPT_DIR"
    
    # Detect Python
    find_python
    
    # Install system dependencies if requested
    if [ "$INSTALL_SYSTEM_TOOLS" = true ]; then
        install_system_deps
    fi
    
    # Create virtual environment
    create_venv
    
    # Install Python dependencies
    install_python_deps
    
    # Install optional tools
    if [ "$INSTALL_SYSTEM_TOOLS" = true ]; then
        install_optional_tools
    fi
    
    # Create launcher
    create_launcher
    
    # Verify installation
    verify_installation
    
    # Success message
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    ✓ INSTALLATION COMPLETE!                                 ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${WHITE}To run SUPER-CRAB-V1:${NC}"
    echo -e "  ${GREEN}cd $SCRIPT_DIR${NC}"
    echo -e "  ${GREEN}./run.sh${NC}"
    echo ""
    echo -e "${WHITE}Or manually:${NC}"
    if [ "$SKIP_VENV" = false ]; then
        echo -e "  ${GREEN}source venv/bin/activate${NC}"
    fi
    echo -e "  ${GREEN}python super_crab_v1.py${NC}"
    echo ""
}

# Run main
main "$@"
