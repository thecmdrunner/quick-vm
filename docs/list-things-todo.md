
## 🔌 TODO-notes (no particular order)

- Make a more functional VM with optimizations, and VM specific stuff such as:
  - Adding a virtual sound card for passing through microphone from your Linux host. [Video tutorial](https://www.youtube.com/watch?v=AfUgNEOx3uk) by Pavol Elsig
  - Looking Glass? https://www.youtube.com/watch?v=wEhvQEyiOwI&t=2s
  - GPU passthrough? Parsec for gaming? Intel iGPU passthrough: https://www.youtube.com/watch?v=Tt4kHYO1S8U
  - Remote desktop
  - Remote Apps
  - Mouse and KB passthrough using `evdev`: [Video tutorial](https://www.youtube.com/watch?v=4XDvHQbgujI)
- Robust CLI
- Use `set -x` to show what commands are being executed when necessary.
- Add more distros support, and a general linux profile
- Maybe add a features section?
- make every define and creation with general command that has `$variables` based on the system and user choice
- Fork iommu, UEFI, laptop detection, GPU detection and some other features from https://github.com/T-vK/GPU-pass-through-compatibility-check
- Actual CPU Core allocation instead of vCPUs (CPU Pinning)
- USB_Passthrough guide (maybe also mouse and keyboard passthrough with evdev?)
- convert the xmls into actual defining commands of qemu
- you'll also likely need `vendor-reset` for cards suffering from the AMD reset bug (RX 5000 and older).
- (maybe?) IOMMU and VFIO
- gotchas section from archwiki pci passthrough
- GPU Passthrough edits in XML for `kvm hidden state` and `vendor_id` 
- make use of `hostnamectl` somehow
- Stealth VM notes
- GPU Passthrough options and notes
- AMD GPUs can use `vendor_id="AuthenticAMD"`
- Single GPU Passthrough for NVIDIA and AMD


## 🔮 Feature ideas

- ask user to enter the path to the isos instead of putting it in one folder (just for giving an option to the user)
- Better TUI and CLI design
- ability to make multiple VMs from the same profile.
- Motherboard Compatibility list (based on good IOMMU Groups separation)
