#!/bin/bash

#tabs length 25
tabs 25

#Controll for root login
if [ "$(id -u)" != "0" ]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi

#Print system manager
function system_manager {
	echo "************************************************************"
	echo "               SYSTEM MANAGER (version 1.0.0)"
	echo "------------------------------------------------------------"

	return 0
}

#List all functions available in the main menu
function list {
	printf "\e[0;31mua\e[0m - User Add        \t (Create a new user)"
	printf "\n\e[0;31mul\e[0m - User List     \t (List all login users)"
	printf "\n\e[0;31muv\e[0m - User View     \t (View user properties)"
	printf "\n\e[0;31mum\e[0m - User Modify   \t (Modify user properties)"
	printf "\n\e[0;31mud\e[0m - User Delete   \t (Delete a login user)"
	printf "\n\e[0;31mga\e[0m - Group Add     \t (Create a new group)"
	printf "\n\e[0;31mgl\e[0m - Group List    \t (List all groups, not system groups)"
	printf "\n\e[0;31mgv\e[0m - Group View    \t (List all users in a group)"
	printf "\n\e[0;31mgm\e[0m - Group Modify  \t (Add/remove user to/from a group)"
	printf "\n\e[0;31mgd\e[0m - Group Delete  \t (Delete a group, not system groups)"
	printf "\n\e[0;31mfa\e[0m - Folder Add    \t (Create a new folder)"
	printf "\n\e[0;31mfl\e[0m - Folder List   \t (View content in a folder)"
	printf "\n\e[0;31mfv\e[0m - Folder View   \t (View folder properties)"
	printf "\n\e[0;31mfm\e[0m - Folder Modify \t (Modify folder properties)"
	printf "\n\e[0;31mfd\e[0m - Folder Delete \t (Delete a folder/folders)"
	printf "\n\e[0;31mss\e[0m - SSH Server    \t (Manage SSH Server)"
	printf "\n\e[0;31mex\e[0m - Exit          \t (Exit System Manager)\n"

	return 0
}

function option {
#Clear the terminal before any option is shown
	clear
	case $1 in
		ua )
			user_add
			;;
		ul )
			user_list
			;;
		uv )
			user_view
			;;
		um )
			user_modify
			;;
		ud )
			user_delete
			;;
		ga )
			group_add
			;;
		gl )
			group_list
			;;
		gv )
			group_view
			;;
		gm )
			group_modify
			;;
		gd )
			group_delete
			;;
		fa )
			folder_add
			;;
		fl )
			folder_list
			;;
		fv )
			folder_view
			;;
		fm )
			folder_modify
			;;
		fd )
			folder_delete
			;;
		ss )
			ssh
			;;
		ex )
			exit_program
			;;
		* )
			system_manager
			echo "Invalid option."
		esac
	return 0
}


function user_add {
	system_manager
	echo "                          User Add"
	echo "Info:"
	echo "Creates a User based on input. Users get assigned UIDs"
	echo "between 1000 and 19999 to avoid UPG and supplement groups"
	echo "from overlapping."
	echo "------------------------------------------------------------"

	echo -n "User: "
	read userName
	sudo adduser $userName --home /home/$userName --shell /bin/bash

	return 0
}

#List all users in the system with uid less then 20000
function user_list {
	system_manager
	echo "                      User List"
	echo "Info:"
	echo "List all System Users."
	echo -n "------------------------------------------------------------"
	awk -F':' '{ if ( $3 >= 1000 && $3 <= 19999 ) printf "\n\033[0;31mUser:\033[0m %s \t \033[0;31mUser-id:\033[0m "$3, $1 }' /etc/passwd #lägsta = 1000, högsta = 19999
	echo -e
	return 0
}

#View all the details listed in /etc/passwd file about specific user
function user_view {
	system_manager
	echo "                      User View"
	echo "Info:"
	echo "List attributes for a user."
	echo "------------------------------------------------------------"
	echo -n "Choice: "
	read user_Name

	#If no input is given to user_Name
	if [ -z "$user_Name" ]; then
		echo "No user choosen, you get returned to the main menu"
		return 1
	#If user name is entered it searches for it in the passwd file
	else
		getent passwd $user_Name &> /dev/null
		if [ $? -eq 0 ]; then
			printf "\e[0;31mUser:\e[0m       - \t"
			grep $user_Name /etc/passwd | awk -F: '{print $1}'
			printf "\e[0;31mPassword:\e[0m   - \t"
			grep $user_Name /etc/passwd | awk -F: '{print $2}'
			printf "\e[0;31mUser ID:\e[0m    - \t"
			grep $user_Name /etc/passwd | awk -F: '{print $3}'
			printf "\e[0;31mGroup ID:\e[0m   - \t"
			grep $user_Name /etc/passwd | awk -F: '{print $4}'
			printf "\e[0;31mComment:\e[0m    - \t"
			grep $user_Name /etc/passwd | awk -F: '{print $5}'
			printf "\e[0;31mDirectory:\e[0m  - \t"
			grep $user_Name /etc/passwd | awk -F: '{print $6}'
			printf "\e[0;31mShell:\e[0m      - \t"
			grep $user_Name /etc/passwd | awk -F: '{print $7}'
			echo ""
			printf "\e[0;31mGroups:\e[0m     -      \t"

			grep $user_Name /etc/group | awk -F: '{printf $1", "}' | head -c -2
			echo ""
		#If user is not in the system
		else
			echo "User $user_Name doesn't exists"
			return 1
		fi
	fi
	return 0
}

#Modify an existing user.
function user_modify {
	system_manager
	echo "                     User Modify"
	echo "Info:"
	echo "First choose which user to modify, then choose what to"
	echo "modify on specified user."
	echo "------------------------------------------------------------"
	echo -n "User: "
	read user

	if [ -z "$user" ]; then
		echo "No user chosen."
		return 1
	else

		#Check if user exist in the system
		getent passwd $user_Name &> /dev/null
		if [ $? -eq 0 ]; then

			#List of what to enter to change specific area
   			echo -e "\033[31mna\e[0m - Change name"
		   	echo -e "\033[31mpa\e[0m - Change password"
   			echo -e "\033[31mui\e[0m - Change user-id"
   			echo -e "\033[31mgi\e[0m - Change group-id"
   			echo -e "\033[31mco\e[0m - Change comment"
			echo -e "\033[31mho\e[0m - Change home-directory"
			echo -e "\033[31msh\e[0m - Change shell"
			echo "------------------------------------------------------------"
			echo -en "Modify: "
			read toModify

			if [ -z "$toModify" ]; then
				echo "No option choosen, you get returned to the main menu"
				return 1
			fi

		#If user is not in the system the function ends.
		else
			echo "user $user does not exist"
			return 1
		fi
	fi

	case $toModify in
		na )
			echo -n "Type the new name for the user: "
			read newName
			usermod -l $newName $user
			;;
		pa )
			echo -n "Type the new password: "
			read -s newPassword
			echo -e
			echo -n "Type the password again: "
			read -s passwordCheck
			echo -e
			echo -e "$newPassword\n$passwordCheck" | passwd $user
			;;
		ui )
			echo -n "Type the new user-id for the user: "
			read newUid
			usermod -u $newUid $user
			;;
		gi )
			echo -n "Type the new group-id for the user: "
			read newGid
			usermod -g $newGid $user
			;;
		co )
			echo -n "Please enter comment for the user: "
			read comment
			usermod -c  "$comment" $user
			;;
		ho )
			echo -n "Please enter home directory for the user: "
			read homeDirectory
			usermod -d $homeDirectory $user
			;;
		sh )
			echo -n "Decide wich shell to use: "
			read shell
			usermod -s $shell $user
			;;
		* )
			echo "Invalid option."
		esac
	return 0
}

#Remove a user
function user_delete {
	system_manager
	echo "                      User Delete"
	echo "Info:"
	echo "Delete a user based on input."
	echo "------------------------------------------------------------"
	echo -n "User: "
	read userName

	#Check userName so it's not empty
	if [ -z "$userName" ]; then
		echo "No user chosen."
		return 1
	#User deletes
	else
   		sudo userdel $userName && echo "User deleted"
   		sudo rm -r /home/$userName
	fi
	return 0
}

# Create a group based on input.
function group_add {
	system_manager
	echo "                          Group Add"
	echo "Info:"
	echo "Create a group based on input. Groups get assigned GIDs at"
	echo "20,000+ to avoid UPG and supplement groups from overlapping." 
	echo "------------------------------------------------------------"

	echo -n "Name: "
	read gaName
	gidStart=20000

	if [ -z "$gaName" ]; then
		echo "Need an input to add a group."
		return 1
	fi

	if getent group $gidStart > /dev/null; then
	    	groupadd $gaName &> /dev/null && echo "Group successfully added." || echo "Could not add group."
	else
	    	groupadd -g $gidStart $gaName &> /dev/null && echo "Group successfully added." || echo "Could not add group."
	fi

	return 0
}

# List all groups (not system groups).
function group_list {
	system_manager
	echo "                      Group List"
	echo "Info:"
	echo "List all groups (not system groups)."
	echo "------------------------------------------------------------"

	echo -e "\e[31mUser private groups (UPGs): \e[0m"
	awk -F: '{if($3 >= 1000 && $3 < 20000) print "Group: " $1, "\t(GID: " $3 ")"}' /etc/group

	echo -e "\n\e[31mSupplementary groups: \e[0m"
	awk -F: '{if($3 >= 20000 && $3 != 65534) print "Group: " $1, "\t(GID: " $3 ")"}' /etc/group

	return 0
}

# List all users in a group.
function group_view {
	system_manager
	echo "                      Group View"
	echo "Info:"
	echo "List all users in a group."
	echo "------------------------------------------------------------"

	echo -n "Group: "
	read gvGroup

	if [ -z "$gvGroup" ]; then
		echo "Need an input to view a group."
		return 1
	fi

	if grep -w $gvGroup /etc/group > /dev/null; then
		echo -en "\e[31mUsers:\e[0m "
	    	awk -F: '{ if("'$gvGroup'" == $1) print $4}' /etc/group
	else
	    	echo "Group does not exist."
	fi

	return 0
}

# Add a user to an existing group.
function group_add_user {
	system_manager
	echo "                        Add User"
	echo "Info:"
	echo "Add a user to an existing group."
	echo "------------------------------------------------------------"

	echo -n "User:"
	read gauUser

	if [ -z "$gauUser" ]; then
		echo "Need an input."
		return 1
	elif [ ! $(getent passwd $gauUser) &> /dev/null ]; then
		echo "User does not exist."
		return 2
	fi

	echo -n "Group: "
	read gauGroup

	if [ -z "$gauGroup" ]; then
		echo "Need an input."
		return 1
	elif [ ! $(getent group $gauGroup) &> /dev/null ]; then
		echo "Group does not exist."
		return 2
	fi

	usermod -aG $gauGroup $gauUser &> /dev/null && echo "User added successfully." || echo "User could not be added."

	return 0
}

# Remove a users association to an existing group.
function group_remove_user {
	system_manager
	echo "                     Remove User"
	echo "Info:"
	echo "Remove a users association to an existing group."
	echo "------------------------------------------------------------"

	echo -n "User: "
	read gruUser

	if [ -z "$gruUser" ]; then
		echo "Need an input."
		return 1
	elif [ ! $(getent passwd $gruUser) &> /dev/null ]; then
		echo "User does not exist."
		return 2
	fi

	echo -n "Group: "
	read gruGroup

	if [ -z "$gruGroup" ]; then
		echo "Need an input."
		return 1
	elif [ ! $(getent group $gruGroup) &> /dev/null ]; then
		echo "Group does not exist."
		return 2
	fi

	deluser $gruUser $gruGroup &> /dev/null && echo "User successfully removed." || echo "User could not be removed."

	return 0
}

# Add or remove a user from a group.
function group_modify {	
	system_manager
	echo "                     Group Modify"
	echo "Info:"
	echo "Add or remove a user from a group."
	echo ""
 	echo -e "\e[31mOptions:\e[0m"
	echo -e "\e[31mad\e[0m - Add user"
	echo -e "\e[31mrm\e[0m - Remove user"
	echo -e "---------------------------------------------------------"

	echo -n "Choice: "
	read gmChoice

	if [ "$gmChoice" = "ad" ]; then
		clear
		group_add_user
	elif [ "$gmChoice" = "rm" ]; then
		clear
		group_remove_user
	else
		echo "Invalid option."
	fi

	return 0
}

# Delete a group based on input.
function group_delete {
	system_manager
	echo "                      Group Delete"
	echo "Info:"
	echo "Delete a group based on input."
	echo "------------------------------------------------------------"

	echo -n "Group to remove: "
	read gdGroup

	if [ -z "$gdGroup" ]; then
	    echo "Need an input."
	    return 1
	fi

	if getent group $gdGroup > /dev/null; then
		gid=$(getent group $gdGroup | cut -d : -f 3) > /dev/null

	    	if [ $gid -gt 1000 ] && [ $gid -ne 65534 ]; then
		  	groupdel $gdGroup &> /dev/null && echo -e "Group successfully removed." || echo "Could not remove group."
	      	else
		  	echo "Invalid gid: $gid (only user groups are allowed)."
	    	fi
	else
	    	echo "Group does not exist."
	fi

	return 0
}

# Create a folder using an absolute path or a folder name.
function folder_add {
	system_manager
	echo "                       Folder Add"
	echo "Info:"
	echo "Create a folder using an absolute path or a folder name. If"
	echo "only a name is written, the folder will be placed in the"
	echo "user's \"Documents\" directory."
	echo "------------------------------------------------------------"

	echo -n "Folder: "
	read faFolder

	if [ -z "$faFolder" ]; then
	    echo "Need an input."
	    return 1
	fi

	if [ ${faFolder:0:1} != "/" ]; then
	    faFolder="/home/$SUDO_USER/Documents/$faFolder"
	fi

	mkdir $faFolder &> /dev/null && echo "Folder successfully created." || echo "Folder could not be created."

	return 0
}

# List a folder's content.
function folder_list {
	system_manager
	echo "                        Folder List"
	echo "Info:"
	echo "List a folder's content. Specify either the absolute path or"
	echo "the folder's name (initiates a search)."
	echo "------------------------------------------------------------"

	echo -n "Folder: "
	read flFolder

	if [ -z "$flFolder" ]; then
	    echo "Need an input."
	    return 1
	fi

	if [ ! -d "$flFolder" ]; then
	    flFolder=$(find "/" -name "$flFolder" 2> /dev/null )

	    if [ -z "$flFolder" ]; then
		echo "Cannot find folder."
		return 1
	    elif [ ! -d "$flFolder" ]; then
		echo -e "Multiple folders and files found; use the absolute path.\n"
		echo -e "\e[31mFolders/files found:\e[0m\n$flFolder"
		return 2
	    fi

	    echo "Full path: $flFolder"
	fi

	echo -e "\n\e[31mContain file(s):\e[0m"
	ls -1 "$flFolder"

	return 0
}

# Print a string of read, write and/or execute if the corresponding flags are found.
# Arguments:
# 	1. Permission flags:	rwx-r-xr--
# 	2. Section:		u, g or o
function flag_print {

	if [ "$2" = "u" ]; then
		fpSec=1
	elif [ "$2" = "g" ]; then
		fpSec=4
	elif [ "$2" = "o" ]; then
		fpSec=7
	else
		echo "Invalid flag option."
		return 1
	fi

	fpPerm="-"

	# Read.
	if [ ${1:$fpSec:1} = "r" ]; then
		fpPerm="read"
	fi

	# Write.
	if [ ${1:$(($fpSec + 1)):1} = "w" ]; then
		if [ "$fpPerm" != "-" ]; then
			fpPerm="${fpPerm}, write"
	      	else
			fpPerm="write"
	    	fi
	fi

	# Execute.
	if [ ${1:$(($fpSec + 2)):1} = "x" ] || [ ${1:$(($fpSec + 2)):1} = "s" ] || [ ${1:$(($fpSec + 2)):1} = "t" ]; then
		if [ "$fpPerm" != "-" ]; then
			fpPerm="${fpPerm}, execute"
	      	else
			fpPerm="execute"
	  	fi
	fi

	echo "$fpPerm"

	return 0
}

# Print menu of Folder View, which list a folder's attributes. Either the absolute path or the folder's name can be used (initiates a search).
function folder_view {
	system_manager
	echo "                       Folder View"
	echo "Info:"
	echo "List a folder's attributes. Specify either the absolute path"
	echo "or the folder's name (initiates a search)."
	echo "------------------------------------------------------------"

	# Directory search/test.
	echo -n "Folder: "
	read fvFolder

	if [ -z "$fvFolder" ]; then
	    echo "Need an input."
	    return 1
	fi

	# Search / check folder name.
	if [ ! -d "$fvFolder" ]; then
	    fvFolder=$(find "/" -name $fvFolder 2> /dev/null )

	    if [ -z "$fvFolder" ]; then
		echo "Cannot find folder."
		return 1
	    elif [ ! -d "$fvFolder" ]; then
		echo -e "Multiple folders and files found; use the absolute path.\n"
		echo -e "\e[31mFolders/files found:\e[0m\n$fvFolder"
		return 2
	    fi

	    echo "Full path: $fvFolder"
	fi

	# Owner
	fvOwner=$(ls -ld $fvFolder | awk '{print $3}')
	echo -e "\e[31m\nOwner:\e[0m\t$fvOwner"

	# Permissions
	fvFlags=$(ls -ld $fvFolder | awk '{print $1}')

	echo -ne "\e[31mUser permissions:\e[0m\t"
	flag_print "$fvFlags" u

	echo -ne "\e[31mGroup permissions:\e[0m\t"
	flag_print "$fvFlags" g

	echo -ne "\e[31mOther permissions:\e[0m\t"
	flag_print "$fvFlags" o

	# Sticky Bit.
	if [ ${fvFlags:9:1} = "T" ] || [ ${fvFlags:9:1} = "t" ]; then
		echo -e "\e[31mSticky bit:\e[0m\ton"
	else
		echo -e "\e[31mSticky bit:\e[0m\toff"
	fi

	#Setgid.
	if [ ${fvFlags:6:1} = "S" ] || [ ${fvFlags:6:1} = "s" ]; then
	    	echo -e "\e[31mSetgid:\e[0m\ton"
	else
	    	echo -e "\e[31mSetgid:\e[0m\toff"
	fi

	# Modified.
	fvModified=$(ls -ld $fvFolder | awk '{print $6, $7 ", " $8}')
	echo -e "\e[31mModified:\e[0m\t$fvModified"

	return 0
}

# Change the owner of the folder.
function set_owner {
	echo -n "New owner: "
	read soNewOwner

	if id -u "$soNewOwner" &> /dev/null; then
		chown "$soNewOwner" "$1" && echo "Owner successfully changed." || echo "Could not change owner." 
	else
		echo "User does not exist."
	fi

	return 0
}

# Change a folder's read, write, execute, setuid, setgid or sticky bit permissions.
# Arguments:
#	1. Path to folder:	/home/anders/Documents
#	2. Section flag: 	u, g or o
#	3. Permission: 		r, w, x, s or t
#	4. Action:		on, off
function set_permissions {
  	if [ "$4" = "on" ]; then
      		chmod "$2"+"$3" "$1"
    	elif [ "$4" = "off" ]; then
        	chmod "$2"-"$3" "$1"
    	else
      		echo "Invalid option - no change occured."
		return 1
  	fi

	echo "Permission changed."

	return 0
}

# Print the sub-menu of "Permissions".
function menu_permissions {
	system_manager
	echo "               Folder Modify - Permissions"
	echo "Info:"
	echo "Specify which group to change permissions in, then specify"
	echo "the changes you want to make."
	echo ""
	echo "Section options:"
	echo -e "\e[31mu\e[0m - User"
	echo -e "\e[31mg\e[0m - Group"
	echo -e "\e[31mo\e[0m - Other"
	echo "------------------------------------------------------------"
	echo -e "\e[31mActive folder:\e[0m "$1""

	# Select group.
  	echo -n "Choice: "
  	read mpSecChoice

	if [ -z "$mpSecChoice" ]; then
	    echo "Need an input."
	    return 1
	fi

  	if [ "$mpSecChoice" != "u" ] && [ "$mpSecChoice" != "g" ] && [ "$mpSecChoice" != "o" ]; then
      		echo "Invalid option."
      		return 1
  	fi

	# Read permission.
  	echo -en "\e[31mRead (on/off):\e[0m "
	read mpChoice
	set_permissions $1 $mpSecChoice r $mpChoice

	# Write permission.
  	echo -en "\e[31Write (on/off):\e[0m "	
	read mpChoice
	set_permissions $1 $mpSecChoice w $mpChoice

	# Execute permission.
  	echo -en "\e[31Execute (on/off):\e[0m "
	read mpChoice
	set_permissions $1 $mpSecChoice x $mpChoice
 
	return 0
}

# Print the menu of "Folder Modify"
function folder_modify {
	system_manager
	echo "                       Folder Modify"
	echo "Info:"
	echo "Specify a folder to modify, then specify the change you"
	echo "want to make."
	echo ""
	echo "Change options:"
	echo -e "\e[31mow\e[0m - Owner"
	echo -e "\e[31mpm\e[0m - Permissions"
	echo -e "\e[31msb\e[0m - Sticky bit"
	echo -e "\e[31msg\e[0m - Setgid"
	echo "------------------------------------------------------------"

	echo -n "Folder: "
	read fmFolder

	if [ -z "$fmFolder" ]; then
	    echo "Need an input."
	    return 1
	fi

	# Search / check folder name.
	if [ ! -d "$fmFolder" ]; then
		fmFolder=$(find "/" -name $fmFolder 2> /dev/null )

		if [ -z "$fmFolder" ]; then
			echo -e "Cannot find folder."
			return 1
		elif [ ! -d "$fmFolder" ]; then
			echo -e "Multiple folders and files found; use the absolute path.\n"
			echo -e "\e[31mFolders/files found:\e[0m\n$fmFolder"
			return 2
		fi

		echo "Full path: $fmFolder"
	fi

	echo -n "Change: "
	read fmChange

	case "$fmChange" in
	  	"ow")
	    		set_owner $fmFolder
	    		;;
	  	"pm")
	    		clear
			menu_permissions $fmFolder
	    		;;
		"sb")
			echo -en "\e[31mSticky bit (on/off):\e[0m "
  			read fmChoice
	    		set_permissions $fmFolder o t $fmChoice
	    		;;
	  	"sg")
	    		echo -en "\e[31mSetgid (on/off):\e[0m "
  			read fmChoice
	    		set_permissions $fmFolder g s $fmChoice
	    		;;
	  	*)
	    		echo -e "Selected option is not available."
	esac

	return 0
}

# Remove a specified folder and its subfolders.
function folder_delete {
	system_manager
	echo "                    Folder Delete"
	echo "Info:"
	echo "Remove a specified folder and its subfolders. Specify either"
	echo "the absolute path, or enter the folder name to initate"
	echo "a search."
	echo "------------------------------------------------------------"

	echo -n "Folder: "
	read fdFolder

	if [ -z "$fdFolder" ]; then
	    echo "Need an input."
	    return 1
	fi

	# Search / check folder name.
	if [ ! -d "$fdFolder" ]; then
	    	fdFolder=$(find "/" -name $fdFolder 2> /dev/null )

	    	if [ -z "$fdFolder" ]; then
			echo -e "Cannot find folder."
			return 2
	    	elif [ ! -d "$fdFolder" ]; then
			echo -e "Multiple folders and files found; use the absolute path.\n"
			echo -e "\e[31mFolders/files found:\e[0m\n$fdFolder"
			return 3
	    	fi

	    	echo "Full path: $fdFolder"
	    	echo -en "Remove directory (y/n)? "
	    	read choice

	    	if [ "$choice" != "y" ]; then
			echo "Cancelled removal."
			return 1
	    	fi
	fi

	rm -r "$fdFolder" && echo "Folder successfully removed." || echo "Could not remove folder."

	return 0
}

# Decide if install/uninstall/start/stop ssh
function ssh {
        system_manager
        echo "                       SSH menu"
	echo "Info:"
	echo "Manage SSH options."
	echo ""
	echo "SSH  options:"
        echo -e "\033[31mst\e[0m - Start"
        echo -e "\033[31msp\e[0m - Stop"
        echo -e "\033[31min\e[0m - Install"
        echo -e "\033[31mun\e[0m - Uninstall"
        echo -e "\033[31mse\e[0m - Status"
        echo "------------------------------------------------------------"
        echo -n "Choice: " 
        read sshChoice

	#Case with each ssh option
        case $sshChoice in
                st )
                        service ssh start && echo "SSH sccessfully started." || echo "Failed to start SSH."
                        ;;
                sp )
                        service ssh stop && echo "SSH successfully stopped."
                        ;;
                in )	#update database and install ssh-server
			echo "------------------------------------------------------------"
                        apt update
                        apt install openssh-server && echo "SSH successfully installed." || echo "SSH did not install"
                        ;;
                un )
			echo "------------------------------------------------------------"
                        apt-get purge openssh-client && echo "SSH successfully removed." || echo "SSH not removed"
                        ;;
                se ) #show ssh serv
                        service ssh status
                        ;;
		* )
			echo "Invalid option."
        esac

	return 0
}

# Exit function, shuts down the script.
function exit_program {
	system_manager
	echo -n "Exit the program (y/n)?: "
	read exitScript
	if [ $exitScript = "y" ]; then
		clear
		exit 0
	else
   		echo "Returning to the main menu."
	fi
	return 0
}

# The main program iteration.
function main_menu {
	 while true; do
		clear
		system_manager
		list
		echo "------------------------------------------------------------"
		echo -n "Choice: "
		read choice
		option $choice
		echo "------------------------------------------------------------"
		echo "Press enter to continue..."
		read paus
	done
}

main_menu
