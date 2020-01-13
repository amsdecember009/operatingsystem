
contains_element(){ 
	#check if an element exist in a string
	for e in "${@:2}"; do [[ $e == $1 ]] && break; done;
}

select_device(){
	device_list=(`ls /dev/sd*`);
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
	selected_device=$device
	echo -e $selected_device
}

#select_random(){
#	random_list=("/dev/random" "/dev/urandom");
#	PS3="$prompt1"
#	select random in "${random_list[@]}"; do
#		if contains_element "${random}" in "${random_list[@]}"; then
#			break
#		else
#			echo -e "invalid_option function\n:"
#		fi
#	done
#	random=${random}
#	echo -e "$random"
#}

#select_type(){
#	type_list=("luks" "luks1" "luks2" "plain" "loopaes" "tcrypt");
#	PS3="$prompt1"
#	select type in "${type_list[@]}"; do
#		if contains_element "$type" in "${type_list[@]}"; then
#			break
#		else
#			echo -e "invalid_option function\n:"
#		fi
#	done
#	type=${type}
#	echo -e "$type"
#}

wipe_device(){
   echo -e "#####################################################################################################"
   echo -e "######################## willkommen nach wipe_device! sehr toll zuper ###############################"
   echo -e "#####################################################################################################"
	select_device
	sgdisk -z $selected_device
	crypt_chosen=$selected_device
	cryptsetup benchmark
	 echo -e "#####################################################################################################"
	 echo -e "########### below ouput cryptsetup benchmark available hashes and ciphers this computer #############"
	 echo -e "#####################################################################################################"
	#echo -e "here is the man page for cryptsetup"
	#man cryptsetup
	#cryptsetup wipe selected device

	PS3='please enter your choice of process: '
    options=("complex cipher simple hash" "simple cipher complex complex")
    select opt in "${options[@]}"
    do
      case $opt in
  "complex cipher simple hash")
	  echo -e "#####################################################################################################"
	  echo -e "############ cryptsetup will open a container on selected then container will be wiped ##############"
	  echo -e "#####################################################################################################"
	  echo -e "\n"
	  echo -e "#####################################################################################################"
	  echo -e "\n"

    echo -e "########################################################"
	  echo -e "###############    select_cipher     ###################"
	  echo -e "########################################################"

	  select_cipher(){
		    cipher_list=('aes-cbc-essiv:sha256' 'aes-xts-essiv:sha256' 'serpent-xts-plain:sha256' 'serpent-xts-plain:sha512' 'serpent-xts-plain64:sha256'
		    'serpent-xts-plain64:sha512', 'twofish-xts-plain:sha256', 'twofish-xts-plain:sha512', 'twofish-xts-plain64:sha256' 'twofish-xts-plain64:sha512'
		    'twofish-cbc-plain:sha256', 'twofish-cbc-plain:sha512', 'twofish-cbc-plain64:sha256', 'twofish-cbc-plain64:sha512', 'serpent-cbc-plain:sha256', 'serpent-cbc-plain:sha512')
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
	  select_cipher

    #echo -e "##################################################################################################"

	  #select_keysize(){
	  #		# print information cipher key
	  #	echo "enter a good key size"
	  #	read key_size
	  #	key_size=${key_size}
	  #echo "${key_size}"
	  #}
    #select_keysize

    #echo -e "##################################################################################################"

	  #select_hash(){
	  #hash_list=('sha1' 'sha256' 'sha512' 'ripemd160' 'whirlpool')
	  #PS3="$prompt1"
	  #select hash in "${hash_list[@]}"; do
	  #	if contains_element "${hash}" "${hash_list[@]}"; then
	  #		break
	  #	else
	  #		echo -e "invalid_option function:\n"
	  #	fi
	  #done
	  #hash=${hash}
	  #echo -e "$hash"
	  # Need function select only hash name out of less selection
	  #}
	  #select_hash

	  #echo -e "##################################################################################################"

    echo -e "########################################################"
    echo -e "################   select_random    ####################"
    echo -e "########################################################"

	  select_random(){
	      random_list=("--use-random" "--use-urandom");
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
          echo -e "$random"

    }
	  select_random

	  echo -e "##################################################################################################"

	  read -p "enter cryptsetup container name: " crypt_name

	  echo -e "##################################################################################################"

	  cryptsetup --type luks1 --cipher $cipher $random luksFormat $crypt_chosen

	  echo -e "##################################################################################################"

	  cryptsetup open $crypt_chosen $crypt_name

	  echo -e "##################################################################################################"

	  dd if=/dev/zero of=/dev/mapper/$crypt_name status=progress

	  echo -e "##################################################################################################"

	  echo -e "closing wipe container"

	  echo -e "##################################################################################################"

	  cryptsetup close /dev/mapper/$crypt_name

	  echo -e "##################################################################################################"

	  echo -e "container closed"

	  echo -e "##################################################################################################"

  break
  ;;

 "simple cipher complex complex")

 	  echo -e "#####################################################################################################"
	  echo -e "############# cryptsetup will open a container on selected then container will be wiped #############"
	  echo -e "#####################################################################################################"
	  echo -e "\n"
	  echo -e "#####################################################################################################"
	  echo -e "\n"
	  echo -e "#####################################################################################################"

	  select_cipher(){
		    cipher_list=('aes-cbc-essiv:sha256' 'aes-xts-essiv:sha256' 'aes-xts-plain64')
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
	  select_cipher

    echo -e "########################################################"
	  echo -e "#################  select_keysize  #####################"
	  echo -e "########################################################"

    select_keysize(){
	  	  # print information cipher key
	  	  echo "enter a good key size"
	  	  read key_size
	  	  key_size=${key_size}
	      echo "${key_size}"
	  }
    select_keysize


    echo -e "########################################################"
	  echo -e "################    select_hash     ####################"
	  echo -e "########################################################"

	  select_hash(){
	      echo -e "make sure selected hash matches the selected cipher where applicable: i.e. --cipher {cipher}:sha256 == --hash sha256"
	      hash_list=('sha1' 'sha256' 'sha512' 'ripemd160' 'whirlpool')
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
	        #Need function select only hash name out of less selection
	  }
	  select_hash

	  echo -e "########################################################"
    echo -e "################   select_random    ####################"
    echo -e "########################################################"

	  select_random(){
	      random_list=("--use-random" "--use-urandom");
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
          echo -e "$random"

    }
	  select_random

	  echo -e "##################################################################################################"

	  read -p "enter cryptsetup container name: " crypt_name

	  echo -e "##################################################################################################"

	  cryptsetup --cipher $cipher --key-size $key_size --hash $hash $random luksFormat $crypt_chosen

	  echo -e "##################################################################################################"

	  cryptsetup open $crypt_chosen $crypt_name

	  echo -e "##################################################################################################"

	  dd if=/dev/zero of=/dev/mapper/${crypt_name} status=progress

	  echo -e "##################################################################################################"

	  echo -e "closing wipe container"

	  echo -e "##################################################################################################"

	  cryptsetup close /dev/mapper/${crypt_name}

	  echo -e "##################################################################################################"

	  echo -e "container closed"

	  echo -e "##################################################################################################"
    ;;
    esac
  done
}
wipe_device

#!/bin/bash

crypt_setup(){

  echo -e "#########################################################"
  echo -e "################   crypt_benchmark    ###################"
  echo -e "#########################################################"

    cryptsetup benchmark
    PS3='please enter your choice of process: '
    options=("cryptsetup boot container" "cryptsetup key_file")
    select opt in "${options[@]}"
      do
    case $opt in
	"cryptsetup boot container")

	echo -e "#########################################################"
	echo -e "##################   select_name    #####################"
	echo -e "#########################################################"

	select_name(){
		    read -p "please enter encrypted device name \n: " main_name
		    echo -e "$(main_name)"
	  }
	select_name

	echo -e "########################################################"
	echo -e "###############    select_device     ###################"
	echo -e "########################################################"

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
		    else
			    echo -e "invalid_option function:\n"
		    fi
	      done
	      selected_device=$device
	      echo -e $selected_device
    }
	select_device

	echo -e "########################################################"
	echo -e "###############    select_cipher     ###################"
	echo -e "########################################################"

	select_cipher(){
		  cipher_list=('aes-cbc-essiv:sha256' 'aes-xts-essiv:sha256' 'aes-xts-plain64')
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
	select_cipher

	echo -e "########################################################"
	echo -e "#################  select_keysize  #####################"
	echo -e "########################################################"

	select_keysize(){
	    # print information cipher key
		  read -p "please enter key size : " key_size
		  key_size=${key_size}
		  echo "${key_size}"
		  # if then else statement for default selection none
	}
	select_keysize

	echo -e "########################################################"
	echo -e "################    select_hash     ####################"
	echo -e "########################################################"

	select_hash(){
	    cryptsetup benchmark
	    hash_list=('sha1' 'sha256' 'sha512' 'ripemd160' 'whirlpool')
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
	    # Need function select only hash name out of less selection
	}
	select_hash

       echo -e "########################################################"
       echo -e "###############   select_itertime    ###################"
       echo -e "########################################################"

  select_itertime(){
        echo -e "iter-time select increaes or decreases the number of interations by the hash"
        iter_time=('1000' '1500' '2000' '2500' '3000' '3500' '4000' '4500' '5000')
        PS3="$prompt1"
        select time in "${iter_time[@]}"; do
          if contains_element "${time}" "${iter_time[@]}"; then
            break
          else
            echo -e "invalid_option function:\n"
          fi
          done
          time=${time}
          echo -e "$time"
  }
  select_itertime

       echo -e "########################################################"
       echo -e "################   select_random    ####################"
       echo -e "########################################################"

  select_random(){
        echo -e "select random number generator for entropy"
        select_random=('/dev/urandom' '/dev/random')
        PS3="$prompt1"
        select random in "${select_random[@]}"; do
          if contains_element "${random}" "${select_random[@]}"; then
            break
          else
            echo -e "invalid_option function:\n"
          fi
          done
          random=${random}
          echo -e "$random"
  }
	select_random

     echo -e "#########################################################"
     echo -e "############ running cryptsetup command #################"
     echo -e "#########################################################"

      	cryptsetup -v --cipher $cipher --key-size $key_size --hash $hash --iter-time $time --use-random luksFormat $selected_device
      	cryptsetup open $selected_device $main_name
      	mkfs.ext4 /dev/mapper/$main_name
      	mkdir /mnt/boot
      	mkdir /mnt/efi
      	partitions_usb=1
      	mount /dev/mapper/$main_name /mnt
      	echo -e "setting /mnt/key.img"
      	read -p "please enter correct blocksize /mnt/key.img" block_size
     	read -p "please enter specific count for /mnt/key.img" meta_count
      	dd if=/dev/urandom of=/mnt/key.img bs=$block_size count=$meta_count
	cryptsetup --align-payload=1 luksFormat /mnt/key.img
      	cryptsetup open /mnt/key.img lukskey
      	;;

	"cryptsetup key_file")
     echo -e "##########################################################"
     echo -e "#################   select_name    #######################"
     echo -e "##########################################################"

  select_name(){
	      read -p "please enter container name: " main_name
		    echo -e "$(main_name)"
	}
	select_name

     echo -e "##########################################################"
     echo -e "################  select_keyfile   #######################"
     echo -e "##########################################################"

#  select_keyfile(){
#        echo -e "select the keyfile to be used for cryptsetup device"
#        key_file=(`lsblk -p | grep /dev/mapper| awk '{ print $1 }'`)
#          PS3="$prompt1"
#          select key in "${key_file[@]}"; do
#            if contains_element "${key}" "${key_file[@]}"; then
#            break
#          else
#             echo -e "invalid_option function:\n"
#          fi
#          done
#          key_file="${key_file}"
#          echo -e "${key_file}"
#  }
#	select_keyfile

     echo -e "##########################################################"
     echo -e "#################  select_offset   #######################"
     echo -e "##########################################################"

  select_offset(){
         echo -e "any good encrypted keyfile needs an offset from zero"
         read -p "please enter a good keyfile offset" key_file_offset
         key="${key_file_offset}"
  }
	select_offset

     echo -e "##########################################################"
     echo -e "#################   select_size      #####################"
     echo -e "##########################################################"

  select_size(){
         echo -e "select the keyfile size to be used"
         key_size=('256' '512')
         PS3="$prompt1"
         select keysize in "${key_size[@]}"; do
         if contains_element "${keysize}" "${key_size[@]}"; then
           break
         else
            echo -e "invalid_option function:\n"
         fi
         done
         keysize="${keysize}"
         echo -e "${keysize}"
  }
	select_size

     echo -e "#######################################################"
     echo -e "#################  select_device  #####################"
     echo -e "#######################################################"

  select_device(){
         echo -e "select main device for utilizing key"
         main_list=(`lsblk -d | awk '{print "/dev/" $1}' | grep 'sd\|hd\|vd\|nvme\|mmcblk'`)
         PS3="$prompt1"
         select opt in "${main_list[@]}"; do
         if contains_element "${opt}" "${main_list[@]}"; then
           break
         else
           echo -e "invalid_option function:\n"
         fi
         done
         selected_device="${opt}"
         echo -e "${selected_device}"
  }
	select_device

     echo -e "#########################################################"
     echo -e "################  payload_align   #######################"
     echo -e "#########################################################"

  payload_align(){
         read -p "enter the payload alignment: " pay_load
         pay_load=${pay_load}
         echo -e "${pay_load}"
  }
	payload_align

     echo -e "#####################################################"
     echo -e "###############  select_header   ####################"
     echo -e "#####################################################"

 # select_header(){
 #        echo -e "select the correct header path and name"
 #        header_list=(`lsblk -p | grep '/mnt' | awk '{ print $1 }'`)
 #        PS3="$prompt1"
 #        select opt in "${header_list[@]}"; do
 #        if contains_element "${opt}" "${header_list[@]}"; then
 #          break
 #        else
 #          echo -e "invalid_option function:\n"
 #        fi
 #        done
 #        head_sel="${opt}"
 #        echo -e "${head_sel}"
 # }
	select_header

     echo -e "#######################################################"
     echo -e "############ truncate -s file truncation ##############"
     echo -e "#######################################################"

	   echo -e "need a good truncate -s "
        read -p "please enter specific truncation allocation " truncs
        truncate -s $truncs /mnt/header.img
        cryptsetup --key-file=/dev/mapper/lukskey --keyfile-offset=$key --keyfile-size=$keysize luksFormat $selected_device --align-payload $pay_load --header /mnt/header.img
        cryptsetup open --header /mnt/header.img --key-file=$key_file --keyfile-offset=$key --keyfile-size=$keysize $selected_device $select_name
        cryptsetup close lukskey
        umount /mnt
        LUKS=1
        ;;
	esac
	done
}
crypt_setup

     echo -e "##########################################################"
     echo -e "###################  setup_lvm   #########################"
     echo -e "##########################################################"

  setup_lvm(){
		    if [[ $LUKS -eq 1 ]]; then
		    read "please enter name main drive" main_name
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
				  lvcreate -l 100%FREE mvg -n ${partition_name}
			  else
				  read -p "enter $i partition size [ex: 25G, 200M]: " partition_size
				  lvcreate -L ${partition_size} mvg -n ${partition_name}
				  if [[ "swap" -eq $partition_name ]]; then
				    mkswap /dev/mvg/$partition_name
				    swapon /dev/mvg/$partition_name
				  else
				    mkfs.ext4 /dev/mvg/${partition_name}
				  fi
			fi
			i=$(( i + 1 ))
		  done
		  LVM=1
	  }

     echo -e "#############################################################"
     echo -e "####################  format_mvgdir  ########################"
     echo -e "#############################################################"

  format_mvgdir(){
	    if [[ $LVM -eq 1 ]]; then
	    lvm_list=(`lsblk -p | grep /dev/mvg/ | awk '{ print $1 }'`)
	    read -p "enter number lvm" number_lvm
	    i=1
	      while [[ $i -le $number_lvm ]]; do
	        mvg_list=(`lsblk -p | grep /dev/mvg/ | awk '{ print $1 }'`)
	        PS3="$prompt1"
          select mvg in "${mvg_list[@]}"; do
            if contains_element ${mvg} ${mvg_list[@]}; then
              echo -e "${mvg}"
              read -p "enter corresponding mvg directory name" $dir_name
              # following assumes stored variable is command execution
              name_full=$(`mkdir /mnt/${dir_name}`)
              # mount read name to corresponding mvg filesystem
              mount $mvg $name_full
            else
              echo -e "NO MVG IN MVG LIST"
            i=$(( i + 1 ))
            fi
            done
          done
      else
          echo -e "LVM NOT EQUAL TO 1"
      fi
    }
     echo -e "#############################################################"
     echo -e "#####################  bash_mount  ##########################"
     echo -e "#############################################################"

  bash_mount(){
      if [[ $partitions_usb -eq 1 ]]; then
        base_list=(`lsblk -p | grep '/dev/sd' | awk '{ print $1 }'`)
        PS3="$prompt1"
        select base in "${base_list[@]}"; do
          if contains_element "${base}" "${base_list[@]}"; then
            mount $base /mnt/efi
          else
            echo -e "invalid_option"
          fi
          done
      fi
  }


	#check_mountpoint(){
	#	if mount | grep $2; then
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


	format_partitions(){
		block_list=(`lsblk | grep 'part\|lvm' | awk '{print substr($1,3)}'`)

		if [[ ${block_list[@]} -eq 0 ]]; then
			echo "no partition found"
			exit 0
		fi
		done
		}
	
		partitions_list=(){
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
			select partition in "${partitions_list[@]}"; do
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
		pause_function
	


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

select_linux_version(){
	version_list=("linux (default)" "linux-lts (long term support)" "linux-hardened (hardened linux)");
	PS3="$prompt1"
	echo -e "select linux version to install\n"
	select VERSION in "${version_list[@]}"; do
		if contains_element "$VERSION" "${version_list[@]}"; then
			if [ "linux (default)" == "$VERSION" ]; then
				pacstrap ${MOUNTPOINT} base linux linux-headers
			elif [ "linux-lts (long term support)" == "$VERSION" ]; then
				pacstrap ${MOUNTPOINT} base linux-lts linux-lts-headers
			elif [ "linux-hardened (hardened linux)" == "$VERSION" ]; then
				pacstrap ${MOUNTPOINT} base linux-hardened linux-hardened-headers
			fi
			pacstrap ${MOUNTPOINT} \
				cryptsetup lvm2 netctl dhcpcd inetutils jfutils diffutils e2fspogs \
				less linux-firmware lgorotate man-db man-pages mdadm nano \
				perl reiserfsprogs s-nail sysfutils texinfo usbutils vi vim which xfsprogs
			break
		else
			invalid_option
		fi
	done
}
install_base_system(){
	pacman -Sy archlinux-keyring
	print_info "using pacstrap script to install base system."
	rm ${MOUNTPOINT}${EFI_MOUNTPOINT}/vmlinuz-linux
	select_linux_version
	pacstrap ${MOUNTPOINT} base-devel parted btrfs-progs f2fs-tools net-tools
	[[ $? -ne 0 ]] && error_msg "Installing base system to ${MOUNTPOINT} failed. check error messages above."
	local PTABLE=`parted -sl | grep "gpt"`
	[[ -n $PTABLE ]] && pacstrap ${MOUNTPOINT} gptfdisk
	WIRELESS_DEV=`ip link | grep wl | awk '{print $2}'| sed 's/://' | sed '1!d'`
	if [[ -n $WIRELESS_DIV ]]; then
		pacstrap ${MOUNTPOINT} iw wireless_tools wpa_supplicant dialog
	else
		WIRED_DEV=`ip link | grep "ens\|eno\|enp" | awk '{print $2}' | sed 's/://' | sed '1!d'`
		if [[ -n $WIRED_DEV ]]; then
			arch_chroot "systemctl enable dhcpcd@${WIRED_DEV}.service"
		fi
	fi
	if is_package_installed "espeakup"; then
		pacstrap ${MOUNTPOINT} alsa-utils espeakup brltty
		arch_chroot "systemctl enable espeakup.service"
	fi
}
#}}}
#CONFIGURE KEYMAP {{{
configure_keymap(){
	#ADD KEYMAP TO THE NEW SETUP
	echo "KEYMAP=$KEYMAP" > ${MOUNTPOINT}/etc/vconsole.conf
}
#}}}
#CONFIGURE FSTAB {{{
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

install_base_system(){
	pacman -Sy archlinux-keyring
	print_info "using pacstrap script to install base system."
	rm ${MOUNTPOINT}${EFI_MOUNTPOINT}/vmlinuz-linux
	select_linux_version
	pacstrap ${MOUNTPOINT} base-devel parted btrfs-progs f2fs-tools net-tools
	[[ $? -ne 0 ]] && error_msg "Installing base system to ${MOUNTPOINT} failed. check error messages above."
	local PTABLE=`parted -sl | grep "gpt"`
	[[ -n $PTABLE ]] && pacstrap ${MOUNTPOINT} gptfdisk
	WIRELESS_DEV=`ip link | grep wl | awk '{print $2}'| sed 's/://' | sed '1!d'`
	if [[ -n $WIRELESS_DIV ]]; then
		pacstrap ${MOUNTPOINT} iw wireless_tools wpa_supplicant dialog
	else
		WIRED_DEV=`ip link | grep "ens\|eno\|enp" | awk '{print $2}' | sed 's/://' | sed '1!d'`
		if [[ -n $WIRED_DEV ]]; then
			arch_chroot "systemctl enable dhcpcd@${WIRED_DEV}.service"
		fi
	fi
	if is_package_installed "espeakup"; then
		pacstrap ${MOUNTPOINT} alsa-utils espeakup brltty
		arch_chroot "systemctl enable espeakup.service"
	fi
}
configure_hostname(){
	print_info "configures host name"
	read -p "Hostname [ex: archlinux]: " host_name
	echo "$host_name" > ${MOUNTPOINT}/etc/hostname
	if [[ ! -f ${MOUNTPOINT}/etc/host.aui ]]; then
		cp ${MOUNTPOINT}/etc/hosts ${MOUNTPOINT}/etc/host.aui
	else
		cp ${MOUNTPOINT}/etc/host.aui ${MOUNTPOINT}/etc/hosts
	fi
	arch_chroot "sed -i '/127.0.0.1/s/$/ '${host_name}'/' /etc/hosts"
	arch_chroot "sed -i '/::1/s/$/ '${host_name}'/' /etc/hosts"
}
#}}}

#CONFIGURE TIMEZONE {{{
configure_timezone(){
	print_info "determining time (clock) is determined by four parts: Time value, Time standard, Time Zone, and DST (Daylight Saving Time where applicable)."
	OPTION=n
	while [[ $OPTION != y ]]; do
		settimezone
		read_input_text "confirm timezone (${ZONE}/${SUBZONE})"
	done
	arch_chroot "ln -sf /usr/share/zoneinfo/${ZONE}/${SUBZONE} /etc/localtime"
	arch_chroot "sed -i '/#NTP=/d' /etc/systemd/timesyncd.conf"
	arch_chroot "sed -i 's/#Fallback//' /etc/systemd/timesyncd.conf"
	arch_chroot "echo \"FallbackNTP=0.pool.ntp.org 1.pool.ntp.org 0.fr.pool.ntp.org\" >> /etc/systemd/timesyncd.conf"
	arch_chroot "systemctl enable systemd-timesyncd.service"
}
#}}}

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
#CONFIGURE LOCALE {{{
configure_locale(){
	print_info "locales are used in linux to define which language the user uses."
	OPTION=n
	while [[ $OPTION != y ]]; do
		setlocale
		read_input_text "Confirm locale ($LOCALE)"
	done
	echo 'LANG="'$LOCAL_UTF8'"' > ${MOUNTPOINT}/etc/locale.conf
	arch_chroot "sed -i 's/#\('${LOCALE_UTF8}'\)/\1/' /etc/locale.gen"
	arch_chroot "locale-gen"
}
#}}}

configure_mkinitcpio(){
	print_info "mkinitcpio is a bash script used to create an initial ramdisk environemnt."
	[[ $LUKS -eq 1 ]] && sed -i '/^HOOK/s/block/block keymap encrypt/' ${MOUNPOINT}/etc/mkinitcpio.conf
	[[ $LVM -eq 1 ]] && sed -i '/^HOOK/s/filesystems/lvm2 filesystems/' ${MOUNTPOINT}/etc/mkinitcpio.conf
	if [ "$(arch-chroot ${MOUNTPOINT} ls /boot | grep hardened -c)" -gt "0" ]; then
		arch_chroot "mkinitcpio -p linux-hardened"
	elif [ "$(arch-chroot ${MOUNTPOINT} ls /boot | grep lts -c)" -gt "0" ]; then
		arch_chroot "mkinitcpio -p linux-lts"
	else 
		arch_chroot "mkinitcpio -p linux"
	fi
}
#}}}

#INSTALL BOOTLOADER {{{
install_bootloader(){
	print_info "the boot loader is responsible for loading the kernel and initial RAM disk before initiating the boot process."
	print_warning "\tROOT Partition: ${ROOT_MOUNTPOINT}"
	if [[ $UEFI -eq 1 ]]; then
		print_warning "\tUEFI Mode Detected"
		bootloaders_list=("Grub2" "Syslinux" "Systemd" "rEFInd" "Skip")
	else
		print_warning "\tBIOS mode detected"
		bootloaders_list=("Grub2" "Syslinux" "Skip")
	fi
	PS3="$prompt1"
	echo -e "install bootloader:\n"
	select bootloader in "${bootloaders_list[@]}"; do
		case "REPLY" in
			1)
				pacstrap ${MOUNTPOINT} grub os-prober
				break
				;;
			2)	
				pacstrap ${MOUNTPOINT} syslinux gptfdisk
				break
				;;
			3)
				break
				;;
			4)
				if [[ $UEFI -eq 1 ]]
				then
					pacstrap ${MOUNTPOINT} refind-efi os-prober
					break
				else
					invalid_option
				fi
				;;
			5)
				[[ $UEFI -eq 1 ]] && break || invalid_option
				;;
			*)
				invalid_option
				;;
		esac
	done
	[[ $UEFI -eq 1 ]] && pacstrap ${MOUNTPOINT} efibootmgr dosfstools
}
#}}}

configure_bootloader(){
	case $bootloader in
		Grub2)
			grub_install_mode=("Autotmatic" "Manual")
			PS3="$prompt1"
			echo -e "Grub Install:\n"
			select OPT in "${grub_install_mode[@]}"; do
				case "$REPLY" in
					1)
						if [[ $LUKS -eq 1 ]]; then
							sed -i -e 's/GRUB_CMDLINE_LINUX="\(.\+\)"/GRUB_CMDLINE_LINUX="\1 cyrptdevice=\/dev\/'"${LUKS_DISK}"':crypt"/g' -e 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLgfINE_LINUX="cryptdevic=\/dev\/'"$LUKS_DISK}"':crypt"/g' ${MOUNTPOINT}/etc/defualt/grub
						fi
						if [[ $UEFI -eq 1 ]]; then
							arch_chroot "grub-install --target=x86_64-efi --efi-directory=${EFI_MOUNTPOINT} --bootloader-id=arch_grub --recheck"
						else
							arch_chroot "grub-install --target=i386-pc --recheck --debug ${BOOT_MOUNPOINT}"
						fi
						break
						;;
					2)
						arch-chroot ${MOUNTPOINT}
						break
						;;
					*)
						invalid_option
						;;
				esac
			done
			arch_chroot "grub-mkconfig -o /boot/grub/grub.cfg"
			;;
		       Syslinux)
			       syslinux_install_mode=("[MBR] Automatic" "[PARTITION] Automatic" "Manual")
			       PS3="$prompt1"
			       echo -e "Syslinux Install:\n"
			       select OPT in "${syslinux_install_mode[@]}"; do
				       case "$REPLY" in
					       1)
						       arch_chroot "syslinux-install_update -iam"
							if [[ $LUKS -eq 1 ]]; then
								sed -i "s/APPEND root=.*/APPEND root=\/dev\/mapper\/${ROOT_PART} cryptdevice=\/dev\/${LUKS_DISK}:crypt ro/g" ${MOUNTPOINT}${EFI_MOUNTPOINT}/syslinux/syslinux.cfg
							elif [[ $LVM -eq 1 ]]; then
								sed -i "s/sda[0-9]/\/dev\/mapper\/${ROOT_PART}/g" ${MOUNTPOINT}4{EFI_MOUNTPOINT}/syslinux/syslinux.cfg
							else
								sed -i "s/sda[0-9]/${ROOT_PART}/g" ${MOUNTPOINT}${EFI_MOUNTPOINT}/syslinux/syslinux.cfg
							fi
							pause_function
							$EDITOR ${MOUNTPOINT}${EFI_MOUNTPOINT}/syslinx/syslinux.cfg
							break
							;;
						2)
							arch_chroot "syslinux-install_update -iam"
							if [[ $LUKS -eq 1 ]]; then
								sed -i "s/APPEND root=.*/APPEND root=\/dev\/mapper\/${ROOT_PART} cryptdevice=\/dev\/${LUKS_DISK}:crypt ro/g" ${MOUNTPOINT}${EFI_MOUNPOINT}/syslinux/syslinux.cfg
							elif [[ $LVM -eq 1 ]]; then
								sed -i "s/sda[0-9]/\dev/\mapper\/${ROOT_PART}g" ${MOUNTPOINT}${EFI_MOUNTPOINT}/syslinux/syslinux.cfg
							else
								sed -i "s/sda[0-9]/${ROOT_PART}/g" ${MOUNTPOINT}${EFI_MOUNTPOINT}/syslinux/syslinux.cfg
							fi
							pause_function
							$EDITOR ${MOUNTPOINT}${EFI_MOUNTPOINT}/syslinux/syslinux.cfg
							break
							;;
						3)
							print_info "Your boot partition, on which you plan to install Syslinux, must contain FAT, ext2, ext4, ext4 or Btrfs filesystem."
							echo -e $prompt3
							arch-chroot ${MOUNTPOINT}
							break
							;;
						*)
							invalid_option
							;;
					esac
				done
				;;
			Systemd)
				gummiboot_install_mode=("Automatic" "Manual")
				select OPT in "${gummiboot_install_mode[@]}"; do
					case "$REPLY" in
						1)
							arch_chroot "bootctl --path=${EFI_MOUNTPOINT} install"
							partuuid]`blkid -s PARTUUID ${ROOT_MOUNTPOINT} | awk '{print $2}' | sed 's/"//g' | sed 's/^.*=//'`
							if [ "$(arch-chroot ${MOUNTPOINT} ls /boot | grep hardened -c)" -gt "0" ]; then
								img_name="linux-lts"
							else
								img_name="linux"
							fi
							if [[ $LUKS -eq 1 ]]; then
								echo -e "title\tArch Linux\nlinux\t/vmlinuz-${img_name}\ninitrd\t/initramfs-${img_name}.img\noptions\tcryptdevice=\/dev\/${LUKS_DISK}:luks root=\/dev\/mapper\/:synt${ROOT_PART} rw" > ${MOUNTPOINT}${EFI_MOUNTPOINT}/loader/entries/arch.conf
							elif [[ $LVM -eq 1 ]]; then
								echo -e "title\arch"
							else 
								echo -e "title\tArch"
							fi
							echo -e "default arch\ntimeout 5" > ${MOUNTPOINT}${EFI_MOUNTPOINT}/loader/loader.conf
							pause_function
							$EDITOR ${MOUNTPOINT}${EFI_MOUNTPOINT}/loader/entries/arch.conf
							$EDITOR ${MOUNTPOINT}${EFI_MOUNTPOINT}/loader/loader.conf
							break 
							;;
						2)
							arch-chroot ${MOUNTPOINT}
							break
							;;
						*)
							invalid_option
							;;
					esac
				done
				;;
			rEFInd)
				refind_install_mode=("Automatic" "Manual")
				PS3="$prompt1"
				echo -e "rEFInd install:\n"
				select OPT in "${refind_install_mode[@]}"; do
					case "$REPLY" in
						1)
							arch_chroot "refind-install"
							$EDITOR ${MOUNTPOINT}${EFI_MOUNTPOINT}/refind_linux.conf
							break
							;;
						2)
							arch-chroot ${MOUNTPOINT}
							break
							;;
						*)
							invalid_option
							;;
					esac
				done
				;;
		esac
		pause_fuction
	}	
#}}}
#ROOT PASSWORD {{{
root_password(){
	print_title "ROOT PASSWORD"
	print_warning "enter your new root password"
	arch_chroot "passwd"
	pause_function
}
#}}}
#}}}
finish(){
	print_title "INSTALL COMPLETED"
	#COPY AUI TO ROOT FOLDER IN THE NEW SYSTEM
	print_warning "\nA copy of the AUI will be placed in /root directory of your new system"
	cp -R `pwd` ${MOUNTPOINT}/root
	read_input_text "Reboot system"
	if [[ $OPTION == y ]]; then
		umount_partitions
		reboot
	fi
	exit 0
}
#}}}


