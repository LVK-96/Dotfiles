#“AddScreen/ScreenInit failed for driver 0”
Add iomem=relaxed to GRUB_CMDLINE_LINUX_DEFAULT in /etc/default/grub. Then generate a new grub config and initramfs with

```
grub-mkconfig -o /boot/grub/grub.cfg
```
