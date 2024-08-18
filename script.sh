#!/bin/bash

#.............................PROCESS MANAGEMENT......................................
# Function to list all running processes
list_processes() {
    echo "Listing all running processes:"
    echo "-------------------------------------------------------------"
  printf "%-10s %-10s %-10s %s\n" "PID" " USER" " MEM(%)  "
    echo "-------------------------------------------------------------"

    
    ps aux --sort=-%mem | awk 'NR>1 {printf "%-10s %-10s %-10s\n", $2, $1 ,$4}'
}

# Function to kill the process by it PID
kill_process(){
	local pid=$1
	if [ -z "$pid" ];then
		echo "Error: No PID provided."
		exit 1;
	fi

    kill $pid

	if [ $? -eq 0 ]; then
		echo "Process $pid successfully terminated."
	else 
		echo "Failed to terminated process $pid. the process might not exist."
	fi	
}

#Function to monitor and display sytem load and cpu usage in real time
monitor_system() {
	echo " Monitoring system load and cpu Usage in real time (press ctrl+c to stop)"
	echo "........................................................................."

	top -d 1 -n 20
}

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>DISK MANAGEMENT>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#Function for showing disk usage of mounted filesystem
disk_usage(){
	echo "Displaying disk uasge of all mounted filesystem"
	echo "................................................"

	df -h
}

#Function for dispalying available disk space on all mounted file system
available_diskspace(){
	echo "Available disk space on all mounted filesystem"
	echo ".............................................."

	df -h
}

#Function to show disk partition and their status
list_diskpartition(){
	echo "Listing all disk partition and their status"
	echo "............................................"

	lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT,STATE
}

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>FILE MANAGEMENT>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#Searching for file in specified directory
search_files(){
	local directory=$1
	local filename=$2

	if [ -z "$directory" ] || [ -z "$filename" ]; then
		echo "Error: Both directory and filename must be provided."
		echo "usage: $0 search_files <directory> <filename>"
		exit 1

	fi 

	echo "Searching for files named named '$filename' in directory '$directory':"
	echo "......................................................................."

	find "$directory" -type f -name "$filename"
}
#function to create ,delete and rename the file
create_item(){
  	local path=$1
	local type=$2

	if [ -z "$path" ] || [ -z "$type" ]; then
		echo "Error:Both path and type(file/directory) must be provided"
		echo "Usage: $0 create_item <path> <fiel|directory>"
		exit 1
	fi

	if [ "$type" == "file" ]; then
		touch "$path" && echo "File "$path" created successfully."
	elif [ "$type" == "directory" ]; then
		mkdir -p "$path" && echo "Directory '$path' createed successfully."
	else
		echo "Invalid type specified. Use 'file' or 'directory'."
		exit 1
	fi
}
delete_item(){
	local path=$1

	if [ -z "$path" ]; then
		echo "Error: path must be provided"
		echo "Usage: $0 delete_item <path>"
		exit 1
	fi

	if [ -f "$path" ]; then
		rm "$path" && echo "File '$path' delete successfully."
	elif [ -d "$path" ]; then
		rm -r "$path" && echo "Directory '$path' delete successfully."
	else 
		echo "Error: '$path' is not a valid file or directory."
		exit 1
	fi
}

rename_item(){
	local old_path=$1
	local new_path=$2

	if [ -z "$old_path" ] || [ -z "$new_path" ]; then 
		echo "Error: Both old path and new paht mst be provided."
	       echo "uasge: $0 rename_item <old_path> <new_path>"
       		exit 1
 	fi

	if [ -e "$old_path" ]; then
	mv "$old_path" "$new_path" && echo "Renamed '$old_path' to '$new_path'successfully"
	else
		echo "Error: '$old_path' does not exist."
		exit 1
	fi

}

#Function of Backup of a specified file
backup_item(){
 local source_path=$1
 local backup_path=$2

 	if [ -z "$source_path" ] || [ -z "$backup_path" ]; then
		echo "Error: Both source_path and backup_path must be provided"
		echo "Usage: $0 <source_paht> <backup_path>"
		exit 1
	fi

	if [ -e "$source_path" ]; then
		cp -r  "$source_path" "$backup_path" && echo "Backup of '$source_path' succesfully done"
	else 
		echo "Error: '$source_path' does not exist."
		exit 1
	fi
}

#Function to dispaly list of all users with their uids
list_users(){
 echo "Listing all user with their UID nad  home directory:"
 echo "....................................................."
 echo "Username            UID      Home Directory"
 echo "....................................................."
 
 awk -F: '{printf "%-20s %-6s %s\n", $1, $3, $6}' /etc/passwd 
}

#Function for adding new user
add_user(){
	local username=$1
	local home_dir=$2

	if [ -z "$username" ] || [ -z "$home_dir" ]; then
		echo "Error: Both <username> & <home_dir> is required"
		echo "Usage: $0 add_user <username> <home_dir>"
		exit 1
	fi

	sudo useradd -m -d "$home_dir" "$username"

	if [ $? -eq 0 ];then
		echo "User '$username' successfully created"
	else 
		echo "'$username' User failed to created"
	fi
}

#Function to delete the existing user
delete_user(){
	local username=$1
	 	
		if [ -z "$username" ];then
			echo "Error: Provide a username to delete"
			echo "Usage: $0 delete_user <username>"
			exit 1;
		fi
	
	sudo  userdel -r  "$username"
	 
	less /etc/passwd | grep "$username"
	 if [ $? -eq 1 ]; then
        echo "User '$username' deleted successfully."
    else
        echo "Failed to delete user '$username'. The user may not exist."
    fi
} 
#Function to change the password of user
change_password(){
	local username=$1

	if [ -z "$username" ]; then
		echo "Error: Username must be provided"
		echo "Usage: $0 change_password <username>"
		exit 1;
	fi
	
	sudo  passwd "$username"

	if [ $? -eq 0 ]; then
		echo "Password changed successfully"
	else 
		echo "Failed to chnage the password for '$username'."
	fi
}

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>SYSTEM INFORMATION>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#Function to display how long the system has been running
system_uptime(){
	echo "CurrentTime  Uptime   User   loadAverage"
	uptime
}	

#Function to show the current memeory usage, including total,used,free memory.
show_memory_usage(){
	echo "Memory Usage"
	echo "............"

	free -h | awk 'NR==1{print $1,$2,$3} NR==2{print $2,$3,$4}'

	echo "............."
}

help(){
       less readmefile
}

LOGFILE="var/log/script.sh.log"

#Function to log actions with timestamps
log_action() {
        local action="$1"
        local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
        echo "$timestamp - $action" >> "$LOGFILE"

}
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>#
# Main script execution
case "$1" in 
	list_processes)
		list_processes
		;;
	kill_process)
		if [ ! -z "$2" ]; then
			kill_process $2
		else 
		     echo "Usage: $0 kill_process <PID>"
		fi
		;;
	monitor_system)
		monitor_system
		;;
	disk_usage)
		disk_usage
		;;
	available_diskspace)
		available_diskspace
		;;
	list_diskpartition)
		list_diskpartition
		;;
	search_files)
		if [ ! -z "$2" ] && [ ! -z "$3" ]; then
			search_files "$2" "$3"
		else 
			echo "Usage: $0 serach_files <directory> <filename>"
		fi
		;;
	create_item)
		if [ ! -z "$2" ] && [ ! -z "$3" ]; then
			create_item "$2" "$3"
		else
			echo "Usage: $0 create_item <path> <file|directory>"
		fi
		;;
	delete_item)
		if [ ! -z "$2" ]; then
			delete_item "$2"
		else
			echo "Usage: $0 delete_item <path>"
		fi
		;;
	 rename_item)
        	if [ ! -z "$2" ] && [ ! -z "$3" ]; then
            	rename_item "$2" "$3"
        	else
            	echo "Usage: $0 rename_item <old_path> <new_path>"
        	fi
        	;;
	backup_item)
		if [ ! -z "$2" ] && [ ! -z "$3" ]; then
			backup_item "$2" "$3"
		else 
			echo "Usage: $0 backup_item <source_path> <backup_path>"
		fi
		;;
	list_users)
		list_users
		;;
	add_user)
		if [ ! -z "$2" ] && [ ! -z "$3" ]; then
			 add_user "$2" "$3"
		else 
			echo "Usage: $0 add_user <username> <home_dir>"
		fi
		;;
	delete_user)
		if [ ! -z "$2" ];then 
			delete_user "$2"
		else 
			echo "Usage: $0 del_user <username>"
		fi
		;;
	change_password)
		if [ ! -z "$2" ];then
			change_password "$2"
		else 
			echo "Usage: $0 change_password <username>"
		fi
		;;
	system_uptime)
		system_uptime
		;;
	show_memory_usage)
		show_memory_usage
		;;
	--help)
		help
		;;
	*)
		echo "Invalid argument"
		echo "For more information: '$0' --help"
		;;
	esac
