#!/bin/bash

# === CONFIGURATION ===
source_folder="$HOME/TestFolder"       
backup_root="$HOME/folder_snapshots"   
max_snapshots=5                        
sleep_after_snapshot=10                

# === Detect OS ===
OS="$(uname -s)"
echo "OS: $OS"

# === Install missing dependencies ===
install_dependency() {
    local tool="$1"

    if [[ "$OS" == "Linux" ]]; then
        if command -v apt &>/dev/null; then
            echo "🔧 Installing $tool with apt..."
            sudo apt update && sudo apt install -y "$tool"
        elif command -v apk &>/dev/null; then
            echo "🔧 Installing $tool with apk..."
            sudo apk add "$tool"
        elif command -v dnf &>/dev/null; then
            echo "🔧 Installing $tool with dnf..."
            sudo dnf install -y "$tool"
        elif command -v pacman &>/dev/null; then
            echo "🔧 Installing $tool with pacman..."
            sudo pacman -Sy "$tool" --noconfirm
        else
            echo "❌ Unsupported package manager. Please install $tool manually."
            exit 1
        fi
    elif [[ "$OS" == "Darwin" ]]; then
        if ! command -v brew &>/dev/null; then
            echo "❌ Homebrew not found. Install it from https://brew.sh"
            exit 1
        fi
        echo "🔧 Installing $tool with Homebrew..."
        brew install "$tool"
    fi
}

# === Check and install rsync ===
if ! command -v rsync &>/dev/null; then
    echo "❗ 'rsync' not found. Attempting to install..."
    install_dependency rsync
fi

# === Check and install appropriate watcher ===
if [[ "$OS" == "Linux" ]]; then
    if ! command -v inotifywait &>/dev/null; then
        echo "❗ 'inotify-tools' not found. Installing..."
        install_dependency inotify-tools
    fi
    watcher="inotify"
elif [[ "$OS" == "Darwin" ]]; then
    if ! command -v fswatch &>/dev/null; then
        echo "❗ 'fswatch' not found. Installing..."
        install_dependency fswatch
    fi
    watcher="fswatch"
else
    echo "❌ Unsupported OS: $OS"
    exit 1
fi

# === Ensure backup directory exists ===
mkdir -p "$backup_root"
mkdir -p "$source_folder"

# === Snapshot function ===
create_snapshot() {
    timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
    folder_name=$(basename "$source_folder")
    snapshot_name="${folder_name}_$timestamp"
    snapshot_path="$backup_root/$snapshot_name"

    echo "📸 Creating snapshot: $snapshot_name"
    rsync -a --delete "$source_folder/" "$snapshot_path"
    echo "✅ Snapshot saved at: $snapshot_path"

    # Enforce snapshot retention
    snapshots=($(ls -dt "$backup_root/${folder_name}_"* 2>/dev/null))
    if (( ${#snapshots[@]} > max_snapshots )); then
        to_delete=("${snapshots[@]:$max_snapshots}")
        for snap in "${to_delete[@]}"; do
            echo "🗑️ Removing old snapshot: $snap"
            rm -rf "$snap"
        done
    fi
}

# === Start watching ===
echo "📡 Monitoring changes in: $source_folder"

if [[ "$watcher" == "inotify" ]]; then
    inotifywait -m -r -e modify,create,delete,move "$source_folder" --format '%w%f' |
    while read changed; do
        echo "📝 Change detected: $changed"
        create_snapshot
        sleep "$sleep_after_snapshot"
    done
elif [[ "$watcher" == "fswatch" ]]; then
    fswatch -0 "$source_folder" | while read -d "" changed; do
        echo "📝 Change detected: $changed"
        create_snapshot
        sleep "$sleep_after_snapshot"
    done
fi
