# Quick-VM 
Setup a Windows VM very easily and quickly on any Arch, Debian or Fedora system using RedHat KVM. 
Now that [NVIDIA has enabled GPU Passthrough for Windows based Virtual Machines](https://nvidia.custhelp.com/app/answers/detail/a_id/5173), this project will also include easy setup and configuration for passing through NVIDIA GPUs in KVM.
Till then, read [Single GPU Passthrough](https://github.com/joeknock90/Single-GPU-Passthrough) and [WinApps](https://github.com/Fmstrat/winapps/)

## Getting Started

### Simple Method:

1. Place the ISOs in `~/WindowsVM` and rename them as follows:
  - **Windows 10 ISO** ➜ `win10.iso`
  - **VirtIO Drivers** ➜ `virtio-win.iso`

2. Place the ISOs in `~/WindowsVM` and run the one-liner script below. The script will copy the ISOs to `/var/lib/libvirt/images/` for easy setup.

## One-liner to Setup KVM
### Paste this in your terminal

```bash
bash <(curl -sL https://git.io/JqtJc) 
 ```

Here is the [Raw Script](https://raw.githubusercontent.com/gamerhat18/quick-vm/main/main.sh)

### Host System Requirements:
 
  - **Ubuntu 18.04** or newer
  - **Fedora 30** or newer
  - **Arch** (You can read this [Guide by LinuxHint](https://linuxhint.com/install_configure_kvm_archlinux) for permissions and User Group setup)
  - **4 CPUs** (2 Hyperthreaded Cores at minimum, 1 vCPU is reserved for the host)
  - **8 GiB Memory** (in total)
  - **40-50 GiB of Storage Free** (For a typical install)
> **Linux Kernel 5.4 LTS** or newer is recommended 

### Default specs of the VM:

>**CPU**: 3 vCPUs Allocated
>
>**GPU**: You may Passthrough a GPU if you need using [ArchWiki](https://wiki.archlinux.org/index.php/PCI_passthrough_via_OVMF) or [Single-GPU-Passthrough](https://github.com/joeknock90/Single-GPU-Passthrough) 
>
>**Memory**: Total 4 GiB, 1 GiB Allocated initially
>
>**Primary Drive**: 1 TB VirtIO Disk (Dynamically Allocated)
>
>**Secondary Drive**: Windows 10 ISO
>
>**Other Drives**: VirtIO Drivers ISO, Essential Tools ISO (to optimize VM performance)
>
>**Network Card**: VirtIO (Recommended Disabled until debloated)



<p>
<details>
<summary>Manual Step-by-Step-Process</summary>
<br>

### First, you must install the required packages on your system. You may search the packages in your package manager or compile them yourself.

<p>
<details>
<summary>Installing Dependencies</summary>
<br>


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

### After installing the dependencies, make sure you enable `libvirtd.service`

```bash
 # Enable Libvirt Service
 sudo systemctl enable --now libvirtd
 ```
 
</br> 
</details>
</p>
 
**Note:** Any Linux distribution will work just fine. You do need to install `libvirt`, `virt-manager`, `qemu`, and other required dependencies.
> **Linux Kernel 5.4 LTS** or newer is recommended
 
## Download the Windows 10 ISO and KVM VirtIO drivers
You will need **Windows 10 Pro/Pro N**, as it has RDP Support which is needed if you want to run Windows Apps under Linux. You will also need drivers for VirtIO to ensure the best performance with the least overhead on your system.
 
- Download [VirtIO Drivers (Stable)](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso) from FedoraPeople

- Download [Official Windows 10 ISO](https://www.microsoft.com/en-us/software-download/windows10ISO) from Microsoft 

> You may even supply your own custom Windows Image (like Windows Ameliorated Edition)
 

**Note:** Place the ISOs in `~/WindowsVM` , as this script points to that directory to find those ISOs. You can change the location in the `kvm/Windows10-Vanilla.xml` file if you prefer.


### Make sure you rename both of the ISOs as following:

**Windows 10 ISO** ➜ `win10.iso`

**VirtIO Drivers** ➜ `virtio-win.iso`



</br>
</details>
</p>
