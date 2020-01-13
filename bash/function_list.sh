#!/bin/bash


#CURRENTLY:
#	<FIND FUNCTION REGEX FUNCTION customencrypthook
#	<INPUT FUNCTION customencrypthook
#	<INPUT FUNCTION less /proc/crypto correctly 

contains_element(){ 
	#check if an element exist in a string
	for e in "${@:2}"; do [[ $e == $1 ]] && break; done;
}

select_device(){
	device_list=(`lsblk -d | awk '{print "/dev/" $1}' | grep 'sd\|hd\|vd\|nvme\|mmcblk'`);
	PS3="$prompt1"
	echo -e "Attached Devices /dev/sdx:\n"
	lsblk -lnp -I 2,3,8,9,22,34,56,57,58,65,66,67,68,69,70,71,72,91,128,129,130,131,132,133,134,135,259 | awk '{print $1, $4, $6, $7}'| column -t 
	echo -e "\n"
	echo -e "Select Device:\n"
	select device in "${device_list[@]}"; do 
		if contains_element "${device}" "${device_list[@]}"; then
			break
		lz /else
			echo -e "invalid_option function:\n"
		fi
	done
	selected_device=$device
	echo -e $selected_device
}

select_type(){
	type_list=("luks" "luks1" "luks2" "plain" "loopaes" "tcrypt");
	PS3="$prompt1"
	select type in "${type_list[@]}"; do
		if contains_element "$type" in "${type_list[@]}"; then
			break
		else
			echo -e "invalid_option function\n:"
		fi
	done
	type=${type}
	echo -e "$type"
}

select_random(){
	random_list=("/dev/random" "/dev/urandom");
	PS3="$prompt1"
	select random in "${random_list[@]}"; do
		if contains_element "${random}" in "${random_list[@]}"; then
			break
		else
			echo -e "invalid_option function\n:"
		fi
	done
	random=${random}
	echo -e "$random"
}

	echo -e "#####################################################################################################"
wipe_device(){
	echo -e "Please Select Device to Be Wiped Clean"
	echo -e "#####################################################################################################"
	select_device
	crypt_chosen=$selected_device
	#echo -e "here is the man page for cryptsetup"
	#man cryptsetup
	#cryptsetup wipe selected device
	echo -e "#####################################################################################################"
	echo -e "cryptsetup will open a container on selected"
	echo -e "#####################################################################################################"
	echo -e "\n
	full:: cryptsetup open --type <selection> -d <selection> /dev/<selection> <block device name>"
	echo -e "\n"
	echo -e "#####################################################################################################"
	echo -e "list of pertinent actions and options"
	echo -e "#####################################################################################################"
	echo -e "\n"
	cryptsetup --help | sed -n '140,141p;'
	echo -e "\n"
	echo -e "#####################################################################################################"
	echo -e "\n"
	cryptsetup --help | sed -n '67,68p;'
	echo -e "\n"
	echo -e "#####################################################################################################"	
	echo -e "\n"
	cryptsetup --help | sed -n '13, 15p;'
	echo -e "\n"
	echo -e "#####################################################################################################"
	echo -e "\n"
	echo -e "for option -d there is random & urandom"
	echo -e "\n"
	cryptsetup --help | sed -n '43, 44p;'	
	cryptsetup --help | sed -n '45, 46p;'
	echo -e "\n"
	echo -e "#####################################################################################################"
	echo -e "please input selection decisions for cryptsetup command"	
	select_type(){
		type_list=("luks" "luks1" "luks2" "plain" "loopaes" "tcrypt");
		PS3="$prompt1"
		echo -e "Please select type option"
		select OPT in "${type_list[@]}"; do
			if contains_element "$OPT" in "${type_list[@]}"; then
				break
			else
				echo -e "invalid_option function\n:"
			fi
		done
		type=$OPT
	echo -e "####################################################################################################"
		echo -e "$type"
	echo -e "####################################################################################################"
	}
	# function select random against urandom
	select_random(){
		random_list=("/dev/random" "/dev/urandom");
		PS3="$prompt1"
		echo -e "Please select random option"
		select OPT_random in "${random_list[@]}"; do
			if contains_element "$OPT_random" in "${random_list[@]}"; then
				break
			else
				echo -e "invalid_option function\n:"
			fi
		done
		random=$OPT_random
	echo -e "##################################################################################################"
		echo -e "$random"
	echo -e "##################################################################################################"
	}
	#function read input selected device name user input	
	echo -e "##################################################################################################"
	select_type
	select_random
	read -p "enter cryptsetup container name: " crypt_name
	echo -e "##################################################################################################"
	echo -e "cryptsetup open --type $type -d $random $crypt_chosen $crypt_name"
	echo -e "##################################################################################################"
	echo -e "input real command here" "real command run alongside tmux"
	echo -e "##################################################################################################"
	echo -e "once dd finished for container"
	echo -e "##################################################################################################"
	echo -e "cryptsetup close container
	echo -e "##################################################################################################"
}

###################################################################################################################"
#   wipe device													  #
###################################################################################################################"

	
################
#       }      #
################

	partition_gen(){
		# select device function to choose proper drive
		select_device
		partition_select="${selected_device}"
	# clear out all partition data selected device
	# once selected ask number partitions
	echo -e "#################################################################################################"
	read -p "please enter number partitions selected device: " number_partitions
	echo -e "#################################################################################################"
	echo -e "selected number partitions: " ${number_partitions}
	echo -e "#################################################################################################"
	#clear out all partition data selected device
	sgdisk -z $partition_select
	sgdisk -o $partition_select
		# < create array matching number partitions
		iter=${number_partitions}
		counter=1
		while [[ $counter -le ${iter} ]]; do
		  
	echo -e "#################################################################################################"
			read  -p "please enter partition size: ie '200M' '20G': " partition_size
	echo -e "#################################################################################################"
			read  -p "please enter partition type code: " type_code
	echo -e "#################################################################################################"
			read  -p "please enter partition name: " partition_name
	echo -e "#################################################################################################"
	partition_name_edit="\""${partition_name}"\""
	secho -e "#################################################################################################"
	echo -e " sgdisk --new 0:0:+"${partition_size}"  -t 0:"${type_code}" -c :"${partition_name_edit}" "${partition_select}""
	echo -e "#################################################################################################"
		  sgdisk --new 0:0:+"${partition_size}" -t 0:"${type_code}" -c 0:"${partition_name_edit}" "${partition_select}"
		  sgdisk -p print display basic gpt partition data
		  sgdisk -p "${partition_select}"
		  counter=$((counter+1))
		  done
 }

###################################################################################################################
# partition_gen													  #
###################################################################################################################

#################################################################################
# Number	start(sector)	end(sector)	size	code 	name		#
# 1		2048		1050623		512MiB	EF00	EFI 	      	#
# 2		1050624		1406233		200MiB  8300    Linux System	#
# 3		100% Free				8300	Linux 		#
################################################################################# 

#################################################################################
# after partition usb								#
#################################################################################

#################################################################################
# NOTES CRYPTSETUP USB								#
#################################################################################
#										#
# < prompt > creating cryptsetup container < prompt > cascade ciphers		#
#	< list cryptsetup encryption options all >				#
#		< unable to do with current kernel config missing module	#
#	< list cryptsetup encryption options LUKS mode >			#
#		< unable to do with current kernel config missing module	#
#	< list cryptsetup ciphers modes of operation >				#
#		< unable to do with current kernel config missing module	#
#	# cryptsetup options							# 
#		< possible to list options					#
#	# cryptsetup open <selected_device> <name_selected device>		#
#										#
#################################################################################

########################################################################
#								       #
# remember do something about further options plain loopaes tcrypt     #
#								       #
########################################################################

crypt_setup (){
	select_name(){
		read "please enter encrypted device name \n: " crypt_name
		echo -e "$(crypt_name)"
	}
	select_crypt(){
		crypt_list=`(lsblk)`
		echo -e "Attached devices: \n"
		PS3="$prompt1"
		select crypt_device in "${crypt_list[@]}"; do
			if contains_element "${crypt_device}" "${crypt_list[@]}"; then
				break
			else
				echo -e "invalid_option function:\n"
			fi
		done
		crypt_select=$crypt_device
		echo -e $crypt_select
	}

	select_type(){
		type_list=("luks" "luks1" "luks2" "plain" "loopaes" "tcrypt");
		PS3="$prompt1"
		select type in "${type_list[@]}"; do
			if contains_element "${type}" "${type_list[@]}"; then
				break
			else
				echo -e "invalid_option function \n:"
			fi
		done
		type=${type}
		echo -e "$type"
	}

	select_random(){
		random_list=( "/dev/urandom" "/dev/random" );
		PS3="$prompt1"
		select random in "${random_list[@]}"; do
			if contains_element "${random} "${random_list[@]}"; then
				break
			else
				echo -e "invalid_option function \n:"
			fi
		done
		random=${random}
		echo -e "$random"
	}

	select_itertime(){
		iter_list=("1000" "2000" "3000" "4000" "5000");
		PS3="$prompt1"
		select iter in "${iter_list[@]}"; do
			if contains_element "${iter}" "${iter_list[@]}"; then 
				break
			else
				echo -e "invalid_option function:\n"
			fi
		done
		iter=${iter}
		echo -e "$iter"
	}

	select_hash(){
		hash_list=(`less /proc/crypto | awk -v RS='' " "'/hash/{ print "\n" $0 }' | less`)
		PS3="$prompt1"
		select hash in "${hash_list[@]}"; do
			if contains_element "${hash}" "${hash_list[@]}"; then
				break
			else 
				echo -e "invalid_option function:\n"
			fi
		done
		hash=${hash}
		echo -e "$hash"
		# need function select only hash name out of less selection
	}

	select_cipher(){
		echo "less /proc/crypto | awk -v RS='' " "'/cipher/{ print "\n" $0 }' | less" 
		cipher_list=(`less /proc/crypto | awk -v RS='' " "'/cipher/{ print "\n" $0 }' | less`)
		PS3="$prompt1"
		select cipher in "${cipher_list[@]}"; do
			if contains_element "${cipher}" "${cipher_list[@]}"; then
				break
			else
				echo -e "invalid_option function:\n"
			fi
		done
		cipher=${cipher}
		echo -e "$cipher"
		# need function select only cipher name out of less selection
	}

	select_keysize(){
		# print information cipher key
		read "please enter key size 4M " key_size
		key_size=${key_size}
		echo "${key_size}"
		# if then else statement for default selection none
	}

	select_keyfilesize(){
		# print information key file
		read "please enter keyfile size /num/ number in bytes: " keyfilesize
		echo -e "${keyfilesize}"
		# if then else statement for default selection none
	}

	select_keyfileoffset(){
		# print information key file
		read "please enter keyfile offsetnum number in bytes " keyfileoffset
		echo -e "${keyfileoffset}"
		# if then else statement for default selection none
	}

	crypt_setup_setup(){
		cryptsetup -v --type ${type} --cipher ${cipher} --key-size ${key_size} --keyfile-offset ${keyfileoffset} --keyfile-size ${keyfilesize} --hash ${hash} --iter-time ${iter} ${generator} --verify-passphrase luksFormat ${crypt_select}		
		cryptsetup open ${crypt_select} ${crypt_name}
			# check validity key-size
			# check enter input yes to select option
			# check enter input no to skip option
			# possible to leave cryptsetup option selections blank with successful run of command?
	}
}

		####################################################################
		# select crypt							   #
		####################################################################

#####################################
# presume cryptdevice open          #
#####################################

####################################################################
#							           #
#		prepare boot partition format efi		   #
# 								   #
####################################################################

setup_boot(){
	echo -e "lsblk -lnp"
	echo -e "select just selected device encrypted boot"
	boot_list={`lsblk -lnp`)
	PS3="$prompt1"
	select boot in "${boot_list[@]}"; do
		if contains_element "${boot}" "${boot_list}" then
			break
		else
			echo -e "invalid_function \n:"
		fi
	done
	boot=${boot}
	mkfs.ext4 ${boot}
	mount ${boot} /mnt
	dd if=/dev/urandom of=/mnt/key.img bs=4M count=1
	cryptsetup luksFormat /mnt/key.img
	cryptsetup open /mnt/key.img lukskey
# make sure the "${boot}"  variable contains the full /dev/mapper/<name> according to output lsblk -lnp
}


####################################################################
#                                                                  # 
#  mount /dev/mapper/cryptboot /mnt				   #
#  dd if=/dev/urandom of=/mnt/key.img bs=filesize count=1	   #
#  cryptsetup luksFormat /mnt/key.img				   #
#  cryptsetup open /mnt/key.img lukskey  			   #
#								   #
####################################################################

########################################################################
# /mnt/key.img lukskey open in /mnt on /dev/mapper/<crypt_boot_name>   #
########################################################################



###########################################################################################################################################################################################
#																							  #
# truncate -s 16M /mnt/header.img																			  #
# cryptsetup --key-file=/dev/mapper/lukskey --kefile-offset=< applied offset > --keyfile-size=< applied size > luksFormat <crypt_selected_device> --header /mnt/header.img		  #
# cryptsetup open --header /mnt/header.img --key-file=/dev/mapper/lukskey --keyfile-offset= < applied offset > --keyfile-size= < applied size > <crypt_selected_device> < chosen_name >   #
# cryptsetup close lukskey																				  #
# umount /mnt																						  #
#																							  #
###########################################################################################################################################################################################

# CURRENT EITHER REWRITE cryptsetup function to accommodate keyfile-size -keyfile-offset or enter in keyfile-offset into the above command with y/n and none option
# generalize then reuse above cryptsetup function with main device selection command
# then
# cryptsetup close lukskey
# umount /mnt
# assume cryptsetup statement has been generalized 
# in theory should work however just barely and in theory so not really






#####################################################################
#								    # 
# setup_luks							    #
#								    #
# setup_lvm							    #
#								    #
# format && mount all within lvm main				    #
#								    #
# mount /mnt/boot && /mnt/efi				   	    #
#								    #
#####################################################################
#								    #
# installation guide till mkinitcpio				    #
#								    #
#####################################################################
#								    #
# mkinitcpio custom encrypthook					    #
#								    #
#####################################################################
#								    #
# finish installation guide installation all wanted programs        #
#								    #
#####################################################################
#								    #
# install && configure bootloader				    #
#								    #
#####################################################################


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
	
			#truncate -s 16M /mnt/header.img
			#cryptsetup --key-file=/dev/mapper/lukskey --keyfile-offset="${keyfileoffset}" --keyfile-size="${keyfilesize}" luksFormat ${select_main} --header /mnt/header.img
			#cryptsetup open --header /mnt/header.img --key-file=/dev/mapper/lukskey --keyfile-offset="${keyfileoffset}" --keyfile-size="${keyfilesize}" "${select_main}" "${main_name}"
			#cryptsetup close lukskey
			#umount /mnt
			#LUKS=1
			#LUKS_DISK=`echo ${OPT} | sed 's/\/dev\///'`
	

###################################################################
# following section needs personalization 			  #
###################################################################

	##setup_luks(){
		##block_list=(`lsblk | grep 'part' | awk '{print "/dev/" substr($1,3)}'`)
		##PS3="$prompt1"
		##echo -e "select partition:"
		##select OPT in "${block_list[@]}"; then
			##if contains_element "$OPT" "${block_list[@]}"; then
			# cryptsetup --cipher <saved option> --key-size <saved keysize> --iter-time <saved iter time> --use-random --verify-passphrase luksFormat $OPT
			# cryptsetup open --type luks $([[ $TRIM -eq 1 ][] && echo "--allow-discards") $OPT <saved option>
			# LUKS=1
			# LUKS_DISK=`echo ${OPT} | sed 's/\/dev\///'`
			##break
			##elif [[ $OPT == "Cancel" ]]; then
			 ##break
			##else
			  ##invalid_option
			##fi
		##done
	##}

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

	format_swap_partition(){
		read_input_text "Confirm format $1 partition"
		if [[ $OPTION == y ]]; then
		  mkswap $1
		  swapon $1
		  disable_partition
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

	check_mountpoint(){
		if mount | grep $2; then
			echo "Successfully mounted"
			disable_parition "$1"
		else
			echo "WARNING: Not successfully mounted"
		fi
	}	

	set_efi_partition(){
		efi_options=("/boot/efi" "/boot" "/mnt/efi" "/efi")
		PS3="$prompt1"
		echo -e "Select EFI mountpoint:\n"
		select EFI_MOUNTPOINT in "${efi_options[@]}"; do
			if contains_element "${EFI_MOUNTPOINT}" "${efi_options[@]}"; then
				break
			else
				invalid_option
			fi
		done
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



