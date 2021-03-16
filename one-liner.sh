#!/bin/bash

# Arch Setup with systemd init 
arch_setup () {
  sudo pacman -S --noconfirm qemu libvirt bridge-utils edk2-ovmf vde2 ebtables dnsmasq openbsd-netcat virt-manager && libvirt_systemd_start
}

# Fedora Setup with systemd init
fedora_setup () {
  sudo dnf -y install qemu-kvm libvirt bridge-utils virt-install virt-manager && libvirt_systemd_start 
}

# Debian Setup with systemd init
debian_setup () {
  sudo apt install -y qemu qemu-kvm libvirt-bin libvirt-daemon libvirt-clients bridge-utils virt-manager && libvirt_systemd_start 
}

# Unknown Distro detected. Tells the user to install dependencies himself.
unknown_distro () {
  echo "Your System possibly isn't Debian/Fedora/Arch, make sure to install the KVM dependencies and enable LIBVIRTD SERVICE/SOCKET before you continue." 
}

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
  arch_setup
elif [[ -f /usr/bin/dnf ]]
then
  fedora_setup
elif [[ -f /usr/bin/apt ]]
then
  debian_setup
else
  unknown_distro
fi

curl
