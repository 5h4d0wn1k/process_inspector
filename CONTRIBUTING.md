# Contributing to Process Inspector

Thanks for contributing.

This repository is a small Linux and cybersecurity learning project, not a large production framework. The best contributions make the tool clearer, more accurate, and more educational without adding unnecessary complexity.

## What Fits Well

Good contribution areas:

- bug fixes in `/proc` parsing
- clearer Bash implementation
- better output formatting
- documentation improvements
- sample outputs from different process types
- small, well-scoped Linux process inspection features

## Contribution Principles

Please keep these constraints in mind:

1. Stay close to the Linux fundamentals the project is teaching.
2. Prefer direct `/proc` inspection over heavyweight abstractions.
3. Optimize for readability. Someone newer to Linux should be able to learn from the code.
4. Keep scope realistic for an incremental learning repo.
5. Handle permission errors and disappearing processes gracefully.

## Before Opening a Pull Request

Run the basic checks you can:

```bash
bash -n inspector.sh
./inspector.sh $$
./inspector.sh 1
```

If available:

```bash
shellcheck inspector.sh
```

When testing, it is useful to compare different kinds of processes:

- your current shell
- PID `1`
- a background service
- a process with sockets or pipes open

## Pull Request Guidelines

- Keep pull requests focused.
- Explain what Linux concept or user problem the change improves.
- Update the README if behavior or output changes.
- Avoid large refactors unless there is a strong reason.
- Do not turn the repo into a general-purpose framework in one jump.

## Reporting Issues

When opening a bug report, include:

- Linux distribution and kernel version if relevant
- `bash` version
- the command you ran
- the PID or process type you inspected
- what you expected
- what actually happened

## Philosophy

The point of this repository is to build a strong mental model of:

`process -> /proc -> file descriptors -> terminals/files/pipes/sockets -> kernel`

If your change strengthens that model, it is probably a good fit.
