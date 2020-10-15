#!/bin/sh
#
# Requires root
#
# curl
# xz
# mkisofs

# https://download.freebsd.org/ftp/releases/ISO-IMAGES/12.1/FreeBSD-12.1-RELEASE-i386-bootonly.iso.xz
if [ $# -ne 2 ]; then
    echo "usage: $(basename $0) VM_NAME FREEBSD_BOOT_ISO"
    exit 1
fi

VM_NAME="$1"
FREEBSD_INSTALL_URL="$2"

INSTALL_ISO=$(mktemp)
echo "Downloading install iso"
curl -o - "${FREEBSD_INSTALL_URL}" | xz -F xz -d - > "${INSTALL_ISO}"

MOUNTD=$(mktemp -d)    || exit 1
NEWD=$(mktemp -d)      || exit 1
MODIFIED_ISO=$(mktemp) || exit 1

# Since we're using sudo, this is a sanity check.
if [ -z "${MOUNTD}" ]; then exit 1; fi
if [ -z "${NEWD}" ]; then exit 1; fi
if [ -z "${MODIFIED_ISO}" ]; then exit 1; fi

# The install cd is setup to mount itself based on volume id, so we preserve that.
VOLUME_ID=$(isoinfo -d -i "${INSTALL_ISO}" | grep "Volume id:" | cut -d ':' -f 2 | tr -d ' ')

# Attach ISO to loop back device and mount.
LOOPD=$(sudo losetup --show --find "${INSTALL_ISO}") || exit 1
sudo mount "${LOOPD}" "${MOUNTD}" || exit 1

# Make a copy of the ISO we can modify.
echo "Copying install iso"
sudo cp -r "${MOUNTD}/." "${NEWD}" || exit 1

# Unmount, detach, and remove install ISO to free up space.
sudo umount "${MOUNTD}"
rmdir "${MOUNTD}"
sudo losetup -d "${LOOPD}"
rm "${INSTALL_ISO}"

# Copy scripts and create new ISO.
echo "Modifying install iso"
sudo cp os-install.sh "${NEWD}/etc/rc.local" || exit 1
sudo cp first-build.sh "${NEWD}/root"        || exit 1
sudo mkisofs -V "${VOLUME_ID}" -quiet -R -no-emul-boot -b boot/cdboot -o - "${NEWD}" > "${MODIFIED_ISO}" || exit 1

# Delete directory of new ISO to free up space.
sudo rm -fr "${NEWD}"

# Create the vm.
echo "Creating VM"
VBoxManage createvm --name "${VM_NAME}" --register --ostype FreeBSD --default || exit 1

# Modify some settings.
VBoxManage modifyvm "${VM_NAME}" \
                            --memory 8192         \
                            --vram 16             \
                            --rtcuseutc on        \
                            --audio none          \
                            --cpus 6              \
                            --ioapic on           \
                            --usbohci off         \
                            --usbehci off         \
                            --usbxhci off         \
                            --nic1 nat            \
                            --nictype1 82540EM    || exit 1

# Determine the vm directory.
VM_CONFIG=$(VBoxManage showvminfo "${VM_NAME}" --machinereadable | grep CfgFile | cut -d '=' -f 2 | sed 's/^"//;s/"$//')
VM_HOME="$(dirname "${VM_CONFIG}")"

# Create disk.
VBoxManage createmedium --filename "${VM_HOME}/disk1.vdi" --size 20480 --format VDI --variant Standard || exit 1

# Create storage controller.
VBoxManage storagectl "${VM_NAME}" --name "IDE" --remove
VBoxManage storagectl "${VM_NAME}" --name "SATA Controller" --add sata --controller IntelAHCI --portcount 2 || exit 1

# Attach media.
VBoxManage storageattach "${VM_NAME}" --storagectl "SATA Controller" --port 0 --type hdd --medium "${VM_HOME}/disk1.vdi" || exit 1
VBoxManage storageattach "${VM_NAME}" --storagectl "SATA Controller" --port 1 --type dvddrive --medium "${MODIFIED_ISO}" || exit 1

echo "Starting VM"
VBoxManage startvm "${VM_NAME}" || exit 1

echo -n "Waiting for VM shutdown"
FOUND=0
while [ ${FOUND} -ne 1 ]; do
    echo -n "."
    VBoxManage list runningvms | grep -q "${VM_NAME}" 
    FOUND="$?"
    sleep 30
done
echo

echo "Removing iso and starting VM"
VBoxManage storageattach "${VM_NAME}" --storagectl "SATA Controller" --port 1 --type dvddrive --medium none

rm "${MODIFIED_ISO}"

VBoxManage startvm "${VM_NAME}"
