#!/bin/bash

# Exit on error
set -e

echo "Starting setup process..."

# Function to check command status
check_status() {
    if [ $? -eq 0 ]; then
        echo "✓ $1 completed successfully"
    else
        echo "✗ Error during $1"
        exit 1
    fi
}

# Detect conda installation
detect_conda_path() {
    if command -v conda &> /dev/null; then
        # Conda is already in PATH
        CONDA_PREFIX=$(conda run python -c "import sys; print(sys.prefix)")
        echo "$CONDA_PREFIX"
    elif [ -d "$HOME/anaconda3" ]; then
        echo "$HOME/anaconda3"
    elif [ -d "$HOME/miniconda3" ]; then
        echo "$HOME/miniconda3"
    else
        echo ""
    fi
}

# Basic setup
if ! command -v conda &> /dev/null; then
    echo "Installing Miniconda..."
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    chmod +x Miniconda3-latest-Linux-x86_64.sh
    ./Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda3
    $HOME/miniconda3/bin/conda init bash
    eval "$($HOME/miniconda3/bin/conda shell.bash hook)"
    rm ./Miniconda3-latest-Linux-x86_64.sh
    check_status "Miniconda installation"
    CONDA_PATH="$HOME/miniconda3"
else
    echo "Conda is already installed. Skipping Miniconda installation."
    CONDA_PATH=$(detect_conda_path)
    echo "Detected Conda installation at: $CONDA_PATH"
fi

# Install required packages
echo "Installing required packages..."
sudo apt update
sudo apt install -y unzip libgl1 libosmesa6 ffmpeg libsm6 xvfb libxext6
check_status "Package installation"

# Git LFS setup
echo "Setting up Git and Git LFS..."
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
sudo apt-get install -y git-lfs
git lfs install
check_status "Git setup"

echo "Initializing conda..."
$CONDA_PATH/bin/conda init bash
source ~/.bashrc
eval "$($CONDA_PATH/bin/conda shell.bash hook)"

# Accept conda Terms of Service using full path to ensure it works
echo "Accepting Anaconda Terms of Service..."
$CONDA_PATH/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main || true
$CONDA_PATH/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r || true
# Fallback: try to accept all terms at once
$CONDA_PATH/bin/conda tos accept || true
check_status "Conda ToS acceptance"