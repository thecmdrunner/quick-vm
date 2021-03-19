#!/bin/bash


# For normal and bold text

old=$(tput bold)
normal=$(tput sgr0)

boldtext() {
  echo -e "\033[1m$TEXT"
}

# Credits for colored output https://gist.github.com/amberj/5166112

SELF_NAME=$(basename $0)



redtext() {
  echo -e "\x1b[1;31m$TEXT\e[0m"
}


greentext() {
  echo -e "\x1b[1;32m$TEXT\e[0m"
}


bluetext() {
  echo -e "\x1b[1;34m$TEXT\e[0m"
}

# Checks if the current working directory is read only and warns the user.
# Logs cant be stored on a READ-ONLY Drive.

echo ''
cd ~/
#touch ~/quick-vm.log
if [[ -f ~/quick-vm.log ]]
then
  echo "Logs for Quick-VM Project are written here. Link: https://github.com/gamerhat18/quick-vm" >> ~/quick-vm.log
else
  TEXT="Filesystem is READ-ONLY. Errors may not be logged."; redtext
  TEXT="YOU MAY CONTINUE, BUT MIGHT ENCOUNTER ERRORS."; redtext
fi
echo ''



### PRE-DEFINED OPERATIONS

# exit function

byee() {

  echo ""
  TEXT=":: Exiting, Bye!"; greentext
  echo ""

}

# Start Libvirt service through systemd

libvirt_systemd_start () {

  echo ""
  TEXT=":: Now starting up libvirtd socket and service"; bluetext
  echo ""

  TEXT=":: Executing 'sudo systemctl enable --now libvirtd' ..."; bluetext
  echo ""

  sudo systemctl enable libvirtd >> ~/quick-vm.log
  sudo systemctl start libvirtd >> ~/quick-vm.log

  sudo systemctl enable libvirtd.socket >> ~/quick-vm.log
  sudo systemctl start libvirtd.socket >> ~/quick-vm.log

  sudo systemctl enable libvirtd.service >> ~/quick-vm.log
  sudo systemctl start libvirtd.service >> ~/quick-vm.log

  TEXT="[✓] Done. Logs saved to ~/quick-vm.log"; greentext
  echo ""
  echo ""

  TEXT=":: Now starting up virtlogd socket and service"; bluetext
  echo ""

  TEXT=":: Executing 'sudo systemctl enable --now virtlogd'"; bluetext
  echo ""

  sudo systemctl enable virtlogd >> ~/quick-vm.log
  sudo systemctl start virtlogd >> ~/quick-vm.log

  sudo virsh net-autostart default >> ~/quick-vm.log
  sudo virsh net-start default >> ~/quick-vm.log

  TEXT="[✓] Done. Logs saved to ~/quick-vm.log"; greentext
  echo ""
  echo ""

}

# Check if Windows iso and virtio-drivers exist in ~/WindowsVM

maindir=/home/$USER/WindowsVM

checkiso() {

 if [[ -d $maindir ]]; then
   if [[ -f $maindir/]]; then
     echo "~/WindowsVM exists!"
}

# Arch Setup 

arch_setup() {
  
  echo ""
  TEXT="[✓] BASE SYSTEM: ARCH"; greentext
  echo ""
  echo ":: Installing Dependencies..."; 
  echo ""
  echo ""
  #sudo pacman -S qemu libvirt bridge-utils edk2-ovmf vde2 ebtables dnsmasq openbsd-netcat virt-manager
  echo ""
  TEXT="[✓] Setup Finished!"; greentext

}

# Fedora Setup

fedora_setup() {

  echo ""
  TEXT="[✓] BASE SYSTEM: FEDORA"; greentext
  echo ""
  echo ":: Installing Dependencies"; 
  echo ""
  echo ""
  echo ""
  sudo dnf -y install qemu-kvm libvirt bridge-utils virt-install virt-manager 
  echo ""
  TEXT="[✓] Setup Finished!"; greentext

}

# Debian Setup

debian_setup() {

  echo ""
  TEXT="[✓] BASE SYSTEM: DEBIAN"; greentext
  echo ""
  echo ":: Installing Dependencies..."; 
  echo ""
  echo ""
  echo ""
  sudo apt install -y qemu qemu-kvm libvirt-bin libvirt-daemon libvirt-clients bridge-utils virt-manager 
  echo ""
  TEXT="[✓] Setup Finished!"; greentext

}

# Fallback: Unknown Distro detected. Tells the user to install dependencies himself and checks if the system uses systemd init, then exits.

unknown_distro() {

  echo "Your System possibly isn't Debian/Fedora/Arch, make sure to install the KVM dependencies through your package manager."
  echo ""
  if [[ -f /usr/bin/systemctl ]]
  then
    echo "Your system has Systemd init, you can type the following to get libvirtd service running quickly after installing the dependencies."
    echo ""
    TEXT="sudo systemctl enable --now libvirtd"; bluetext
  else
    TEXT="Your system doesn't use Systemd init, so you need to manually enable libvirt service and socket."; redtext
  fi
  byee;

}

# Check the flavour of Linux and install dependencies

install_all() {

if [[ -f /usr/bin/makepkg ]] # Present in Arch
then
  arch_setup && libvirt_systemd_start 
elif [[ -f /usr/bin/rpm ]] # Present in Fedora
then
  fedora_setup && libvirt_systemd_start
elif [[ -f /usr/bin/dpkg ]] # Present in Debian
then
  debian_setup && libvirt_systemd_start
else # Resorts to fallback
  unknown_distro
fi

}

# Simple Quick and automatic setup.

simplesetup() {
  
  echo "";
  echo -e "Starting Simple Setup"

}


#  ${bold}  ${normal}
TEXT="\x1b[1;32m:: Thank you for choosing Quick-VM, the setup process is starting.\e[0m"; boldtext 
echo "${bold}:: Select any one of the options below to get started!${normal}"
echo ""

echo "[1] Default install (Fully Automated & Quick)"; boldtext
echo "[2] Advanced install (Pick and choose what you want)"; boldtext

echo ""
read -p ":: Choose an option [1, 2]: " user_choice
echo ""

if [[ $user_choice == 1 ]]
then
  echo "You selected Default install"
elif [[ $user_choice == 2 ]]
then
  clear;
  simplesetup;
else
  echo "Invalid choice, please select from the options above."
  byee;
fi

echo ""
