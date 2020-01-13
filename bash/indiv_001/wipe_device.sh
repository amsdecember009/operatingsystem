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


