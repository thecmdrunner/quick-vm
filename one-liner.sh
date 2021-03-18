#!/bin/bash

# Credits for colored output https://gist.github.com/amberj/5166112

SELF_NAME=$(basename $0)

# Prints warning/error $MESSAGE in red foreground color
# For e.g. You can use the convention of using RED color for [E]rror messages
red_echo() {
    echo -e "\x1b[1;31m[E] $SELF_NAME: $MESSAGE\e[0m"
}

simple_red_echo() {
    echo -e "\x1b[1;31m$MESSAGE\e[0m"
}

# Prints success/info $MESSAGE in green foreground color
# For e.g. You can use the convention of using GREEN color for [S]uccess messages
green_echo() {
    echo -e "\x1b[1;32m[S] $SELF_NAME: $MESSAGE\e[0m"
}

simple_green_echo() {
    echo -e "\x1b[1;32m$MESSAGE\e[0m"
}

# Prints $MESSAGE in blue foreground color
# For e.g. You can use the convetion of using BLUE color for [I]nfo messages that require special user attention (especially when script requires input from user to continue)
blue_echo() {
    echo -e "\x1b[1;34m[I] $SELF_NAME: $MESSAGE\e[0m"
}

simple_blue_echo() {
    echo -e "\x1b[1;34m$MESSAGE\e[0m"
}

### PRE-DEFINED OPERATIONS

# Arch Setup 
arch_setup () {
  
  MESSAGE="[✓] BASE SYSTEM: ARCH"; simple_green_echo
  echo ""
  echo "[ ] Installing Dependencies..."; 
  echo ""
  echo ""
  echo ""
  sudo pacman -S qemu libvirt bridge-utils edk2-ovmf vde2 ebtables dnsmasq openbsd-netcat virt-manager
  MESSAGE="[✓] Setup Finished!"; simple_green_echo

}

# Fedora Setup
fedora_setup () {

  MESSAGE="[✓] BASE SYSTEM: FEDORA"; simple_green_echo
  echo ""
  echo "[ ] Installing Dependencies..."; 
  echo ""
  echo ""
  echo ""
  sudo dnf -y install qemu-kvm libvirt bridge-utils virt-install virt-manager 
  MESSAGE="[✓] Setup Finished!"; simple_green_echo

# Debian Setup
debian_setup () {

  MESSAGE="[✓] BASE SYSTEM: DEBIAN"; simple_green_echo
  echo ""
  echo "[ ] Installing Dependencies..."; 
  echo ""
  echo ""
  echo ""
  sudo apt install -y qemu qemu-kvm libvirt-bin libvirt-daemon libvirt-clients bridge-utils virt-manager 
  MESSAGE="[✓] Setup Finished!"; simple_green_echo
}

# Unknown Distro detected. Tells the user to install dependencies himself.
unknown_distro () {
  echo "Your System possibly isn't Debian/Fedora/Arch, make sure to install the KVM dependencies and enable LIBVIRTD SERVICE/SOCKET before you continue." 
}

# Start Libvirt service through systemd
libvirt_systemd_start () {
sudo systemctl enable libvirtd
sudo systemctl start libvirtd
sudo systemctl enable libvirtd.socket  
sudo systemctl start libvirtd.socket
sudo systemctl enable libvirtd.service
sudo systemctl start libvirtd.service
}

# Check the flavour of Linux and install dependencies

if [[ -f /usr/bin/pacman ]]
then
  arch_setup;
  libvirt_systemd_start;
  sudo systemctl enable --now virtlogd;
  sudo virsh net-autostart default;
  sudo virsh net-start default;

elif [[ -f /usr/bin/dnf ]]
then
  fedora_setup
elif [[ -f /usr/bin/apt ]]
then
  debian_setup
else
  unknown_distro
fi

