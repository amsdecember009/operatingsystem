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
