
# 🛸 DIY From Scratch (Almost Done) 

If you want to go through the process of making a VM all by yourself, this section is for you.

This guide works regardless of your distribution.

## Enabling Virtualization in your UEFI/Coreboot

You need to enable **AMD-V** or Intel **VT-x/VT-d** depending on your CPU brand in your UEFI before going further. 

**THIS VARIES BETWEEN VARIOUS MOTHERBOARDS**

Take a look at how to do it below:

<p>
<details>
<summary>How to enable Virtualization on your Motherboard</summary>
<br>

Please follow below steps to enable virtualization(SVM) in the BIOS for AMD motherboards:

#### 1. Press `Del` or `F2` in the keyboard after power on, then press `F7` to enter into Advanced Mode(ROG series motherboard can directly enter into Advanced Mode, no need to press `F7`)

![Screenshot](img/asus-b450-1.jpg)

#### 2. Click `F7` if you are not in advanced mode already

![Screenshot](img/asus-b450-2.jpg)

#### 3. Click [Advanced] - [CPU Configuration] 

![Screenshot](img/asus-b450-3.jpg)

#### 4. Enable Virtualization based on your CPU [INTEL or AMD] 

- **Enable SVM (AMD)**

![Screenshot](img/asus-b450-4.jpg)

- **Enable VT-x and Intel Virtualization (Intel)**

![Screenshot](img/asus-laptop-intel1.jpg)

- **OLD BIOS (Intel and AMD)**

![Screenshot](img/asus-laptop-intel2.jpg)

#### 5. Finally, **Save** and **Reboot**.

>Instructions and media taken from Asus Forums.

</br>
</details>
</p>


If you have a laptop with UEFI, you can also [check this video](https://youtu.be/NbnPWhI4xis).

For Coreboot devices, refer to your manufacturer's instructions or check the official documentation [here](https://coreboot.org/status/kconfig-options.html). 

## Installing Dependencies 

Boot into your preffered Linux OS and install the packages. You may search the packages in your package manager or compile them yourself.

<p>
<details>
<summary>Installing Dependencies</summary>
<br>

### Install Qemu-KVM, Virt-Manager, Libvirt and other dependencies on your distro.

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

### After installing the dependencies, make sure you enable the following services.

Instead of `Systemd`, you can use `OpenRC`, `Runit`, `SysVinit` as well.

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
 

## Downloading ISOs

If you want to run Anti-Cheat games and use Winapps, you will need **Windows 10 Pro/Pro N/Pro Workstation/Enterprise**, as they have Hyper-V Support which is required.
 
- Download [Windows 10 Pro ISO](https://www.microsoft.com/en-us/software-download/windows10ISO), and [VirtIO Drivers (Stable)](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso)

> You may even supply your own custom Windows Image (like Windows Ameliorated Edition)

**Note:** Place ISOs in `/var/lib/libvirt/images/` to avoid permission issues.

## Creating a VM

<p>
<details>
<summary>Step by Step Guide - Click Me!</summary>
<br>

+ Open Virt Manager from your applications menu or type `virt-manager` in terminal.

+ Click on the ➕ icon or the first icon in Virt Manager to create a VM.

![Screenshot](img/diy-create-1.png)

![Screenshot](img/diy-create-2.png)

+ Select the Windows 10 ISO that you downloaded earlier, and choose the OS from the list if it isn't detected automatically.

![Screenshot](img/diy-create-3.png)

+ Allocate Memory and CPUs as per requirement.

![Screenshot](img/diy-create-4.png)

+ Either create a new disk or create one as big as you want, and later select the disk here.
You can enter any directory you wish, as well as how big you want it to be.

+ Enter this command to create a disk.
`qemu-img create -f qcow2 /var/lib/libvirt/images/Windows10Vanilla.qcow2 1024G`

![Screenshot](img/diy-create-5.png)

+ Check `Customize configuration before install` and click **Finish**.

![Screenshot](img/diy-create-6.png)

+ In the Overview section, Select `OVMF_CODE.fd` in Firmware.

![Screenshot](img/diy-create-7.png)

+ In the CPU section, check `Copy host CPU configuration` if you aren't planning to make a Stealth VM, and `host-passthrough` otherwise.

+ You may manually set `CPU Topology` if you know the exact layout of your CPU.

>for example: **Ryzen 5 3600** has `6 Cores`, `12 Threads` and is only available in `1 Socket` motherboards.

![Screenshot](img/diy-create-8.png)

+ In the Memory section, enter `Current allocation = 1024` to make initial RAM usage less.

![Screenshot](img/diy-create-9.png)

+ In SATA Disk section, Change the `Disk Bus` to `VirtIO` to make operations faster by reducing overhead.

![Screenshot](img/diy-create-10.png)

+ In NIC section, Change the `Device model` to `VirtIO` to enable Virtual Network Bridge for interfacing between VM and Host.

![Screenshot](img/diy-create-11.png)

+ Click **Add Hardware** and select the Storage section to add VirtIO Drivers ISO and change the `Device type` to `CDROM device` and click Finish.

![Screenshot](img/diy-create-12.png)

![Screenshot](img/diy-create-13.png)

+ In the Boot Options section, select Windows ISO CDROM and VirtIO Disk that we created earlier, and check 'Enable boot menu'.

+ Finally, Click `Begin Installation` to save and start the VM.

![Screenshot](img/diy-create-14.png)

+ Click inside the VM Window and press any key when asked.  

![Screenshot](img/first-boot.png)

![Screenshot](img/booting-iso.png)

+ Select your language and keyboard input and click Next.

![Screenshot](img/install-1.png)

![Screenshot](img/install-2.png)

+ Enter your product key now, or you can skip and enter your product key after installation.

![Screenshot](img/install-3.png)

+ Selecting **Windows 10 Pro N** will install **Windows 10 Pro** without extra bloat.
> Note: Choose Windows 10 Pro XXX or Enterprise if you need Hyper-V for Stealth VM. 

![Screenshot](img/install-4.png)

![Screenshot](img/install-5.png)

+ Select **Custom Install**  (because the other one is useless)

![Screenshot](img/install-6.png)

+ Click on **Load Driver** to install disk drivers.

![Screenshot](img/install-7.png)

![Screenshot](img/install-8.png)

+ Double-Click on **CD Drive virtio-win** ➜ **amd64** ➜ **w10** and click **OK**. 

![Screenshot](img/install-9.png)

+ Just click N**ext** to select the default one.

![Screenshot](img/install-10.png)

+ Select `Unallocated Space` and click **Next** to begin the installation.

![Screenshot](img/install-11.png)

![Screenshot](img/install-12.png)

+ After installation, Windows will boot normally and you will need to set up your user account and password.

+ Avoid Microsoft Sign in if you can at all 😉 

</br>
</details>
</p>

## CPU Optimization

There usually isn't much that needs to be done for optimizing CPU Performance in VM, but there are a couple of things that need to be taken into consideration for more than just a basic VM.

- [CPU Pinning](https://mathiashueber.com/performance-tweaks-gaming-on-virtual-machines/#CPU_Pinning) for better CPU Allocation
- []

## GPU Passthrough 

TLDR; see 1. [Ubuntu/Pop OS 20.04 Guide](https://mathiashueber.com/pci-passthrough-ubuntu-2004-virtual-machine/), 2. [ArchWiki PCI Passthrough via OVMF](https://wiki.archlinux.org/index.php/PCI_passthrough_via_OVMF), 3. [Gentoo Guide](https://wiki.gentoo.org/wiki/GPU_passthrough_with_libvirt_qemu_kvm)

Video Guides: 1. [TechTeamGB Ubuntu NVIDIA Passthrough](https://www.youtube.com/watch?v=NDgiV7Lgku8), 2. [SomeOrdinaryGamers' Arch NVIDIA Passthrough](https://www.youtube.com/watch?v=h7SG7ccjn-g), 3. [Level1Linux Fedora Passthrough](https://www.youtube.com/watch?v=aLeWg11ZBn0) 

For laptops, see [Laptop Compatibility](https://github.com/thegamerhat/quick-vm/blob/main/docs/diy-vm.md#-laptop-compatibility)

---

Ideally you need to have 2 GPUs (one dedicated and one integrated) in order to access Windows as well as Linux desktop simultaneously, by using 2 monitors or switching the display output on one monitor.

However, if you are living in the world after 2020, I know your pain and why you have only one (or possibly none) GPU.

You might be in one of the following situations:

  1. You ONLY have one GPU, either discrete GPU (NVIDIA/AMD) or integrated Graphics (Intel UHD/AMD Radeon)
  2. You have a discrete GPU (NVIDIA/AMD) + integrated Graphics (Intel UHD/AMD Radeon)
  3. You have two discrete GPUs (then integrated graphics won't matter)

If you are one of the privileged people to own a GPU, and are looking to pass it through without integrated graphics, check out these Single GPU Passthrough Guides:
  1. [SomeOrdinaryGamers' Single GPU Passhrough Video (NVIDIA)](https://youtube.com/watch?v=BUSrdUoedTo)
  2. [joeknock90 central repository](https://github.com/joeknock90/Single-GPU-Passthrough)

If you are lucky enough to have 2 discrete GPUs, you can reserve one GPU for your Linux system and pass the other one to Windows. Check these guides out:

  1. [Level1Tech's GPU Passthrough Guide](https://www.youtube.com/watch?v=aLeWg11ZBn0)
  2. [SomeOrdinaryGamers' KVM Guide](https://www.youtube.com/watch?v=h7SG7ccjn-g)

> In the past, it was required that you have two different GPUs (typically AMD + NVIDIA), but that's not a requirement anymore!

If you only have integrated graphics right now, check out:

- [Lan Tian's Intel GPU iPasshrough Guide](https://lantian.pub/en/article/modify-computer/laptop-intel-nvidia-optimus-passthrough.lantian/)

If you want to be able to use Hardware Accelerated Applications (like Video Games, Adobe CC, etc) on a Windows VM without dedicating an entire monitor to Windows VM, check out the **Looking Glass** Project:

  - [Looking Glass](https://looking-glass.io) - An extremely low latency Memory-to-Memory frame copy from the Guest to Host.
  - [Level1Techs Video](https://www.youtube.com/watch?v=okMGtwfiXMo) - It has gotten better than what this video demonstrates!

### Code 43/Black Screen fix 

NVIDIA's driver **465** and newer support GPU Passthrough to a Windows Guest on a Linux Host.

>**NOTE**: NVIDIA still doesn't support SR-IOV so you will need an iGPU or a separate GPU if you want to be able to access the Linux Host.
>
>If you don't want to use a second GPU, check out [Single GPU Passthrough](https://github.com/joeknock90/Single-GPU-Passthrough)

So if you need to passthrough an NVIDIA or AMD GPU without making it obvious that you are using a VM, add the following lines to your XML.

**1. List all VMs**

```bash
sudo virsh list --all
```

![Screenshot](img/virsh-list.png)

**2. Edit the VM config**

```bash
sudo virsh edit Windows10
```

**3. Enter the following text between the already existing sections**

#### You can replace `randomid` with `AuthenticAMD` to fix a few issues on RX 5000 and older AMD GPUs. 

```bash
...
<features>
...
  <hyperv>
  ...
    <vendor_id state="on" value="randomid"> 

  </hyperv>
  
  <kvm>
      <hidden state="on"/>
  </kvm>
...
</features>
```

## Gotchas

For any issues not just limited to the following, check the following sections on the Arch Wiki.

[**Section 1**](https://wiki.archlinux.org/index.php/PCI_passthrough_via_OVMF#Gotchas_1):
- Unisolated IOMMU Groupings
- Problems with vfio-pci loading correctly

[**Section 2**](https://wiki.archlinux.org/index.php/PCI_passthrough_via_OVMF#Gotchas_2):
- Using a non-EFI image on EFI based VM

[**Section 3**](https://wiki.archlinux.org/index.php/PCI_passthrough_via_OVMF#Gotchas_3):
- Passing through a device that does not support resetting via kernel

## 💻 Laptop Compatibility

![Screenshot](img/mux-laptop.jpg)

According to the image above, if you have a MUXless laptop, then it is tricky to dedicate your GPU to a VM and have its own separate display, because the GPU doesn't connect to the HDMI/DisplayPort Port directly, and instead uses the iGPU as a bridge to the laptop screen.
Read more about it on [this post in Level1Forums](https://forum.level1techs.com/t/implications-of-muxed-muxless-laptops-for-gpu-passthrough/129165)

You might be able to get around this by passing the iGPU to the VM, as [shown here](https://lantian.pub/en/article/modify-computer/laptop-intel-nvidia-optimus-passthrough.lantian)


You can still get past through this sometimes like [this reddit post](https://www.reddit.com/r/VFIO/comments/hx5j8q/success_with_laptop_gpu_passthrough_on_asus_rog/) mentions, using an ROG Zephyrus G14 w/ RTX 2060.


### NVIDIA Issues on Laptops

Sometimes on Optimus/Max-Q laptops, NVIDIA wants to check for the battery info in Windows or else it returns **Code 43**.

If you experience that issue, check out the [SSDT Workaround](https://wiki.archlinux.org/index.php/PCI_passthrough_via_OVMF#%22Error_43:_Driver_failed_to_load%22_with_mobile_(Optimus/max-q)_nvidia_GPUs) on ArchWiki.

If you still get a **Code 43**, perhaps [batmanfeynman's post](https://www.reddit.com/r/VFIO/comments/mqxhus/code_43_on_optimus_laptop_help/) or [alterNERDtive's post](https://www.reddit.com/r/VFIO/comments/mqz2gt/solved_nvidia_passthrough_post_driver_465_code_43/) could help.


## AMD Reset Bug Fixes

- For Polaris, Vega and Gen1 Navi Reset fix, installing [vendor-reset](https://github.com/gnif/vendor-reset) is enough thanks to [gnif](https://github.com/gnif).
- For RX 5000, check out [Navi Reset Bug Kernel V2](https://forum.level1techs.com/t/navi-reset-bug-kernel-patch-v2/163103/14)
- Also see the recent [Pop! OS 20.10 VFIO 5700XT](https://forum.level1techs.com/t/pop-os-20-10-vfio-5700xt-pain/169647/2) post

## Making your VM Stealth

### 🔖 [Guide on Stealthy VM](stealth-vm.md)
