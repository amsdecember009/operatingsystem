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

