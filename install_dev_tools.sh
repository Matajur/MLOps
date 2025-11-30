#!/usr/bin/env bash
set -e

LOGFILE="install.log"
touch "$LOGFILE"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOGFILE"
}

log "Starting DevOps & ML environment setup"

# 1. Tool installation check function

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

check_python_version() {
    if command_exists python3; then
        PYVER=$(python3 -c "import sys; print('.'.join(map(str, sys.version_info[:2])))")
        python3 - <<EOF
import sys
exit(0) if sys.version_info >= (3,9) else exit(1)
EOF
        return $?
    else
        return 1
    fi
}

# 2. Docker installation

if command_exists docker; then
    log "Docker already installed: $(docker --version)"
else
    log "Installing Docker..."
    sudo apt-get update -y >> "$LOGFILE" 2>&1
    sudo apt-get install -y ca-certificates curl gnupg >> "$LOGFILE" 2>&1

    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo $VERSION_CODENAME) stable" \
      | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update -y >> "$LOGFILE" 2>&1
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >> "$LOGFILE" 2>&1

    log "Docker installed successfully."
fi

log "Docker version: $(docker --version)"

# 3. Docker Compose installation

if command_exists docker-compose; then
    log "Docker Compose already installed: $(docker-compose --version)"
else
    log "Installing Docker Compose..."
    sudo apt-get install -y docker-compose >> "$LOGFILE" 2>&1 || true
fi

command_exists docker-compose && log "Docker Compose version: $(docker-compose --version)"

# 4. Python installation (via apt or pyenv fallback)

if check_python_version; then
    log "Python already installed and sufficiently new: $(python3 --version)"
else
    log "Python 3.9+ not detected. Installing..."

    # Try apt first
    sudo apt-get update -y >> "$LOGFILE"
    sudo apt-get install -y python3 python3-pip python3-venv >> "$LOGFILE" || true

    if check_python_version; then
        log "Python installed via apt: $(python3 --version)"
    
    # Try pyenv
    else
        log "System Python too old—installing pyenv..."
        if ! command_exists git; then sudo apt-get install -y git; fi

        curl https://pyenv.run | bash >> "$LOGFILE" 2>&1

        export PATH="$HOME/.pyenv/bin:$PATH"
        eval "$(pyenv init -)"
        eval "$(pyenv virtualenv-init -)"

        pyenv install -s 3.10.14 >> "$LOGFILE" 2>&1
        pyenv global 3.10.14

        log "Python installed via pyenv: $(python3 --version)"
    fi
fi

# 5. pip installation

if command_exists pip3; then
    log "pip already installed: $(pip3 --version)"
else
    log "Installing pip..."
    sudo apt-get install -y python3-pip >> "$LOGFILE" 2>&1
fi

log "pip version: $(pip3 --version)"

# 6. Python packages: Django, torch, torchvision, pillow

install_if_missing() {
    PACKAGE=$1
    if python3 -c "import $PACKAGE" 2>/dev/null; then
        log "Python package '$PACKAGE' already installed."
    else
        log "Installing Python package: $PACKAGE"
        pip3 install "$PACKAGE" >> "$LOGFILE" 2>&1
    fi
}

install_if_missing django
install_if_missing torch
install_if_missing torchvision
install_if_missing PIL

log "Installed Python packages:"
log " - Django: $(python3 -c 'import django; print(django.get_version())')"
log " - torch: $(python3 -c 'import torch; print(torch.__version__)')"
log " - torchvision: $(python3 -c 'import torchvision; print(torchvision.__version__)')"
log " - pillow: $(python3 -c 'import PIL; print(PIL.__version__)')"

log "Environment setup complete. Log saved to $LOGFILE"
