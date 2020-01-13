
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


