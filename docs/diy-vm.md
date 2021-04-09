

## 🛸 DIY (From Scratch) - WIP

### First, you must install the required packages on your system. You may search the packages in your package manager or compile them yourself.

<p>
<details>
<summary>Installing Dependencies</summary>
<br>


#### Install Qemu-KVM, Virt-Manager, Libvirt and other dependencies on your distro.
 

**Note:** Any Linux distribution will work just fine. You do need to install `libvirt`, `virt-manager`, `qemu`, and other required dependencies.

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

 # Enable VM Console logging 
 sudo systemctl enable --now virtlogd 

 # Enable Virtual Network Bridge 
 sudo virsh net-autostart default
 sudo virsh net-start default
 ```
 
</br> 
</details>
</p>
 
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

