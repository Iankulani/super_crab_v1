# =============================================================================
# SUPER-CRAB-V1 - Dockerfile
# Author: Ian Carter Kulani, MSc
# Version: 1.0.0
# =============================================================================

# ==================== BUILD STAGE ====================
FROM python:3.11-slim-bookworm AS builder

LABEL maintainer="Ian Carter Kulani, MSc"
LABEL description="SUPER-CRAB-V1 - Cyber Command Platform"
LABEL version="1.0.0"

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    g++ \
    make \
    libssl-dev \
    libffi-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    libjpeg-dev \
    libpng-dev \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip and install build tools
RUN pip install --upgrade pip setuptools wheel

# Copy requirements
COPY requirements.txt /tmp/requirements.txt

# Install Python dependencies
RUN pip install -r /tmp/requirements.txt

# ==================== RUNTIME STAGE ====================
FROM python:3.11-slim-bookworm AS runtime

LABEL maintainer="Ian Carter Kulani, MSc"
LABEL description="SUPER-CRAB-V1 - Cyber Command Platform"
LABEL version="1.0.0"

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:$PATH" \
    SUPER_CRAB_HOME=/app

# Install runtime dependencies and security tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Network tools
    nmap \
    curl \
    wget \
    netcat-openbsd \
    dnsutils \
    traceroute \
    whois \
    openssh-client \
    # SSL/TLS
    openssl \
    ca-certificates \
    # System utilities
    procps \
    htop \
    net-tools \
    iputils-ping \
    iproute2 \
    # Required libraries
    libssl3 \
    libffi8 \
    libxml2 \
    libxslt1.1 \
    zlib1g \
    libjpeg62-turbo \
    libpng16-16 \
    # Chrome dependencies for Selenium
    chromium \
    chromium-driver \
    # Other tools
    git \
    vim \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Install nikto (from source since not in repos)
RUN git clone https://github.com/sullo/nikto.git /opt/nikto && \
    ln -s /opt/nikto/program/nikto.pl /usr/local/bin/nikto && \
    chmod +x /opt/nikto/program/nikto.pl

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv

# Create app directory
WORKDIR /app

# Create non-root user
RUN groupadd -r supercrab && useradd -r -g supercrab -d /app -s /sbin/nologin supercrab

# Create necessary directories
RUN mkdir -p /app/.super_crab_v1 \
    /app/.super_crab_v1/payloads \
    /app/.super_crab_v1/workspaces \
    /app/.super_crab_v1/scans \
    /app/.super_crab_v1/ssh_keys \
    /app/.super_crab_v1/traffic_logs \
    /app/.super_crab_v1/nikto_results \
    /app/.super_crab_v1/phishing_pages \
    /app/.super_crab_v1/phishing_templates \
    /app/.super_crab_v1/captured_credentials \
    /app/.super_crab_v1/agents \
    /app/.super_crab_v1/c2_logs \
    /app/.super_crab_v1/modules \
    /app/.super_crab_v1/network_monitor \
    /app/.super_crab_v1/keylog_exfil \
    /app/.super_crab_v1/deployments \
    /app/.super_crab_v1/domain_hosting \
    /app/.super_crab_v1/cracking \
    /app/.super_crab_v1/arp_logs \
    /app/.super_crab_v1/mac_logs \
    /app/.super_crab_v1/nat_logs \
    /app/.super_crab_v1/platform_logs \
    /app/.super_crab_v1/docker_scans \
    /app/.super_crab_v1/email_composer \
    /app/.super_crab_v1/threat_monitor \
    /app/.super_crab_v1/saas \
    /app/super_crab_reports \
    /app/super_crab_reports/pdf_reports \
    /app/super_crab_reports/graphics \
    /app/temp \
    && chown -R supercrab:supercrab /app

# Copy application files
COPY --chown=supercrab:supercrab super_crab_v1.py /app/
COPY --chown=supercrab:supercrab requirements-check.py /app/
COPY --chown=supercrab:supercrab requirements.txt /app/

# Switch to non-root user
USER supercrab

# Expose ports
# 5000 - Web Dashboard
# 8080 - Phishing Server
# 4444 - Metasploit Handler
# 8081 - Additional services
EXPOSE 5000 8080 4444 8081

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import sys; sys.exit(0)" || exit 1

# Default command
ENTRYPOINT ["python", "super_crab_v1.py"]
CMD ["--help"]
