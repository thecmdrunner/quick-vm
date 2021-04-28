# 🗔 Installing Windows on a VM

### Please follow along the steps below to get the VM ready.

+ Open **Virtual Machine Manager** and Start the **Windows VM**

> If you encounter an OVMF/edk2 problem, check out [OVMF Fix](https://wiki.archlinux.org/index.php/PCI_passthrough_via_OVMF#Cannot_boot_after_upgrading_ovmf)
>
> **Or you can enter the following command in terminal (only applicable this VM)**
>
> Ubuntu/Debian ➜ `sudo cp /usr/share/OVMF/OVMF_CODE.fd /var/lib/libvirt/qemu/nvram/Windows10-default_VARS.fd `
>
> Fedora ➜ `sudo cp /usr/share/edk2/ovmf/OVMF_CODE.fd /var/lib/libvirt/qemu/nvram/Windows10-default_VARS.fd`
>
> Arch ➜ `sudo cp /usr/share/ovmf/x64/OVMF_VARS.fd /var/lib/libvirt/qemu/nvram/Windows10-default_VARS.fd`

+ Click inside the VM Window and press any key when asked.  

![Screenshot](docs/img/first-boot.png)

![Screenshot](docs/img/booting-iso.png)

+ Select your language and keyboard input and click Next.

![Screenshot](docs/img/install-1.png)

![Screenshot](docs/img/install-2.png)

+ Enter your product key now, or you can skip and enter your product key after installation.

![Screenshot](docs/img/install-3.png)

+ Selecting **Windows 10 Pro N** will install **Windows 10 Pro** without extra bloat.
> Note: Choose Windows 10 Pro XXX or Enterprise if you need Hyper-V for Stealth VM. 

![Screenshot](docs/img/install-4.png)

![Screenshot](docs/img/install-5.png)

+ Select **Custom Install**  (because the other one is useless)

![Screenshot](docs/img/install-6.png)

+ Click on **Load Driver** to install disk drivers.

![Screenshot](docs/img/install-7.png)

![Screenshot](docs/img/install-8.png)

+ Double-Click on **CD Drive virtio-win** ➜ **amd64** ➜ **w10** and click **OK**. 

![Screenshot](docs/img/install-9.png)

+ Just click N**ext** to select the default one.

![Screenshot](docs/img/install-10.png)

+ Select `Unallocated Space` and click **Next** to begin the installation.

![Screenshot](docs/img/install-11.png)

![Screenshot](docs/img/install-12.png)

### 🎉 That's it, You have successfully installed Windows!
