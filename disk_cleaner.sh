#!/bin/bash

# Function: Show disk usage
view_disk_usage() {
    echo "Disk Usage:"
    df -h /
}

# Function: Show summary (file count + size)
show_summary() {
    local path="$1"
    local file_count=$(find "$path" -type f 2>/dev/null | wc -l)
    local total_size=$(du -sh "$path" 2>/dev/null | awk '{print $1}')
    echo "Path: $path — Files: $file_count, Size: $total_size"
}

# Function: Clean apt cache
clean_apt_cache() {
    echo "APT Cache:"
    show_summary "/var/cache/apt/archives"

    read -p "Delete APT cache? (y/n): " confirm
    if [[ "$confirm" == "y" ]]; then
        sudo apt clean
        echo "APT cache cleaned."
    else
        echo "Skipped."
    fi
}

# Function: Clean thumbnail cache
clean_thumbnails() {
    echo "Thumbnail Cache:"
    show_summary "$HOME/.cache/thumbnails"

    read -p "Delete thumbnail cache? (y/n): " confirm
    if [[ "$confirm" == "y" ]]; then
        rm -rf "$HOME/.cache/thumbnails/"*
        echo "Thumbnail cache cleaned."
    else
        echo "Skipped."
    fi
}

# Function: Clean old system logs
clean_system_logs() {
    echo "System Logs older than 7 days:"
    logs=$(find /var/log -type f -name "*.log" -mtime +7)
    file_count=$(echo "$logs" | wc -l)
    total_size=$(du -ch $(echo "$logs") 2>/dev/null | grep total$ | awk '{print $1}')

    echo "Log files: $file_count, Size: $total_size"
    read -p "Delete these old logs? (y/n): " confirm
    if [[ "$confirm" == "y" ]]; then
        echo "$logs" | xargs rm -f
        echo "Old logs cleaned."
    else
        echo "Skipped."
    fi
}

# Function: Delete old downloads
clean_old_downloads() {
    echo "Files in Downloads older than 30 days:"
    files=$(find "$HOME/Downloads" -type f -mtime +30)
    file_count=$(echo "$files" | wc -l)
    total_size=$(du -ch $(echo "$files") 2>/dev/null | grep total$ | awk '{print $1}')

    echo "Old files: $file_count, Size: $total_size"
    read -p "Delete old Downloads files? (y/n): " confirm
    if [[ "$confirm" == "y" ]]; then
        echo "$files" | xargs rm -f
        echo "Old downloads deleted."
    else
        echo "Skipped."
    fi
}

# Main menu
while true; do
    echo ""
    echo "Choose an option:"
    echo "1. View Disk Usage"
    echo "2. Clean Apt Cache"
    echo "3. Clean Thumbnail Cache"
    echo "4. Clean System Logs"
    echo "5. Delete Old Downloads (30+ days)"
    echo "6. Exit"
    read -p "Enter your choice [1-6]: " choice

    case $choice in
        1) view_disk_usage ;;
        2) clean_apt_cache ;;
        3) clean_thumbnails ;;
        4) clean_system_logs ;;
        5) clean_old_downloads ;;
        6) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid option. Try again." ;;
    esac
done