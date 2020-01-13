#CONFIGURE TIMEZONE {{{
configure_timezone(){
	print_info "determining time (clock) is determined by four parts: Time value, Time standard, Time Zone, and DST (Daylight Saving Time where applicable)."
	OPTION=n
	while [[ $OPTION != y ]]; do
		settimezone
		read_input_text "confirm timezone (${ZONE}/${SUBZONE})"
	done
	arch_chroot "ln -sf /usr/share/zoneinfo/${ZONE}/${SUBZONE} /etc/localtime"
	arch_chroot "sed -i '/#NTP=/d' /etc/systemd/timesyncd.conf"
	arch_chroot "sed -i 's/#Fallback//' /etc/systemd/timesyncd.conf"
	arch_chroot "echo \"FallbackNTP=0.pool.ntp.org 1.pool.ntp.org 0.fr.pool.ntp.org\" >> /etc/systemd/timesyncd.conf"
	arch_chroot "systemctl enable systemd-timesyncd.service"
}
#}}}

