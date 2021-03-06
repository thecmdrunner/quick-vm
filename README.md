# Quick-VM
Setup a Windows VM very easily and quickly on any Arch, Debian or Fedora system using Red Hat KVM. 

### Requirements:

  - **Ubuntu 18.04** or newer
  - **Fedora 29** or newer
  - **Arch** (You can read the [ArchWiki Guide for GPU Passthrough](https://wiki.archlinux.org/index.php/PCI_passthrough_via_OVMF))

Note that any Linux distribution will work just fine as long as it is somewhat recent, 
and can install `virt-manager` and `qemu`. You do need **Linux Kernel Version 4.19+**

You can make a Linux VM or a Windows VM. However, this guide focuses on making a Window
s VM, as the process is a relatively easier for Linux VM because you don't have to down
load or install any drivers through an iso.

This guide uses **Ubuntu 20.04** for the demo.


# Creating a Virtual Machine in KVM
This step-by-step guide will take you through setting up a CPU and memory efficient vir
tual machine to use OBS Studio and give exam at the same time.

## Install KVM
First up, you must install KVM and the Virtual Machine Manager. By installing `virt-manager`, you will get everything you need for your distribution:
```bash
sudo apt-get install -y virt-manager
```

## Download the Windows Professional and KVM VirtIO drivers
You will need the Windows 10 ISO. You will also need drivers for VirtIO to ensure the best performance and lowest overhead for your system. You can download these at the following links.

Windows 10 ISO: https://www.microsoft.com/en-us/software-download/windows10ISO


