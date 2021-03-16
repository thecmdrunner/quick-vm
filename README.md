# Quick-VM (WORK IN PROGRESS)
Setup a Windows VM very easily and quickly on any Arch, Debian or Fedora system using RedHat KVM. 

## One-liner to Setup KVM (INCOMPLETE AS OF NOW)
### Paste this in your terminal

```bash

curl -sSL https://git.io/JqtJc | bash

```
Here is the [Raw Script](https://raw.githubusercontent.com/gamerhat18/Quick-VM/main/one-liner.sh)

### Host System Requirements:
 
  - **Ubuntu 18.04** or newer
  - **Fedora 30** or newer
  - **Arch** (You can read this [Guide by LinuxHint](https://linuxhint.com/install_configure_kvm_archlinux) for permissions and User Group setup)
  - **4 CPUs** (2 Hyperthreaded Cores at minimum, 1 vCPU is reserved for the host)
  - **8 GiB Memory** (in total)
  - **40 GiB of Storage for the VM** (For a typical install)
> **Linux Kernel 5.4 LTS** or newer is recommended 

### Default specs of the VM:

>**CPU**: 3 vCPUs Allocated
>
>**GPU**: You may Passthrough a GPU if you need using [ArchWiki](https://wiki.archlinux.org/index.php/PCI_passthrough_via_OVMF) or 
>
>**Memory**: Total 4 GiB, 1 GiB Allocated initially
>
>**Primary Drive**: 256 GB VirtIO Disk (Dynamically Allocated)
>
>**Secondary Drive**: Windows 10 ISO (SATA CDROM)
>
>**Other Drives**: VirtIO Drivers ISO (SATA CDROM), Essential Tools ISO (to optimize VM performance)
>
>**Network Card**: VirtIO (Disabled by default, Recommended this way until debloated)

<p>
<details>
<summary>Installing Dependencies</summary>
<br>

### Make sure your CPU Supports KVM.

#### Install Qemu-KVM, Virt-Manager, Libvirt and other dependencies depending on your distro.
 
 ```bash
# Debian & Ubuntu (Linux Mint, PopOS, ElementaryOS)
sudo apt install -y qemu qemu-kvm libvirt-bin libvirt-daemon libvirt-clients bridge-utils virt-manager
``` 

 ```bash
# Fedora based ditros  
sudo dnf -y install qemu-kvm libvirt bridge-utils virt-install virt-manager
``` 

```bash
# Arch (Manjaro, Arco Linux, EndeavourOS) 
sudo pacman -S --noconfirm qemu libvirt bridge-utils edk2-ovmf vde2 ebtables dnsmasq openbsd-netcat virt-manager

 ```

### After installing the dependencies, make sure you enable libvirtd.service

```bash
 # Enable Libvirt Service
 sudo systemctl enable --now libvirtd
 ```
 
<br> 
</details>
</p>
 
**Note:** Any Linux distribution will work just fine. You do need to install `libvirt`, `virt-manager`, `qemu`, and other required dependencies. ***Linux Kernel Version 5.4 LTS or newer is recommended.*** 
 
 ## Download the Windows 10 ISO and KVM VirtIO drivers
 You will need **Windows 10 Pro/Pro N**, as it has RDP Support which is needed if you want to run Windows Apps under Linux. You will also need drivers for VirtIO to ensure the best performance with the least overhead on your system.
 
- Download [VirtIO Drivers](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso) from FedoraPeople

- Download [Official Windows 10 ISO](https://www.microsoft.com/en-us/software-download/windows10ISO) from Microsoft 

> You may even supply your own custom Windows Image (like Windows Ameliorated Edition)
 

**Note:** Place the ISOs in `~/WindowsVM` , as this KVM config file points to that directory to find those ISOs. You can change the location in the `kvm/Windows10-Vanilla.xml` file if you prefer.


### Make sure you rename both of the ISOs as following:

**Windows 10 ISO** ➜ `win10.iso`

**VirtIO Drivers** ➜ `virtio-win.iso`




