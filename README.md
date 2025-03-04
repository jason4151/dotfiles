# Dot Files

This repository contains my personal dotfiles (e.g., `bashrc`, `bash_profile`) for a consistent shell environment across CentOS Stream 10, Ubuntu 24.04, and macOS Sequoia. The `setup_dotfiles.sh` script automates cloning, updating, symlinking, and sourcing these files from `~/Projects/dotfiles` to your home directory.

## Prerequisites

- **Git**: Installed on your system.
  - CentOS: `sudo dnf install git`
  - Ubuntu: `sudo apt install git`
  - macOS: `brew install git`
- **SSH Key**: Added to GitHub for passwordless access.
  - Generate: `ssh-keygen -t rsa -b 4096 -C "jason4151@MBP"`
  - Add to GitHub: Copy `~/.ssh/id_rsa.pub` to [GitHub SSH settings](https://github.com/settings/keys).

## Setup Instructions

### Deploy to Each System
On each machine (CentOS, Ubuntu, macOS), run the setup script to clone or update the repo and symlink the dotfiles:

### Download and run the script
```bash
bash <(curl -s https://raw.githubusercontent.com/jason4151/dotfiles/main/setup_dotfiles.sh)