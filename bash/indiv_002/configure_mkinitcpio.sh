configure_mkinitcpio(){
	print_info "mkinitcpio is a bash script used to create an initial ramdisk environemnt."
	[[ $LUKS -eq 1 ]] && sed -i '/^HOOK/s/block/block keymap encrypt/' ${MOUNPOINT}/etc/mkinitcpio.conf
	[[ $LVM -eq 1 ]] && sed -i '/^HOOK/s/filesystems/lvm2 filesystems/' ${MOUNTPOINT}/etc/mkinitcpio.conf
	if [ "$(arch-chroot ${MOUNTPOINT} ls /boot | grep hardened -c)" -gt "0" ]; then
		arch_chroot "mkinitcpio -p linux-hardened"
	elif [ "$(arch-chroot ${MOUNTPOINT} ls /boot | grep lts -c)" -gt "0" ]; then
		arch_chroot "mkinitcpio -p linux-lts"
	else 
		arch_chroot "mkinitcpio -p linux"
	fi
}
#}}}

