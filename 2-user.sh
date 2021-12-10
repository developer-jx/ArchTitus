#!/usr/bin/env bash
#-------------------------------------------------------------------------
#  █████╗ ██████╗  ██████╗██╗  ██╗ ██╗  ██╗
# ██╔══██╗██╔══██╗██╔════╝██║  ██║ ╚██╗██╔╝
# ███████║██████╔╝██║     ███████║  ╚███╔╝ 
# ██╔══██║██╔══██╗██║     ██╔══██║  ██╔██╗ 
# ██║  ██║██║  ██║╚██████╗██║  ██║ ██╔╝ ██╗
# ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝ ╚═╝  ╚═╝
# A fork of ArchTitus through GitHub.
#-------------------------------------------------------------------------

echo -e "\n[ArchX] Installing AUR helper called YAY.\n" && sleep 2
# You can solve users running this script as root with this and then doing the same for the next for statement. However I will leave this up to you.

echo "[ArchX] Cloning YAY from AUR repository."
cd ~
git clone "https://aur.archlinux.org/yay.git"
cd ${HOME}/yay
makepkg -si --noconfirm
cd ~
touch "$HOME/.cache/zshhistory"
git clone "https://github.com/ChrisTitusTech/zsh"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/powerlevel10k
ln -s "$HOME/zsh/.zshrc" $HOME/.zshrc

PKGS=(
# ARCHTITUS LEFTOVERS
#'lightly-git' # KDE. A modern style for qt applications
#'lightlyshaders-git' # KDE. Round corners and outline effect for KWin
#'plasma-pa' # Volume applet for Plasma
#
# THEME LEFTOVERS
# Nordic Theme
# 'nordic-darker-standard-buttons-theme'
# 'nordic-darker-theme'
# 'nordic-kde-git'
# 'nordic-theme'
# 'sddm-nordic-theme-git'
#
# Icons
#'papirus-icon-theme'
#
'autojump' # A faster way to navigate your filesystem from the command line
'awesome-terminal-fonts' # fonts/icons for powerlines
'brave-bin' # Brave Browser
'dxvk-bin' # DXVK DirectX to Vulcan
'github-desktop-bin' # Github Desktop sync
'mangohud' # Gaming FPS Counter
'mangohud-common' # Gaming FPS Counter
'nerd-fonts-fira-code' # Patched font Fira (Fura) Code from the nerd-fonts library
'noto-fonts-emoji' # Google Noto emoji fonts
'ocs-url' # install packages from websites
'snapper-gui-git' # Gui for snapper, a tool of managing snapshots of Btrfs subvolumes and LVM volumes
'ttf-droid' # Droid font
'ttf-hack' # Hack font
'ttf-meslo' # Nerdfont package, Font for powerlevel10k
'zoom' # video conferences
'snap-pac' # Pacman hooks that use snapper to create pre/post btrfs snapshots like openSUSE's YaST
#
# Fonts
'ttf-droid' # Droid font
'ttf-hack' # Hack font
'ttf-meslo' # Nerdfont package, Font for powerlevel10k
'ttf-roboto' # Roboto font
#
# archX added packages
'vscodium-bin'
'firefox'
'firefox-developer-edition'
'anydesk-bin'
)

for PKG in "${PKGS[@]}"; do
    yay -S --noconfirm $PKG
done

export PATH=$PATH:~/.local/bin
cp -r $HOME/ArchTitus/dotfiles/* $HOME/.config/


# #REMOVED -- Archived ARCHTITUS configuration pass-over.
export PATH=$PATH:~/.local/bin
cp -r $HOME/ArchTitus/dotfiles/* $HOME/.config/
pip install konsave
konsave -i $HOME/ArchTitus/kde.knsv
sleep 1
konsave -a kde

echo -e "\n[ArchX] Done setting up users and AUR! Proceeding to post-setup configuration.\n"
exit
