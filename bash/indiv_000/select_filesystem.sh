
	select_filesystem(){
		filesystem_list=( "btrfs" "ext2" "ext3" "ext4" "f2fs" "jfs" "nilfs2" "ntfs" "reiserfs" "vfat" "xfs");
		PS3="$prompt1"
		echo -e "selection filesystem:\n"
		select filesystem in "${filesystems_list[@]}"; do
			if contains_element "${filesystem}" "${filesystems_list[@]}"; then
				break
			else
				invalid_option
			fi
		done
	}


