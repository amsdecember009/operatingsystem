#!/bin/bash

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
		else
			echo -e "invalid_option function:\n"
		fi
	done
	selected_device=$device
	echo -e $selected_device
}

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
      	read -p "creating /mnt/key.img please input name: " lukskey
      	echo -e "setting /mnt/key.img"
      	read -p "please enter correct blocksize /mnt/key.img" block_size
     	read -p "please enter specific count for /mnt/key.img" meta_count
      	dd if=/dev/urandom of=/mnt/key.img bs=$block_size count=$meta_count
	cryptsetup --align-payload=1 luksFormat /mnt/key.img
      	cryptsetup open /mnt/key.img $lukskey
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

  select_keyfile(){
        echo -e "select the keyfile to be used for cryptsetup device"
        key_file=(`lsblk -p | grep /dev/mapper/$lukskey | awk '{ print $1 }'`)
          PS3="$prompt1"
          select key in "${key_file[@]}"; do
            if contains_element "${key}" "${key_file[@]}"; then
            break
          else
             echo -e "invalid_option function:\n"
          fi
          done
          key_file="${key_file}"
          echo -e "${key_file}"
  }
	select_keyfile

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

     echo -e "######################################################"
     echo -e "############ truncate -s file truncation #############"
     echo -e "######################################################"

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


