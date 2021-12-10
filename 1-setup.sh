#!/usr/bin/env bash
#-------------------------------------------------------------------------
#   █████╗ ██████╗  ██████╗██╗  ██╗████████╗██╗████████╗██╗   ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝██║  ██║╚══██╔══╝██║╚══██╔══╝██║   ██║██╔════╝
#  ███████║██████╔╝██║     ███████║   ██║   ██║   ██║   ██║   ██║███████╗
#  ██╔══██║██╔══██╗██║     ██╔══██║   ██║   ██║   ██║   ██║   ██║╚════██║
#  ██║  ██║██║  ██║╚██████╗██║  ██║   ██║   ██║   ██║   ╚██████╔╝███████║
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝   ╚═╝    ╚═════╝ ╚══════╝
#-------------------------------------------------------------------------
echo "archX---------------------------------"
echo "--          Network Setup           --"
echo "--------------------------------------"
pacman -S networkmanager dhclient --noconfirm --needed
systemctl enable --now NetworkManager
echo "archX--------------------------------------------"
echo "    Setting up mirrors for optimal download      "
echo "-------------------------------------------------"
pacman -S --noconfirm pacman-contrib curl
pacman -S --noconfirm reflector rsync
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

nc=$(grep -c ^processor /proc/cpuinfo)
echo "You have " $nc" cores."
echo "-------------------------------------------------"
echo "Changing the makeflags for "$nc" cores."
TOTALMEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
if [[  $TOTALMEM -gt 8000000 ]]; then
sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$nc\"/g" /etc/makepkg.conf
echo "Changing the compression settings for "$nc" cores."
sed -i "s/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T $nc -z -)/g" /etc/makepkg.conf
fi
echo "archX-----------------------------------------------"
echo "   Set Language to US and locale to Manila (Asia)   "
echo "----------------------------------------------------"
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
timedatectl --no-ask-password set-timezone Asia/Manila
timedatectl --no-ask-password set-ntp 1
localectl --no-ask-password set-locale LANG="en_US.UTF-8" LC_TIME="en_US.UTF-8"

# Set keymaps
localectl --no-ask-password set-keymap us

# Add sudo no password rights
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

#Add parallel downloading
sed -i 's/^#Para/Para/' /etc/pacman.conf

#Enable multilib
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
pacman -Sy --noconfirm

echo -e "\n[ArchX] Beginning base system installation.\n"

PKGS=(
### Xorg --  open source implementation of the X Window System
'mesa' # Essential Xorg First
'xorg'
'xorg-server'
'xorg-apps'
'xorg-drivers'
'xorg-xkill'
'xorg-xinit'
'xterm'
#
#
### LINUX ARCH CORE -- Absolute Essentials
# Linux Kernel
'base' # Minimal package set to define a basic Arch Linux installation
'linux' # The Linux kernel and modules
'linux-firmware' #	Firmware files for Linux
'linux-headers' # Headers and scripts for building modules for the Linux kernel
#
# Processor Utilities
'haveged' # Entropy harvesting daemon using CPU timings; Deprecated soon due to integration into linux kernel
'm4' # 	The GNU macro processor
#
# Graphics Processor Utilities
'egl-wayland' # EGLStream-based Wayland external platform for NVIDIA GPU
'picom' # X compositor that may fix tearing issues
#
# System Chip Utilities
'swtpm' # Libtpms-based TPM emulator with socket, character device, and Linux CUSE interface
#
# Other Hardware
'dtc' # Hardware Info; Device Tree Compiler is a data structure for describing hardware
'usbutils' # A collection of USB tools to query connected USB devices
'synergy' # Share a single mouse and keyboard between multiple computers
#
# Fonts
'terminus-font' # Monospace bitmap font (for X11 and console)
'powerline-fonts' # patched fonts for powerline
#
# Audio [ALSA -- Advanced Linux Sound Architecture (ALSA) software framework]
# https://wiki.archlinux.org/title/Advanced_Linux_Sound_Architecture#ALSA_firmware
'alsa-firmware' # ALSA firmware
'sof-firmware' # Sound-Open firmware
'alsa-ucm-conf' # ALSA Use Case Manager configuration (and topologies)
'alsa-plugins' # ALSA plugins
'alsa-utils' # ALSA utils
'pulseaudio' # A tool for managing print jobs and printers
'pulseaudio-alsa' # ALSA Configuration for PulseAudio
'pulseaudio-bluetooth' # Bluetooth support for PulseAudio
#
#
## SHELL AND SCRIPTS
# Shell
'dialog' # A tool to display dialog boxes from shell scripts
'zsh' # Shell; A very advanced and programmable command interpreter (shell) for UNIX
'zsh-syntax-highlighting' # Shell Util; Fish shell like syntax highlighting for Zsh
'zsh-autosuggestions' # Shell Util; Fish-like autosuggestions for zsh
#
# Scripts
'python-notify2' # Python interface to DBus notifications
'python-psutil' # A cross-platform process and system utilities module for Python
'python-pyqt5' # A set of Python bindings for the Qt5 toolkit
'python-pip' # The PyPA recommended tool for installing Python packages
#
# Bootloader
'efibootmgr' # EFI boot
'grub' # Bootloader; GNU GRand Unified Bootloader (2)
'os-prober' # Utility to detect other OSes on a set of drives
#
# Filesystems and Hard Disks/SSDs
'btrfs-progs' # Btrfs filesystem utilities
'dosfstools' # DOS filesystem utilities
'ntfs-3g' # Open source implementation of Microsoft NTFS that includes read and write support.
'exfat-utils' # Utilities for exFAT filesystems
'xdg-user-dirs' # Manage user directories like ~/Desktop and ~/Music
#
# Network
'networkmanager' # Network connection manager and user applications
'bind' # Network DNS system; A complete, highly portable implementation of the DNS protocol
'bridge-utils' # Utilities for configuring the Linux ethernet bridge
'iptables-nft' # Linux kernel packet control tool (using nft interface)
'zeroconf-ioslave' # Network Monitor for DNS-SD services (Zeroconf)
'openbsd-netcat' # TCP/IP swiss army knife. OpenBSD variant.
'ufw' # Firewall; Uncomplicated and easy to use CLI tool for managing a netfilter firewall
#
# Time and Space
'ntp' # Network Time Protocol
#
#
## DAEMONS
# Print
'cups' # The CUPS Printing System - daemon package
'print-manager' # A tool for managing print jobs and printers
#
# Bluetooth
'bluez' # Daemons for the bluetooth protocol stack
'bluez-libs' # Deprecated libraries for the bluetooth protocol stack
'bluez-utils' # Development and debugging utilities for the bluetooth protocol stack
#
# Others
'cronie' # cron.d tool; Daemon that runs specified programs at scheduled times and related tools
#
# OS Installation Utility
'gamemode' # A daemon/lib combo that allows games to request a set of optimisations be temporarily applied to the host OS
#
# Post-setup Necessities
'sudo' # Give certain users the ability to run some commands as root
'pacman-contrib' # Contributed scripts and tools for pacman systems
'bash-completion' # Programmable completion for the bash shell
#
#
### BUILD TOOLS
'autoconf' # buildtool; Autoconf is an extensible package of M4 macros
'automake' # buildtool; GNU Automake is a tool for automatically generating Makefile.in files compliant with the GNU Coding Standards.
'make' # build; GNU make utility to maintain groups of programs
'gcc' # build; The GNU Compiler Collection - C and C++ frontends
'binutils' # A set of programs to assemble and manipulate binary and object files
'extra-cmake-modules' #	build; Extra modules and scripts for CMake
'pkgconf' # Package compiler and linker metadata toolkit
#
#
### TERMINAL UTILITIES
# Files and Directories
'rsync' # A fast and versatile file copying tool for remote and local files
'gptfdisk' # A text-mode partitioning tool that works on GUID Partition Table (GPT) disks
# Files and Text
'patch' # A utility to apply patch files to original sources
'bison' # The GNU general-purpose parser generator
'flex' # fast lexical analyzer generator; A tool for generating text-scanning programs
# File Editors
'nano' # Pico editor clone with enhancements
'vim' # Vi Improved, a highly configurable, improved version of the vi text editor
# Archives
'zip' # Compressor/archiver for creating and modifying zipfiles
'unrar' # The RAR uncompression program
'unzip' # For extracting and viewing files in .zip archives
'lzop' # File compressor using lzo lib
'p7zip' # Command-line file archiver with high compression ratio
# Network
'wget' # Downloader; Network utility to retrieve files from the Web
'traceroute' # Tracks the route taken by packets over an IP network
# Helpers
'which' # A utility to show the full path of commands
# Developer
'git' # Git repository manager
# System
'grub-customizer' # A graphical grub2 settings manager
'htop' # Interactive process viewer
'neofetch' # A CLI system information tool written in BASH that supports displaying images.
'lsof' # Lists open files for running Unix processes
'openssh' # Premier connectivity tool for remote login with the SSH protocol
# Backup
'snapper' # A tool for managing BTRFS and LVM snapshots. It can create, diff and restore snapshots and provides timelined auto-snapping.
#
#
### UTILITIES
# Virtualization
'virt-manager' # Desktop user interface for managing virtual machines
'virt-viewer' # A lightweight interface for interacting with the graphical display of virtualized guest OS.
# Wine
'wine-gecko' # Wine's built-in replacement for Microsoft's Internet Explorer
'wine-mono' # Wine's built-in replacement for Microsoft's .NET Framework
'winetricks' # Script to install various redistributable runtime libraries in Wine.
# ISO Support
'fuse2'# A library that makes it possible to implement a filesystem in a userspace program.
'fuse3' # A library that makes it possible to implement a filesystem in a userspace program.
'fuseiso' # FUSE module to mount ISO filesystem images
#
#
### LIBRARIES
'gst-libav' # Multimedia graph framework - libav plugin
'gst-plugins-good' # Multimedia graph framework - good plugins
'gst-plugins-ugly' # Multimedia graph framework - ugly plugins
'libdvdcss' # Portable abstraction library for DVD decryption
'libnewt' # Not Erik's Windowing Toolkit - text mode windowing with slang
'libtool' #	A generic library support script
### DEV KITS
'jdk-openjdk' # Java OpenJDK
#
#
### APPS
'ark' # Archiving Tool
'celluloid' # Video Player; Simple GTK+ frontend for mpv
'gimp' # Photo Editor.
'gwenview' # Image Viewer; A fast and easy to use image viewer
'kitty' # Terminal; A modern, hackable, featureful, OpenGL-based terminal emulator
'lutris' #	Gaming; Open Gaming Platform
'steam' # Gaming; Valve's digital software delivery system
'qemu' # A generic and open source machine emulator and virtualizer
'gparted' # Partition manager
#
#
'sddm'
'sddm-kcm'
)

for PKG in "${PKGS[@]}"; do
    echo "\n[ARCHX] INSTALLING: ${PKG}"
    sudo pacman -S "$PKG" --noconfirm --needed
done

#
# Determine processor type and install microcode
# 
proc_type=$(lscpu | awk '/Vendor ID:/ {print $3}')
case "$proc_type" in
	GenuineIntel)
		print "[ArchX] Installing Intel microcode"
		pacman -S --noconfirm intel-ucode
		proc_ucode=intel-ucode.img
		;;
	AuthenticAMD)
		print "[ArchX] Installing AMD microcode"
		pacman -S --noconfirm amd-ucode
		proc_ucode=amd-ucode.img
		;;
esac	

# Graphics Drivers find and install
if lspci | grep -E "NVIDIA|GeForce"; then
    pacman -S nvidia --noconfirm --needed
	nvidia-xconfig
elif lspci | grep -E "Radeon"; then
    pacman -S xf86-video-amdgpu --noconfirm --needed
elif lspci | grep -E "Integrated Graphics Controller"; then
    pacman -S libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils --needed --noconfirm
fi

# Notify installation finish
echo -e "\n[ArchX] Done installing!\n" && sleep 2

# Begin User Setup
echo -e "\n[ArchX] User Setup, ready.\n" && sleep 1
if ! source install.conf; then
	read -p "Enter preferred username: " username
echo "username=$username" >> ${HOME}/ArchTitus/install.conf
fi
if [ $(whoami) = "root"  ];
then
    useradd -m -G wheel,libvirt -s /bin/bash $username 
	passwd $username
	cp -R /root/ArchTitus /home/$username/
    chown -R $username: /home/$username/ArchTitus
	read -p "Enter name of machine: " nameofmachine
	echo $nameofmachine > /etc/hostname
else
	echo "You are already a user! Proceeding with AUR installations."
fi

# ARCHIVE.

### ARCHTITUS LEFTOVER -- KDE packages
#'plasma-desktop' # KDE Load second 
#'audiocd-kio' # KDE Audio Integration
#'bluedevil' # Integrate the Bluetooth technology within KDE workspace and applications
#'breeze' # 	Artwork, styles and assets for the Breeze visual style for the Plasma Desktop
#'breeze-gtk' # 	Breeze widget theme for GTK 2 and 3
#'cmatrix' # A curses-based scrolling 'Matrix'-like screen
#'code' # Visual Studio code
#'discover' # KDE and Plasma resources management GUI
#'dolphin' # KDE File Manager
#'kate' # KDE Advanced Text Editor
#'kcodecs' # KDE Provide a collection of methods to manipulate strings using various encodings
#'kcoreaddons' # KDE Addons to QtCore
#'kdeplasma-addons' # ArchTitus leftover
#'kde-gtk-config' # ArchTitus leftover
#'kscreen' # KDE screen management software
#'konsole' # KDE terminal emulator
#'milou' # KDE; A dedicated search application built on top of Baloo
#'okular' # Universal PDF Reader for KDE
#'oxygen' # KDE Oxygen style
#'plasma-meta' # Meta package to install KDE Plasma
#'plasma-nm' # Plasma applet written in QML for managing network connections
#'powerdevil' # Manages the power consumption settings of a Plasma Shell
#'spectacle' # KDE screenshot capture utility
#'systemsettings' # KDE system manager for hardware, software, and workspaces
#'xdg-desktop-portal-kde'
#'filelight' # KDE; View disk usage information
#'kinfocenter' # KDE; A utility that provides information about a computer system
#'kvantum-qt5' # KDE; SVG-based theme engine for Qt5 (including config tool and extra themes)
#'layer-shell-qt' #	KDE; Qt component to allow applications to make use of the Wayland wl-layer-shell protocol
#