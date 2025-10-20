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

# Initialize conda in the current shell
echo "Initializing conda..."
CONDA_PATH=$(detect_conda_path)
if [ -z "$CONDA_PATH" ]; then
    echo "Error: Conda installation not found"
    exit 1
fi

$CONDA_PATH/bin/conda init bash
source ~/.bashrc

full_path=$(realpath $0)
dir_path=$(dirname $full_path)

echo "Creating sglang-vla environment..."
# Create and activate environment
if ! conda env list | grep -qE "^\s*sglang-vla\s"; then
    $CONDA_PATH/bin/conda create -n sglang-vla python=3.10 -y
else
    echo "Conda environment 'sglang-vla' already exists. Skipping creation."
fi

source $CONDA_PATH/etc/profile.d/conda.sh
conda activate sglang-vla

cd "$dir_path/../sglang-vla"
pip install --upgrade pip
pip install -e "python[all]"
pip install timm==0.9.10
pip install json_numpy
pip install flask
sudo apt-get update
sudo apt-get install -y libnuma1 numactl
check_status "SGLang setup"