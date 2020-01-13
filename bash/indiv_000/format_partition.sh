
	format_partition(){
		read_input_text "confirm format $1 partition"
		if [[ $OPTION == y ]]; then
			[[ -z $3 ]] && select_filesystem || filesystem=$3
			mkfs.${filesystem} $1 \
				$([[ ${filesystem} == xfs || ${filesystem} == btrfs || ${filesystem} == reiserfs ]] && echo "-f") \
				$([[ ${filesystem} == vfat ]] && echo "-F32") \
				$([[ $TRIM -eq 1 && ${filesystem} == ext4 ]] && echo "-E discard")
			fsck -p $1
			mkdir -p $2
			mount -t ${filesystem} $1 $2
			disable_partition
		fi
	}


