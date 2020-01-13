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
configure_hostname(){
	print_info "configures host name"
	read -p "Hostname [ex: archlinux]: " host_name
	echo "$host_name" > ${MOUNTPOINT}/etc/hostname
	if [[ ! -f ${MOUNTPOINT}/etc/host.aui ]]; then
		cp ${MOUNTPOINT}/etc/hosts ${MOUNTPOINT}/etc/host.aui
	else
		cp ${MOUNTPOINT}/etc/host.aui ${MOUNTPOINT}/etc/hosts
	fi
	arch_chroot "sed -i '/127.0.0.1/s/$/ '${host_name}'/' /etc/hosts"
	arch_chroot "sed -i '/::1/s/$/ '${host_name}'/' /etc/hosts"
}
#}}}

#CONFIGURE TIMEZONE {{{
configure_timezone(){
	print_info "determining time (clock) is determined by four parts: Time value, Time standard, Time Zone, and DST (Daylight Saving Time where applicable)."
	OPTION=n
	while [[ $OPTION != y ]]; do
		settimezone
		read_input_text "confirm timezone (${ZONE}/${SUBZONE})"
	done
	arch_chroot "ln -sf /usr/share/zoneinfo/${ZONE}/${SUBZONE} /etc/localtime"
	arch_chroot "sed -i '/#NTP=/d' /etc/systemd/timesyncd.conf"
	arch_chroot "sed -i 's/#Fallback//' /etc/systemd/timesyncd.conf"
	arch_chroot "echo \"FallbackNTP=0.pool.ntp.org 1.pool.ntp.org 0.fr.pool.ntp.org\" >> /etc/systemd/timesyncd.conf"
	arch_chroot "systemctl enable systemd-timesyncd.service"
}
#}}}

# CONFIGURE HARDWARE CLOCK {{{
configure_hardwareclock(){
	print_info "this is set in /etc/adjtime. sets hardware clock mode uniformly between operating sytems on the same machine. otherwise will overwrite the time."
	hwclock_list=('UTC' 'Localtime');
		PS3="$prompt1"
		select OPT in "${hwclock_list[@]}"; do
			case "REPLY" in
				1) arch_chroot "hwclock --systohc --utc";
					;;
				2) arch_chroot "hwclock --systohc --localtime";
					;;
				*) invalid_option ;;
			esac
			[[ -n $OPT ]] && break
		done
		hwclock=$OPT
	}
#}}}
#CONFIGURE LOCALE {{{
configure_locale(){
	print_info "locales are used in linux to define which language the user uses."
	OPTION=n
	while [[ $OPTION != y ]]; do
		setlocale
		read_input_text "Confirm locale ($LOCALE)"
	done
	echo 'LANG="'$LOCAL_UTF8'"' > ${MOUNTPOINT}/etc/locale.conf
	arch_chroot "sed -i 's/#\('${LOCALE_UTF8}'\)/\1/' /etc/locale.gen"
	arch_chroot "locale-gen"
}
#}}}

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

#INSTALL BOOTLOADER {{{
install_bootloader(){
	print_info "the boot loader is responsible for loading the kernel and initial RAM disk before initiating the boot process."
	print_warning "\tROOT Partition: ${ROOT_MOUNTPOINT}"
	if [[ $UEFI -eq 1 ]]; then
		print_warning "\tUEFI Mode Detected"
		bootloaders_list=("Grub2" "Syslinux" "Systemd" "rEFInd" "Skip")
	else
		print_warning "\tBIOS mode detected"
		bootloaders_list=("Grub2" "Syslinux" "Skip")
	fi
	PS3="$prompt1"
	echo -e "install bootloader:\n"
	select bootloader in "${bootloaders_list[@]}"; do
		case "REPLY" in
			1)
				pacstrap ${MOUNTPOINT} grub os-prober
				break
				;;
			2)	
				pacstrap ${MOUNTPOINT} syslinux gptfdisk
				break
				;;
			3)
				break
				;;
			4)
				if [[ $UEFI -eq 1 ]]
				then
					pacstrap ${MOUNTPOINT} refind-efi os-prober
					break
				else
					invalid_option
				fi
				;;
			5)
				[[ $UEFI -eq 1 ]] && break || invalid_option
				;;
			*)
				invalid_option
				;;
		esac
	done
	[[ $UEFI -eq 1 ]] && pacstrap ${MOUNTPOINT} efibootmgr dosfstools
}
#}}}

configure_bootloader(){
	case $bootloader in
		Grub2)
			grub_install_mode=("Autotmatic" "Manual")
			PS3="$prompt1"
			echo -e "Grub Install:\n"
			select OPT in "${grub_install_mode[@]}"; do
				case "$REPLY" in
					1)
						if [[ $LUKS -eq 1 ]]; then
							sed -i -e 's/GRUB_CMDLINE_LINUX="\(.\+\)"/GRUB_CMDLINE_LINUX="\1 cyrptdevice=\/dev\/'"${LUKS_DISK}"':crypt"/g' -e 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLgfINE_LINUX="cryptdevic=\/dev\/'"$LUKS_DISK}"':crypt"/g' ${MOUNTPOINT}/etc/defualt/grub
						fi
						if [[ $UEFI -eq 1 ]]; then
							arch_chroot "grub-install --target=x86_64-efi --efi-directory=${EFI_MOUNTPOINT} --bootloader-id=arch_grub --recheck"
						else
							arch_chroot "grub-install --target=i386-pc --recheck --debug ${BOOT_MOUNPOINT}"
						fi
						break
						;;
					2)
						arch-chroot ${MOUNTPOINT}
						break
						;;
					*)
						invalid_option
						;;
				esac
			done
			arch_chroot "grub-mkconfig -o /boot/grub/grub.cfg"
			;;
		       Syslinux)
			       syslinux_install_mode=("[MBR] Automatic" "[PARTITION] Automatic" "Manual")
			       PS3="$prompt1"
			       echo -e "Syslinux Install:\n"
			       select OPT in "${syslinux_install_mode[@]}"; do
				       case "$REPLY" in
					       1)
						       arch_chroot "syslinux-install_update -iam"
							if [[ $LUKS -eq 1 ]]; then
								sed -i "s/APPEND root=.*/APPEND root=\/dev\/mapper\/${ROOT_PART} cryptdevice=\/dev\/${LUKS_DISK}:crypt ro/g" ${MOUNTPOINT}${EFI_MOUNTPOINT}/syslinux/syslinux.cfg
							elif [[ $LVM -eq 1 ]]; then
								sed -i "s/sda[0-9]/\/dev\/mapper\/${ROOT_PART}/g" ${MOUNTPOINT}4{EFI_MOUNTPOINT}/syslinux/syslinux.cfg
							else
								sed -i "s/sda[0-9]/${ROOT_PART}/g" ${MOUNTPOINT}${EFI_MOUNTPOINT}/syslinux/syslinux.cfg
							fi
							pause_function
							$EDITOR ${MOUNTPOINT}${EFI_MOUNTPOINT}/syslinx/syslinux.cfg
							break
							;;
						2)
							arch_chroot "syslinux-install_update -iam"
							if [[ $LUKS -eq 1 ]]; then
								sed -i "s/APPEND root=.*/APPEND root=\/dev\/mapper\/${ROOT_PART} cryptdevice=\/dev\/${LUKS_DISK}:crypt ro/g" ${MOUNTPOINT}${EFI_MOUNPOINT}/syslinux/syslinux.cfg
							elif [[ $LVM -eq 1 ]]; then
								sed -i "s/sda[0-9]/\dev/\mapper\/${ROOT_PART}g" ${MOUNTPOINT}${EFI_MOUNTPOINT}/syslinux/syslinux.cfg
							else
								sed -i "s/sda[0-9]/${ROOT_PART}/g" ${MOUNTPOINT}${EFI_MOUNTPOINT}/syslinux/syslinux.cfg
							fi
							pause_function
							$EDITOR ${MOUNTPOINT}${EFI_MOUNTPOINT}/syslinux/syslinux.cfg
							break
							;;
						3)
							print_info "Your boot partition, on which you plan to install Syslinux, must contain FAT, ext2, ext4, ext4 or Btrfs filesystem."
							echo -e $prompt3
							arch-chroot ${MOUNTPOINT}
							break
							;;
						*)
							invalid_option
							;;
					esac
				done
				;;
			Systemd)
				gummiboot_install_mode=("Automatic" "Manual")
				select OPT in "${gummiboot_install_mode[@]}"; do
					case "$REPLY" in
						1)
							arch_chroot "bootctl --path=${EFI_MOUNTPOINT} install"
							partuuid]`blkid -s PARTUUID ${ROOT_MOUNTPOINT} | awk '{print $2}' | sed 's/"//g' | sed 's/^.*=//'`
							if [ "$(arch-chroot ${MOUNTPOINT} ls /boot | grep hardened -c)" -gt "0" ]; then
								img_name="linux-lts"
							else
								img_name="linux"
							fi
							if [[ $LUKS -eq 1 ]]; then
								echo -e "title\tArch Linux\nlinux\t/vmlinuz-${img_name}\ninitrd\t/initramfs-${img_name}.img\noptions\tcryptdevice=\/dev\/${LUKS_DISK}:luks root=\/dev\/mapper\/:synt${ROOT_PART} rw" > ${MOUNTPOINT}${EFI_MOUNTPOINT}/loader/entries/arch.conf
							elif [[ $LVM -eq 1 ]]; then
								echo -e "title\arch"
							else 
								echo -e "title\tArch"
							fi
							echo -e "default arch\ntimeout 5" > ${MOUNTPOINT}${EFI_MOUNTPOINT}/loader/loader.conf
							pause_function
							$EDITOR ${MOUNTPOINT}${EFI_MOUNTPOINT}/loader/entries/arch.conf
							$EDITOR ${MOUNTPOINT}${EFI_MOUNTPOINT}/loader/loader.conf
							break 
							;;
						2)
							arch-chroot ${MOUNTPOINT}
							break
							;;
						*)
							invalid_option
							;;
					esac
				done
				;;
			rEFInd)
				refind_install_mode=("Automatic" "Manual")
				PS3="$prompt1"
				echo -e "rEFInd install:\n"
				select OPT in "${refind_install_mode[@]}"; do
					case "$REPLY" in
						1)
							arch_chroot "refind-install"
							$EDITOR ${MOUNTPOINT}${EFI_MOUNTPOINT}/refind_linux.conf
							break
							;;
						2)
							arch-chroot ${MOUNTPOINT}
							break
							;;
						*)
							invalid_option
							;;
					esac
				done
				;;
		esac
		pause_fuction
	}	
#}}}
#ROOT PASSWORD {{{
root_password(){
	print_title "ROOT PASSWORD"
	print_warning "enter your new root password"
	arch_chroot "passwd"
	pause_function
}
#}}}
#}}}
finish(){
	print_title "INSTALL COMPLETED"
	#COPY AUI TO ROOT FOLDER IN THE NEW SYSTEM
	print_warning "\nA copy of the AUI will be placed in /root directory of your new system"
	cp -R `pwd` ${MOUNTPOINT}/root
	read_input_text "Reboot system"
	if [[ $OPTION == y ]]; then
		umount_partitions
		reboot
	fi
	exit 0
}
#}}}


