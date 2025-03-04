#!/bin/bash
# setup_dotfiles.sh
# Clone or update 'dot-files' repo to ~/Projects/dot-files, symlink dotfiles to ~, and source .bashrc

DOTFILES_DIR="$HOME/Projects/dot-files"
REPO_URL="git@github.com:jason4151/dot-files.git"

# Ensure ~/Projects exists
[ -d "$HOME/Projects" ] || mkdir -p "$HOME/Projects"

# Clone or pull the repo
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Cloning dot-files repo to $DOTFILES_DIR..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
else
    echo "Updating dot-files repo in $DOTFILES_DIR..."
    cd "$DOTFILES_DIR"
    git pull origin main
fi

# Symlink dotfiles (only specific files)
echo "Symlinking dotfiles from $DOTFILES_DIR..."
for file in bashrc bash_profile; do
    source_file="$DOTFILES_DIR/$file"
    target_file="$HOME/.$file"
    if [ -f "$source_file" ]; then
        if [ -e "$target_file" ] && [ ! -L "$target_file" ]; then
            echo "Backing up existing $target_file to $target_file.bak"
            mv "$target_file" "$target_file.bak"
        fi
        ln -sf "$source_file" "$target_file"
    fi
done

# Source .bashrc automatically
if [ -f "$HOME/.bashrc" ]; then
    echo "Sourcing ~/.bashrc to apply changes..."
    source "$HOME/.bashrc"
else
    echo "Warning: ~/.bashrc not found after setup."
fi

echo "Dotfiles setup complete."