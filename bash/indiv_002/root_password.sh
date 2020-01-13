#}}}
#ROOT PASSWORD {{{
root_password(){
	print_title "ROOT PASSWORD"
	print_warning "enter your new root password"
	arch_chroot "passwd"
	pause_function
}
#}}}
