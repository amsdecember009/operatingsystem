
	disable_partition(){
		unset partitions_list[${partition_number}]
		partitions_list=(${partitions_list[@]})
		[[${partition_name[i]} != another ]] && i=$(( i + 1 ))
	}


