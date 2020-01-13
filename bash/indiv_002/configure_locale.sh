#CONFIGURE LOCALE {{{
configure_locale(){
	print_info "locales are used in linux to define which language the user uses."
	OPTION=n
	while [[ $OPTION != y ]]; do
		setlocale
		read_input_text "Confirm locale ($LOCALE)"
	done
	echo 'LANG="'$LOCAL_UTF8'"' > ${MOUNTPOINT}/etc/locale.conf
	arch_chroot "sed -i 's/#\('${LOCALE_UTF8}'\)/\1/' /etc/locale.gen"
	arch_chroot "locale-gen"
}
#}}}

