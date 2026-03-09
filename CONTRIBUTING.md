# Contributing to Process Inspector

First off, thank you for considering contributing to the Process Inspector! It's people like you that make open source such a great community to learn, inspire, and create.

## 🧠 Philosophy
This tool was built out of a desire to understand **how Linux actually works** under the hood, specifically focusing on processes and File Descriptors as seen via the `/proc` filesystem.

If you are a student, a cybersecurity enthusiast, or a system administrator looking to demystify Linux, this is your playground.

## 🐛 Submitting Bugs
*   Check the issue tracker to ensure the bug hasn't already been reported.
*   Clearly describe the steps to reproduce the issue.
*   Include your OS version and bash version.

## 🚀 Proposing Features
*   Open an issue to discuss your feature idea before writing a massive pull request.
*   Features should align with the core philosophy: **Educational, Lightweight, and observability-focused.**

## 🛠️ Submitting Pull Requests
1.  **Fork** the repo on GitHub.
2.  **Clone** the project to your own machine.
3.  **Create a branch** for your feature or fix (`git checkout -b feature/my-cool-feature`).
4.  **Make your changes**. Ensure your bash script adheres to basic linting (e.g., it should pass `shellcheck inspector.sh` without major warnings).
5.  **Test** your changes locally by running against your own processes (`./inspector.sh $$`) and system processes (`sudo ./inspector.sh 1`).
6.  **Commit** with clear, descriptive commit messages.
7.  **Push** to your fork and **Submit a Pull Request** to the `master` branch of this repository.

## 📝 Code Style & Guidelines
*   **Keep it readable:** Use comments. Remember, beginners will be reading this script to learn how Linux works. Explain *why* you are reading a specific file in `/proc`.
*   **Color Output:** Use the existing color variables (`$RED`, `$GREEN`, etc.) to keep output clean and readable.
*   **Fail Gracefully:** If a file in `/proc` cannot be read due to permissions (very common when not running as root), handle the error elegantly rather than throwing a raw bash permission denied error.
