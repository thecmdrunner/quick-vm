# Quick-VM
Setup a Windows VM very easily and quickly on any Arch, Debian or Fedora system using Red Hat KVM. 

### Requirements:
 
  - Ubuntu 18.04 or newer
  - Fedora 29 or newer
  - Arch (You can read this [Guide by LinuxHint](https://linuxhint.com/install_configure_kvm_archlinux)for permissions and User Group setup)
 
<p>
<details>
<summary>Installing Dependencies</summary>
 
 ### Install Qemu, Virt-Manager, Libvirt and other dependencies depending on your distro.
 First up, you must install KVM and the Virtual Machine Manager. By installing `virt-manager`, you will get everything you need for your distribution:
 ```bash
 
 # Debian & Ubuntu based ditros 
 sudo apt install -y qemu qemu-kvm libvirt-daemon libvirt-clients bridge-utils virt-manager
 
 # Fedora based ditros  
 sudo dnf -y install bridge-utils libvirt virt-install qemu-kvm
 
 # Arch based ditros 
 sudo pacman -S --noconfirm virt-manager qemu vde2 ebtables dnsmasq ridge-utils openbsd-netcat
 
 # Enable Libvirt Service
 sudo systemctl enable --now libvirtd
 ```
 
 
</details>
</p>
 
 
 Note that any Linux distribution will work just fine as long as it is somewhat recent, and can install `virt-manager` and `qemu`. You do need Linux Kernel Version 4.19+
 
 You can make a Linux VM or a Windows VM. However, this guide focuses on making a Windows VM, as the process is a relatively easier for Linux VM because you don't have to download
 or install any drivers through an iso.
 
 This guide uses Ubuntu 20.04 for the demo.
 
 
 # Creating a Virtual Machine in KVM
 This step-by-step guide will take you through setting up a CPU and memory efficient virtual machine to use OBS Studio and give exam at the same time.
 
 ## Install KVM
 First up, you must install KVM and the Virtual Machine Manager. By installing `virt-manager`, you will get everything you need for your distribution:
 ```bash
 sudo apt-get install -y virt-manager
 ```
 
 ## Download the Windows Professional and KVM VirtIO drivers
 You will need the Windows 10 ISO. You will also need drivers for VirtIO to ensure the best performance and lowest overhead for your system. You can download these at the following links.
 
 Windows 10 ISO: https://www.microsoft.com/en-us/software-download/windows10ISO
