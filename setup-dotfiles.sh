#!/bin/bash
# setup-dotfiles.sh
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

# Symlink dotfiles
echo "Symlinking dotfiles from $DOTFILES_DIR..."
for file in "$DOTFILES_DIR"/.*; do
    filename=$(basename "$file")
    # Skip .git, ., .., and the script itself
    if [[ "$filename" == ".git" || "$filename" == "." || "$filename" == ".." || "$filename" == ".setup-dotfiles.sh" ]]; then
        continue
    fi
    target="$HOME/$filename"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo "Backing up existing $target to $target.bak"
        mv "$target" "$target.bak"
    fi
    ln -sf "$file" "$target"
done

# Source .bashrc automatically
if [ -f "$HOME/.bashrc" ]; then
    echo "Sourcing ~/.bashrc to apply changes..."
    source "$HOME/.bashrc"
else
    echo "Warning: ~/.bashrc not found after setup."
fi

echo "Dotfiles setup complete."