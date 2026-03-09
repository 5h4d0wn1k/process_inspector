#!/usr/bin/env bash

# Lightweight /proc inspector for the first public version of the project.
# Scope is intentionally small: process identity, command, cwd, and open FDs.

set -u

if [[ -t 1 ]]; then
    RED=$'\033[0;31m'
    GREEN=$'\033[0;32m'
    YELLOW=$'\033[0;33m'
    CYAN=$'\033[0;36m'
    BOLD=$'\033[1m'
    NC=$'\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    CYAN=''
    BOLD=''
    NC=''
fi

print_usage() {
    cat <<'EOF'
Usage:
  ./inspector.sh <pid>
  ./inspector.sh --help

Description:
  Inspect a Linux process by reading /proc/<pid> directly.
  The script prints:
  - process name, PID, PPID, and state
  - command line
  - current working directory
  - open file descriptors and their target types

Examples:
  ./inspector.sh $$
  ./inspector.sh 1
EOF
}

print_header() {
    printf "%b\n" "${BOLD}${CYAN}============================================================${NC}"
    printf "%b\n" "${BOLD}${CYAN} Process Inspector: /proc walk for PID $1${NC}"
    printf "%b\n" "${BOLD}${CYAN}============================================================${NC}"
}

print_error() {
    printf "%b\n" "${RED}[ERROR] $1${NC}" >&2
}

print_info() {
    printf "%b%-18s%b : %s\n" "${BOLD}" "$1" "${NC}" "$2"
}

read_status_field() {
    local key="$1"
    local status_file="$2"

    awk -F ':' -v key="$key" '
        $1 == key {
            sub(/^[[:space:]]+/, "", $2)
            print $2
            exit
        }
    ' "$status_file" 2>/dev/null
}

read_cmdline() {
    local proc_dir="$1"
    local cmdline=''
    local comm=''

    if [[ -r "$proc_dir/cmdline" ]]; then
        cmdline=$(tr '\0' ' ' < "$proc_dir/cmdline")
        cmdline="${cmdline%" "}"
    fi

    if [[ -n "$cmdline" ]]; then
        printf "%s\n" "$cmdline"
        return
    fi

    if [[ -r "$proc_dir/comm" ]]; then
        IFS= read -r comm < "$proc_dir/comm"
        printf "[%s] (no argv exposed in cmdline)\n" "$comm"
        return
    fi

    printf "Unavailable\n"
}

read_link_or_reason() {
    local path="$1"
    local target=''

    if target=$(readlink "$path" 2>/dev/null); then
        printf "%s\n" "$target"
        return
    fi

    if [[ -e "$path" || -L "$path" ]]; then
        printf "unavailable (permission denied or process changed state)\n"
        return
    fi

    printf "unavailable (fd disappeared while inspecting)\n"
}

classify_fd_target() {
    local target="$1"

    case "$target" in
        /dev/pts/*|/dev/tty*|/dev/console)
            printf "terminal\n"
            ;;
        socket:\[*\])
            printf "socket\n"
            ;;
        pipe:\[*\])
            printf "pipe\n"
            ;;
        anon_inode:*)
            printf "anon_inode\n"
            ;;
        /dev/*)
            printf "device\n"
            ;;
        /*)
            printf "file\n"
            ;;
        unavailable*)
            printf "unknown\n"
            ;;
        *)
            printf "other\n"
            ;;
    esac
}

print_fd_table() {
    local proc_dir="$1"
    local -a fd_numbers=()
    local fd_number=''
    local fd_path=''
    local target=''
    local fd_type=''

    printf "\n%b\n" "${BOLD}${CYAN}Open File Descriptors${NC}"
    printf "%-6s %-12s %s\n" "FD" "TYPE" "TARGET"
    printf "%-6s %-12s %s\n" "--" "----" "------"

    if [[ ! -d "$proc_dir/fd" ]]; then
        printf "%s\n" "N/A    unknown      /proc/<pid>/fd is not available"
        return
    fi

    mapfile -t fd_numbers < <(find "$proc_dir/fd" -mindepth 1 -maxdepth 1 -printf '%f\n' 2>/dev/null | sort -n)

    if [[ ${#fd_numbers[@]} -eq 0 ]]; then
        printf "%s\n" "N/A    unknown      no readable file descriptors (permission denied or none open)"
        return
    fi

    for fd_number in "${fd_numbers[@]}"; do
        fd_path="$proc_dir/fd/$fd_number"
        target=$(read_link_or_reason "$fd_path")
        fd_type=$(classify_fd_target "$target")
        printf "%-6s %-12s %s\n" "$fd_number" "$fd_type" "$target"
    done
}

main() {
    local pid="${1:-}"
    local proc_dir=''
    local name='Unavailable'
    local ppid='Unavailable'
    local state='Unavailable'
    local cmdline='Unavailable'
    local cwd='Unavailable'

    case "$pid" in
        "" )
            print_usage
            exit 1
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
    esac

    if [[ ! "$pid" =~ ^[0-9]+$ ]]; then
        print_error "PID must be a numeric value."
        exit 1
    fi

    proc_dir="/proc/$pid"

    if [[ ! -d "$proc_dir" ]]; then
        print_error "Process $pid does not exist, or /proc/$pid is not visible from this context."
        exit 1
    fi

    if [[ -r "$proc_dir/status" ]]; then
        name=$(read_status_field "Name" "$proc_dir/status")
        ppid=$(read_status_field "PPid" "$proc_dir/status")
        state=$(read_status_field "State" "$proc_dir/status")
    fi

    cmdline=$(read_cmdline "$proc_dir")

    if [[ -L "$proc_dir/cwd" || -e "$proc_dir/cwd" ]]; then
        cwd=$(read_link_or_reason "$proc_dir/cwd")
    fi

    print_header "$pid"
    print_info "Process Name" "${GREEN}${name:-Unavailable}${NC}"
    print_info "PID" "${GREEN}$pid${NC}"
    print_info "PPID" "${GREEN}${ppid:-Unavailable}${NC}"
    print_info "State" "${GREEN}${state:-Unavailable}${NC}"
    print_info "Command" "${YELLOW}$cmdline${NC}"
    print_info "CWD" "${YELLOW}$cwd${NC}"

    print_fd_table "$proc_dir"

    printf "\n%b\n" "${BOLD}${CYAN}Tip:${NC} sockets and pipes are shown as kernel-managed objects, while terminal and file entries resolve to real paths."
}

main "$@"
