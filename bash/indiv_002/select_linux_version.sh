select_linux_version(){
	version_list=("linux (default)" "linux-lts (long term support)" "linux-hardened (hardened linux)");
	PS3="$prompt1"
	echo -e "select linux version to install\n"
	select VERSION in "${version_list[@]}"; do
		if contains_element "$VERSION" "${version_list[@]}"; then
			if [ "linux (default)" == "$VERSION" ]; then
				pacstrap ${MOUNTPOINT} base linux linux-headers
			elif [ "linux-lts (long term support)" == "$VERSION" ]; then
				pacstrap ${MOUNTPOINT} base linux-lts linux-lts-headers
			elif [ "linux-hardened (hardened linux)" == "$VERSION" ]; then
				pacstrap ${MOUNTPOINT} base linux-hardened linux-hardened-headers
			fi
			pacstrap ${MOUNTPOINT} \
				cryptsetup lvm2 netctl dhcpcd inetutils jfutils diffutils e2fspogs \
				less linux-firmware lgorotate man-db man-pages mdadm nano \
				perl reiserfsprogs s-nail sysfutils texinfo usbutils vi vim which xfsprogs
			break
		else
			invalid_option
		fi
	done
}
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
#}}}
#CONFIGURE KEYMAP {{{
configure_keymap(){
	#ADD KEYMAP TO THE NEW SETUP
	echo "KEYMAP=$KEYMAP" > ${MOUNTPOINT}/etc/vconsole.conf
}
#}}}
#CONFIGURE FSTAB {{{
configure_fstab(){
	print_info "configuring fstab"
	if [[ ! -f ${MOUNTPOINT}/etc/fstab.aui ]]; then
		cp ${MOUNTPOINT}/etc/fstab ${MOUNTPOINT}/etc/fstab.aui
	else
		cp ${MOUNTPOINT}/etc/fstab.aui ${MOUNTPOINT}/etc/fstab
	fi
	if [[ $UEFI -eq 1 ]]; then
		fstab_list=("DEV" "PARTUUID" "LABEL");
	else
		fstab_list=("DEV" "UUID" "LABEL");
	fi

	PS3="$prompt1"
	echo -e "configure fstab based on:"
	select OPT in "${fstab_list[@]}"; do
		case "$REPLY" in
			1) genfstab =p ${MOUNTPOINT} >> ${MOUNTPOINT}/etc/fstab ;;
			2) if [[ $UEFI -eq 1 ]]; then
				genfstab -t PARTUUID -p ${MOUNTPOINT} >> ${MOUNTPOINT}/etc/fstab
			   else
				genfstab -U -p ${MOUNTPOINT} >> ${MOUNTPOINT}/etc/fstab
			  fi
			  ;;
			3) genfstab -L -p ${MOUNTPOINT} >> ${MOUNTPOINT}/etc/fstab ;;
			*) invalid_option ;;
		esac
		[[ -n $OPT ]] && break
	done
	fstab=$OPT
	echo "review fstab"
	[[ -f ${MOUNTPOINT}/swapfile ]] && sed -i "s/\\${MOUNTPOINT}//" ${MOUNTPOINT}/etc/fstab
	pause_function
	$EDITOR ${MOUNTPOINT}/etc/fstab
}

