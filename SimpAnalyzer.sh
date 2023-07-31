#!/bin/sh

# Download the JSON file to /tmp folder
curl -o /tmp/Vendors.json https://raw.githubusercontent.com/DattoCorn/DattoNetworkTools/main/Vendors.json

# Retrieve the ARP table
ARP_TABLE=$(cat /proc/net/arp)

# Function to get vendor name from the JSON file
get_vendor_name() {
  MAC=$1
  MAC_PREFIX=$(echo "$MAC" | cut -d ":" -f 1-3)
  VENDOR_NAME=$(jq -r --arg mac "$MAC_PREFIX" '.[$mac]' /tmp/Vendors.json)
  echo "$VENDOR_NAME"
}

# Print the custom column headers
printf "----------------------Simp Tool V1------------------------\n"
printf "%-15s %-17s %-12s %-15s\n" "IP Address" "HW Address" "Device" "Vendor"
printf "---------------------------------------------------------\n"

# Inside the loop...
echo "$ARP_TABLE" | while read -r line
do
  IP_ADDRESS=$(echo "$line" | awk '{print $1}')
  MAC_ADDRESS=$(echo "$line" | awk '{print $4}')
  DEVICE=$(echo "$line" | awk '{print $6}')
  
  # Check if the MAC address matches the specified patterns
  VENDOR_NAME=$(get_vendor_name "$MAC_ADDRESS")
  
  # Output the custom formatted information for matched MAC address prefixes
  printf "%-15s %-17s %-12s %-15s\n" "$IP_ADDRESS" "$MAC_ADDRESS" "$DEVICE" "$VENDOR_NAME"
done
