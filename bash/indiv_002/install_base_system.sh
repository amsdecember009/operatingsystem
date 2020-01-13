install_base_system(){
	pacman -Sy archlinux-keyring
	print_info "using pacstrap script to install base system."
	rm ${MOUNTPOINT}${EFI_MOUNTPOINT}/vmlinuz-linux
	select_linux_version
	pacstrap ${MOUNTPOINT} base-devel parted btrfs-progs f2fs-tools net-tools
	[[ $? -ne 0 ]] && error_msg "Installing base system to ${MOUNTPOINT} failed. check error messages above."
	local PTABLE=`parted -sl | grep "gpt"`
	[[ -n $PTABLE ]] && pacstrap ${MOUNTPOINT} gptfdisk
	WIRELESS_DEV=`ip link | grep wl | awk '{print $2}'| sed 's/://' | sed '1!d'`
	if [[ -n $WIRELESS_DIV ]]; then
		pacstrap ${MOUNTPOINT} iw wireless_tools wpa_supplicant dialog
	else
		WIRED_DEV=`ip link | grep "ens\|eno\|enp" | awk '{print $2}' | sed 's/://' | sed '1!d'`
		if [[ -n $WIRED_DEV ]]; then
			arch_chroot "systemctl enable dhcpcd@${WIRED_DEV}.service"
		fi
	fi
	if is_package_installed "espeakup"; then
		pacstrap ${MOUNTPOINT} alsa-utils espeakup brltty
		arch_chroot "systemctl enable espeakup.service"
	fi
}
