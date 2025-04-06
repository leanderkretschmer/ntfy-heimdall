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

# Docker Container überwachen
CURRENT_DOCKER_STATUS=$(get_docker_status)

# Write current status to file with timestamp
echo "#######################################################" >> "$STATUS_FILE"
echo "#               Aktueller Status - $(date +'%H:%M')              #" >> "$STATUS_FILE"
echo "#######################################################" >> "$STATUS_FILE"
echo "" >> "$STATUS_FILE"

echo "$CURRENT_DOCKER_STATUS" | while read line; do
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
fi

exit 0
