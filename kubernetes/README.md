- Create the qcow image
  
```
docker build --tag image-builder:bionic .
```
  
```
docker run --rm -it --privileged -v $PWD/images:/app -v $PWD/elements:/elements image-builder:bionic /bin/bash
```

Useful elements for debugging
```
journal-to-console
devuser
```

Checking contents of /tmp folder of created qcow image:

```
guestfish
add stretch_2.qcow2
run
list-filesystems
mount /dev/sda1 /
ls /tmp
```

```
disk-image-create -o stretch_1 debian vm debian-systemd growroot kubernetes cloud-init

export break=after-error
export DIB_RELEASE=stretch
export DIB_APT_MINIMAL_CREATE_INTERFACES=0
disk-image-create -o stretch_1 debian vm cloud-init

export break=after-error
export DIB_RELEASE=stretch
export DIB_APT_MINIMAL_CREATE_INTERFACES=0
disk-image-create -o stretch_2 debian vm cloud-init debian-networking-fix cloud-init-fix

export break=after-error
export DIB_RELEASE=stretch
export DIB_APT_MINIMAL_CREATE_INTERFACES=0
disk-image-create -o stretch_3 debian vm cloud-init debian-networking-fix cloud-init-fix kubernetes

export break=after-error
export DIB_RELEASE=buster
export DIB_APT_MINIMAL_CREATE_INTERFACES=0
disk-image-create -o buster_1 debian vm cloud-init 

export break=after-error
export DIB_RELEASE=buster
export DIB_APT_MINIMAL_CREATE_INTERFACES=0
disk-image-create -o buster_2 debian vm cloud-init debian-networking-fix

export break=after-error
export DIB_RELEASE=bionic
export DIB_APT_MINIMAL_CREATE_INTERFACES=0
disk-image-create -o bionic_1 ubuntu vm cloud-init
```

- Boot image with vmware

```
qemu-img convert -f qcow2 -O vmdk image.qcow2 image.vmdk
```

- Create `cloud-init` config

```
mkisofs -output cloud-init.iso -volid cidata -joliet -rock {cloud-init/user-data,cloud-init/meta-data}
```

- Boot image with qemu `-nographic` can also be used instead of `-serial stdio`

```
./boot_qemu.sh images/stretch_3.qcow2
```

- Run tests to see if the image is OK
  - root partition is grown to 32G
  - kubelet service
  - kubectl, kubeadm, kubelet same versions

- Sync image to /var/lib/vz/template in proxmox

```
scp image.qcow2 mediacenter:/images/image.qcow2
```

- Update proxmox

```
qm rescan
```

- Create new VM in proxmox
  - 32 GB disk
  - Serial Port
  - CloudInit Drive
  - VGA to serial0
  - Replace qcow2 disk with our created disk

```
mv -v /data/images/image.qcow2 /data/images/images/100/vm-100-disk-0.qcow2
```

- Resize qcow2 disk to 32 GB (same as VM creation)

```
qemu-img resize /data/images/images/100/vm-100-disk-0.qcow2 32G
```

- Boot VM

NOTE: Proxmox KVM will hang at 100% CPU when there is no serial port configured for a diskimage-create image.
https://bugs.launchpad.net/cloud-images/+bug/1573095
Immediate fix is to add a serial console to the VM