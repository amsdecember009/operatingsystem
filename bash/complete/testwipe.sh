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


	
