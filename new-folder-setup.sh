#!/bin/bash

# Define the source folder
SOURCE_FOLDER=~/Documents/CASES/BASIC
sleep 1
# Prompt for the new folder name
read -p "Enter the new folder name: " NEW_FOLDER_NAME

# Expand the ~ to the full home directory path
SOURCE_FOLDER=$(eval echo "$SOURCE_FOLDER")

# Get the parent directory of the source folder
PARENT_DIR=$(dirname "$SOURCE_FOLDER")

# Define the full path for the new folder
NEW_FOLDER_PATH="$PARENT_DIR/$NEW_FOLDER_NAME"

# Check if the source folder exists
if [ ! -d "$SOURCE_FOLDER" ]; then
    echo "Source folder does not exist: $SOURCE_FOLDER"
    exit 1
fi

# Create the new folder if it doesn't exist
if [ ! -d "$NEW_FOLDER_PATH" ]; then
    mkdir -p "$NEW_FOLDER_PATH"
    echo "Created new folder: $NEW_FOLDER_PATH"
else
    echo "Folder already exists: $NEW_FOLDER_PATH"
fi

# Copy files and folders from the source folder to the new folder
cp -r "$SOURCE_FOLDER"/* "$NEW_FOLDER_PATH"

echo "Files and folders copied successfully."
sleep 1
read -p "Enter the image version: " IMAGE_VERSION

cd $NEW_FOLDER_PATH
compose_file="docker-compose.yaml"

if [ ! -f "$compose_file" ]; then
    echo "Docker Compose file not found: $compose_file"
    exit 1
fi

# Update the Docker Compose file
echo "Updating Docker Compose file..."

# Use sed to replace ${IMAGE_VERSION} with the user input
sed -i.bak \
    -e "s|\${IMAGE_VERSION}|$IMAGE_VERSION|g" \
    "$compose_file"

echo "Docker Compose file updated successfully."

sleep 1


# Define the parent directory
parent_dir="$NEW_FOLDER_PATH/.."

# Check if the directory exists
if [ ! -d "$parent_dir" ]; then
    echo "The specified directory does not exist."
    exit 1
fi


# Get the second most recent directory
second_most_recent=$(ls -l "$parent_dir" | grep '^d' | awk '{print $NF}' | sort -r | sed -n '3p')


deck gateway dump -o ~/Documents/CASES/$second_most_recent/$second_most_recent-deck.yaml --headers 'kong-admin-token:password'

echo "The deck dump is stored under directory: $second_most_recent"

# Prompt user to confirm container removal
read -p "Do you want to remove old running kong containers? [y/n]: " confirm_remove


# Check user input
if [[ "$confirm_remove" == "y" ]]; then
    # Remove containers
    echo "Removing containers..."
    docker rm kong-cp kong-dp kong-db keycloak httpbin httpbin-1 -f

    # Check if containers are successfully removed
    if [[ $? -ne 0 ]]; then
        echo "Failed to remove containers. Exiting."
        exit 1
    fi
elif [[ "$confirm_remove" == "n" ]]; then
    echo "Skipping container removal."
else
    echo "Invalid input. Exiting."
    exit 1
fi


sleep 2
echo "Cleaning up Docker system..."
docker system prune -f
sleep 2
#echo "Starting Docker Compose services..."
#docker-compose up -d

echo "Starting Docker Compose services..."
docker-compose up -d > /dev/null 2>&1
sleep 5
# Check if Docker Compose started successfully
if [ $? -ne 0 ]; then
    echo "Failed to start Docker Compose services."
    exit 1
fi

echo "Docker Compose services started successfully."
sleep 1
echo "Done.. Happy Learning!!"
