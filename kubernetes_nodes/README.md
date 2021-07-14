- Run tests to see if the image is OK
  - firewall works and has proper ports open (https://wiki.debian.org/Uncomplicated%20Firewall%20%28ufw%29)

NOTE: Proxmox KVM will hang at 100% CPU when there is no serial port configured for a diskimage-create image.
https://bugs.launchpad.net/cloud-images/+bug/1573095
Immediate fix is to add a serial console to the VM
- Create new VM in proxmox
  - 32 GB disk
  - 2 CPU cores (host cpu enabled, not kvm)
  - 4096 MB
  - Serial Port
  - CloudInit Drive
  - VGA to serial0
  - Replace qcow2 disk with our created disk
  - Enable qemu-agent
  - Extra VIRTIO (for performance) network adapter attached to private network for NFS

- Sync image to proxmox
```
scp image.qcow2 mediacenter:/images/image.qcow2
cp -v /data/images/image.qcow2 /data/images/images/100/vm-100-disk-0.qcow2
qm rescan
```

- Boot VMs

|hostname|ip            |gateway    |dns         |
|--------|--------------|-----------|------------|
|master  |192.168.1.3/24|192.168.1.1|192.168.1.1 |
|worker1 |192.168.1.4/24|192.168.1.1|192.168.1.1 |
|worker2 |192.168.1.5/24|192.168.1.1|192.168.1.1 |
|worker3 |192.168.1.6/24|192.168.1.1|192.168.1.1 |

- Install metallb

```
kubectl --kubeconfig ./admin.conf apply -f https://raw.githubusercontent.com/google/metallb/v0.8.3/manifests/metallb.yaml
```

- Service ips

|hostname |ip             |
|---------|---------------|
|resilio-1|192.168.1.10/24|
|resilio-2|192.168.1.11/24|
|plex     |192.168.1.12/24|
|radarr   |192.168.1.13/24|

---

- Useful elements for debugging
```
journal-to-console
devuser
```

- Checking contents of /tmp folder of created qcow image:
```
guestfish
add kubernetes_buster.qcow2
run
list-filesystems
mount /dev/sda1 /
ls /tmp
```

- Boot image with vmware
```
qemu-img convert -f qcow2 -O vmdk image.qcow2 image.vmdk
```

- Repository with a lot of kubernetes configs
https://github.com/hyperbolic2346/kubernetes
