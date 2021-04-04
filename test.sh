
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


yellowtext() {
  echo -e "\x1b[1;33m$TEXT\e[0m"
}


bluetext() {
  echo -e "\x1b[1;34m$TEXT\e[0m"
}


cyantext() {
  echo -e "\e[1;36m$TEXT\e[0m"
}


# System resource definitions
totalmem=$(grep MemTotal /proc/meminfo | awk '{print $2}')
totalcpus=$(getconf _NPROCESSORS_ONLN)


vm_define() {

  TEXT='\n:: Making a Gaming capable VM!\n'; greentext
  echo 'sudo virsh define ~/quick-vm/kvm/Windows10-highend.xml'
  sudo virsh define ~/quick-vm/kvm/Windows10-highend.xml

}

vm2_define() {

  TEXT='\n:: Making a useful VM!\n'; greentext
  echo 'sudo virsh define ~/quick-vm/kvm/Windows10-default.xml'
  sudo virsh define ~/quick-vm/kvm/Windows10-default.xml

}

vm3_define() {

  TEXT='\n:: Making an economic VM!\n'; greentext
  echo 'sudo virsh define ~/quick-vm/kvm/Windows10-barebones.xml'
  sudo virsh define ~/quick-vm/kvm/Windows10-barebones.xml

}

vm1_define() {

  TEXT='\n:: Stealthy VM applies some mitigations to bypass and prevent VM detection.\n'; yellowtext
  TEXT='This is useful if the programs you use have some kind of DRM/Anticheat built into then (for eg. Games).\n'; yellowtext
  TEXT='\nHowever, the workarounds and mitigations result in a performace hit depending on your hardware config, and the way you have your VM Set up.'; yellowtext
  TEXT='Therefore, It is adviced that you use a Stealthy VM for ONLY operating the Softwares/Games that DO NOT run well in a traditional VM (even after GPU Passthrough).'; yellowtext
  TEXT='\n\nNOTE: Please follow the steps '
  TEXT='\n\nCreating a Stealth VM'; yellowtext
  sleep 5
}


stealth_define() {

  TEXT='\n:: Stealthy VM applies some mitigations to bypass and prevent VM detection.\n'; yellowtext
  TEXT='This is useful if the programs you use have some kind of DRM/Anticheat built into then (for eg. Games).\n'; yellowtext
  TEXT='\nHowever, the workarounds and mitigations result in a performace hit depending on your hardware config, and the way you have your VM Set up.'; yellowtext
  TEXT='Therefore, It is adviced that you use a Stealthy VM for ONLY operating the Softwares/Games that DO NOT run well in a traditional VM (even after GPU Passthrough).'; yellowtext
  TEXT='\n\nNOTE: Please follow the steps '
  TEXT='\n\nCreating a Stealth VM'; yellowtext
  sleep 5

}


vm_profile_define() {
  
  if [[ ! -d ~/quick-vm ]]; then
    cd ~/
    echo "cloning from git repo" >> ~/quick-vm.log
    git clone --recursive https://github.com/gamerhat18/quick-vm >> ~/quick-vm.log 
    cd ~/quick-vm
  fi

  TEXT='\n:: Please Selct the VM Profile according to your needs.'; greentext
  TEXT='\nYou can change the resource allocations anytime.\n'; greentext
  TEXT='\n[1] Serious Business (6 CPU Threads/8 GB RAM)'; boldtext
  TEXT='\n[2] Decently Powerful (4 CPU Threads/6 GB RAM) [Default]'; boldtext
  TEXT='\n[3] Lightweight and Barebones (2 CPU Threads/4 GB RAM)'; boldtext

  TEXT='\n\n[4] Create a Stealth VM [For DRM/Anticheat Programs]\n'; cyantext
    
  if [[ $totalcpus < 4 || $totalmem < 7000000 ]]; then
    TEXT=':: Your system probably does NOT have enough CPU/Memory resources, slowdowns might occur.'; redtext

  elif [[ $totalcpus < 4 && $totalmem < 7000000 ]]; then
    TEXT=':: Your system probably does NOT have enough CPU and Memory resources, slowdowns might occur.'; redtext

  else
    TEXT=':: Your system has enough resources for VMs!\n'; yellowtext
  fi

  echo ''
  read -pr ":: Choose an option [1-4]: " vm_profile_choice
#  PS3=$(echo_prompt ':: Choose an option [1-4]: ' vm_profile_choice
  echo ''

  if [[ $vm_profile_choice=='1' ]]; then                       # High-End!
    vm1_define;

  elif [[ $vm_profile_choice=='2' ]]; then                     # Default.
    vm2_define;

  elif [[ $vm_profile_choice=='3' ]]; then                     # Barebones..
    vm3_define;

  elif [[ $vm_profile_choice=='4' ]]; then                     # Stealthy ^=^
    stealth_define;


  fi

}

vm_profile_define
