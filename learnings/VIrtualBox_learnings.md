
# Boot Order

# Network

Bridge adapter

# Increase hard disk space in an existing virtual machine
 
As long as I advanced in the project, I discovered that the original 2GB disk was not enough. Early in the project docker compose reported `no space left on device`.

I duplicated the hard disk size with these commands

```bash
VBoxManage modifymedium disk "/sgoinfre/students/luicasad/maria/maria/inception Clone.vdi" --resize 4096
VBoxManage showhdinfo "/sgoinfre/students/luicasad/maria/maria/inception Clone.vdi"
```

That requires the edition of the virtual machine partition table. With `fdisk /dev/sda` deleted 3rd partition `-d` without erase data.

That requires a file system extension. `resize2fs /dev/sda3` made it possible.

# Shared folders

This mechanism allows me to edit from the host machine, using Visual Studio code, inside the virtual machine.

<img src="https://github.com/user-attachments/assets/d2d72222-050d-4f1a-b480-989d1778f7ce" alt="Sample Image" style="width:50%; height:auto;">

![Shared folders](https://github.com/user-attachments/assets/d2d72222-050d-4f1a-b480-989d1778f7ce)

The mounted shared folder in the virtual machine gets ownership root:vboxsf, no mater how you configure fstab

🚫
You're absolutely right — and this is a known limitation of vboxsf (VirtualBox Shared Folders):

Even with uid= and gid= options in /etc/fstab, vboxsf mounts are always owned by root:vboxsf, and Alpine (or other Linux guests) can't force change that ownership.

This is not a bug in Alpine, but a design limitation of the VirtualBox shared folder driver.
