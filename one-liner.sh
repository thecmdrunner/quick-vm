#!/bin/bash
 
# Project: https://github.com/thegamerhat/quick-vm

# oneliner commands: 

# bash <(wget -qO- https://git.io/JOeOs) 
# OR
# bash <(curl -sSL https://git.io/JOeOs) 

# Credits for colored output https://techstop.github.io/bash-script-colors
# For normal and bold text

old=$(tput bold)
normal=$(tput sgr0)
SELF_NAME=$(basename $0)

boldtext() {
  echo -e "\033[1m$TEXT"
}

redtext() {
  echo -e "\x1b[1;31m$TEXT\e[0m"
}

greentext() {
  echo -e "\x1b[1;32m$TEXT\e[0m"
}

yellowtext() {
  echo -e "\x1b[1;33m$TEXT\e[0m"
}

bluetext() {
  echo -e "\x1b[1;34m$TEXT\e[0m"
}

cyantext() {
  echo -e "\x1b[1;36m$TEXT\e[0m"
}

whitetext() {
  echo -e "\x1b[1;37m$TEXT\e[0m"
}

purpletext() {
  echo -e "\x1b[1;105m$TEXT\e[0m"
}

whiteunderline() {
  echo -e "\e[4;37m$TEXT\e[0m"
}

ROOT_UID=0

# System resource definitions
totalmem=$(grep MemTotal /proc/meminfo | awk "{print $2}")
totalcpus=$(getconf _NPROCESSORS_ONLN)

# Logging file
logfile=$HOME/.local/quick-vm.log

# what distro
distro=""

# Check if the system supports virtualisation
cpu_kvm_flags=$(egrep -c '(vmx|svm)' /proc/cpuinfo)
cpu_vt=$(lscpu | grep Virtualization)

# Script specific constants
dirname=WindowsVM
maindir=$HOME/$dirname
imagesdir=/var/lib/libvirt/images


# Check if log already exists
cd $HOME
if [[ ! -f $logfile ]]; then
  touch $logfile
  echo -e "\nLogs for Quick-VM Project are written here.\nLink: https://github.com/thegamerhat/quick-vm\n" >> $logfile
fi

# Append log with big line and current date & time
echo -e "\n---------------------------------------------" >> $logfile
echo "$(date)" >> $logfile

# Detecs if script is run as root
if [[ $EUID == 0 ]]; then
  echo -e "[!] Running the script as ROOT!" >>  $logfile
  TEXT="\n [!] RUNNING AS ROOT IS DISCOURAGED.\n"; redtext
  TEXT="\n [!] PROCEED WITH CAUTION.\n"; redtext
else
  echo -e "Running the script as USER: $USER" >>  $logfile
fi

# What CPU is it
if [[ $cpu_vt =~ "AMD" ]]; then
  cpubrand="AMD"
elif [[ $cpu_vt =~ "VT" ]]; then
  cpubrand="INTEL"
else
  cpubrand="UNKNOWN"
fi

# will throw an error if /usr/bin/virt-host-validate doesn't exist
if [[ -f /usr/bin/virt-host-validate ]]; then 
  kvm_validate=$(/usr/bin/virt-host-validate | grep '/dev/kvm exists')
fi

# What main distro is the system running
if [[ -f /usr/bin/apt ]]; then
  apt_sources=$(cat /etc/apt/sources.list)

  if [[ $apt_sources =~ "ubuntu" ]]; then
    distro="UBUNTU"
  else
    distro="DEBIAN"
  fi

elif [[ -f /usr/bin/dnf ]]; then
  distro="FEDORA"
elif [[ -f /usr/bin/pacman ]]; then
  distro="ARCH"
else
  distro="UNKNOWN"
fi

# Append log with system details
echo -e "---------------------------------------------" >> $logfile
echo -e "-- BASE SYSTEM:                   $distro" >> $logfile
echo -e "-- CPU VENDOR:                    $cpubrand" >> $logfile
echo -e "-- TOTAL CPU THREADS:             $totalcpus" >> $logfile
echo -e "-- TOTAL MEMORY: $totalmem" >> $logfile
echo -e "---------------------------------------------" >> $logfile


# Logs cant be stored on a READ-ONLY Drive.
# $logfile has been touched above, so it should exist now. 
# if it doesnt, then the disk is probably READ ONLY
if [[ ! -f $logfile ]]; then
  TEXT="\n It's possible that the disk is READ-ONLY. Errors may not be logged."; redtext
  TEXT=" YOU MAY CONTINUE, BUT MIGHT ENCOUNTER ERRORS.\n"; redtext
fi


### PRE-DEFINED OPERATIONS

# echo -------------------

border() {
  TEXT="\n-------------------------------------------------------------------------------"; whitetext
}

# exit function

byee() {
  echo ""
  TEXT=" :: Exiting! Logs save in ~/.local/quick-vm.log\n"; yellowtext
  echo -e "-- Exit Successfully!\n" >>  $logfile
  exit
}


check_kvm() {
   echo -e "\n-- FUNCTION: Check KVM Compatibility" >>  $logfile
   echo ""

  # throws up an error in front of the user if 
  # /usr/bin/virt-host-validate does not exist
  if [[ -f /usr/bin/virt-host-validate ]]; then
    kvm_validate=$(/usr/bin/virt-host-validate | grep '/dev/kvm exists')
  else
    TEXT=" Dependencies not installed. Run setup first?"; yellowtext
    echo ""
    read -p " ➜ Enter your choice [Y/n]: " install_choice
    echo ""

    if [[ $install_choice =~ "n" || $install_choice =~ "N" ]]; then
      TEXT=" Okay, not installing..."; yellowtext
      byee;
    else
      installdeps;
      clear;
    fi
  fi
  
  # if the output is more than 0 then,
  # virtualization is supported, else not
  if [[ $cpu_kvm_flags > 0 ]]; then

    if [[ $cpu_vt =~ "AMD" ]]; then
      TEXT=" ✔ AMD Virtualization (AMD-V) is Supported!"; greentext
      echo -e "-- AMD Virtualization (AMD-V) is Supported" >> $logfile
    elif [[ $cpu_vt =~ "VT" ]]; then
      TEXT=" ✔ Intel Virtualization (VT-x/VT-d) is Supported!"; greentext
      echo -e "-- INTEL Virtualization (VT-x/VT-d) is Supported" >> $logfile
    else
      echo -e "-- NO Virtualization detected.." >> $logfile
      TEXT=" [!] AMD-V/VT-x not detected. Virtualization support might be limited."; yellowtext
      echo -e " The setup can still continue."
    fi
  
    if [[ $kvm_validate =~ ": PASS" ]]; then
      TEXT=" ✔ KVM is enabled!"; greentext
      kvm_enabled=true
      echo -e "-- KVM is enabled" >> $logfile
    elif [[ $kvm_validate =~ ": FAIL" ]]; then
      TEXT=" [X] KVM not detected. Please ensure Virtualization is enabled in UEFI/CoreBoot."; redtext
      kvm_enabled=false
      echo -e "-- KVM is NOT enabled" >> $logfile
    else
      TEXT=" [!] ERROR CHECKING virt-host-validate."; yellowtext
    fi
  
  elif [[ $cpu_kvm_flags < 1 ]]; then
    
    TEXT=" [X] VIRTUALIZATION NOT ENABLED. Please ensure Virtualization is enabled in UEFI/CoreBoot."; redtext
    echo -e "-- VIRTUALIZATION is NOT enabled, flags not detected." >> $logfile
    
  fi

}

reload_kvm() {
   echo -e "\n-- FUNCTION: Reload KVM Kernel Modules" >>  $logfile

  if [[ $cpu_vt =~ "AMD" ]]; then
      cpubrand="AMD"
  elif [[ $cpu_vt =~ "VT" ]]; then
      cpubrand="INTEL"
  fi 

  if [[ $cpubrand == "AMD" ]]; then
    sudo modprobe -r kvm_amd kvm >>  $logfile
    sudo modprobe kvm >>  $logfile
    sudo modprobe kvm_amd nested=1 >>  $logfile

  # elif [[ $cpubrand == "INTEL" ]]; then
  #   sudo modprobe -r kvm_intel kvm
  #   sudo modprobe kvm
  #   sudo modprobe kvm_intel nested=1

  else
    sudo modprobe -r kvm_intel kvm >>  $logfile
    sudo modprobe kvm >>  $logfile
    sudo modprobe kvm_intel nested=1 >>  $logfile
  
  fi

  if [[ $kvm_validate =~ ": PASS" ]]; then
    kvm_enabled=true
  elif [[ $kvm_validate =~ ": FAIL" ]]; then
    kvm_enabled=false
  fi

  echo -e "-- Modprobe finished" >>  $logfile

  if [[ kvm_enabled=true ]]; then
    echo -e "\n-- KVM detected properly." >> $logfile
    TEXT="\n :: REBOOT MIGHT BE REQUIRED IF THE VM DOES NOT BOOT PROPERLY."; whiteunderline
    
  elif [[ kvm_enabled=false ]]; then
    echo -e "\n-- KVM NOT detected.\n" >> $logfile
    TEXT="\n [X] KVM DOES NOT SEEM TO BE ENABLED IN UEFI/COREBOOT."; redtext 
  fi

}

# Start Libvirt service through systemd

libvirt_systemd_start () {
  echo -e "\n-- FUNCTION: Enable Libvirt Service & Virtual Networking" >>  $logfile

  # libvirt check
  if [[ ! -f /usr/bin/virsh ]]; then
    TEXT="\n [X] Virsh not found! Please make sure all the dependencies are installed correctly.\n"; redtext
    exit
  fi

  TEXT="\n :: Starting up libvirtd socket and service"; bluetext
  TEXT="\n :: Executing 'sudo systemctl enable --now libvirtd'\n"; cyantext

  echo "-- Executing 'sudo systemctl enable --now libvirtd'" >> $logfile
  sudo systemctl enable --now libvirtd >> $logfile

  sudo systemctl enable libvirtd.socket >> $logfile
  sudo systemctl start libvirtd.socket >> $logfile
  sudo systemctl enable libvirtd.service >> $logfile
  sudo systemctl start libvirtd.service >> $logfile

  TEXT=" :: Starting up virtlogd socket and service"; bluetext
  TEXT="\n :: Executing 'sudo systemctl enable --now virtlogd'\n"; cyantext

  echo "-- Executing 'sudo systemctl enable --now virtlogd'" >> $logfile
  sudo systemctl enable --now virtlogd >> $logfile

  TEXT=" :: Enabling Virtual Network Bridge at startup\n"; greentext

  echo "-- Executing 'sudo virsh net-autostart default'" >> $logfile
  echo "-- Executing 'sudo virsh net-start default'" >> $logfile
  sudo virsh net-autostart default >> $logfile
  sudo virsh net-start default >> $logfile

  TEXT="\n [✔] Done!\n"; greentext

}

# Restart Libvirt service through systemd
libvirt_systemd_restart () {
  echo -e "\n-- FUNCTION: (re)Enable Libvirt Service & Virtual Networking" >>  $logfile

  # libvirt check
  if [[ ! -f /usr/bin/virsh ]]; then
    TEXT="\n [X] Virsh not found! Please make sure all the dependencies are installed correctly.\n"; redtext
    exit
  fi

  TEXT="\n :: Trying to restart libvirtd socket and service\n"; cyantext

  echo "-- Restarting libvirtd" >> $logfile
  sudo systemctl stop libvirtd >> $logfile
  sudo systemctl enable --now libvirtd >> $logfile
  sudo systemctl start libvirtd >> $logfile

  sudo systemctl stop libvirtd.socket >> $logfile
  sudo systemctl enable --now libvirtd.socket >> $logfile
  sudo systemctl start libvirtd.socket >> $logfile

  sudo systemctl stop libvirtd.service >> $logfile
  sudo systemctl enable libvirtd.service >> $logfile
  sudo systemctl start libvirtd.service >> $logfile

  TEXT="\n :: Trying to restart virtlogd socket and service\n"; cyantext

  echo "-- Restarting virtlogd" >> $logfile
  sudo systemctl stop virtlogd >> $logfile
  sudo systemctl enable --now virtlogd >> $logfile
  sudo systemctl start virtlogd >> $logfile

  TEXT="\n :: Re-enabling Virtual Network Bridge at startup\n"; cyantext

  echo "-- Restarting virtual network bridge" >> $logfile
  sudo virsh net-destroy default >> $logfile
  sudo virsh net-autostart default >> $logfile
  sudo virsh net-start default >> $logfile

  TEXT="\n ✔ Done!\n"; greentext

}

# Downloads VirtIO Drivers if dont exist already
virtio_download() {
  echo -e "\n-- FUNCTION: VirtIO Drivers Download\n" >> $logfile

  if [[ ! -f $maindir/virtio-win.iso && ! -f $imagesdir/virtio-win.iso ]]; then
    echo "-- VirtIO Drivers ISO doesn't exist in ~/$dirname or $imagesdir" >> $logfile
  
    TEXT="\n\n VirtIO Drivers ISO doesn't exist in ~/$dirname or $imagesdir!"; redtext
    #echo -e "\nPlease make sure that $HOME/$dirname/virtio-win.iso exists and run the script again!\n"
    TEXT="\n [!] Do you want to download them now? The VM will NOT boot without it.\n"; yellowtext
    
    read -p " ➜ Please enter your choice [Y/n]: " virt_choice
    
    if [[ $virt_choice =~ "n" || $virt_choice =~ "N" ]]; then
      TEXT="\n [!] OK! Skipping VirtIO Drivers for now.\n"; bluetext
      echo "-- Skipped Downloading VirtIO Drivers." >> $logfile
      echo " Download the VirtIO Drivers (Stable) ISO and put it in ~/$dirname or $imagesdir and run the script again."
      sleep 4;
  
    else
      echo "-- Downloading VirtIO Drivers" >> $logfile
      TEXT="\n Downloading VirtIO Drivers (Stable)...\n"; greentext
      wget -cq https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso -O ~/$dirname/virtio-win.iso --show-progress --progress=bar
      echo ""
  
      if [[ -f $maindir/virtio-win.iso ]]; then
        sudo rsync --partial --progress $maindir/virtio-win.iso /var/lib/libvirt/images/virtio-win.iso
        TEXT="\n ✔ Operation Done! Setup will now continue.\n"; greentext
        echo "-- Downloading VirtIO Drivers Finished." >> $logfile

      else
        TEXT="\n [X] ERROR DURING DOWNLOAD. PLEASE CHECK YOUR NETWORK CONNECTION.\n"; redtext
        echo " Download the VirtIO Drivers (Stable) ISO and put it in $maindir or $imagesdir and run the script again."
        echo "-- VirtIO Drivers FAILED." >> $logfile

      fi
    fi
  fi
}

# Check if Windows iso and virtio-drivers exist in ~/$maindir
checkiso() {
 echo -e "\n-- FUNCTION: Locate ISOs" >> $logfile

 # checks if ~/$dirname exists
 if [[ -d $maindir ]]; then
   
   # Checks if the ISOs already exists
   if [[ -f $imagesdir/win10.iso && -f $imagesdir/virtio-win.iso ]]; then
    TEXT="\n [✔] VirtIO Drivers and Windows 10 ISO exist in '$imagesdir'!\n"; whitetext
    echo "-- VirtIO Drivers and Windows 10 ISO already exist" >> $logfile
   else

     # Windows ISO check and moves it to $imagesdir
     if [[ -f $maindir/win10.iso && ! -f $imagesdir/win10.iso ]]; then
       TEXT=" Windows ISO exists in ~/$dirname !\n"; greentext
       TEXT=" ➜ Relocating to $imagesdir\n"; bluetext
       sudo rsync --partial --progress $maindir/win10.iso /var/lib/libvirt/images/win10.iso
       echo "-- Relocated Windows ISO to $imagesdir" >> $logfile
       TEXT="\n ✔ Operation Done!\n"; greentext
  
     elif [[ -f $imagesdir/win10.iso ]]; then
       TEXT=" Windows ISO already exists in $imagesdir !\n"; greentext
       echo "-- Windows ISO already exists in $imagesdir" >> $logfile
  
     elif [[ ! -f $maindir/win10.iso && ! -f $imagesdir/win10.iso ]] ; then
       TEXT=" Windows ISO doesn't exist in either ~/$dirname or $imagesdir !"; redtext
       echo -e "\n Please make sure that ~/$dirname/win10.iso exists and run the script again!"
       echo "-- Windows ISO does not exist in either $maindir or $imagesdir" >> $logfile

     else
       TEXT=" ERROR OCCURED. Please check the logs."; redtext
     fi
     
     # VirtIO Check and moves it to $imagesdir
     if [[ -f $imagesdir/virtio-win.iso ]]; then
      TEXT=" VirtIO Drivers ISO already exists in $imagesdir !\n"; greentext
      echo "-- VirtIO Drivers ISO already exists in $imagesdir" >> $logfile

     elif [[ -f $maindir/virtio-win.iso ]]; then
      TEXT="\n VirtIO Drivers exist in ~/WindowsVM !\n"; greentext
      TEXT=" ➜ Relocating to /var/lib/libvirt/images\n"; bluetext
      sudo rsync --partial --progress $maindir/virtio-win.iso /var/lib/libvirt/images/virtio-win.iso
      echo "-- Relocated VirtIO Drivers ISO to $imagesdir" >> $logfile
      TEXT="\n ✔ Operation Done!\n"; greentext
  
     elif [[ ! -f $maindir/virtio-win.iso && ! -f $imagesdir/virtio-win.iso ]]; then
      virtio_download

     else
      TEXT=" ERROR OCCURED. Please check the logs."; redtext
     fi
  
   fi

 else
  mkdir $maindir
  echo "-- Windows and VirtIO ISOs do not exist in either $maindir or $imagesdir, attempting VirtIO download." >> $logfile
  virtio_download
  TEXT="\n :: Please download Windows ISO in $maindir and run this script again.\n"; redtext
  exit
 fi
 
}
  

# Clones the main reporsitory and defining the VM via `virsh`
gitndefine() {
  echo -e "\n-- FUNCTION: Clone Repository and define VM" >> $logfile

  if [[ $distro == "UBUNTU" ]]; then
    distro="DEBIAN"
  fi

  if [[ ! -d $HOME/quick-vm ]]; then
    cd $HOME
    echo "-- Cloning from the repository..." >> $logfile
    git clone --recursive https://github.com/thegamerhat/quick-vm >> $logfile 
  
  else
    cd $HOME/quick-vm
    git pull

  fi

  echo "-- Copying vdisk and essentials to $imagesdir" >> $logfile
  sudo rsync -q $HOME/quick-vm/kvm/Windows10Vanilla.qcow2 $imagesdir/ >> $logfile
  sudo rsync -q $HOME/quick-vm/kvm/essentials.iso $imagesdir/ >> $logfile

  if [[ -f $imagesdir/virtio-win.iso && -f $imagesdir/win10.iso ]]; then
    echo "-- Defining default VM" >> $logfile
    sudo virsh define ~/quick-vm/kvm/$distro/Windows10-default.xml  >> $logfile

    echo "-- Copying OVMF_CODE.fd" >> $logfile
    if [[ $distro == "ARCH" ]]; then
      sudo cp /usr/share/ovmf/x64/OVMF_CODE.fd /var/lib/libvirt/qemu/nvram/Windows10-default_VARS.fd >> $logfile
    elif [[ $distro == "DEBIAN" || $distro == "UBUNTU" ]]; then
      sudo cp /usr/share/OVMF/OVMF_CODE.fd /var/lib/libvirt/qemu/nvram/Windows10-default_VARS.fd  >> $logfile
    elif [[ $distro == "FEDORA" ]]; then
      sudo cp /usr/share/edk2/ovmf/OVMF_CODE.fd /var/lib/libvirt/qemu/nvram/Windows10-default_VARS.fd >> $logfile
    fi

    TEXT="\n ✔ Setup is Finished! Follow the instructions from the Official Project page to get started."; greentext

  else
    TEXT="\n [!] Some files missing from $imagesdir"; redtext
    echo -e "\n Please read the instructions on how and where to place them on the Official GitHub Page.\n"
    TEXT="\n ➜ Quick-VM Official GitHub Page: https://github.com/thegamerhat/quick-vm"; whitetext
  fi

}

installdeps() {
  echo -e "\n-- FUNCTION: Install required packages" >> $logfile

  TEXT="\n [✔] BASE SYSTEM: $distro\n"; cyantext
  echo -e " :: Installing Dependencies\n"; 

# Arch-Setup 

  if [[ $distro == "ARCH" ]]; then
    sudo pacman -S --noconfirm git qemu rsync libvirt bridge-utils edk2-ovmf vde2 ebtables dnsmasq openbsd-netcat virt-manager 

# Fedora Setup

  elif [[ $distro == "FEDORA" ]]; then
    sudo dnf -y install @virtualization git qemu-kvm rsync libvirt bridge-utils edk2-ovmf virt-install virt-manager 

# Debian Setup

  elif [[ $distro == "DEBIAN" || $distro == "UBUNTU" ]]; then

    if [[ $distro="UBUNTU" && ! $apt_sources =~ "universe" ]]; then
      sudo apt-get update -q ; sudo apt-get install software-properties-common -qy
      sudo add-apt-repository universe -y
    fi

    sudo apt-get update -q ; sudo apt-get install -y git qemu rsync qemu-kvm libvirt-daemon libvirt-clients bridge-utils ovmf virt-manager
  
# UNKNOWN Distro

  else
    TEXT="\n [X] Skipping Distro Check...\n"; cyantext
    TEXT=" :: Your System possibly isn't Debian/Fedora/Arch, make sure to install the KVM dependencies through your package manager.\n"; bluetext
    echo -e "\n After installing, run the Advanced Setup to complete the rest of the process."
    echo -e " OR check out the Manual Setup Process on the Project's GitHub Page: https://github.com/thegamerhat/Quick-VM\n"
    sleep 3
    byee;
  fi

  TEXT="\n ✔ Setup Finished!"; greentext
  
}

# Simple Quick and automatic setup for One-Liner.

simplesetup() {
  echo -e "\n [ SIMPLE SETUP ]" >> $logfile
  
  TEXT="\n ➜ Starting Simple Setup"; cyantext
  installdeps;
  border;
  check_kvm;
  border && sleep 5;
  libvirt_systemd_start;
  checkiso;
  gitndefine;
  reload_kvm;
  
  if [[ -f /usr/bin/virt-manager ]]; then
    echo -e "-- Virt-Manager exists! Launching..." >> $logfile
    bash /usr/bin/virt-manager &
  fi

  byee;
}

# Define VMs from a set Profile

vm1_define() {
  echo -e "\n-- FUNCTION: Define: Tier 1 VM" >> $logfile

  echo -e "-- Making appropriate virtual disk" >> $logfile
  sudo cp $HOME/quick-vm/kvm/Windows10Vanilla.qcow2 $imagesdir/Windows10highend.qcow2 >> $logfile

  TEXT="\n :: Making a Gaming capable VM!\n"; greentext
  echo -e "\n ➜ sudo virsh define Windows10-highend.xml\n"

  echo -e "-- Defining the VM...\n" >> $logfile
  sudo virsh define $HOME/quick-vm/kvm/$distro/Windows10-highend.xml >> $logfile

  if [[ $distro == "ARCH" ]]; then
    sudo cp /usr/share/ovmf/x64/OVMF_CODE.fd /var/lib/libvirt/qemu/nvram/Windows10-highend_VARS.fd
  elif [[ $distro == "DEBIAN" || $distro == "UBUNTU" ]]; then
    sudo cp /usr/share/OVMF/OVMF_CODE.fd /var/lib/libvirt/qemu/nvram/Windows10-highend_VARS.fd
  elif [[ $distro == "FEDORA" ]]; then
    sudo cp /usr/share/edk2/ovmf/OVMF_CODE.fd /var/lib/libvirt/qemu/nvram/Windows10-highend_VARS.fd
  fi

}

vm2_define() {
  echo -e "\n-- FUNCTION: Define: Tier 2 VM" >> $logfile

  TEXT="\n :: Making a useful VM!\n"; greentext
  echo -e "\n ➜ sudo virsh define Windows10-default.xml\n"
  
  echo -e "-- Making appropriate virtual disk" >> $logfile
  sudo cp $HOME/quick-vm/kvm/Windows10Vanilla.qcow2 $imagesdir/Windows10Default.qcow2 >> $logfile
  
  echo -e "-- Defining the VM...\n" >> $logfile
  sudo virsh define $HOME/quick-vm/kvm/$distro/Windows10-default.xml >> $logfile

  if [[ $distro == "ARCH" ]]; then
    sudo cp /usr/share/ovmf/x64/OVMF_CODE.fd /var/lib/libvirt/qemu/nvram/Windows10-default_VARS.fd
  elif [[ $distro == "DEBIAN" || $distro == "UBUNTU" ]]; then
    sudo cp /usr/share/OVMF/OVMF_CODE.fd /var/lib/libvirt/qemu/nvram/Windows10-default_VARS.fd
  elif [[ $distro == "FEDORA" ]]; then
    sudo cp /usr/share/edk2/ovmf/OVMF_CODE.fd /var/lib/libvirt/qemu/nvram/Windows10-default_VARS.fd
  fi

}

vm3_define() {
  echo -e "\n-- FUNCTION: Define: Tier 3 VM" >> $logfile

  echo -e "-- Making appropriate virtual disk" >> $logfile
  sudo cp $HOME/quick-vm/kvm/Windows10Vanilla.qcow2 $imagesdir/Windows10light.qcow2 >> $logfile

  TEXT="\n :: Making an economic VM!\n"; greentext
  echo -e "\n ➜ sudo virsh define Windows10-light.xml\n"

  echo -e "-- Defining the VM...\n" >> $logfile
  sudo virsh define $HOME/quick-vm/kvm/$distro/Windows10-light.xml >> $logfile

  if [[ $distro == "ARCH" ]]; then
    sudo cp /usr/share/ovmf/x64/OVMF_CODE.fd /var/lib/libvirt/qemu/nvram/Windows10-light_VARS.fd
  elif [[ $distro == "DEBIAN" || $distro == "UBUNTU" ]]; then
    sudo cp /usr/share/OVMF/OVMF_CODE.fd /var/lib/libvirt/qemu/nvram/Windows10-light_VARS.fd
  elif [[ $distro == "FEDORA" ]]; then
    sudo cp /usr/share/edk2/ovmf/OVMF_CODE.fd /var/lib/libvirt/qemu/nvram/Windows10-light_VARS.fd
  fi

}

stealth_define() {
  echo -e "\n-- FUNCTION: Define: Stealth VM" >> $logfile
  border;

  # TEXT="\n :: NOTE: THIS IS STILL BETA AND MIGHT NOT WORK OUT OF THE BOX.\n"; redtext

  TEXT="\n :: A Stealthy VM applies some mitigations to prevent VM detection.\n"; cyantext
  TEXT=" This is useful for running programs that have DRM/Anticheat built into them.\n"; cyantext
  TEXT=" (for eg. Video Games)\n"; cyantext
  TEXT=" These workarounds and mitigations might result in a performace hit depending on your hardware config, and the way you have your VM Set up.\n"; redtext
  TEXT=" Therefore, It is adviced that you use a Stealthy VM for ONLY operating the Softwares/Games that DO NOT run well in a traditional VM (even after GPU Passthrough)."; yellowtext

  sleep 3;

  if [[ $totalmem < 8388608 ]]; then
    TEXT="\n :: It is recommended that you allocate atleast 8 GiB RAM and 4 CPUs to the VM."; redtext
    echo -e "-- WARNING: Likely enough RAM not present." >> $logfile
  elif [[ $totalcpus < 4 ]]; then
    TEXT="\n :: YOUR CPU LIKELY DOES NOT HAVE ENOUGH CORES, PLEASE REDUCE THE ALLOCATION IN THE CONFIG."; redtext
    echo -e "-- WARNING: Likely enough CPU threads not present." >> $logfile
  fi

  sleep 1;

  TEXT="\n Creating a Stealth VM...\n"; greentext
  echo -e "-- Making appropriate virtual disk" >> $logfile
  sudo cp $HOME/quick-vm/kvm/Windows10Vanilla.qcow2 $imagesdir/Windows10Stealth.qcow2 >> $logfile

  echo -e "-- Defining the VM...\n" >> $logfile
  if [[ $cpubrand == "AMD" ]]; then
    echo -e "\n ➜ sudo virsh define Windows10-Stealth-amd.xml\n"
    sudo virsh define $HOME/quick-vm/kvm/$distro/Windows10-Stealth-amd.xml >> $logfile

  elif [[ $cpubrand == "INTEL" || $cpubrand == "UNKNOWN" ]]; then
    echo -e "\n ➜ sudo virsh define ~/quick-vm/kvm/Windows10-Stealth-intel.xml\n"
    sudo virsh define $HOME/quick-vm/kvm/$distro/Windows10-Stealth-intel.xml >> $logfile

  else
    TEXT="\n :: NO STEALTH VM PROFILE FOUND FOR YOUR PLATFORM!\n"; redtext
  fi

  TEXT="\n NOTE: Follow the further instructions from the Official GitHub Page."; yellowtext
  TEXT="\n https://github.com/thegamerhat/quick-vm/blob/main/docs/stealth-vm.md\n"; whitetext 

  sleep 3;

}


vm_profile_define() {
  echo -e "\n-- FUNCTION: Select a Custom VM Profile" >> $logfile

  if [[ $distro == "UBUNTU" ]]; then
    distro="DEBIAN"
  fi
  
  if [[ ! -d $HOME/quick-vm ]]; then
    cd $HOME
    echo -e "-- Cloning the repository" >> $logfile
    git clone https://github.com/thegamerhat/quick-vm
    clear;
  else
    cd $HOME/quick-vm
    TEXT="\n :: Fetching updates, please wait..."; yellowtext
    git pull
    clear;
  fi
  
  border;

  TEXT="\n :: Please Selct the VM Profile according to your needs."; greentext
  TEXT="\n You can change the resource allocations anytime.\n"; greentext
  TEXT=" [1] Serious Business (6 CPU Threads/8 GB RAM)"; whitetext
  TEXT=" [2] Decently Powerful (4 CPU Threads/6 GB RAM) [Default]"; whitetext
  TEXT=" [3] Lightweight and Barebones (2 CPU Threads/4 GB RAM)"; whitetext

  TEXT="\n [4] Create a Stealth VM [For DRM/Anticheat Programs] \n"; cyantext
    
  if [[ $totalcpus < 4 || $totalmem < 7000000 ]]; then
    TEXT=" ➜ Your system probably does NOT have enough CPU/Memory resources, slowdowns might occur."; redtext

  elif [[ $totalcpus < 4 && $totalmem < 7000000 ]]; then
    TEXT=" ➜ Your system probably does NOT have enough CPU and Memory resources, slowdowns might occur."; redtext

  else
    TEXT=" :: Your system has enough resources for VMs\n"; yellowtext
  fi

  echo ""
  read -p " ➜ Choose an option [1-4]: " vm_profile_choice
  echo ""

  if [[ $vm_profile_choice == 1 ]]; then                       # High-End!
    vm1_define;

  elif [[ $vm_profile_choice == 2 ]]; then                     # Default.
    vm2_define;

  elif [[ $vm_profile_choice == 3 ]]; then                     # Barebones..
    vm3_define;

  elif [[ $vm_profile_choice == 4 ]]; then                     # Stealthy ^=^
    stealth_define;

  else
    vm2_define;

  fi

  if [[ -f /usr/bin/virt-manager ]]; then
    echo ""
    read -p " ➜ Open Virt-Manager? [Y/n]: " virtmanagerchoice
    echo ""

      if [[ $virtmanagerchoice =~ "N" || $virtmanagerchoice =~ "n" ]]; then
        echo "\n"
      
      else
        echo -e ""
        virt-manager &
      fi

  fi
  setupmode="advanced" && advancedsetup;

}

# Advanced Setup with every step
advancedsetup(){
  echo -e "\n-- [ ADVANCED SETUP ]\n" >> $logfile

  while [[ $setupmode == "advanced" ]]
  do
  
    border;
  
    TEXT="\n :: You have selected Advanced Install."; greentext
    TEXT=" :: Select any one of the options below to get started!\n"; boldtext
    TEXT=" [1] Check KVM Compatibility"; bluetext 
    TEXT=" [2] Install required packages (via package manager)"; bluetext
    TEXT=" [3] Enable Libvirt Service & Virtual Networking (SYSTEMD ONLY)"; bluetext 
    TEXT=" [4] Locate ISOs (in $maindir & $imagesdir)"; bluetext
    TEXT=" [5] Select a Custom VM Profile"; bluetext
    TEXT=" [6] Reload KVM Kernel Modules (enables Nested Virtualization)"; bluetext
    echo ""
    TEXT=" [7] Return"; boldtext 
  
    echo ""
    read -p " ➜ Choose a task from above [1-7]: " setup_choice
    echo ""
  
    if [[ $setup_choice == 1 ]]; then
      clear;
      check_kvm;
    elif [[ $setup_choice == 2 ]]; then
      clear;
      installdeps;
    elif [[ $setup_choice == 3 ]]; then
      clear;
      libvirt_systemd_restart;
    elif [[ $setup_choice == 4 ]]; then
      clear;
      checkiso;
    elif [[ $setup_choice == 5 ]]; then
      clear;
      vm_profile_define;
    elif [[ $setup_choice == 6 ]]; then
      clear;
      reload_kvm;
    elif [[ $setup_choice == 7 ]]; then
      clear;
      echo "\n-- [ Return ]" >> $logfile
      welcome;
    else
      clear;
      TEXT=" Invalid choice, please select from the options below."; yellowtext
      setupmode="advanced"
    fi
  
  done

}

welcome() {

  TEXT="\n\n\x1b[1;32m :: Thank you for using Quick-VM, the setup process is starting.\e[0m"; boldtext 
  TEXT=" :: Select any one of the options below to get started!\n"; boldtext
  TEXT=" [1] Default install (Fully Automated & Quick)"; whitetext
  echo ""
  TEXT=" [2] Advanced install (Pick & choose functions)"; whitetext
  echo ""
  TEXT=" [3] Exit without installation"; whitetext
  echo -e "\n"
  read -p " ➜ Choose an option [1,2,3]: " user_choice
  echo ""
  
  if [[ $user_choice == 1 ]]; then
    clear;
    setupmode="simple"
    simplesetup
  elif [[ $user_choice == 2 ]]; then
    clear;
    setupmode="advanced"
    advancedsetup
  elif [[ $user_choice == 3 ]]; then
    echo ""
    byee;
  else
    echo " Invalid choice, please select from the options above."
    exit
  fi
  
  echo "\n"
}

welcome
