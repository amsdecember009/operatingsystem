#}}}
#CONFIGURE KEYMAP {{{
configure_keymap(){
	#ADD KEYMAP TO THE NEW SETUP
	echo "KEYMAP=$KEYMAP" > ${MOUNTPOINT}/etc/vconsole.conf
}
#
