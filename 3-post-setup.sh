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

echo -e "\nFINAL SETUP AND CONFIGURATION"
echo "--------------------------------------"
echo "-- GRUB EFI Bootloader Install&Check--"
echo "--------------------------------------"
if [[ -d "/sys/firmware/efi" ]]; then
    grub-install --efi-directory=/boot ${DISK}
fi
grub-mkconfig -o /boot/grub/grub.cfg

# ------------------------------------------------------------------------

echo -e "\n[ArchX] Enabling Login Display Manager"
systemctl enable sddm.service
echo -e "\n[ArchX] Setup SDDM Theme"
cat <<EOF > /etc/sddm.conf
[Theme]
Current=Nordic
EOF

# ------------------------------------------------------------------------

echo -e "\n[ArchX] Enabling essential services"

systemctl enable cups.service
ntpd -qg
systemctl enable ntpd.service
systemctl disable dhcpcd.service
systemctl stop dhcpcd.service
systemctl enable NetworkManager.service
systemctl enable bluetooth
echo "
###############################################################################
# Cleaning
###############################################################################
"
# Remove no password sudo rights
sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
# Add sudo rights
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

# Replace in the same state
cd $pwd
echo "
###############################################################################
# Done - Please Eject Install Media and Reboot
###############################################################################
"
