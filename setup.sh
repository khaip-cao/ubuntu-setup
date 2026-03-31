#!/bin/bash

# Features: Arch detection, Retries, and Verification

# 1. Utility Functions
log() { echo -e "\033[1;32m🚀 $1\033[0m"; }
error() { echo -e "\033[1;31m❌ $1\033[0m"; }

retry() {
    local n=1
    local max=3
    local delay=5
    while true; do
        "$@" && break || {
            if [[ $n -lt $max ]]; then
                ((n++))
                error "Command failed. Attempt $n/$max in ${delay}s..."
                sleep $delay;
            else
                error "The command has failed after $n attempts."
                return 1
            fi
        }
    done
}

# Detect Architecture
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    GO_ARCH="amd64"
elif [ "$ARCH" = "aarch64" ]; then
    GO_ARCH="arm64"
else
    error "Unsupported architecture: $ARCH"
    exit 1
fi

log "Starting setup for $ARCH architecture..."

# 2. System Update
log "Updating system packages..."
retry sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev wget llvm libncurses-dev \
xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev \
liblzma-dev make jq htop tmux ncdu net-tools

# 3. Docker (with check)
if ! command -v docker &> /dev/null; then
    log "Installing Docker..."
    sudo apt install -y docker.io docker-compose-v2
    sudo usermod -aG docker $USER
else
    log "Docker already installed."
fi

# 4. NVM Installation (with path verification)
export NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
    log "Installing NVM..."
    retry curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi

# Load NVM for the rest of this script
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

if command -v nvm &> /dev/null; then
    log "Installing Node LTS..."
    nvm install --lts
    npm install -g pnpm pm2
else
    error "NVM failed to load."
fi

# 5. Pyenv Installation
export PYENV_ROOT="$HOME/.pyenv"
if [ ! -d "$PYENV_ROOT" ]; then
    log "Installing pyenv..."
    retry curl https://pyenv.run | bash
fi

# Load pyenv for script context
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv &> /dev/null; then
    eval "$(pyenv init -)"
    log "Installing Python 3.12.9 (This takes time on ARM)..."
    # Only install if not present
    pyenv versions | grep -q "3.12.9" || pyenv install 3.12.9
    pyenv global 3.12.9
else
    error "Pyenv failed to load."
fi

# 6. Go Installation (Architecture Aware)
GO_VERSION="1.22.1"
if [[ "$(go version 2>/dev/null)" != *"$GO_VERSION"* ]]; then
    log "Installing Go $GO_VERSION for $GO_ARCH..."
    wget "https://go.dev/dl/go${GO_VERSION}.linux-${GO_ARCH}.tar.gz"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-${GO_ARCH}.tar.gz"
    rm "go${GO_VERSION}.linux-${GO_ARCH}.tar.gz"
else
    log "Go $GO_VERSION already correct."
fi

# 7. Final .bashrc Cleanup (Avoid Duplicates)
log "Finalizing .bashrc..."
declare -a CONFIG_LINES=(
    'export PYENV_ROOT="$HOME/.pyenv"'
    '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"'
    'eval "$(pyenv init -)"'
    'export NVM_DIR="$HOME/.nvm"'
    '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'
    'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin'
)

for line in "${CONFIG_LINES[@]}"; do
    grep -qF "$line" ~/.bashrc || echo "$line" >> ~/.bashrc
done

log "Setup Complete! Please run: source ~/.bashrc"