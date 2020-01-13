
	format_partitions(){
		block_list=(`lsblk | grep 'part\|lvm' | awk '{print substr($1,3)}'`)

		if [[ ${#block_list[@]} -eq 0 ]]; then
			echo "no partition found"
			exit 0
		fi
	
		partitions_list=()
		for OPT in ${block_list[@]}; do
			check_lvm=`echo $OPT | grep mvg`
			if [[ -z $check_lvm ]]; then
				partitions_list+=("/dev/$OPT")
			else
				partitions_list+=("/dev/mapper/$OPT")
			fi
		done
	
		if [[ $UEFI -eq 1 ]]; then
			partition_name=("root" "EFI" "swap" "another")
		else
			partition_name=("root" "swap" "another")
		fi
	}

