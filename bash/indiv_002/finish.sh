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


