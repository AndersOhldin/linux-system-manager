A bash-script that offers an interactable UI aimed to manage a Linux system, including but not limited to: 
- List active users with UID less than 2000
- Modify an existing user
- Create a group based on input
- List all groups (excluding system groups)
- List all users in a group
- Add a user to an existing group
- Remove a user's association to an existing group
- Add or remove a user from a group
- Change a folder's read, write, execute, setuid, setgid or sticky bit permissions
- Install/uninstall/start/stop SSH

Known flaws: This was written as a group project and in the final completion stages I strongly reacted to the SSH handling due to it creating a recursive loop... I am not sure if that ever got fixed.
