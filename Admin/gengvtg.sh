#!/bin/sh

#Set Vars
PCI=$(lspci -D -nn | grep -m1 VGA | cut -d ' ' -f1)
GVT_GUID=71abd338-d32e-4a56-8f9a-5830d16a2828
GVT_TYPE=i915-GVTg_V5_4

#Initialize GVT-G
if ( lsmod | grep kvmgt | grep vfio_iommu_type1 | grep mdev > /dev/null ); then
    echo GVT-G Already Initialized...
else
    echo Initializing GVT-G...
    sudo modprobe kvmgt vfio-mdev vfio-iommu-type1
fi

#Remove GVT-G if '-r' argument or if GVT Device already exists
if [ "$1" = "-r" ] || [ -f /sys/bus/pci/devices/$PCI/$GVT_GUID/remove ]; then
    echo Removing GVT Device, enter root password to continue...
    su -c 'echo 1 > /sys/bus/pci/devices/'"$PCI"'/'"$GVT_GUID"'/remove'
    exit
fi

#Create GVT-G if it does not exist.
if [ -f /sys/devices/pci0000:00/$PCI/mdev_supported_types/$GVT_TYPE/description ]; then
    echo Creating GVT Device, enter root password to continue...
    su -c 'echo "'"$GVT_GUID"'" > "/sys/devices/pci0000:00/'"$PCI"'/mdev_supported_types/'"$GVT_TYPE"'/create"'
else
    echo 'Error: '/sys/devices/pci0000:00/$PCI/mdev_supported_types/$GVT_TYPE/' not found, aborting...'
fi
