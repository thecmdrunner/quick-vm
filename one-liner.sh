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

# Start Libvirt service through systemd

libvirt_systemd_start () {

  MESSAGE="[ ] Executing 'sudo systemctl enable --now libvirtd' ..."; blue_echo

  sudo systemctl enable libvirtd >> ~/quick-vm.log
  sudo systemctl start libvirtd >> ~/quick-vm.log


  sudo systemctl enable libvirtd.socket >> ~/quick-vm.log
  sudo systemctl start libvirtd.socket >> ~/quick-vm.log


  sudo systemctl enable libvirtd.service >> ~/quick-vm.log
  sudo systemctl start libvirtd.service >> ~/quick-vm.log

  MESSAGE="[✓] Done. Logs saved to ~/quick-vm.log"; green_echo

}

virtlogd_systemd_start () {
  
  MESSAGE="[ ] Executing 'sudo systemctl enable --now virtlogd' ..."; blue_echo

  sudo systemctl enable virtlogd >> ~/quick-vm.log
  sudo systemctl start virtlogd >> ~/quick-vm.log

  sudo virsh net-autostart default >> ~/quick-vm.log
  sudo virsh net-start default >> ~/quick-vm.log

  MESSAGE="[✓] Done. Logs saved to ~/quick-vm.log"; green_echo

}

# Arch Setup 

arch_setup() {
  
  MESSAGE="[✓] BASE SYSTEM: ARCH"; simple_green_echo
  echo ""
  echo "[ ] Installing Dependencies..."; 
  echo ""
  echo ""
  #sudo pacman -S qemu libvirt bridge-utils edk2-ovmf vde2 ebtables dnsmasq openbsd-netcat virt-manager
  echo ''
  MESSAGE="[✓] Setup Finished!"; simple_green_echo
  echo ''
  MESSAGE="[ ] Now starting up libvirt socket and service..."; simple_blue_echo
  libvirt_systemd_start

}

# Fedora Setup

fedora_setup() {

  MESSAGE="[✓] BASE SYSTEM: FEDORA"; simple_green_echo
  echo ""
  echo "[ ] Installing Dependencies..."; 
  echo ""
  echo ""
  echo ""
  sudo dnf -y install qemu-kvm libvirt bridge-utils virt-install virt-manager 
  echo ''
  MESSAGE="[✓] Setup Finished!"; simple_green_echo

}

# Debian Setup

debian_setup() {

  MESSAGE="[✓] BASE SYSTEM: DEBIAN"; simple_green_echo
  echo ""
  echo "[ ] Installing Dependencies..."; 
  echo ""
  echo ""
  echo ""
  sudo apt install -y qemu qemu-kvm libvirt-bin libvirt-daemon libvirt-clients bridge-utils virt-manager 
  echo ''
  MESSAGE="[✓] Setup Finished!"; simple_green_echo

}

# Fallback: Unknown Distro detected. Tells the user to install dependencies himself and checks if the system uses systemd init

unknown_distro() {

  echo "Your System possibly isn't Debian/Fedora/Arch, make sure to install the KVM dependencies through your package manager."
  echo ""
  if [[ -f /usr/bin/systemctl ]]
  then
    echo "Your system has Systemd init, you can type the following to get libvirtd service running quickly after installing the dependencies."
    echo ""
    MESSAGE="sudo systemctl enable --now libvirtd"; simple_blue_echo
  else
    MESSAGE="Your system doesn't use Systemd init, so you need to manually enable libvirt service and socket."; simple_red_echo
  fi

}

# Check the flavour of Linux and install dependencies

if [[ -f /usr/bin/makepkg ]] # Present in Arch
then
  arch_setup && libvirt_systemd_start && sudo systemctl enable --now virtlogd >> ~/quick-vm.log && sudo virsh net-autostart default >> ~/quick-vm.log && sudo virsh net-start default >> ~/quick-vm.log;
elif [[ -f /usr/bin/rpm ]] # Present in Fedora
then
  fedora_setup && libvirt_systemd_start
elif [[ -f /usr/bin/dpkg ]] # Present in Debian
then
  debian_setup && libvirt_systemd_start
else # Resorts to fallback
  unknown_distro
fi

