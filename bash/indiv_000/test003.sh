	check_mountpoint(){
		if mount | grep $2; then
			echo "Successfully mounted"
			disable_parition "$1"
		else
			echo "WARNING: Not successfully mounted"
		fi
	}	

	create_swap(){
	swap_options=("partition" "file" "skip");
		PS3="$prompt1"
		echo -e "Select ${BYellow}${partition_name[i]}${Reset} filesystem:\n"
		select OPT in "${swap_options[@]}"; do
			case "$REPLY" in
			1)
				select partition in "${partitions_list[@]}"; do
					partition_number=$(( $REPLY - 1 ))
					if contains_element "${partition}" "${partitions_list[@]}"; then
						format_swap_partition "${partition}"
					fi
					break
				done
				swap_type="partition"
				break
				;;
			2)
				total_memory=`grep MemTotal /proc/meminfo | awk '{print $2/1024}' | sed 's/\..*//'`
				fallocate -l ${total_memory}M ${MOUNTPOINT}/swapfile
				chmod 600 ${MOUNTPOINT}/swapfile
				mkswap ${MOUNTPOINT}/swapfile
				swapon ${MOUNTPOINT}/swapfile
				i=$(( i + 1 ))
				swap_type="file"
				break
				;;
			3)
				i=$(( i + 1 ))
				swap_type="none"
				break
				;;
			*)
				invalid_option
				;;
			esac
		done
	}	


