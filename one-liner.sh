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
touch ~/quick-vm.log
if [[ -f ~/quick-vm.log ]]
then
  echo "Logs for Quick-VM Project are written here. Link: https://github.com/gamerhat18/quick-vm" >> ~/quick-vm.log
  if [[ $EUID -ne 0 ]]; then
    echo " Not running this script as root. " >>  ~/quick-vm.log
  fi
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

  # checks if ~/WindowsVM exists
 if [[ -d $maindir ]]; then
   
   if [[ -f $maindir/win10.iso ]]; then
     echo -e "Windows ISO exists in ~/WindowsVM! \n";
     TEXT="Relocating the image in /var/lib/libvirt/images !"; bluetext
     sudo rsync --partial --progress $maindir/Win10*.iso /var/lib/libvirt/images/win10.iso 
     TEXT="[✓] Operation Done!"; greentext
   elif [[ ! -f $maindir/win10.iso ]] ; then
     TEXT="Windows ISO doesn't exist in ~/WindowsVM!"; redtext
     echo "Please make sure that it is in $maindir"
   else
     TEXT="ERROR OCCURED. Please check the logs."; redtext
   fi
   
   if [[ -f $maindir/virtio-win.iso ]]; then
     echo -e "VirtIO Drivers exist in ~/WindowsVM! \n"
     TEXT="Relocating the image in /var/lib/libvirt/images !"; bluetext
     sudo rsync --partial --progress $maindir/virtio-win.iso /var/lib/libvirt/images/virtio-win.iso
     TEXT="[✓] Operation Done!"; greentext
   elif [[! -f $maindir/virtio-win.iso ]] ; then
     TEXT="VirtIO Drivers ISO doesn't exist in ~/WindowsVM!"; redtext
     echo "Please make sure that it is in $maindir"
   else
     TEXT="ERROR OCCURED. Please check the logs."; redtext
   fi

 fi
   
}
   


# Clones the main reporsitory and defining the VM via `virsh`

gitndefine() {

  cd ~/
  echo "cloning from git repo" >> ~/quick-vm.log
  git clone --recursive https://github.com/gamerhat18/Quick-VM >> ~/quick-vm.log 
  cd Quick-VM
  sudo rsync -q kvm/Windows10Vanilla.qcow2 /var/lib/libvirt/images >> ~/quick-vm.log
  sudo rsync -q kvm/essentials.iso /var/lib/libvirt/images >> ~/quick-vm.log

  if [[ -f /var/lib/libvirt/images/virtio-win.iso && /var/lib/libvirt/images/win10.iso ]]; then
    virsh define kvm/Windows10-Vanilla.xml >> ~/quick-vm.log;
    echo "" && TEXT="Your VM is Ready! Launch Virt-Manager to start the VM."; greentext
  else
    TEXT="ISOs Don't exist in /var/lib/libvirt/images/"; redtext
    echo -e "Please read the instructions on how and where to place them on the Official GitHub Page. \n"
  fi

}

# Arch Setup 

arch_setup() {
  
  echo ""
  TEXT="[✓] BASE SYSTEM: ARCH"; greentext
  echo ""
  echo ":: Installing Dependencies..."; 
  echo ""
  echo ""
  #sudo pacman -S git qemu rsync libvirt bridge-utils edk2-ovmf vde2 ebtables dnsmasq openbsd-netcat virt-manager
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
  sudo dnf -y install git qemu-kvm rsync libvirt bridge-utils virt-install virt-manager 
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
  sudo apt install -y git qemu rsync qemu-kvm libvirt-bin libvirt-daemon libvirt-clients bridge-utils virt-manager 
  echo ""
  TEXT="[✓] Setup Finished!"; greentext

}

# Fallback: Unknown Distro detected. Tells the user to install dependencies himself and checks if the system uses systemd init, then exits.

unknown_distro() {

  TEXT="Your System possibly isn't Debian/Fedora/Arch, make sure to install the KVM dependencies through your package manager."; bluetext
  echo ""
  echo "Check out the Manual Setup Process on the Project's GitHub Page: https://github.com/gamerhat18/Quick-VM"
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
  install_all;
  libvirt_systemd_start;
  checkiso;
  gitndefine;
  
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
