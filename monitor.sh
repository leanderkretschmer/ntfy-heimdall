#!/bin/bash

# Configuration
NTFY_TOPIC="ntfy-chat"
STATUS_FILE="/path/to/ntfy/status.txt"
BLACKLIST_FILE="/path/to/ntfy/blacklist.txt"

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

# Main script
# 1. Rotate the old status file (delete if it exists, then rename)
if [ -f "$STATUS_FILE.old" ]; then
  rm -f "$STATUS_FILE.old"
fi

if [ -f "$STATUS_FILE" ]; then
  mv "$STATUS_FILE" "$STATUS_FILE.old"
fi

# 2. Create and populate the new status file
touch "$STATUS_FILE"

# Get current status
CURRENT_PROXMOX_STATUS=$(get_proxmox_status)
CURRENT_DOCKER_STATUS=$(get_docker_status)

# Combine the status
CURRENT_STATUS="$CURRENT_PROXMOX_STATUS
$CURRENT_DOCKER_STATUS"

# Write current status to file with timestamp
echo "#######################################################" >> "$STATUS_FILE"
echo "#               Aktueller Status - $(date +'%H:%M')              #" >> "$STATUS_FILE"
echo "#######################################################" >> "$STATUS_FILE"
echo "" >> "$STATUS_FILE"

echo "$CURRENT_STATUS" | while read line; do
  create_db_entry "$line" >> "$STATUS_FILE"
done

echo "" >> "$STATUS_FILE"
echo "#######################################################" >> "$STATUS_FILE"

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

exit 0
