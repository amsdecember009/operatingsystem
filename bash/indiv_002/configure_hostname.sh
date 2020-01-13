configure_hostname(){
	print_info "configures host name"
	read -p "Hostname [ex: archlinux]: " host_name
	echo "$host_name" > ${MOUNTPOINT}/etc/hostname
	if [[ ! -f ${MOUNTPOINT}/etc/host.aui ]]; then
		cp ${MOUNTPOINT}/etc/hosts ${MOUNTPOINT}/etc/host.aui
	else
		cp ${MOUNTPOINT}/etc/host.aui ${MOUNTPOINT}/etc/hosts
	fi
	arch_chroot "sed -i '/127.0.0.1/s/$/ '${host_name}'/' /etc/hosts"
	arch_chroot "sed -i '/::1/s/$/ '${host_name}'/' /etc/hosts"
}
#}}}

