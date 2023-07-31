#!/bin/sh

# Download the JSON file to /tmp folder
curl -o /tmp/Vendors.json https://raw.githubusercontent.com/DattoCorn/DattoNetworkTools/main/Vendors.json

# Retrieve the ARP table
ARP_TABLE=$(cat /proc/net/arp)

# Function to get vendor name from the JSON file
get_vendor_name() {
  MAC=$1
  VENDOR_NAME=$(jq -r --arg mac "$MAC" '.[$mac]' /tmp/Vendors.json)
  echo "$VENDOR_NAME"
}

# Print the table header
printf "%-17s | %-25s | %s\n" "MAC Address" "Vendor" "Port"
printf "-----------------------------------+---------------------------+-----------------\n"

# Inside the loop...
echo "$ARP_TABLE" | while read -r line
do
  IP_ADDRESS=$(echo "$line" | awk '{print $1}')
  MAC_ADDRESS=$(echo "$line" | awk '{print $4}')
  DEVICE=$(echo "$line" | awk '{print $6}')
  
  # Extract the first 6 characters of the MAC address
  MAC_PREFIX=$(echo "$MAC_ADDRESS" | cut -d ":" -f 1-3)
  
  # Check if the MAC address matches the specified patterns
  VENDOR_NAME=$(get_vendor_name "$MAC_PREFIX")
  
  # Output the custom formatted information for matched MAC address prefixes
  printf "%-17s | %-25s | %s\n" "$MAC_ADDRESS" "$VENDOR_NAME" "$DEVICE"
done | column -t -s "|"
