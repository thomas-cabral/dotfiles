#!/bin/bash

# Dotfiles Setup Script
# This script creates symlinks from the dotfiles repo to ~/.config

DOTFILES_DIR="$HOME/dotfiles"
HYPRLAND_DIR="$DOTFILES_DIR/hyprland"
CONFIG_DIR="$HOME/.config"

echo "Setting up dotfiles..."

# Backup existing configs if they exist and aren't symlinks
backup_if_exists() {
    if [ -e "$1" ] && [ ! -L "$1" ]; then
        echo "Backing up existing $1 to $1.backup"
        mv "$1" "$1.backup"
    fi
}

# Create symlinks
create_symlink() {
    local source="$1"
    local target="$2"
    
    # Remove existing symlink if it exists
    if [ -L "$target" ]; then
        rm "$target"
    fi
    
    # Backup existing directory/file
    backup_if_exists "$target"
    
    # Create the symlink
    ln -s "$source" "$target"
    echo "Created symlink: $target -> $source"
}

# Hyprland configs
create_symlink "$HYPRLAND_DIR/hypr" "$CONFIG_DIR/hypr"
create_symlink "$HYPRLAND_DIR/waybar" "$CONFIG_DIR/waybar"
create_symlink "$HYPRLAND_DIR/wlogout" "$CONFIG_DIR/wlogout"
create_symlink "$HYPRLAND_DIR/wofi" "$CONFIG_DIR/wofi"

# Neovim config
create_symlink "$DOTFILES_DIR/nvim" "$CONFIG_DIR/nvim"

# WezTerm config (goes in home directory, not .config)
create_symlink "$DOTFILES_DIR/.wezterm.lua" "$HOME/.wezterm.lua"

echo "Dotfiles setup complete!"
echo ""
echo "To add more configs to the repo:"
echo "  1. Copy the config to ~/dotfiles/hyprland/"
echo "  2. Add the symlink creation to this script"
echo "  3. Run this script again"
echo ""
echo "To push to GitHub:"
echo "  cd ~/dotfiles"
echo "  git add ."
echo "  git commit -m 'Your message'"
echo "  git remote add origin YOUR_GITHUB_REPO_URL"
echo "  git push -u origin main"