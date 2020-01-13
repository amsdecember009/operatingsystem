
	format_swap_partition(){
		read_input_text "Confirm format $1 partition"
		if [[ $OPTION == y ]]; then
		  mkswap $1
		  swapon $1
		  disable_partition
		fi
	}


