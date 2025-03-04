#!/bin/bash
# setup-dotfiles.sh
# Clone or update 'dotfiles' repo to ~/Projects/dotfiles, symlink dotfiles to ~, and source .bashrc

DOTFILES_DIR="$HOME/Projects/dotfiles"
REPO_URL="git@github.com:jason4151/dotfiles.git"

# Ensure ~/Projects exists
[ -d "$HOME/Projects" ] || mkdir -p "$HOME/Projects"

# Clone or pull the repo
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Cloning dotfiles repo to $DOTFILES_DIR..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
else
    echo "Updating dotfiles repo in $DOTFILES_DIR..."
    cd "$DOTFILES_DIR"
    git pull origin main
fi

# Symlink dotfiles (only regular files starting with .)
echo "Symlinking dotfiles from $DOTFILES_DIR..."
for file in "$DOTFILES_DIR"/.[!.]*; do
    # Check if it's a regular file (not a dir or symlink)
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        # Skip the script itself
        if [[ "$filename" == "setup-dotfiles.sh" ]]; then
            continue
        fi
        target="$HOME/$filename"
        if [ -e "$target" ] && [ ! -L "$target" ]; then
            echo "Backing up existing $target to $target.bak"
            mv "$target" "$target.bak"
        fi
        ln -sf "$file" "$target"
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