#!/bin/bash

# Configuration
NTFY_TOPIC="ntfy-chat"
STATUS_FILE="/path/to/ntfy/status.txt"
BLACKLIST_FILE="/path/to/ntfy/blacklist.txt"
DISK_CONFIG_FILE="/path/to/ntfy/disk_config.txt"
# Function to send a notification
send_notification() {
  message="$1"
  curl -d "$message" "ntfy.sh/$NTFY_TOPIC"
}

# Function to create the database entries
create_db_entry() {
  echo "$1-$2-$(date +'%H:%M')"
}

# Monitor Proxmox VMs
get_proxmox_status() {
  qm list | sed 1d | while IFS= read -r line; do
    vm_id=$(echo "$line" | awk '{print $1}')
    vm_name=$(echo "$line" | awk '{print $2}')
    vm_status=$(echo "$line" | awk '{print $3}')

    # Check if the VM is blacklisted
    if grep -q "$vm_name" "$BLACKLIST_FILE"; then
      continue
    fi

    # Determine the cleartext status
    case "$vm_status" in
      running)
        status_text="running"
        ;;
      stopped)
        status_text="stopped"
        ;;
      *)
        status_text="unknown"
        ;;
    esac
# ECHO NACH OBEN VERSCHOBEN
   echo "proxmox-$vm_name-$status_text"
  done
}

# Docker Container überwachen
get_docker_status() {
  docker ps --format "{{.Names}} {{.Status}}" | while read container_name container_status; do
    # Check if the container is blacklisted
    if grep -q "$container_name" "$BLACKLIST_FILE"; then
      continue
    fi

    # Extract the actual status from the container status
    if [[ "$container_status" == Up* ]]; then
      status_text="running"
    elif [[ "$container_status" == Exited* ]]; then
      status_text="stopped"
    elif [[ "$container_status" == Restarting* ]]; then
      status_text="restarting"
    else
      status_text="unknown"
    fi
# ECHO NACH OBEN VERSCHOBEN
   echo "docker-$container_name-$status_text"
  done
}

# Function to get disk space
get_disk_space() {
  local path="$1"
  local threshold_mb="$2"
  local threshold_gb=$(echo "scale=2; $threshold_mb / 1024" | bc)

  # Get the free disk space in GB
  free_space_kb=$(df -k "$path" | awk 'NR==2{print $4}')
  free_space_gb=$(echo "scale=2; $free_space_kb / 1048576" | bc)

  # Check if the free space is below the threshold
  if (( $(echo "$free_space_gb < $threshold_gb" | bc -l) )); then
    message="Warning: Disk space on $path is running low ($free_space_gb GB < $threshold_gb GB)"
    send_notification "$message"
  fi

  #Logge Speicherplatz in Datei
  echo "Diskspace-$path-$free_space_gb GB"
}

# Main script

# Ausgabe des ASCII Art Banners
echo "#####################################################"
echo "" 
echo "+---------------------------------------------------+"
echo "|  _   _ _____ ___ __  __ ____    _    _     _      |"
echo "| | | | | ____|_ _|  \\/  |  _ \\  / \\  | |   | |     |"
echo "| | |_| |  _|  | || |\\/| | | | |/ _ \\ | |   | |     |"
echo "| |  _  | |___ | || |  | | |_| / ___ \\| |___| |___  |"
echo "| |_| |_|_____|___|_|  |_|____/_/   \\_\\_____|_____| |"
echo "+---------------------------------------------------+"
echo ""

# 1. Rotate the old status file (delete if it exists, then rename)
if [ -f "$STATUS_FILE.old" ]; then
  rm -f "$STATUS_FILE.old"
fi

if [ -f "$STATUS_FILE" ]; then
  mv "$STATUS_FILE" "$STATUS_FILE.old"
fi

# 2. Create and populate the new status file
touch "$STATUS_FILE"

# VMs und Docker Container überwachen
CURRENT_PROXMOX_STATUS=$(get_proxmox_status)
CURRENT_DOCKER_STATUS=$(get_docker_status)

# Write current status to file with timestamp
echo "#####################################################"
echo "" >> "$STATUS_FILE"
echo "                Aktueller Status - $(date +'%H:%M')             " >> "$STATUS_FILE"
echo "" >> "$STATUS_FILE"

echo "$CURRENT_PROXMOX_STATUS" | while read line; do
  create_db_entry "$line" >> "$STATUS_FILE"
done

echo "$CURRENT_DOCKER_STATUS" | while read line; do
  create_db_entry "$line" >> "$STATUS_FILE"
done

# Read the disk configuration file and check the disk space
if [ -f "$DISK_CONFIG_FILE" ]; then
  # Read all lines from the DISK_CONFIG_FILE into an array
  DISK_CONFIG_LINES=($(cat "$DISK_CONFIG_FILE"))
  # Iterate over the lines
  for LINE in "${DISK_CONFIG_LINES[@]}"; do
    # Skip comments and empty lines
    if [[ "$LINE" =~ ^[[:space:]]*#.* ]] || [[ -z "$LINE" ]]; then
      continue
    fi
    # Split the line into path and threshold
    IFS='=' read -r path threshold <<< "$LINE"
    # Log disk space
    create_db_entry "$(get_disk_space "$path" "$threshold")" >> "$STATUS_FILE"
  done
fi
echo "" >> "$STATUS_FILE"
echo "#####################################################" >> "$STATUS_FILE"

# 3. Änderungen erkennen und Benachrichtigungen senden
if [ -f "$STATUS_FILE.old" ]; then
  # Get the list of docker containers from the old status file
  OLD_DOCKER_CONTAINERS=$(grep "^docker-" "$STATUS_FILE.old" | cut -d'-' -f2)

  # Get the list of docker containers from the current status
  CURRENT_DOCKER_CONTAINERS=$(echo "$CURRENT_DOCKER_STATUS" | cut -d'-' -f2)

  # Find the containers that are in the current status but not in the old status
  for NEW_CONTAINER in $CURRENT_DOCKER_CONTAINERS; do
    # Check if the container is blacklisted
    if grep -q "$NEW_CONTAINER" "$BLACKLIST_FILE"; then
      continue
    fi

    if ! echo "$OLD_DOCKER_CONTAINERS" | grep -q "$NEW_CONTAINER"; then
      # The container is now running
      message="Container $NEW_CONTAINER is back Online"
      send_notification "$message"
    fi
  done

  # Find the containers that are in the old status file but not in the current status
  for OLD_CONTAINER in $OLD_DOCKER_CONTAINERS; do
    # Check if the container is blacklisted
    if grep -q "$OLD_CONTAINER" "$BLACKLIST_FILE"; then
      continue
    fi

    if ! echo "$CURRENT_DOCKER_CONTAINERS" | grep -q "$OLD_CONTAINER"; then
      # The container is stopped
      message="Container $OLD_CONTAINER just went offline"
      send_notification "$message"
    fi
  done

  # Rest der alten Logik für VMs (unverändert)
  while IFS= read -r new_line; do
    new_parts=(${new_line//-/ }) # Split the line by "-"
    new_type=${new_parts[0]}      # proxmox or docker
    new_name=${new_parts[1]}      # VM or container name
    new_status=${new_parts[2]}    # running, stopped, restarting, etc.
    new_time=$(echo $new_parts[3] $new_parts[4])      # Timestamp

    # Find the old status
    old_line=$(grep "^${new_type}-${new_name}-" "$STATUS_FILE.old")
    if [ -n "$old_line" ]; then
      old_parts=(${old_line//-/ })
      old_status=${old_parts[2]}
      # If is not the docker part

      # If the status has changed and the last broadcasted status is different...
      if [ "$new_status" != "$old_status" ]; then
        # Create the notification
        if [[ "$new_type" == "proxmox" ]]; then
          type="VM"
        else
          type="Container"
        fi
        if [[ "$new_status" == "stopped" ]]; then
          message="$type $new_name just went offline, was last seen online at ${old_parts[3]:11:8}"
        else
          message="$type $new_name is now $new_status"
        fi

        # Send the notification (not as a file!)
        send_notification "$message"
      fi
    fi
  done < "$STATUS_FILE"
fi

echo ""
echo "for updates and new versions visit" 
echo "https://github.com/leanderkretschmer/ntfy-heimdall"

exit 0
