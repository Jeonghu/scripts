#!/bin/bash
# Check if backup.sh exists in this directory
if [ -e "backup.sh" ]; then echo "Backup script precent"; exit; fi
# User anwser array
a=()
# Prompts
p=(	"Username: "
	"Password: "
	"Specify remote share ie //server/share "
	"Specify mountoint for said share ie /backup "
	"Specify what you want to back up "
)
# Loops until user has anwsered to propmpts and populates anwser array
for i in ${!p[*]}; do
	echo -n "${p[i]}"; read a[i]
done

# Writes actual ready to use script using provided data
cat << EOF > backup.sh
#!/bin/bash
# Mounts remote share to specified mountpoint using provided credentials
sudo mount -t cifs -o username=${a[0]},password=${a[1]} ${a[2]} ${a[3]}
# Launches rsync with archive, verbose, partial progress and delete flags (matches remote destination to local one.)
sudo rsync -avP --delete ${a[4]} ${a[3]}
# Unmounts remote share from local system
sudo umount ${a[3]}
EOF

# Gives owner rwx privileges and removes everyone elses
chmod 700 backup.sh