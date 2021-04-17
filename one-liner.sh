#!/bin/bash

# oneliner command: bash <(curl -sSL https://git.io/JOeOs) 
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


# System resource definitions
totalmem=$(grep MemTotal /proc/meminfo | awk '{print $2}')
totalcpus=$(getconf _NPROCESSORS_ONLN)

# what distro
distro=''

# Checks if the current working directory is read only and warns the user.
# Logs cant be stored on a READ-ONLY Drive.

cd ~/
touch ~/quick-vm.log
if [[ -f ~/quick-vm.log ]]
then
  echo -e "\nLogs for Quick-VM Project are written here. Link: https://github.com/thegamerhat/quick-vm\n\n\n" >> ~/quick-vm.log
  if [[ $EUID -ne 0 ]]; then
    echo " Not running this script as root. " >>  ~/quick-vm.log
  fi
else
  TEXT="Filesystem is possibly READ-ONLY. Errors may not be logged."; redtext
  TEXT="YOU MAY CONTINUE, BUT MIGHT ENCOUNTER ERRORS."; redtext
fi

# What main distro is the system running

if [[ -f /usr/bin/apt ]]; then
  distro='debian'
elif [[ -f /usr/bin/dnf ]]; then
  distro='fedora'
elif [[ -f /usr/bin/pacman ]]; then
  distro='arch'
else
  distro='unknown'
fi


### PRE-DEFINED OPERATIONS

# echo --------------------

border() {
  TEXT="\n--------------------------------------------------------------------------------"; whitetext
}


# exit function

byee() {

  echo ""
  TEXT=":: Exiting, Bye!"; greentext
  echo ""
  exit

}

# Check if the system supports virtualisation

cpu_kvm_flags=$(egrep -c '(vmx|svm)' /proc/cpuinfo)
cpu_vt=$(lscpu | grep Virtualization)

# What CPU is it
if [[ $cpu_vt =~ "AMD-V" ]]; then
  cpubrand='AMD'
elif [[ $cpu_vt =~ "VT-x" ]]; then
  cpubrand='INTEL'
fi


# throws up an error in front of the user if 
# /usr/bin/virt-host-validate does not exist

if [[ -f /usr/bin/virt-host-validate ]]; then 
  kvm_pass=$(/usr/bin/virt-host-validate | grep '/dev/kvm exists')
fi

check_kvm() {

  # throws up an error in front of the user if 
  # /usr/bin/virt-host-validate does not exist

  if [[ -f /usr/bin/virt-host-validate ]]; then
    kvm_pass=$(/usr/bin/virt-host-validate | grep '/dev/kvm exists')
  fi

  echo ''

  # if the output is more than 0 then,
  # virtualization is supported, else not
  if [[ $cpu_kvm_flags > 0 ]]; then

    # if the output is more than 0 then,
    # virtualization is supported, else not
    if [[ $cpu_vt =~ "AMD-V" ]]; then
      TEXT="[✓] AMD Virtualization (AMD-V) is Supported!"; greentext
    elif [[ $cpu_vt =~ "VT-x" ]]; then
      TEXT="[✓] Intel Virtualization (VT-x/VT-d) is Supported!"; greentext
    else
      TEXT="[!] AMD-V/VT-x not detected. Virtualization support might be limited."; yellowtext
      echo -e "The setup can still continue."
    fi
  
    if [[ $kvm_pass =~ ": PASS" ]]; then
      TEXT="[✓] KVM is enabled!"; greentext
      kvm_enabled='yes'
    elif [[ $kvm_pass =~ ": FAIL" ]]; then
      TEXT="[X] KVM not detected. Please ensure Virtualization is enabled in UEFI/CoreBoot."; redtext
      kvm_enabled='no'
    else
      TEXT="[!] ERROR DETECTING KVM SUPPORT."; redtext
    fi
  
  elif [[ $cpu_kvm_flags < 1 ]]; then
    
    TEXT="[X] YOUR CPU DOES NOT SUPPORT VIRTUALIZATION."; redtext

  fi

}

reload_kvm() {

  if [[ $kvm_pass =~ ": PASS" ]]; then
    kvm_enabled='yes'
  elif [[ $kvm_pass =~ ": FAIL" ]]; then
    kvm_enabled='no'
  fi

  if [[ $cpu_vt =~ "AMD-V" ]]; then
      cpubrand='AMD'
  elif [[ $cpu_vt =~ "VT-x" ]]; then
      cpubrand='INTEL'
  fi 

  if [[ $cpubrand == 'AMD' ]]; then
    sudo modprobe -r kvm_amd kvm
    sudo modprobe kvm
    sudo modprobe kvm_amd nested=1

  elif [[ $cpubrand == 'INTEL' ]]; then
    sudo modprobe -r kvm_intel kvm
    sudo modprobe kvm
    sudo modprobe kvm_intel nested=1
  
  fi

  if [[ $kvm_enabled == 'yes' ]]; then
    echo -e "\nkvm detected properly.\n" >> ~/quick-vm.log
    TEXT="\n:: RESTART MIGHT BE REQUIRED IF THE VM DOES NOT BOOT PROPERLY."; whiteunderline
    
  elif [[ $kvm_enabled == 'no' ]]; then
    TEXT="\n[X] KVM DOES NOT SEEM TO BE ENABLED IN UEFI/COREBOOT."; redtext 
  fi

}


# Start Libvirt service through systemd

libvirt_systemd_start () {

  # dependencies check
  
  if [[ ! -f /usr/bin/virsh ]]; then
    echo ''
    TEXT="[X] Virsh not found! Please make sure all the dependencies are installed correctly."; redtext
    exit
  fi

  TEXT="\n:: Now starting up libvirtd socket and service"; bluetext

  TEXT="\n:: Executing 'sudo systemctl enable --now libvirtd'\n"; bluetext

  sudo systemctl enable libvirtd >> ~/quick-vm.log
  sudo systemctl start libvirtd >> ~/quick-vm.log

  sudo systemctl enable libvirtd.socket >> ~/quick-vm.log
  sudo systemctl start libvirtd.socket >> ~/quick-vm.log

  sudo systemctl enable libvirtd.service >> ~/quick-vm.log
  sudo systemctl start libvirtd.service >> ~/quick-vm.log

  TEXT="\n[✓] Done. Logs saved to ~/quick-vm.log\n"; greentext

  TEXT=":: Now starting up virtlogd socket and service"; bluetext

  TEXT="\n:: Executing 'sudo systemctl enable --now virtlogd'\n"; bluetext

  sudo systemctl enable virtlogd >> ~/quick-vm.log
  sudo systemctl start virtlogd >> ~/quick-vm.log

  TEXT=":: Enabling Virtual Network Bridge at startup\n"; bluetext

  sudo virsh net-autostart default >> ~/quick-vm.log
  sudo virsh net-start default >> ~/quick-vm.log

  TEXT="\n[✓] Done. Logs saved to ~/quick-vm.log\n"; greentext

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
    TEXT='[✓] VirtIO Drivers and Windows 10 ISO exist in '$imagesdir'!\n'; whiteunderline

   else

    # Windows ISO check and moves it to $imagesdir

     if [[ -f $maindir/win10.iso && ! -f $imagesdir/win10.iso ]]; then
       TEXT="Windows ISO exists in ~/$dirname!"; greentext
       echo ''
       TEXT="➜ Relocating the image in /var/lib/libvirt/images !"; bluetext
       echo ''
       sudo rsync --partial --progress $maindir/win10.iso /var/lib/libvirt/images/win10.iso
       TEXT="\n[✓] Operation Done!\n"; greentext
  
     elif [[ -f $imagesdir/win10.iso ]]; then
       TEXT="Windows ISO already exists in ~/$imagesdir!\n"; greentext
  
     elif [[ ! -f $maindir/win10.iso && ! -f $imagesdir/win10.iso ]] ; then
       TEXT="Windows ISO doesn't exist in either ~/WindowsVM or $imagesdir!"; redtext
       echo "Please make sure that ~/WindowsVM/win10.iso exists and run the script again!"

     else
       TEXT="ERROR OCCURED. Please check the logs."; redtext
     fi
     
     # VirtIO Check and moves it to $imagesdir
  
     if [[ -f $maindir/virtio-win.iso ]]; then
       TEXT="VirtIO Drivers exist in ~/WindowsVM!\n"; greentext
       TEXT="➜ Relocating the image in /var/lib/libvirt/images !\n"; bluetext
       sudo rsync --partial --progress $maindir/virtio-win.iso /var/lib/libvirt/images/virtio-win.iso
       TEXT="\n[✓] Operation Done!\n"; greentext
  
     elif [[ -f $imagesdir/virtio-win.iso ]]; then
       TEXT="VirtIO Drivers ISO already exists in ~/$imagesdir!"; greentext
       echo ''
  
     elif [[ ! -f $maindir/virtio-win.iso && ! -f $imagesdir/virtio-win.iso ]] ; then
       TEXT="\n\nVirtIO Drivers ISO doesn't exist in in either ~/WindowsVM or $imagesdir!"; redtext
       echo -e "\nPlease make sure that ~/WindowsVM/win10.iso exists and run the script again!\n'"
       TEXT="[!] Do you want to download them now? The VM will NOT boot without the drivers ISO.\n"; greentext
       
       read -p "➜ Please enter your choice [Y/n]: " virt_choice
    
       if [[ $virt_choice == 'y' ]]; then
        TEXT='\nDownloading VirtIO Drivers (Stable)...\n'; greentext
        wget -cq https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso -O ~/WindowsVM/virtio-win.iso --show-progress --progress=bar
        echo ''

        if [[ -f $maindir/virtio-win.iso ]]; then
          sudo rsync --partial --progress $maindir/virtio-win.iso /var/lib/libvirt/images/virtio-win.iso
          echo ":: Done! Now the setup process will continue."
          TEXT="\n[✓] Operation Done!\n"; greentext
        fi

       elif [[ $virt_choice == 'n' ]]; then
        echo ''
        TEXT="[!] OK! Skipping VirtIO Drivers for now.\n"; bluetext
        echo "Make sure to download and put the VirtIO Drivers (Stable) ISO in $imagesdir"
        echo "OR place it in $maindir and run the script again."
        sleep 5;

       else
        TEXT="[!] Invalid Option! Skipping VirtIO Drivers for now,"; redtext
        echo "But make sure you download and put the VirtIO Drivers (Stable) ISO in $imagesdir"
        echo "OR place it in $maindir and run the script again."
        sleep 5;
       fi

     else
       TEXT="ERROR OCCURED. Please check the logs."; redtext
     fi
  
   fi

 else
   mkdir $maindir
   TEXT=":: Please put Windows and VirtIO Drivers ISO in $maindir\n"; redtext
   TEXT="Without the ISOs, the setup can't progress further.\n"; yellowtext
   exit
 fi
 
}
  

# Clones the main reporsitory and defining the VM via `virsh`

gitndefine() {

  if [[ ! -d ~/quick-vm ]]; then
    cd ~/
    echo "Cloning from git repository..." >> ~/quick-vm.log
    git clone --recursive https://github.com/thegamerhat/quick-vm >> ~/quick-vm.log 
  
  else
    cd ~/quick-vm 
    git pull || grep 'yay'

  fi

  sudo rsync -q ~/quick-vm/kvm/Windows10Vanilla.qcow2 /var/lib/libvirt/images/ >> ~/quick-vm.log
  sudo rsync -q ~/quick-vm/kvm/essentials.iso /var/lib/libvirt/images >> ~/quick-vm.log

  if [[ -f /var/lib/libvirt/images/virtio-win.iso && /var/lib/libvirt/images/win10.iso ]]; then
    
    if [[ $distro=='arch' ]]; then
      sudo virsh define ~/quick-vm/kvm/arch/Windows10-default.xml  >> quick-vm.log
      sudo cp /usr/share/ovmf/x64/OVMF_VARS.fd /var/lib/libvirt/qemu/nvram/Windows10-default_VARS.fd
    elif [[ $distro=='debian' ]]; then
      sudo virsh define ~/quick-vm/kvm/debian/Windows10-default.xml >> ~/quick-vm.log
      sudo cp /usr/share/OVMF/OVMF_CODE.fd /var/lib/libvirt/qemu/nvram/Windows10-default_VARS.fd 
    elif [[ $distro=='fedora' ]]; then
      sudo virsh define ~/quick-vm/kvm/fedora/Windows10-default.xml >> ~/quick-vm.log
      sudo cp /usr/share/edk2/ovmf/OVMF_CODE.fd /var/lib/libvirt/qemu/nvram/Windows10-default_VARS.fd
    fi

    TEXT="\n[✓] Your VM is Ready! Follow the instructions from the Official Project page to get started."; greentext

  else
    TEXT="\n[!] Some filess missing from /var/lib/libvirt/images/"; redtext
    echo -e "\nPlease read the instructions on how and where to place them on the Official GitHub Page. \n"
  fi

}

installdeps() {

# Arch-Setup 

  if [[ $distro == 'arch' ]]; then
    TEXT="\n[✓] BASE SYSTEM: ARCH"; cyantext
    echo -e "\n:: Installing Dependencies...\n"; 
    sudo pacman -S --noconfirm git qemu rsync libvirt bridge-utils edk2-ovmf vde2 ebtables dnsmasq openbsd-netcat virt-manager 

# Fedora Setup

  elif [[ $distro == 'fedora' ]]; then
    TEXT="\n[✓] BASE SYSTEM: FEDORA\n"; cyantext
    echo -e ":: Installing Dependencies\n"; 
    sudo dnf -y install @virtualization git qemu-kvm rsync libvirt bridge-utils edk2-ovmf virt-install virt-manager 

# Debian Setup

  elif [[ $distro == 'debian' ]]; then
    TEXT="\n[✓] BASE SYSTEM: DEBIAN\n"; cyantext
    echo -e ":: Installing Dependencies\n"; 
    sudo apt-get update -q && sudo apt-get install -y git qemu rsync qemu-kvm libvirt-daemon libvirt-clients bridge-utils ovmf virt-manager
  
# Unknown Distro

  else
    TEXT="\n[X] Skipping Distro Check...\n"; cyantext
    TEXT=":: Your System possibly isn't Debian/Fedora/Arch, make sure to install the KVM dependencies through your package manager.\n"; bluetext
    echo -e "\nAfter installing, run the Advanced Setup to complete the rest of the process."
    echo -e "OR check out the Manual Setup Process on the Project's GitHub Page: https://github.com/thegamerhat/Quick-VM\n"
    sleep 3
    byee;
  
  fi

  TEXT="\n[✓] Setup Finished!"; greentext

}

# Simple Quick and automatic setup for One-Liner.

simplesetup() {
  
  TEXT="\n➜ Starting Simple Setup"; cyantext
  installdeps;
  border;
  check_kvm;
  border && sleep 5;
  libvirt_systemd_start;
  checkiso;
  gitndefine;
  reload_kvm;
  byee;
  
  if [[ -f /usr/bin/virt-manager ]]; then
    bash /usr/bin/virt-manager &
  fi

}

# Define VMs from a set Profile

vm1_define() {

  sudo cp ~/quick-vm/kvm/Windows10Vanilla.qcow2 $imagesdir/Windows10highend.qcow2

  TEXT='\n:: Making a Gaming capable VM!\n'; greentext
  echo -e '\n➜ sudo virsh define Windows10-highend.xml\n'

  if [[ -f /usr/bin/pacman ]]; then
    sudo virsh define ~/quick-vm/kvm/arch/Windows10-highend.xml
  elif [[ -f /usr/bin/apt ]]; then
    sudo virsh define ~/quick-vm/kvm/debian/Windows10-highend.xml
  elif [[ -f /usr/bin/dnf ]]; then
    sudo virsh define ~/quick-vm/kvm/fedora/Windows10-highend.xml
  fi

}

vm2_define() {

  TEXT='\n:: Making a useful VM!\n'; greentext
  echo -e '\n➜ sudo virsh define Windows10-default.xml\n'

  sudo virsh define ~/quick-vm/kvm/$distro/Windows10-default.xml

}

vm3_define() {

  sudo cp ~/quick-vm/kvm/Windows10Vanilla.qcow2 $imagesdir/Windows10light.qcow2

  TEXT='\n:: Making an economic VM!\n'; greentext
  echo -e '\n➜ sudo virsh define Windows10-light.xml\n'

  sudo virsh define ~/quick-vm/kvm/$distro/Windows10-light.xml

}

stealth_define() {
  
  border;

  TEXT='\n:: NOTE: THIS IS STILL BETA AND MIGHT NOT WORK OUT OF THE BOX.\n'; redtext

  TEXT='\n:: A Stealthy VM applies some mitigations to prevent VM detection.\n'; cyantext
  TEXT='This is useful for running programs that have DRM/Anticheat built into them.\n'; cyantext
  TEXT='(for eg. Video Games)\n'; cyantext
  TEXT='These workarounds and mitigations might result in a performace hit depending on your hardware config, and the way you have your VM Set up.\n'; redtext
  TEXT='Therefore, It is adviced that you use a Stealthy VM for ONLY operating the Softwares/Games that DO NOT run well in a traditional VM (even after GPU Passthrough).'; yellowtext

  sleep 3;

  if [[ $totalmem < 8388608 ]]; then
    TEXT="\n:: It is recommended that you allocate atleast 8 GiB RAM and 4 CPUs to the VM."; redtext
  elif [[ $totalcpus < 4 ]]; then
    TEXT="\n:: YOUR CPU LIKELY DOES NOT HAVE ENOUGH CORES, PLEASE REDUCE THE ALLOCATION IN THE CONFIG."; redtext
  fi

  sleep 1;

  TEXT="\nNOTE: Please follow the instructions from the Official GitHub Page to complete the remaining process."; yellowtext
  TEXT="\nhttps://github.com/thegamerhat/quick-vm/blob/main/docs/stealth-vm.md\n"; whiteunderline 
  TEXT="\nCreating a Stealth VM..."; greentext
  sudo cp ~/quick-vm/kvm/Windows10Vanilla.qcow2 $imagesdir/Windows10Stealth.qcow2

  sleep 3;

  if [[ $cpubrand == 'AMD' ]]; then
    echo -e '\n➜ sudo virsh define Windows10-Stealth-amd.xml\n'
    sudo virsh define ~/quick-vm/kvm/$distro/Windows10-Stealth-amd.xml

  elif [[ $cpubrand == 'INTEL' ]]; then
    echo -e '\n➜ sudo virsh define ~/quick-vm/kvm/Windows10-Stealth-intel.xml\n'
    sudo virsh define ~/quick-vm/kvm/$distro/Windows10-Stealth-intel.xml

  else
    TEXT="\n:: NO STEALTH VM PROFILE FOUND FOR YOUR PLATFORM!\n"; redtext
  fi

}


vm_profile_define() {
  
  if [[ ! -d /home/$USER/quick-vm ]]; then
    cd /home/$USER/
    git clone https://github.com/thegamerhat/quick-vm
    clear;
  else
    cd /home/$USER/quick-vm
    git pull
    clear;
  fi
  
  border;

  TEXT='\n:: Please Selct the VM Profile according to your needs.'; greentext
  TEXT='\nYou can change the resource allocations anytime.\n'; greentext
  TEXT='[1] Serious Business (6 CPU Threads/8 GB RAM)'; whitetext
  TEXT='[2] Decently Powerful (4 CPU Threads/6 GB RAM) [Default]'; whitetext
  TEXT='[3] Lightweight and Barebones (2 CPU Threads/4 GB RAM)'; whitetext

  TEXT='\n[4] Create a Stealth VM [For DRM/Anticheat Programs] \n'; cyantext
    
  if [[ $totalcpus < 4 || $totalmem < 7000000 ]]; then
    TEXT='➜ Your system probably does NOT have enough CPU/Memory resources, slowdowns might occur.'; redtext

  elif [[ $totalcpus < 4 && $totalmem < 7000000 ]]; then
    TEXT='➜ Your system probably does NOT have enough CPU and Memory resources, slowdowns might occur.'; redtext

  else
    TEXT=':: Your system has enough resources for VMs\n'; yellowtext
  fi

  echo ''
  read -p "➜ Choose an option [1-4]: " vm_profile_choice
  echo ''

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
    echo ''
    read -p "➜ Open Virt-Manager? [Y/n]: " virtmanagerchoice
    echo ''

      if [[ $virtmanagerchoice =~ "Y" || $virtmanagerchoice =~ "y" ]]; then
        echo -e '\n \n'
        virt-manager &

      elif [[ $virtmanagerchoice =~ "N" || $virtmanagerchoice =~ "n" ]]; then
        echo '\n'

      else
        echo -e '\n \n'
        virt-manager &

      fi

  fi

  setupmode='advanced' && advancedsetup;

}

# Advanced Setup with every step

advancedsetup(){

while [[ $setupmode=='advanced' ]]
do

  border;

  TEXT="\n:: You have selected Advanced Install."; greentext
  TEXT=":: Select any one of the options below to get started!\n"; boldtext
  TEXT="[1] Check KVM Compatibility"; bluetext 
  TEXT="[2] Install required packages (via package manager)"; bluetext
  TEXT="[3] Enable Libvirt Service & Virtual Networking (SYSTEMD ONLY)"; bluetext 
  TEXT="[4] Locate ISOs (in $maindir & $imagesdir)"; bluetext
  TEXT="[5] Select a Custom VM Profile"; bluetext
  TEXT="[6] Reload KVM Kernel Modules (enables Nested Virtualization)"; bluetext
  echo ''
  TEXT="[7] Return"; boldtext 

  echo ''
  read -p "➜ Choose a task from above [1-7]: " setup_choice
  echo ''

  if [[ $setup_choice == 1 ]]; then
    clear;
    check_kvm;
  elif [[ $setup_choice == 2 ]]; then
    clear;
    installdeps;
  elif [[ $setup_choice == 3 ]]; then
    clear;
    libvirt_systemd_start;
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
    welcome;
  else
    clear;
    echo "Invalid choice, please select from the options below."
    setupmode='advanced'
  fi

done

}

welcome() {

  TEXT="\n\n\x1b[1;32m:: Thank you for choosing Quick-VM, the setup process is starting.\e[0m"; boldtext 
  TEXT=":: Select any one of the options below to get started!\n"; boldtext
  TEXT="[1] Default install (Fully Automated & Quick)"; whitetext
  echo ''
  TEXT="[2] Advanced install (Pick & choose functions)"; whitetext
  echo ''
  TEXT="[3] Exit without installation"; whitetext
  echo -e '\n'
  read -p "➜ Choose an option [1,2,3]: " user_choice
  echo ''
  
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
  
  echo '\n'

}

welcome
