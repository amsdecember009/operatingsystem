
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
