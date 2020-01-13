	setup_lvm(){
		if [[ $LUKS -eq 1 ]]; then
			pvcreate /dev/mapper/${main_name}
			vgcreate mvg /dev/mapper/${main_name}
		else
			block_list=(`lsblk | grep 'part' | awk '{print "/dev/" substr($1, 3)}'`)
			PS3="$prompt1"
			echo -r "selection partition:"
			select OPT in "${block_list[@]}"; do
				if contains_element "$OPT" "${block_list[@]}"; then
					pvcreate $OPT
					vgcreate mvg $OPT
					break
				else
					invalid_option
				fi
			done
		fi
		read -p "Enter number partitions [ex: 2]: " number_partitions
		i=1
		while [[ $i -le $number_partitions ]]; do
			read -p "Enter $i partition name [ex: home]: " partition_name
			if [[ $i -eq $number_partitions ]]; then
				lvcreate -l 100%FREE lvm -n ${partition_name}
			else
				read -p "enter $i partition size [ex: 25G, 200M]: " partition_size
				lvcreate -L ${partition_size} lvm -n ${partition_name}
			fi
			i=$(( i + 1 ))
		done
		LVM=1
	}	
