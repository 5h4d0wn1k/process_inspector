# Process Inspector

`Process Inspector` is a Linux-focused Bash tool that walks `/proc/<pid>` and shows what a process looks like from the kernel's point of view.

Today, it focuses on the layer I am actively learning and rebuilding in public:

- process identity through `PID`, `PPID`, and state
- command lines from `/proc/<pid>/cmdline`
- current working directories from `/proc/<pid>/cwd`
- open file descriptors from `/proc/<pid>/fd`
- the difference between terminals, files, pipes, sockets, devices, and kernel-managed descriptors

This repository is intentionally small. It is not trying to be a replacement for `ps`, `lsof`, or `strace`. It is a first cybersecurity mini-project built to make Linux process internals legible before adding more advanced features over time.

[![License: MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](./LICENSE)
[![Platform: Linux](https://img.shields.io/badge/platform-Linux-blue.svg)](#)
[![Language: Bash](https://img.shields.io/badge/language-Bash-2ea44f.svg)](#)

## Why This Repo Exists

I am relearning Linux fundamentals in public so I can reason about systems at the level where cybersecurity actually happens:

- files and directories
- paths and permissions
- processes and file descriptors
- terminals, pipes, and sockets
- how the kernel exposes all of that through `/proc`

If I cannot clearly explain how a shell, a terminal, a pipe, or a process is wired under the hood, I cannot investigate suspicious behavior with confidence. This project is the first practical step in that direction.

## Current Scope

The current version is deliberately limited to the concepts I have already worked through:

1. Inspect one PID at a time.
2. Read directly from `/proc` instead of relying on higher-level wrappers.
3. Show the command, cwd, and open FDs in a format that is readable to beginners.
4. Classify FD targets so the output teaches something, not just dumps symlink targets.

Current FD classifications:

- `terminal`
- `file`
- `pipe`
- `socket`
- `device`
- `anon_inode`
- `other`
- `unknown`

## Why It Matters for Cybersecurity

Understanding `/proc` is useful because it turns abstract Linux ideas into evidence you can inspect:

- A process is not just "a running program". It has a PID, a parent, a state, a cwd, and a set of live handles to resources.
- File descriptors are how a process talks to the world. `0`, `1`, and `2` are just the beginning.
- `/dev/pts/*` explains where terminal input and output actually flow.
- `pipe:[...]` and `socket:[...]` show when a process is connected to other processes or network activity.
- Kernel-exposed metadata is the foundation for later work in incident response, malware analysis, runtime visibility, and defensive tooling.

This repo is educational first, but the mental model behind it is directly relevant to real security work.

## Example Output

Illustrative sample from inspecting a shell process:

```text
============================================================
 Process Inspector: /proc walk for PID 1299923
============================================================
Process Name       : bash
PID                : 1299923
PPID               : 1227398
State              : S (sleeping)
Command            : bash ./inspector.sh 1299923
CWD                : /mnt/windows/transfer/Work/Cybersecurity/projects/process_inspector

Open File Descriptors
FD     TYPE         TARGET
--     ----         ------
0      terminal     /dev/pts/3
1      terminal     /dev/pts/3
2      terminal     /dev/pts/3
255    file         /mnt/windows/transfer/Work/Cybersecurity/projects/process_inspector/inspector.sh

Tip: sockets and pipes are shown as kernel-managed objects, while terminal and file entries resolve to real paths.
```

Full sample: [`examples/current-shell-output.txt`](./examples/current-shell-output.txt)

## Getting Started

### Requirements

- Linux
- `bash`
- read access to `/proc/<pid>`
- `sudo` if you want to inspect processes owned by another user

### Clone

```bash
git clone https://github.com/5h4d0wn1k/process_inspector.git
cd process_inspector
```

### Run

```bash
chmod +x inspector.sh
./inspector.sh $$
```

Inspect another process:

```bash
./inspector.sh 1
sudo ./inspector.sh "$(pidof sshd | awk '{print $1}')"
```

Show help:

```bash
./inspector.sh --help
```

## How It Works

The script reads the same kernel-backed files you can inspect manually:

- `/proc/<pid>/status` for process name, state, and parent PID
- `/proc/<pid>/cmdline` for the null-separated command line
- `/proc/<pid>/cwd` for the current working directory symlink
- `/proc/<pid>/fd/*` for open file descriptor symlinks

That design keeps the project close to the Linux fundamentals it is meant to teach.

## Repository Layout

```text
.
├── CONTRIBUTING.md
├── examples/
│   └── current-shell-output.txt
├── inspector.sh
├── LICENSE
├── README.md
└── SECURITY.md
```

## Development

The project is intentionally dependency-light.

Basic local checks:

```bash
bash -n inspector.sh
./inspector.sh $$
./inspector.sh 1
```

If you have `shellcheck` installed, run:

```bash
shellcheck inspector.sh
```

## Project Status

This is an early-stage educational cybersecurity repository.

- Linux-only
- Bash-only for now
- focused on `/proc` and file-descriptor visibility
- not intended to replace mature forensic or observability tools
- designed to grow gradually as my Linux and cybersecurity understanding deepens

## Roadmap

Near-term ideas that still fit the learning path:

- add executable path inspection from `/proc/<pid>/exe`
- add optional environment inspection from `/proc/<pid>/environ`
- add memory map inspection from `/proc/<pid>/maps`
- add better socket context by correlating inode-backed sockets
- add a mode to inspect multiple PIDs or walk all numeric `/proc` entries

## Contributing

Contributions are welcome, especially if they keep the repo beginner-readable and aligned with the project's educational scope.

See [`CONTRIBUTING.md`](./CONTRIBUTING.md).

## License

Released under the MIT License. See [`LICENSE`](./LICENSE).
