#!/bin/bash

# Exit on error
set -e

echo "🚀 Starting Full Ubuntu Server Environment Setup..."

# 1. Update System & Install Core Utilities
echo "📦 Updating system and installing build essentials..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev wget llvm libncurses5-dev \
libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev \
liblzma-dev make jq htop tmux ncdu net-tools

# 2. Install Docker & Docker Compose
echo "🐳 Installing Docker..."
sudo apt install -y docker.io docker-compose-v2

# Configure Docker Group (to run without sudo)
echo "🔧 Configuring Docker group..."
if ! getent group docker > /dev/null; then
    sudo groupadd docker
fi
sudo usermod -aG docker $USER
echo "✅ Added $USER to docker group."

# 3. Install pyenv (Python Version Manager)
echo "🐍 Installing pyenv..."
if [ ! -d "$HOME/.pyenv" ]; then
    curl https://pyenv.run | bash
    
    # Add to .bashrc
    {
        echo 'export PYENV_ROOT="$HOME/.pyenv"'
        echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"'
        echo 'eval "$(pyenv init -)"'
        echo 'eval "$(pyenv virtualenv-init -)"'
    } >> ~/.bashrc
fi

# Load pyenv into current session
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Install Python LTS and Global Tools
PYTHON_LTS="3.12.9"
echo "Installing Python $PYTHON_LTS and tools (uv, ruff)..."
pyenv install $PYTHON_LTS
pyenv global $PYTHON_LTS
pip install --upgrade pip
pip install uv ruff python-dotenv

# 4. Install nvm (Node Version Manager)
echo "📦 Installing nvm..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Load nvm into current session
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node LTS and Global Tools
echo "Installing Node.js LTS and tools (pnpm, pm2)..."
nvm install --lts
nvm use --lts
npm install -g pnpm pm2 nodemon

# 5. Install Go (Golang)
# Since you're working on Gin/Go projects, let's grab the latest stable
echo "🐹 Installing Go..."
GO_VERSION="1.22.1" # Standard stable version for 2024/2025
wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
rm go${GO_VERSION}.linux-amd64.tar.gz

# Add Go to .bashrc
if ! grep -q "/usr/local/go/bin" ~/.bashrc; then
    echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc
fi

echo "--------------------------------------------------------"
echo "🎉 Setup Complete!"
echo "--------------------------------------------------------"
echo "1. Run 'source ~/.bashrc' to refresh your current session."
echo "2. LOG OUT AND LOG BACK IN to use Docker without sudo."
echo "3. Verify your stack:"
echo "   - docker ps"
echo "   - go version"
echo "   - python --version (uv, ruff)"
echo "   - node -v (pnpm, pm2)"
echo "--------------------------------------------------------"