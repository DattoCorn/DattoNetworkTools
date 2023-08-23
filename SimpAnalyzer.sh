#!/bin/sh
# Path to the local jq binary in the same directory as the script
JQ_PATH="./jq-Linux64"

# Download the JSON file to /tmp
curl -o /tmp/Vendors.json https://raw.githubusercontent.com/DattoCorn/DattoNetworkTools/main/Vendors.json --insecure
curl -L -o /tmp/jq-Linux64 https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 --insecure
chmod +x /tmp/jq-Linux64

# Retrieve the ARP table
ARP_TABLE=$(cat /proc/net/arp)

# Print the custom column headers
printf "----------------------Simp Tool V3.5------------------------\n"
printf "%-15s %-17s %-12s %-15s\n" "IP Address" "HW Address" "Device" "Vendor"
printf "---------------------------------------------------------\n"

# Iterate over each line in the ARP table
echo "$ARP_TABLE" | while read -r line
do
  IP_ADDRESS=$(echo "$line" | awk '{print $1}')
  MAC_ADDRESS=$(echo "$line" | awk '{print $4}')
  DEVICE=$(echo "$line" | awk '{print $6}')
  
  # Extract the first 6 characters of the MAC address and convert to uppercase
  MAC_PREFIX=$(echo "$MAC_ADDRESS" | cut -d ":" -f 1-3 | tr '[:lower:]' '[:upper:]')
  
  # Search for the MAC prefix in the JSON file and extract the vendor name using the local jq binary
  VENDOR_NAME=$($JQ_PATH -r --arg MAC_PREFIX "$MAC_PREFIX" '.vendors[] | select((.pattern | ascii_upcase) | contains($MAC_PREFIX | ascii_upcase)) | .name' /tmp/Vendors.json)
  if [ -z "$VENDOR_NAME" ]; then
    VENDOR_NAME="Unknown"
  fi
  
  # Output the custom formatted information for matched MAC address prefixes
  printf "%-15s %-17s %-12s %-15s\n" "$IP_ADDRESS" "$MAC_ADDRESS" "$DEVICE" "$VENDOR_NAME"
done
