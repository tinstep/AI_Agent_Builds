#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="${SCRIPT_DIR}/.venv"

echo "Setting up virtual environment..."
python3 -m venv "${VENV_DIR}"

echo "Installing dependencies..."
"${VENV_DIR}/bin/pip" install -r requirements.txt

echo "Installation complete."
echo "To run: source ${VENV_DIR}/bin/activate && python musicgen.py --help"
