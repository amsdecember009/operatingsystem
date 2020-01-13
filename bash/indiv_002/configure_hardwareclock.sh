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
