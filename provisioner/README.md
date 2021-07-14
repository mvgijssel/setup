### Debugging

# https://www.virtualbox.org/ticket/11011

vbox_socket-pty

1. Configure host pipe in virtualbox, point to /tmp/vbox_socket
2. Boot socat on the socket to create pty
```
socat UNIX-CONNECT:/tmp/vbox_socket PTY,link=/tmp/vbox_socket-pty &
```
3. Use screen to attach to the pty using
```
screen /tmp/vbox_socket-pty
```

### Provisioner

Responsibility of the provisioner is running the services to allow the rest of the servers to operate.
Currently this means the following services:

- digital rebar
- vault

Requirements of provisioner:

- runs on both raspberry pi and regular vm
- as minimal as possible
- uses docker to run the necessary services

We can use packer with an arm builder to build a raspberry pi compatible image.
Also leverage packer to build the vm image using the same setup?

We can use qemu chroot builder https://github.com/summerwind/packer-builder-qemu-chroot
so the vm image can also built inside of the docker image.








### Respberry PI notes

Necessary for raspberry pi bootable image:
- /boot/cmdline.txt
- /boot/start.elf (?)
- /boot/config.txt
- Raspbian / Armbian



Use https://github.com/pftf/RPi3



> The use of this firmware can greatly simplify the installation of generic Linux distributions such as Debian or Ubuntu as well as Windows 10 (in regular GUI mode, not IoT mode), straight from their ISO images.


Seems folks are working on making Raspberry Pi 4 UEFI bootable (https://rpi4-uefi.dev/)




- Currently using the packer-arm-builder instead of diskimage-builder

Booting the created image using qemu?

Copy the kernel from inside the image to 
https://forums.gentoo.org/viewtopic-t-1106406-start-0.html

    qemu-system-arm -kernel kernel -append "root=/dev/sda2 panic=1 rootfstype=ext4 rw" -hda ubuntu-20.04.img -cpu arm1176 -m 256 -machine versatilepb

    qemu-system-arm -hda ubuntu-20.04.img -M raspi2


    qemu-system-aarch64 -hda ubuntu-20.04.img -M raspi2
    

https://github.com/guysoft/CustomPiOS/blob/devel/src/qemu_boot64.sh
https://raspberrypi.stackexchange.com/questions/100384/running-raspbian-buster-with-qemu
https://forums.gentoo.org/viewtopic-t-1106406-start-0.html
https://superuser.com/questions/1535589/qemu-emulating-a-raspberry-pi-doesnt-have-internet-capability
https://www.reddit.com/r/virtualization/comments/frtnd7/type_1_hypervisor_for_raspberry_pi_4/
 
 # We're getting at least something on the screen!
 qemu-system-aarch64 \
  -nographic \
  -kernel kernel \
  -dtb bcm2711-rpi-4-b.dtb \
  -m 1G -M raspi3 \
  -cpu cortex-a53 \
  -append "rw earlycon=pl011,0x3f201000 console=ttyAMA0 loglevel=8 root=/dev/mmcblk0p2 fsck.repair=yes net.ifnames=0" \
  -drive file="ubuntu-20.04.img",format=raw,if=sd \
  -no-reboot

 # This works! Using raspberry pi 3 dtb (device tree blob)
 qemu-system-aarch64 \
  -serial stdio \
  -kernel kernel \
  -dtb ./firmware/bcm2837-rpi-3-b.dtb \
  -m 1G -M raspi3 \
  -cpu cortex-a72 \
  -append "rw earlycon=pl011,0x3f201000 console=ttyAMA0 loglevel=8 root=/dev/mmcblk0p2 fsck.repair=yes net.ifnames=0" \

  -append "console=ttyAMA0,115200 kgdboc=ttyAMA0,115200 root=/dev/mmcblk0p2 rootfstype=ext4 rootwait" \

  -drive file="ubuntu-20.04.img",format=raw,if=sd \
  -no-reboot




Think the raspberry pi runs a ARMv8a processor
BCM2711 SoC with a 1.5 GHz 64-bit quad-core ARM Cortex-A72 
https://github.com/unicorn-engine/unicorn






