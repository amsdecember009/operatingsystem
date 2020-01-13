	check_mountpoint(){
		if mount | grep $2; then
			echo "Successfully mounted"
			disable_parition "$1"
		else
			echo "WARNING: Not successfully mounted"
		fi
	}	
