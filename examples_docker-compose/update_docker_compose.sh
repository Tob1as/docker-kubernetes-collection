#!/bin/sh

# Directory containing the Docker-Compose files
COMPOSE_DIR="/data"

# Check if the script is executed in the correct directory
CURRENT_DIR=$(pwd)
if [ "$CURRENT_DIR" != "$COMPOSE_DIR" ]; then
  echo "The script is not being executed in the correct directory. Changing to $COMPOSE_DIR ..."
  if ! cd "$COMPOSE_DIR"; then
    echo "Error: Unable to change to directory $COMPOSE_DIR."
    exit 1
  fi
fi

# Services to be updated (from parameter)
INCLUDE_FILES="$1"

# If no parameter is provided, process all .yml files
if [ -z "$INCLUDE_FILES" ]; then
  echo "No parameters provided. Updating all services."
  INCLUDE_FILES="*"
else
  # Convert comma-separated list into space-separated pattern for file matching
  INCLUDE_FILES=$(echo "$INCLUDE_FILES" | sed 's/,/ /g')
fi

# Iterate over the specified or all .yml files
for COMPOSE_FILE in *.yml; do
  # Extract the base name of the current file without extension
  BASE_NAME=$(basename "$COMPOSE_FILE" .yml)

  # Check if the file is included in INCLUDE_FILES (only if specific parameters are provided)
  if [ "$INCLUDE_FILES" != "*" ] && ! echo "$INCLUDE_FILES" | grep -qw "$BASE_NAME"; then
    echo "Skipping $COMPOSE_FILE (not in the provided list)."
    continue
  fi

  # Always execute the pull command
  echo "Updating images for $COMPOSE_FILE ..."
  docker compose -f "$COMPOSE_FILE" -p "$BASE_NAME" pull

  # Check if any service from the compose file is currently running
  RUNNING_CONTAINERS=$(docker compose -f "$COMPOSE_FILE" -p "$BASE_NAME" ps -q | xargs -r docker inspect --format '{{.State.Running}}' 2>/dev/null | grep -c true)

  if [ "$RUNNING_CONTAINERS" -gt 0 ]; then
    echo "Some services are running. Restarting $COMPOSE_FILE ..."
    docker compose -f "$COMPOSE_FILE" -p "$BASE_NAME" up -d

    if [ $? -ne 0 ]; then
      echo "An error occurred while processing $COMPOSE_FILE."
      exit 1
    fi
  else
    echo "Skipping restart for $COMPOSE_FILE (no services are running)."
  fi
done

echo "The specified Docker-Compose files have been successfully updated."
