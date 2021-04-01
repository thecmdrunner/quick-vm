#!/bin/bash

# oneliner command: bash <(curl -sSL https://git.io/JqtJc) 

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
  exit

}

# Check if the system supports virtualisation

check_kvm() {

if [[ -f /usr/bin/makepkg ]] # Present in Arch
then
  arch_setup
elif [[ -f /usr/bin/rpm ]]   # Present in Fedora
then
  fedora_setup
elif [[ -f /usr/bin/dpkg ]]  # Present in Debian
then
  debian_setup
else                         # Resorts to fallback
  unknown_distro
fi

}


# Start Libvirt service through systemd

libvirt_systemd_start () {

  # dependencies check
  
  if [[ ! -f /usr/bin/virtlogd ]]; then
    echo ''
    TEXT="[X] Virtlogd not found!"; redtext
    exit
  fi


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

  echo ""
  TEXT="[✓] Done. Logs saved to ~/quick-vm.log"; greentext
  echo ""

  TEXT=":: Now starting up virtlogd socket and service"; bluetext
  echo ""

  TEXT=":: Executing 'sudo systemctl enable --now virtlogd'"; bluetext
  echo ""

  sudo systemctl enable virtlogd >> ~/quick-vm.log
  sudo systemctl start virtlogd >> ~/quick-vm.log

  sudo virsh net-autostart default >> ~/quick-vm.log
  sudo virsh net-start default >> ~/quick-vm.log

  echo ""
  TEXT="[✓] Done. Logs saved to ~/quick-vm.log"; greentext
  echo ""
  echo "*******************************************************************************"
  echo ""

}

# Check if Windows iso and virtio-drivers exist in ~/WindowsVM

maindir=/home/$USER/WindowsVM
imagesdir=/var/lib/libvirt/images
dirname=WindowsVM

checkiso() {

  # checks if ~/WindowsVM exists
 if [[ -d $maindir ]]; then
   
   # Checks if the ISOs already exists

   if [[ -f $imagesdir/win10.iso && -f $imagesdir/virtio-win.iso ]]; then
    echo ''
    TEXT='[✓] VirtIO Drivers and Windows 10 ISO already exist in '$imagesdir'!'; greentext
    echo ''

   else

    # Windows ISO check and moves it to $imagesdir

     if [[ -f $maindir/win10.iso ]]; then
       TEXT="Windows ISO exists in ~/$dirname!"; greentext
       echo ''
       TEXT="Relocating the image in /var/lib/libvirt/images !"; bluetext
       echo ''
       sudo rsync --partial --progress $maindir/win10*.iso /var/lib/libvirt/images/win10.iso
       echo ''
       TEXT="[✓] Operation Done!"; greentext
       echo ''
  
     elif [[ -f $imagesdir/win10.iso ]]; then
       TEXT="Windows ISO already exists in ~/$imagesdir!"; greentext
       echo ''
  
     elif [[ ! -f $maindir/win10.iso && ! -f $imagesdir/win10.iso ]] ; then
       TEXT="Windows ISO doesn't exist in either ~/WindowsVM or $imagesdir!"; redtext
       echo "Please make sure that it is in $maindir and run the script again!"

     else
       TEXT="ERROR OCCURED. Please check the logs."; redtext
     fi
     
     # VirtIO Check and moves it to $imagesdir
  
     if [[ -f $maindir/virtio-win.iso ]]; then
       TEXT="VirtIO Drivers exist in ~/WindowsVM!"; greentext
       echo ''
       TEXT="Relocating the image in /var/lib/libvirt/images !"; bluetext
       echo ''
       sudo rsync --partial --progress $maindir/virtio-win.iso /var/lib/libvirt/images/virtio-win.iso
       echo ''
       TEXT="[✓] Operation Done!"; greentext
       echo ''
  
     elif [[ -f $imagesdir/virtio-win.iso ]]; then
       TEXT="VirtIO Drivers ISO already exists in ~/$imagesdir!"; greentext
       echo ''
  
     elif [[! -f $maindir/virtio-win.iso && ! -f $imagesdir/virtio-win.iso ]] ; then
       TEXT="VirtIO Drivers ISO doesn't exist in in either ~/WindowsVM or $imagesdir!"; redtext
       echo ''
       TEXT=":: Do you want to download them now? Else, the setup can't progress further."; greentext
       
       read -p "Please enter your choice [Y/n]: " virt_choice
    
       if [[ $virt_choice == 'y' ]]; then
        echo ''
        echo 'Downloading VirtIO Drivers (Stable)...'
        echo ''
        wget -cq https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso -O ~/WindowsVM/virtio-win.iso --show-progress --progress=bar
        echo ''

        if [[ -f $maindir/virtio-win.iso ]]; then
          echo ":: Done! Now the setup process will continue."
          sudo rsync --partial --progress $maindir/virtio-win.iso /var/lib/libvirt/images/virtio-win.iso
          echo ''
          TEXT="[✓] Operation Done!"; greentext
        fi

       elif [[ $virt_choice == 'n' ]]; then
        echo ''
        TEXT="[✓] OK! Skipping VirtIO Drivers for now,"; bluetext
        echo "But make sure you download and put the VirtIO Drivers (Stable) ISO in $imagesdir"
        echo "OR place it in $maindir and run the script again."

       else
        TEXT="[!] Invalid Option! Skipping VirtIO Drivers for now,"; redtext
        echo "But make sure you download and put the VirtIO Drivers (Stable) ISO in $imagesdir"
        echo "OR place it in $maindir and run the script again."
       fi

     else
       TEXT="ERROR OCCURED. Please check the logs."; redtext
     fi
  
   fi

 else
   mkdir $maindir
   TEXT=":: Please put Windows and VirtIO Drivers ISO in $maindir"; redtext
   echo ''
   echo "Without the ISOs, the setup can't progress further."
   echo ''
   exit
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
    sudo virsh define kvm/Windows10-Vanilla.xml >> ~/quick-vm.log;
    echo "" && TEXT="Your VM is Ready! Launch Virt-Manager to start the VM."; greentext
  else
    TEXT="Some ISOs missing from /var/lib/libvirt/images/"; redtext
    echo -e "Please read the instructions on how and where to place them on the Official GitHub Page. \n"
  fi

}

# Arch-Setup 

arch_setup() {
  
  echo ""
  TEXT="[✓] BASE SYSTEM: ARCH"; greentext
  echo ""
  echo ":: Installing Dependencies..."; 
  echo ""
  echo ""
  sudo pacman -S --noconfirm git qemu rsync libvirt bridge-utils edk2-ovmf vde2 ebtables dnsmasq openbsd-netcat virt-manager
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
  arch_setup
elif [[ -f /usr/bin/rpm ]] # Present in Fedora
then
  fedora_setup
elif [[ -f /usr/bin/dpkg ]] # Present in Debian
then
  debian_setup
else                       # Resorts to fallback
  unknown_distro
fi

}

# Simple Quick and automatic setup for One-Liner.

simplesetup() {
  
  echo "";
  echo -e "Starting Simple Setup"
  install_all;
  libvirt_systemd_start;
  checkiso;
  gitndefine;
  byee;

}

# Advanced Setup with every step

advancedsetup(){

while [[ $setupmode=='advanced' ]]
do

  echo ''
  TEXT=":: Select any one of the options below to get started!"; boldtext
  echo ''
  TEXT="[1] Install required packages (via package manager)"; bluetext
  TEXT="[2] Enable Libvirt Service & Virtual Networking"; bluetext 
  TEXT="[3] Check ISOs (in "$maindir")"; bluetext
  TEXT="[4] Define VM from Windows10-Vanilla.xml"; bluetext
  echo ''
  TEXT="[5] Return"; boldtext 

  echo ''
  read -p ":: Choose a task from above [1-5]: " setup_choice
  echo ''

  if [[ $setup_choice == 1 ]]; then
    clear;
    install_all;
  elif [[ $setup_choice == 2 ]]; then
    clear;
    libvirt_systemd_start;
  elif [[ $setup_choice == 3 ]]; then
    clear;
    checkiso;
  elif [[ $setup_choice == 4 ]]; then
    clear;
    gitndefine;
  elif [[ $setup_choice == 5 ]]; then
    clear;
    welcome;
  else
    echo "Invalid choice, please select from the options above."
    exit
  fi

done

}

welcome() {

  TEXT="\x1b[1;32m:: Thank you for choosing Quick-VM, the setup process is starting.\e[0m"; boldtext 
  TEXT=":: Select any one of the options below to get started!"; boldtext
  echo ""
  TEXT="[1] Default install (Fully Automated & Quick)"; boldtext
  TEXT="[2] Advanced install (Pick and choose what you want)"; boldtext
  TEXT="[3] Exit without installation"; boldtext
  
  echo ""
  read -p ":: Choose an option [1,2,3]: " user_choice
  echo ""
  
  if [[ $user_choice == 1 ]]; then
    clear;
    setupmode='simple'
    simplesetup
  elif [[ $user_choice == 2 ]]; then
    clear;
    setupmode='advanced'
    advancedsetup
  elif [[ $user_choice == 3 ]]; then
    echo ''
    TEXT=":: Exiting, Bye!"; greentext
    exit
  else
    echo "Invalid choice, please select from the options above."
    exit
  fi
  
  echo ""

}

echo ''
welcome
