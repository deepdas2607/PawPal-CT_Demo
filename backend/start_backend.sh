#!/bin/bash
# ==============================================================================
# start_backend.sh
# Starts the PawPal FastAPI backend with local SQLite database.
# ==============================================================================

set -e

# Change directory to backend folder
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🐾 Starting PawPal Backend..."

# Create Python virtual environment if it does not exist
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment at backend/venv..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Upgrade pip and install dependencies
echo "📥 Checking and installing dependencies..."
pip install --quiet --upgrade pip
pip install --quiet -r requirements.txt

# Start FastAPI server using Uvicorn
echo "🚀 Starting server at http://127.0.0.1:8000 (API Docs at http://127.0.0.1:8000/docs)..."
exec uvicorn app.main:app --reload --host 127.0.0.1 --port 8000

