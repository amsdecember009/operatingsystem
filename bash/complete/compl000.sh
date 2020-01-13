

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



	crypt_setup(){
		select_name(){
			read "please enter encrypted device name \n: " main_name
			echo -e "$(main_name)"
		}

		#select_hash(){
		#	hash_list=(`less /proc/crypto | awk -v RS='' " "'/hash/{ print "\n" $0 }' | less`)
		#	PS3="$prompt1"
		#	select hash in "${hash_list[@]}"; do
		#		if contains_element "${hash}" "${hash_list[@]}"; then
		#			break
		#		else 
		#			echo -e "invalid_option function:\n"
		#		fi
		#	done
		#	hash=${hash}
		#	echo -e "$hash"
		#	# Need function select only hash name out of less selection
		#}		

		#select_cipher(){
		#	echo "less /proc/crypto | awk -v RS='' " "'/cipher/{ print "\n" $0 }' | less" 
		#	cipher_list=(`less /proc/crypto | awk -v RS='' " "'/cipher/{ print "\n" $0 }' | less`)
		#	PS3="$prompt1"
		#	select cipher in "${cipher_list[@]}"; do
		#		if contains_element "${cipher}" "${cipher_list[@]}"; then
		#			break
		#		else
		#			echo -e "invalid_option function:\n"
		#		fi
		#	done
		#	cipher=${cipher}
		#	echo -e "$cipher"
		#	# need function select only cipher name out of less selection
		#}

		#select_keysize(){
		#	# print information cipher key
		#	read "please enter key size 4M " key_size
		#	key_size=${key_size}
		#	echo "${key_size}"
		#	# if then else statement for default selection none
		#}

		#select_keyfilesize(){
		#	# print information key file
		#	read "please enter keyfile size num number in bytes" keyfilesize
		#	echo -e "${keyfilesize}
		#	# if then else statement for default selection none
		#}

		select_keyfileoffset(){
			#print information key file
			read "please enter keyfile offset num number in bytes: " keyfileoffset
			echo -e "${keyfileoffset}"
			# if then else statement for default selection none
		}	
	}	

	disable_partition(){
		unset partitions_list[${partition_number}]
		partitions_list=(${partitions_list[@]})
		[[${partition_name[i]} != another ]] && i=$(( i + 1 ))
	}



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


	format_swap_partition(){
		read_input_text "Confirm format $1 partition"
		if [[ $OPTION == y ]]; then
		  mkswap $1
		  swapon $1
		  disable_partition
		fi
	}



	select_filesystem(){
		filesystem_list=( "btrfs" "ext2" "ext3" "ext4" "f2fs" "jfs" "nilfs2" "ntfs" "reiserfs" "vfat" "xfs");
		PS3="$prompt1"
		echo -e "selection filesystem:\n"
		select filesystem in "${filesystems_list[@]}"; do
			if contains_element "${filesystem}" "${filesystems_list[@]}"; then
				break
			else
				invalid_option
			fi
		done
	}



	select_main(){
		device_list=(`lsblk -d | awk '{print "/dev/" $1}' | grep 'sd\|hd\|vd\|nvme\|mmcblk'`);
		PS3="$prompt1"
		echo -e "Attached Devices /dev/sdx:\n"
		lsblk -lnp -I 2,3,8,9,22,34,56,57,58,65,66,67,68,69,70,71,72,91,128,129,130,131,132,133,134,135,259 | awk '{print $1, $4, $6, $7}'| column -t 
		echo -e "\n"
		echo -e "Select Device:\n"
		select device in "${device_list[@]}"; do 
			if contains_element "${device}" "${device_list[@]}"; then
				break
			else
				echo -e "invalid_option function:\n"
			fi
		done	
		select_main=$device
		echo -e $select_main
	}


	while true; do
		PS3="$prompt1"
		if [[ ${partition_name[i]} == swap ]]; then
			create_swap
		else
			echo -e "Select ${BYellow}${partition_name[i]}${Reset} partition:\n"
			select partition in "$i{partitions_list[@]}"; do
				partition_number=$(( $REPLY - 1 ))
				if contains_element "${partition}" "${partitions_list[@]}"; then
					case ${partition_name[i]} in
						root)
							ROOT_PART=`echo ${partition} | sed 's/\/dev\/mapper\///' | sed 's/\/dev\///'`
							ROOT_MOUNTPOINT=${partition}
							format_partition "${partition}" "${MOUNTPOINT}"
							;;
						EFI)
							set_efi_partition
							read_input_text "Format ${partition} partition"
							if [[ $OPTION == y ]]; then
								format_partition "${partition}" "${MOUNTPOINT}${EFI_MOUNTPOINT}" vfat
							else
								mkdir -p "${MOUNTPOINT}${EFI_MOUNTPOINT}"
								mount -t vfat "${partition}" "${MOUNTPOINT}${EFI_MOUNTPOINT}"
								check_mountpoint "${partition}" "${MOUNTPOINT}${EFI_MOUNTPOINT}"
							fi
							;;
						another)
							read -p "Mountpoint [ex: /home]:" directory
							[[ $directory == "/boot" ]] && BOOT_MOUNTPOINT=`echo ${partition} | sed 's/[0-9]//'`
					       		select_filesystem
				        		read_input_text "Format ${partition} partition"
							if [[ $OPTION == y ]]; then	
					 			format_partition "${partition}" "${MOUNTPOINT}${directory}" "${filesystem}"
				 			else
				       	  			read_input_text "Confirm fs="${filesystem}" part="${partition}" dir="${directory}""
			  	 	  			if [[ $OPTION == y ]]; then
					    				mkdir -p ${MOUNTPOINT}${directory}
			  		    				mount -t ${filesystem} ${partition} ${MOUNTPOINT}${directory}
					    				check_mountpoint "${partition}" "${MOUNTPOINT}${directory}"
					  			fi
							fi
							;;
						esac
						break
					else
			  			echo -e "invalid_option selected"
					fi
				done
			fi
	
			if [[ ${#partitions_list[@]} -eq 0 && ${partition_name[i]} != swap ]]; then
				break
			elif [[ ${partition_name[i]} == another ]]; then
				read_input_text "configure more partitions"
				[[ $OPTION != y ]] && break
			fi
		done
		#pause_function
		}



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
		
	setup_main(){
			truncate -s 16M /mnt/header.img
			cryptsetup --key-file=/dev/mapper/lukskey --keyfile-offset="${keyfileoffset}" --keyfile-size="${keyfilesize}" luksFormat ${select_main} --header /mnt/header.img
			cryptsetup open --header /mnt/header.img --key-file=/dev/mapper/lukskey --keyfile-offset="${keyfileoffset}" --keyfile-size="${keyfilesize}" "${select_main}" "${main_name}"
			cryptsetup close lukskey
			umount /mnt
			LUKS=1
			LUKS_DISK=`echo ${OPT} | sed 's/\/dev\///'`
		}	

