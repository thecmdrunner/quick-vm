
# Check the flavour of Linux and install dependencies

if [[ -f /usr/bin/pacman ]]
then
  sudo pacman -S --noconfirm qemu libvirt bridge-utils edk2-ovmf vde2 ebtables dnsmasq openbsd-netcat virt-manager && sudo systemctl enable libvirtd
elif [[ -f /usr/bin/dnf ]]
then
  sudo dnf -y install qemu-kvm libvirt bridge-utils virt-install virt-manager
elif [[ -f /usr/bin/apt ]]
then
  sudo apt install -y qemu qemu-kvm libvirt-bin libvirt-daemon libvirt-clients bridge-utils virt-manager
else
  echo "Your System possibly isn't Debian/Fedora/Arch, make sure to install the KVM dependencies before you continue." && exit 1
fi
