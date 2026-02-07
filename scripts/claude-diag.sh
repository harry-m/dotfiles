#!/bin/bash
# claude-diag.sh — Quick diagnostic snapshot for Claude Code performance
# Run this when things feel slow to capture the state

BOLD='\033[1m'
DIM='\033[2m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
RESET='\033[0m'

divider() {
    echo -e "${DIM}$(printf '%.0s─' {1..60})${RESET}"
}

echo -e "\n${BOLD}Claude Code Diagnostic Snapshot${RESET}"
echo -e "${DIM}$(date '+%Y-%m-%d %H:%M:%S')${RESET}"
divider

# --- System memory ---
echo -e "\n${BOLD}Memory${RESET}"
read total used free bufcache avail <<< $(free -m | awk '/^Mem:/ {print $2, $3, $4, $6, $7}')
pct_used=$((used * 100 / total))
colour=$GREEN
[[ $pct_used -gt 70 ]] && colour=$YELLOW
[[ $pct_used -gt 90 ]] && colour=$RED
echo -e "  Total: ${total}MB  Used: ${colour}${used}MB (${pct_used}%)${RESET}  Available: ${avail}MB"

# --- Swap ---
echo -e "\n${BOLD}Swap${RESET}"
read stotal sused sfree <<< $(free -m | awk '/^Swap:/ {print $2, $3, $4}')
if [[ $stotal -eq 0 ]]; then
    echo -e "  No swap configured"
else
    spct=$((sused * 100 / stotal))
    colour=$GREEN
    [[ $spct -gt 10 ]] && colour=$YELLOW
    [[ $spct -gt 50 ]] && colour=$RED
    echo -e "  Total: ${stotal}MB  Used: ${colour}${sused}MB (${spct}%)${RESET}  Free: ${sfree}MB"
fi

# --- CPU overview ---
echo -e "\n${BOLD}CPU${RESET}"
loadavg=$(cat /proc/loadavg | awk '{print $1, $2, $3}')
ncpu=$(nproc)
echo -e "  Cores: ${ncpu}  Load average: ${loadavg}"

# --- Node.js heap limit ---
echo -e "\n${BOLD}Node.js Default Heap Limit${RESET}"
if command -v node &>/dev/null; then
    heap_limit=$(node -e "console.log(Math.round(v8.getHeapStatistics().heap_size_limit/1024/1024))")
    echo -e "  ${heap_limit}MB"
    [[ -n "$NODE_OPTIONS" ]] && echo -e "  NODE_OPTIONS: $NODE_OPTIONS"
else
    echo -e "  ${RED}node not found${RESET}"
fi

# --- Claude Code processes ---
echo -e "\n${BOLD}Claude Code Processes${RESET}"
claude_pids=$(ps aux | grep -i claude | grep -v -e avahi -e grep -e "watch.*claude" -e "claude-diag" | awk '{print $2}')
if [[ -z "$claude_pids" ]]; then
    echo -e "  ${DIM}No Claude processes running${RESET}"
else
    printf "  ${DIM}%-8s %6s %6s %s${RESET}\n" "PID" "CPU%" "RSS MB" "COMMAND"
    divider
    for pid in $claude_pids; do
        if [[ -d /proc/$pid ]]; then
            rss_kb=$(awk '/^VmRSS:/ {print $2}' /proc/$pid/status 2>/dev/null)
            rss_mb=$((rss_kb / 1024))
            cpu=$(top -b -n1 -p $pid 2>/dev/null | awk -v p=$pid '$1 == p {print $9}')
            cmd=$(ps -p $pid -o args= 2>/dev/null | cut -c1-50)
            colour=$GREEN
            [[ $(echo "${cpu:-0} > 50" | bc 2>/dev/null) == "1" ]] && colour=$YELLOW
            [[ $(echo "${cpu:-0} > 90" | bc 2>/dev/null) == "1" ]] && colour=$RED
            printf "  %-8s ${colour}%5s%%${RESET} %5sMB  %s\n" "$pid" "${cpu:-0}" "$rss_mb" "$cmd"
        fi
    done
fi

# --- Node processes (non-claude, for context) ---
echo -e "\n${BOLD}All Node.js Processes${RESET}"
node_pids=$(pgrep -f "^node\b|/node " 2>/dev/null)
if [[ -z "$node_pids" ]]; then
    echo -e "  ${DIM}No node processes running${RESET}"
else
    printf "  ${DIM}%-8s %6s %6s %s${RESET}\n" "PID" "CPU%" "RSS MB" "COMMAND"
    divider
    for pid in $node_pids; do
        if [[ -d /proc/$pid ]]; then
            rss_kb=$(awk '/^VmRSS:/ {print $2}' /proc/$pid/status 2>/dev/null)
            rss_mb=$((rss_kb / 1024))
            cpu=$(ps -p $pid -o %cpu= 2>/dev/null | tr -d ' ')
            cmd=$(ps -p $pid -o args= 2>/dev/null | cut -c1-50)
            printf "  %-8s %5s%% %5sMB  %s\n" "$pid" "$cpu" "$rss_mb" "$cmd"
        fi
    done
fi

# --- Disk I/O (quick check) ---
echo -e "\n${BOLD}Disk I/O${RESET}"
if command -v iostat &>/dev/null; then
    iostat -d -x 1 2 | tail -n +4 | grep -v "^$" | tail -n +3 | grep -v "^loop"
else
    echo -e "  ${DIM}iostat not available (install sysstat: sudo apt install sysstat)${RESET}"
    # fallback
    echo -e "  /proc/diskstats snapshot:"
    cat /proc/diskstats | awk '$3 ~ /^(sda|vda|nvme)/ && $3 !~ /^loop/ {printf "  %-10s reads: %-8s writes: %s\n", $3, $4, $8}'
fi

