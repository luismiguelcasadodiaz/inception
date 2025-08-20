
# Boot Order

# Network

Bridge adapter

# Increase hard disk space in an existing virtual machine
 
As the project progressed, I realised that the original 2GB disk was insufficient. Early on, Docker Compose began reporting the error: no space left on device.

To resolve this, I doubled the disk size using the following commands.

```bash
VBoxManage modifymedium disk "/sgoinfre/students/luicasad/maria/maria/inception Clone.vdi" --resize 4096
VBoxManage showhdinfo "/sgoinfre/students/luicasad/maria/maria/inception Clone.vdi"
```

This involves modifying the partition table of the virtual machine. Within `fdisk /dev/sda`, I deleted the 3rd partition without erasing data with `-d`.

This involves a file system extension. `resize2fs /dev/sda3` made it possible.

# Shared folders

This setup enables me to use Visual Studio Code on the host machine to seamlessly edit files within the virtual machine.

<img src="https://github.com/user-attachments/assets/d2d72222-050d-4f1a-b480-989d1778f7ce" alt="Sample Image" style="width:50%; height:auto;">

![Shared folders](https://github.com/user-attachments/assets/d2d72222-050d-4f1a-b480-989d1778f7ce)

The mounted shared folder in the virtual machine gets ownership root:vboxsf, no matter how you configure fstab.

🚫
You're absolutely right — and this is a known limitation of vboxsf (VirtualBox Shared Folders):

Even with uid= and gid= options in /etc/fstab, vboxsf mounts are always owned by root:vboxsf, and Alpine (or other Linux guests) can't force a change in that ownership.

This is not a bug in Alpine, but a design limitation of the VirtualBox shared folder driver.

Share folders are available with the help of `virtualbox-guest-additions`. I shall execute virtualbox-guest-additions before Docker.
