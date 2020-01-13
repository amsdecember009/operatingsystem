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


