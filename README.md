# Hyprland Dotfiles

My personal Hyprland configuration files for Wayland desktop environment.

## Contents

- **hypr/** - Hyprland window manager configuration
- **waybar/** - Status bar configuration  
- **wlogout/** - Logout menu configuration
- **wofi/** - Application launcher configuration

## Installation

1. Clone this repository:
```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
```

2. Run the setup script to create symlinks:
```bash
cd ~/dotfiles
./setup.sh
```

## Configuration Details

### Monitor Setup
- Primary monitor (DP-1): Workspaces 1-5
- Secondary monitor (DP-2): Workspaces 6-9

### Key Bindings
- `Super + E`: Open file manager (Dolphin)
- `Super + Return`: Open terminal (Wezterm)
- `Super + Space`: Application launcher (Wofi)
- `Super + [1-9]`: Switch workspace
- `Print`: Screenshot area selection

### Features
- Auto-start applications configured
- Media controls in waybar
- Weather widget for Inverness, FL
- Screenshot functionality with grimblast
- Power menu with wlogout

## Dependencies

Required packages:
- hyprland
- waybar
- wlogout
- wofi
- swaylock
- swayidle
- grimblast
- playerctl
- wezterm
- dolphin

## Backup

Original configs are backed up with `.backup` extension when running the setup script.