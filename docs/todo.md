
## 🔌 TODO-notes

- Maybe add a features section?
- you'll also likely need `vendor-reset` for cards suffering from the AMD reset bug (RX 5000 and older).
- (maybe?) IOMMU and VFIO
- GPU Passthrough edits in XML for `kvm hidden state` and `vendor_id` 
- Stealth VM notes
- Make separate disks for each stealth vm, with their own qcow2
- remove virtio From stealth VM
- GPU Passthrough options and notes
- AMD GPUs can use `vendor_id="AuthenticAMD"`
- Single GPU Passthrough for NVIDIA and AMD

## 🔮 Feature ideas

- ask user to enter the path to the isos instead of putting it in one folder (just for giving an option to the user)
- ꧁ Better design ꧂
- ability to make multiple VMs from the same profile.
- Motherboard Compatibility list (based on good IOMMU Groups separation)
