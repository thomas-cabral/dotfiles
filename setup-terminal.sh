#!/bin/bash

# Terminal Setup Script - WezTerm and Neovim Configuration
# This script configures WezTerm terminal and Neovim editor

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${CYAN}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Get dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_status "Starting terminal environment setup..."

# Check for required tools
check_dependencies() {
    print_status "Checking dependencies..."
    
    local missing_deps=()
    
    # Check for git
    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
    fi
    
    # Check for curl or wget
    if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
        missing_deps+=("curl or wget")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        print_status "Please install missing dependencies and run again."
        exit 1
    fi
    
    print_success "All basic dependencies satisfied"
}

# WezTerm Setup
setup_wezterm() {
    print_status "Setting up WezTerm..."
    
    # Check if WezTerm is installed
    if ! command -v wezterm &> /dev/null; then
        print_warning "WezTerm is not installed."
        print_status "Please install WezTerm from: https://wezfurlong.org/wezterm/installation"
        print_status "Or use your package manager:"
        echo "  - macOS: brew install --cask wezterm"
        echo "  - Ubuntu/Debian: See official installation guide"
        echo "  - Arch: pacman -S wezterm"
        return 1
    fi
    
    # Create config directory if it doesn't exist
    mkdir -p "$HOME/.config/wezterm"
    
    # Link WezTerm configuration
    if [ -f "$DOTFILES_DIR/.wezterm.lua" ]; then
        if [ -f "$HOME/.wezterm.lua" ] || [ -L "$HOME/.wezterm.lua" ]; then
            print_warning "WezTerm config already exists at ~/.wezterm.lua"
            read -p "Do you want to replace it? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                rm -f "$HOME/.wezterm.lua"
                ln -sf "$DOTFILES_DIR/.wezterm.lua" "$HOME/.wezterm.lua"
                print_success "WezTerm configuration linked"
            else
                print_warning "Skipping WezTerm configuration"
            fi
        else
            ln -sf "$DOTFILES_DIR/.wezterm.lua" "$HOME/.wezterm.lua"
            print_success "WezTerm configuration linked"
        fi
    else
        print_warning "WezTerm configuration not found in dotfiles"
    fi
    
    # Also check for config in .config directory
    if [ -f "$HOME/.config/wezterm/wezterm.lua" ] || [ -L "$HOME/.config/wezterm/wezterm.lua" ]; then
        print_warning "WezTerm config also exists at ~/.config/wezterm/wezterm.lua"
        print_status "WezTerm will prioritize ~/.wezterm.lua over ~/.config/wezterm/wezterm.lua"
    fi
}

# Neovim Setup
setup_neovim() {
    print_status "Setting up Neovim..."
    
    # Check if Neovim is installed
    if ! command -v nvim &> /dev/null; then
        print_warning "Neovim is not installed."
        print_status "Installing Neovim..."
        
        # Try to install based on the system
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y neovim
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm neovim
        elif command -v brew &> /dev/null; then
            brew install neovim
        else
            print_error "Could not automatically install Neovim"
            print_status "Please install Neovim manually: https://neovim.io/"
            return 1
        fi
    fi
    
    # Check Neovim version (LazyVim requires 0.8+)
    nvim_version=$(nvim --version | head -n1 | cut -d' ' -f2)
    print_status "Neovim version: $nvim_version"
    
    # Create config directory
    mkdir -p "$HOME/.config"
    
    # Backup existing configuration if it exists
    if [ -d "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
        print_warning "Existing Neovim configuration found"
        read -p "Do you want to backup and replace it? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            backup_dir="$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
            mv "$HOME/.config/nvim" "$backup_dir"
            print_success "Backed up existing config to: $backup_dir"
        else
            print_warning "Skipping Neovim configuration"
            return 0
        fi
    fi
    
    # Remove existing symlink if it exists
    if [ -L "$HOME/.config/nvim" ]; then
        rm "$HOME/.config/nvim"
    fi
    
    # Link Neovim configuration
    if [ -d "$DOTFILES_DIR/nvim" ]; then
        ln -sf "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
        print_success "Neovim configuration linked"
    else
        print_error "Neovim configuration directory not found in dotfiles"
        return 1
    fi
    
    # Install additional dependencies for Neovim
    print_status "Installing Neovim dependencies..."
    
    # Check for node/npm (needed for many LSP servers)
    if ! command -v node &> /dev/null; then
        print_warning "Node.js is not installed (required for many LSP servers)"
        print_status "Consider installing Node.js for full functionality"
    fi
    
    # Check for ripgrep (needed for telescope)
    if ! command -v rg &> /dev/null; then
        print_warning "ripgrep is not installed (required for telescope search)"
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y ripgrep
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm ripgrep
        elif command -v brew &> /dev/null; then
            brew install ripgrep
        fi
    fi
    
    # Check for fd (optional but recommended for telescope)
    if ! command -v fd &> /dev/null; then
        print_warning "fd is not installed (recommended for telescope)"
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y fd-find
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm fd
        elif command -v brew &> /dev/null; then
            brew install fd
        fi
    fi
    
    print_status "Opening Neovim to install plugins..."
    print_status "Lazy.nvim will automatically install plugins on first launch"
    print_warning "Press 'q' when plugin installation is complete"
    
    # Start Neovim to trigger plugin installation
    nvim +LazyInstall +qa || true
    
    print_success "Neovim setup complete!"
}

# Post-setup information
show_post_setup_info() {
    echo
    print_success "Terminal environment setup complete!"
    echo
    echo "Quick start guide:"
    echo "  - WezTerm: Run 'wezterm' to start the terminal"
    echo "  - Neovim: Run 'nvim' to start the editor"
    echo
    echo "Configuration locations:"
    echo "  - WezTerm: ~/.wezterm.lua"
    echo "  - Neovim: ~/.config/nvim/"
    echo
    echo "Tips:"
    echo "  - WezTerm: Press Ctrl+Shift+P to open command palette"
    echo "  - Neovim: Use :Mason to manage LSP servers"
    echo "  - Neovim: Use :Lazy to manage plugins"
    echo
}

# Main execution
main() {
    echo "================================================"
    echo "     Terminal Environment Setup Script"
    echo "     WezTerm + Neovim Configuration"
    echo "================================================"
    echo
    
    check_dependencies
    
    # Setup WezTerm
    setup_wezterm || print_warning "WezTerm setup incomplete"
    
    echo
    
    # Setup Neovim
    setup_neovim || print_warning "Neovim setup incomplete"
    
    # Show post-setup information
    show_post_setup_info
}

# Run main function
main "$@"