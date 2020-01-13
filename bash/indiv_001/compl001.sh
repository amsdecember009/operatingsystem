
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
	echo -e "cryptsetup close container"
	echo -e "##################################################################################################"
}


