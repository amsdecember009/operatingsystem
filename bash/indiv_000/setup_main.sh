		
	setup_main(){
			truncate -s 16M /mnt/header.img
			cryptsetup --key-file=/dev/mapper/lukskey --keyfile-offset="${keyfileoffset}" --keyfile-size="${keyfilesize}" luksFormat ${select_main} --header /mnt/header.img
			cryptsetup open --header /mnt/header.img --key-file=/dev/mapper/lukskey --keyfile-offset="${keyfileoffset}" --keyfile-size="${keyfilesize}" "${select_main}" "${main_name}"
			cryptsetup close lukskey
			umount /mnt
			LUKS=1
			LUKS_DISK=`echo ${OPT} | sed 's/\/dev\///'`
		}	

