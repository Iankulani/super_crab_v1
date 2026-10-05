# =============================================================================
# SUPER-CRAB-V1 - Makefile
# Author: Ian Carter Kulani, MSc
# Version: 1.0.0
# =============================================================================

.PHONY: help install install-dev install-system test test-cov lint format clean build docker docker-alpine docker-push docker-compose-up docker-compose-down security-check requirements-check run venv activate docs

# ==================== VARIABLES ====================
PYTHON := python3
VENV := venv
VENV_BIN := $(VENV)/bin
PIP := $(VENV_BIN)/pip
PYTEST := $(VENV_BIN)/pytest
IMAGE_NAME := super-crab-v1
IMAGE_TAG := latest
DOCKER_REGISTRY := 

# ==================== COLORS ====================
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
CYAN := \033[0;36m
NC := \033[0m

# ==================== HELP ====================
help:
	@echo "$(CYAN)SUPER-CRAB-V1 - Available Commands$(NC)"
	@echo ""
	@echo "$(GREEN)Installation:$(NC)"
	@echo "  make install          - Install production dependencies"
	@echo "  make install-dev      - Install development dependencies"
	@echo "  make install-system   - Install system tools (requires sudo)"
	@echo "  make venv             - Create virtual environment"
	@echo ""
	@echo "$(GREEN)Testing:$(NC)"
	@echo "  make test             - Run tests"
	@echo "  make test-cov         - Run tests with coverage"
	@echo "  make security-check   - Run security checks"
	@echo ""
	@echo "$(GREEN)Code Quality:$(NC)"
	@echo "  make lint             - Run linters"
	@echo "  make format           - Format code"
	@echo "  make type-check       - Run type checker"
	@echo ""
	@echo "$(GREEN)Docker:$(NC)"
	@echo "  make docker           - Build Docker image"
	@echo "  make docker-alpine    - Build Alpine Docker image"
	@echo "  make docker-push      - Push Docker image"
	@echo "  make docker-up        - Start docker-compose services"
	@echo "  make docker-down      - Stop docker-compose services"
	@echo ""
	@echo "$(GREEN)Other:$(NC)"
	@echo "  make run              - Run the application"
	@echo "  make requirements-check - Check dependencies"
	@echo "  make clean            - Clean build artifacts"
	@echo "  make docs             - Build documentation"
	@echo ""

# ==================== VIRTUAL ENVIRONMENT ====================
venv:
	@echo "$(CYAN)Creating virtual environment...$(NC)"
	$(PYTHON) -m venv $(VENV)
	@echo "$(GREEN)Virtual environment created at $(VENV)$(NC)"
	@echo "Run 'source $(VENV_BIN)/activate' to activate"

activate:
	@echo "Run: source $(VENV_BIN)/activate"

# ==================== INSTALLATION ====================
install: venv
	@echo "$(CYAN)Installing production dependencies...$(NC)"
	$(PIP) install --upgrade pip setuptools wheel
	$(PIP) install -r requirements.txt
	@echo "$(GREEN)Dependencies installed successfully!$(NC)"

install-dev: install
	@echo "$(CYAN)Installing development dependencies...$(NC)"
	$(PIP) install -r requirements-dev.txt
	@echo "$(GREEN)Development dependencies installed!$(NC)"

install-system:
	@echo "$(CYAN)Installing system dependencies...$(NC)"
ifeq ($(shell uname), Linux)
	sudo apt-get update
	sudo apt-get install -y nmap curl wget netcat-openbsd dnsutils traceroute whois openssh-client
else ifeq ($(shell uname), Darwin)
	brew install nmap curl wget netcat bind traceroute whois openssh
endif
	@echo "$(GREEN)System dependencies installed!$(NC)"

# ==================== TESTING ====================
test:
	@echo "$(CYAN)Running tests...$(NC)"
	$(PYTEST) tests/ -v

test-cov:
	@echo "$(CYAN)Running tests with coverage...$(NC)"
	$(PYTEST) tests/ -v --cov=. --cov-report=html --cov-report=term

test-integration:
	@echo "$(CYAN)Running integration tests...$(NC)"
	$(PYTEST) tests/integration/ -v

# ==================== CODE QUALITY ====================
lint:
	@echo "$(CYAN)Running linters...$(NC)"
	$(VENV_BIN)/flake8 super_crab_v1.py --count --statistics
	$(VENV_BIN)/pylint super_crab_v1.py || true

format:
	@echo "$(CYAN)Formatting code...$(NC)"
	$(VENV_BIN)/black super_crab_v1.py requirements-check.py
	$(VENV_BIN)/isort super_crab_v1.py requirements-check.py
	@echo "$(GREEN)Code formatted!$(NC)"

type-check:
	@echo "$(CYAN)Running type checker...$(NC)"
	$(VENV_BIN)/mypy super_crab_v1.py --ignore-missing-imports

# ==================== SECURITY ====================
security-check:
	@echo "$(CYAN)Running security checks...$(NC)"
	$(VENV_BIN)/bandit -r . -f txt || true
	$(VENV_BIN)/safety check -r requirements.txt || true
	@echo "$(GREEN)Security checks completed!$(NC)"

requirements-check:
	@echo "$(CYAN)Checking requirements...$(NC)"
	$(PYTHON) requirements-check.py

# ==================== DOCKER ====================
docker:
	@echo "$(CYAN)Building Docker image...$(NC)"
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .
	@echo "$(GREEN)Docker image built: $(IMAGE_NAME):$(IMAGE_TAG)$(NC)"

docker-alpine:
	@echo "$(CYAN)Building Alpine Docker image...$(NC)"
	docker build -f Dockerfile.alpine -t $(IMAGE_NAME):alpine .
	@echo "$(GREEN)Alpine Docker image built: $(IMAGE_NAME):alpine$(NC)"

docker-push:
	@echo "$(CYAN)Pushing Docker image...$(NC)"
	docker push $(DOCKER_REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)

docker-up:
	@echo "$(CYAN)Starting docker-compose services...$(NC)"
	docker-compose up -d
	@echo "$(GREEN)Services started!$(NC)"

docker-down:
	@echo "$(CYAN)Stopping docker-compose services...$(NC)"
	docker-compose down
	@echo "$(GREEN)Services stopped!$(NC)"

docker-logs:
	docker-compose logs -f

# ==================== BUILD ====================
build:
	@echo "$(CYAN)Building package...$(NC)"
	$(VENV_BIN)/python -m build
	@echo "$(GREEN)Package built in dist/$(NC)"

# ==================== RUN ====================
run:
	@echo "$(CYAN)Starting SUPER-CRAB-V1...$(NC)"
	$(PYTHON) super_crab_v1.py

# ==================== DOCUMENTATION ====================
docs:
	@echo "$(CYAN)Building documentation...$(NC)"
	$(VENV_BIN)/sphinx-build -b html docs/ docs/_build/html
	@echo "$(GREEN)Documentation built in docs/_build/html$(NC)"

# ==================== CLEANUP ====================
clean:
	@echo "$(CYAN)Cleaning build artifacts...$(NC)"
	rm -rf build/
	rm -rf dist/
	rm -rf *.egg-info/
	rm -rf .pytest_cache/
	rm -rf .mypy_cache/
	rm -rf .coverage
	rm -rf htmlcov/
	rm -rf __pycache__/
	rm -rf **/__pycache__/
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete
	@echo "$(GREEN)Cleanup complete!$(NC)"

clean-all: clean
	@echo "$(CYAN)Removing virtual environment...$(NC)"
	rm -rf $(VENV)
	@echo "$(GREEN)Full cleanup complete!$(NC)"
