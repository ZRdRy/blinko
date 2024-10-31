#!/bin/bash

# Colors for better visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Set GitHub URL for the docker-compose file
github_url="https://raw.githubusercontent.com/blinko-space/blinko/refs/heads/main/docker-compose.prod.yml"
compose_file="docker-compose.prod.yml"

# Step 1: Remove existing Docker image and container
echo -e "${YELLOW}1. 🗑 Removing existing blinkospace/blinko Docker image...${NC}"
docker rmi blinkospace/blinko:latest -f

if [ $? -ne 0 ]; then
  echo -e "${RED}Failed to remove Docker image. It may not exist or there may be an issue with Docker.${NC}"
else
  echo -e "${GREEN}Successfully removed Docker image: blinkospace/blinko:latest${NC}"
fi

echo -e "${YELLOW}1. 🗑 Removing existing blinko-website container...${NC}"
docker rm blinko-website -f

if [ $? -ne 0 ]; then
  echo -e "${RED}Failed to remove Docker container. It may not exist or there may be an issue with Docker.${NC}"
else
  echo -e "${GREEN}Successfully removed Docker container: blinko-website${NC}"
fi

# Step 2: Fetch docker-compose file using curl
echo -e "${YELLOW}2. ✅ Fetching docker-compose file from GitHub...${NC}"
curl -o $compose_file $github_url

if [ $? -ne 0 ]; then
  echo -e "${RED}Failed to download the docker-compose file. Please check your internet connection or the GitHub URL.${NC}"
  exit 1
fi
echo -e "${GREEN}Successfully downloaded docker-compose file: $compose_file${NC}"

# Default environment variables
NEXTAUTH_URL_DEFAULT="http://localhost:1111"
NEXT_PUBLIC_BASE_URL_DEFAULT="http://localhost:1111"

# Step 3: Ask user if they want to change NEXTAUTH_URL
echo -e "${YELLOW}3. ❓ Configuring NEXTAUTH_URL...${NC}"
read -p "Do you want to change NEXTAUTH_URL from the default ($NEXTAUTH_URL_DEFAULT)? [y/N]: " change_nextauth_url
if [[ "$change_nextauth_url" == "y" || "$change_nextauth_url" == "Y" ]]; then
  read -p "Enter new NEXTAUTH_URL: " NEXTAUTH_URL
else
  NEXTAUTH_URL=$NEXTAUTH_URL_DEFAULT
fi

# Step 4: Ask user if they want to change NEXT_PUBLIC_BASE_URL
echo -e "${YELLOW}4. ❓ Configuring NEXT_PUBLIC_BASE_URL...${NC}"
read -p "Do you want to change NEXT_PUBLIC_BASE_URL from the default ($NEXT_PUBLIC_BASE_URL_DEFAULT)? [y/N]: " change_next_public_base_url
if [[ "$change_next_public_base_url" == "y" || "$change_next_public_base_url" == "Y" ]]; then
  read -p "Enter new NEXT_PUBLIC_BASE_URL: " NEXT_PUBLIC_BASE_URL
else
  NEXT_PUBLIC_BASE_URL=$NEXT_PUBLIC_BASE_URL_DEFAULT
fi

# Step 5: Update the docker-compose file with the chosen environment variables
echo -e "${YELLOW}5. ✏ Updating environment variables in $compose_file...${NC}"
sed -i "s|NEXTAUTH_URL:.*|NEXTAUTH_URL: $NEXTAUTH_URL|" $compose_file
sed -i "s|NEXT_PUBLIC_BASE_URL:.*|NEXT_PUBLIC_BASE_URL: $NEXT_PUBLIC_BASE_URL|" $compose_file

echo -e "${GREEN}Environment variables updated successfully.${NC}"

# Step 6: Run the docker-compose file
echo -e "${YELLOW}6. ⏳ Starting the Docker Compose setup without PostgreSQL...${NC}"
docker-compose -f $compose_file up -d blinko-website

if [ $? -ne 0 ]; then
  echo -e "${RED}Failed to start Docker Compose. Please check the docker-compose file and your Docker setup.${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Docker Compose is up and running.${NC}"
