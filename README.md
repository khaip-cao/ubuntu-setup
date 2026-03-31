# 🚀 Ubuntu Development Environment Setup

An automated setup script to bootstrap a modern development environment on Ubuntu-based systems. This repository provides a one-stop solution for installing essential build tools, version managers, and containerization platforms required for full-stack and data science development.

## ✨ Features

- **🛡️ System Preparation**: Updates system packages and installs core build dependencies (`build-essential`, `curl`, `git`, `libssl`, etc.).
- **🐳 Docker Stack**: Installs Docker Engine and Docker Compose V2, automatically configuring user group permissions for sudo-less usage.
- **🐍 Python Management**: 
    - Installs [`pyenv`](https://github.com/pyenv/pyenv) for seamless Python version switching.
    - Bootstraps the latest Stable/LTS Python (3.12+).
    - Installs [`uv`](https://github.com/astral-sh/uv) — an extremely fast Python package and project manager.
- **📦 Node.js Management**: 
    - Installs [`nvm`](https://github.com/nvm-sh/nvm) (Node Version Manager).
    - Installs the latest Node.js LTS version.

## 🏃 Quick Start

To set up your environment, simply clone this repository and run the setup script:

```bash
git clone https://github.com/yourusername/ubuntu-setup.git
cd ubuntu-setup
chmod +x setup.sh
./setup.sh
```

> [!IMPORTANT]
> To apply Docker group permissions, you must **log out and log back in** after the script completes.

## 🛠️ Verification

After installation, you can verify your environment with:

```bash
docker --version
python --version
node -v
git --version
uv --version
```

---
*Optimized for productivity.*
