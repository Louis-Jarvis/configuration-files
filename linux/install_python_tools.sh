#!/bin/zsh

# The purpose of this script is to install common tools needed for a python development
# including python, and pyenv

# Variables
PYTHON_VERSION=${1:-"3.11.5"}  # Allow Python version as an argument, default to 3.11.5
PYENV_ROOT="$HOME/.pyenv"

# Check if the script is running on Ubuntu
if ! grep -q "Ubuntu" /etc/os-release; then
    echo "This script is intended for Ubuntu distributions only."
    exit 1
fi

# Check for sudo privileges
if ! sudo -v > /dev/null 2>&1; then
    echo "You need sudo privileges to run this script."
    exit 1
fi

# Update and upgrade packages
echo "Updating and upgrading system packages..."
if ! sudo apt update && sudo apt upgrade -y; then
    echo "Failed to update and upgrade system packages."
    exit 1
fi

# Install dependencies
echo "Installing dependencies..."
DEPS="build-essential curl libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
libsqlite3-dev wget llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev \
libffi-dev liblzma-dev git software-properties-common"
if ! sudo apt install -y $DEPS; then
    echo "Failed to install dependencies."
    exit 1
fi

# Install Pyenv
if [ -d "$PYENV_ROOT" ]; then
    echo "Pyenv is already installed."
else
    echo "Installing Pyenv..."
    if ! curl https://pyenv.run | zsh; then
        echo "Failed to install Pyenv."
        exit 1
    fi
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
    echo 'eval "$(pyenv init --path)"' >> ~/.zshrc
    echo 'eval "$(pyenv init -)"' >> ~/.zshrc
    source ~/.zshrc
fi

# Verify Pyenv installation
if ! pyenv --version > /dev/null 2>&1; then
    echo "Pyenv installation failed."
    exit 1
fi

# Install Python through Pyenv
if ! pyenv versions | grep -q "$PYTHON_VERSION"; then
    echo "Installing Python $PYTHON_VERSION through Pyenv..."
    if ! pyenv install "$PYTHON_VERSION"; then
        echo "Failed to install Python $PYTHON_VERSION."
        exit 1
    fi
    pyenv global "$PYTHON_VERSION"
else
    echo "Python $PYTHON_VERSION is already installed."
fi

# Verify Python installation
if ! python --version > /dev/null 2>&1; then
    echo "Python installation failed."
    exit 1
fi

echo "Python version: $(python --version)"
echo "Pip version: $(pip --version)"
echo "Installation completed successfully!"
