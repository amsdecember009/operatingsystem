
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


