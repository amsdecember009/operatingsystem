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

