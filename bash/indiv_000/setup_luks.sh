
###################################################################
# following section needs personalization 			  #
###################################################################

	setup_luks(){
		block_list=(`lsblk | grep 'part' | awk '{print "/dev/" substr($1,3)}'`)
		PS3="$prompt1"
		echo -e "select partition:"
		select OPT in "${block_list[@]}"; do
			if contains_element "$OPT" "${block_list[@]}"; then
			 cryptsetup --cipher "${cipher}" --key-size "${key-size}" --iter-time "${iter-time}" --use-random --verify-passphrase luksFormat $OPT
			 cryptsetup open --type luks $([[ $TRIM -eq 1 ]] && echo "--allow-discards") $OPT "${crypt_name}" 
			 LUKS=1
			 LUKS_DISK=`echo ${OPT} | sed 's/\/dev\///'`
			break
			elif [[ $OPT == "Cancel" ]]; then
			 break
			else
			  invalid_option
			fi
		done
	}


