#!/usr/bin/env bash

# ==============================================================================
#  ____                               ___                           _             
# |  _ \ _ __ ___   ___ ___  ___ ___ |_ _|_ __  ___ _ __   ___  ___| |_ ___  _ __ 
# | |_) | '__/ _ \ / __/ _ \/ __/ __| | || '_ \/ __| '_ \ / _ \/ __| __/ _ \| '__|
# |  __/| | | (_) | (_|  __/\__ \__ \ | || | | \__ \ |_) |  __/ (__| || (_) | |   
# |_|   |_|  \___/ \___\___||___/___/|___|_| |_|___/ .__/ \___|\___|\__\___/|_|   
#                                                  |_|                            
#                                                                           
# A lightweight, educational tool to demystify Linux processes, the /proc 
# filesystem, and exactly how everything maps to File Descriptors under the hood.
# 
# Author   : Process Inspector Contributors
# License  : MIT
# Version  : 1.0.0
# GitHub   : https://github.com/5h4d0wn1k/process_inspector
# ==============================================================================

# --- ANSI Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# --- Functions ---

print_header() {
    echo -e "${BOLD}${CYAN}==========================================${NC}"
    echo -e "${BOLD}${CYAN}      Process Inspector (PID: $1)${NC}"
    echo -e "${BOLD}${CYAN}==========================================${NC}"
}

print_error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
}

print_info() {
    printf "${BOLD}%-20s${NC} : %b\n" "$1" "$2"
}

# --- Main Logic ---

# Check if a PID was provided
if [ -z "$1" ]; then
    print_error "Usage: $0 <PID>"
    exit 1
fi

PID="$1"
PROC_DIR="/proc/$PID"

# Check if the process exists
if [ ! -d "$PROC_DIR" ]; then
    print_error "Process with PID $PID does not exist. (Or you lack permissions to view its /proc directory)."
    exit 1
fi

print_header "$PID"

# 1. Command Line (/proc/[pid]/cmdline is null-separated)
if [ -f "$PROC_DIR/cmdline" ]; then
    # Use tr to replace null bytes with spaces for readability
    CMD_LINE=$(tr '\0' ' ' < "$PROC_DIR/cmdline")
    
    # If it's a kernel thread, cmdline might be empty, try stat or comm
    if [ -z "$CMD_LINE" ]; then
        if [ -f "$PROC_DIR/comm" ]; then
             CMD_LINE="[$(cat "$PROC_DIR/comm")] (Kernel Thread / No cmdline)"
        fi
    fi
    print_info "Command" "${GREEN}$CMD_LINE${NC}"
else
    print_info "Command" "${RED}N/A${NC}"
fi

# 2. Current Working Directory (/proc/[pid]/cwd is a symlink)
if [ -L "$PROC_DIR/cwd" ]; then
    CWD=$(readlink "$PROC_DIR/cwd")
    print_info "CWD" "${YELLOW}$CWD${NC}"
else
    # Might lack permission to readlink, or process is a zombie
    if [ -r "$PROC_DIR/cwd" ]; then
         print_info "CWD" "${RED}Cannot resolve link (Permission denied?)${NC}"
    else
         print_info "CWD" "${RED}Permission denied to read cwd${NC}"
    fi
fi

# 3. Open File Descriptors (symlinks inside /proc/[pid]/fd/)
echo -e "\n${BOLD}${CYAN}--- Open File Descriptors ---${NC}"

if [ -d "$PROC_DIR/fd" ] && [ -r "$PROC_DIR/fd" ]; then
    # List all FDs and resolve where they point
    # We use subshell and loop to handle potential permission issues on individual fds gracefully
    
    # Check if directory is empty
    if [ -z "$(ls -A "$PROC_DIR/fd" 2>/dev/null)" ]; then
        echo "No open file descriptors found or permission denied."
    else
        # We want to sort them numerically
        for fd_path in $(ls -v "$PROC_DIR/fd/"); do
            target=$(readlink "$PROC_DIR/fd/$fd_path" 2>/dev/null)
            if [ -z "$target" ]; then
                # Handle cases where readlink fails (e.g., permission denied on the symlink)
                target="${RED}(Permission Denied or Broken Link)${NC}"
            fi
            printf "  FD %-4s -> %b\n" "$fd_path" "$target"
        done
    fi
else
    print_error "Cannot read $PROC_DIR/fd. Permission denied. (Try running with sudo)"
fi

echo -e "${BOLD}${CYAN}==========================================${NC}"
