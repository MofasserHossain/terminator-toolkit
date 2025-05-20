#!/bin/bash

while true; do
    clear
    echo "📊 Smart Task Manager – Main Menu"
    echo "----------------------------------------"
    echo "1️⃣  View System Information"
    echo "2️⃣  View CPU Usage"
    echo "3️⃣  View Memory Usage"
    echo "4️⃣  View Disk Usage"
    echo "5️⃣  View Uptime"
    echo "6️⃣  View Running Process Count"
    echo "7️⃣  View Top Processes (by CPU)"
    echo "8️⃣  Kill a Process by PID"
    echo "9️⃣  Exit"
    echo "----------------------------------------"
    read -p "📥 Enter your choice [1-9]: " choice

    echo "----------------------------------------"
    case $choice in
        1)
            echo "📅 Date & Time: $(date)"
            echo "🖥️ OS: $(uname -o)"
            echo "🐧 Kernel: $(uname -r)"
            ;;
        2)
            top -bn1 | grep "Cpu(s)" | awk '{print "🧠 CPU Usage: " 100 - $8 "%"}'
            ;;
        3)
            free -h | awk '/Mem:/ {print "💾 Memory Usage: " $3 " / " $2}'
            ;;
        4)
            df -h / | awk 'NR==2 {print "🗄️ Disk Usage: " $3 " / " $2}'
            ;;
        5)
            echo "⏳ Uptime: $(uptime -p)"
            ;;
        6)
            process_count=$(ps aux | wc -l)
            echo "🔢 Total Running Processes: $process_count"
            ;;
        7)
            printf "%-6s %-20s %-8s %-8s\n" "PID" "Process" "CPU(%)" "MEM(%)"
            echo "----------------------------------------"
            ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 10
            ;;
        8)
            read -p "🔪 Enter PID to kill: " pid
            if kill -9 "$pid" 2>/dev/null; then
                echo "✅ Process $pid killed successfully."
            else
                echo "❌ Failed to kill process $pid. Check PID or permissions."
            fi
            ;;
        9)
            echo "👋 Exiting Smart Task Manager. Goodbye!"
            exit 0
            ;;
        *)
            echo "⚠️ Invalid choice. Please enter a number from 1 to 9."
            ;;
    esac

    echo "----------------------------------------"
    read -p "🔁 Press Enter to return to menu..."
done