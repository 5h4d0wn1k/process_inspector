# Process Inspector

**A lightweight, educational tool to demystify Linux processes, the `/proc` filesystem, and File Descriptors (FDs).**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Language-Bash-green.svg)]()
[![Platform](https://img.shields.io/badge/Platform-Linux-blue.svg)]()

## 🔍 Overview

The **Process Inspector** is a minimalist Bash script designed to look under the hood of any running Linux process. Instead of just relying on tools like `ps`, `top`, or `htop`, this tool directly queries the kernel's virtual `/proc` filesystem to expose the raw reality of how processes are managed.

It walks the `/proc/[PID]/` directory and reveals:
- **Command Line:** The exact command and arguments used to start the process.
- **Current Working Directory (CWD):** The directory from which the process was launched.
- **Open File Descriptors (FDs):** A mapped list of every file, pipe, socket, and terminal the process is talking to (e.g., mapping FD `0`, `1`, `2` to `/dev/pts/*`).

This project is built for **cybersecurity enthusiasts, system administrators, and developers** who want to go beyond superficial command usage and build a deep mental model of the Linux OS layer.

---

## 🚀 Why This Matters for Security

*"I could use Linux. But I couldn't defend or break it with confidence."*

If you want to build systems that survive real-world attacks—or if you want to find vulnerabilities in them—you cannot afford a shallow understanding of the OS they run on. 

Understanding how the kernel exposes information via `/proc` helps you bridge the gap between "script-kiddie" usage and true systems comprehension:

1. **Processes as Open Files:** A process isn't just a running program; it's a PID attached to memory, parent processes, and numbered handles (File Descriptors) pointing to actual system resources.
2. **Symlinks as the Explanation Layer:** Seeing `FD 0 -> /dev/pts/1` in `/proc/<pid>/fd/` shows you exactly how standard input is wired to a physical or pseudo-terminal. This is the exact mechanism tools like `lsof` use under the hood.
3. **Paths and Permissions:** Understanding absolute vs. relative paths and integer-based file permissions (like `chmod 644` vs `700`) is what makes or breaks path traversal bugs and security misconfigurations.

By inspecting these elements manually, you learn to reason about how malware hides, how rootkits lie, and how defenders can detect them. Chains like `nginx → bash → curl → bash` stop looking like noise and start looking like maps worth investigating.

## 🛠️ Installation & Usage

### Prerequisites
- A Linux-based operating system.
- `bash` installed.
- Root (`sudo`) privileges are recommended when inspecting processes not owned by your user.

### Clone the Repository
```bash
git clone https://github.com/YOUR_USERNAME_HERE/process_inspector.git
cd process_inspector
```

### Run the Inspector
Make sure the script is executable:
```bash
chmod +x inspector.sh
```

Execute it by passing a Process ID (PID):
```bash
# Inspect your current shell
./inspector.sh $$

# Inspect a specific service (requires sudo if owned by another user, e.g., root)
sudo ./inspector.sh $(pidof sshd | awk '{print $1}')
```

### Example Output
```text
==========================================
      Process Inspector (PID: 12345)
==========================================
Command              : /usr/bin/bash
CWD                  : /home/user/projects/process_inspector

--- Open File Descriptors ---
  FD 0    -> /dev/pts/1
  FD 1    -> /dev/pts/1
  FD 2    -> /dev/pts/1
  FD 255  -> /dev/pts/1
==========================================
```

## 🌱 Future Roadmap

This tool represents the beginning of a deep-dive journey into Linux internals. Future planned features include:
- Inspecting memory maps (`/proc/[PID]/maps`).
- Dumping process environment variables securely (`/proc/[PID]/environ`).
- Tracing live system calls.
- Parent and child process tree visualizations.

## 🤝 Contributing
Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](). If you are learning Linux internals too, fork the repo and experiment.

## 📜 License
This project is licensed under the MIT License.
