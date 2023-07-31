#!/bin/sh

# Download the JSON file to /tmp
curl -o /tmp/Vendors.json https://raw.githubusercontent.com/DattoCorn/DattoNetworkTools/main/Vendors.json

# Retrieve the ARP table
ARP_TABLE=$(cat /proc/net/arp)

# Print the custom column headers
printf "----------------------Simp Tool V1------------------------\n"
printf "%-15s %-17s %-12s %-15s\n" "IP Address" "HW Address" "Device" "Vendor"
printf "---------------------------------------------------------\n"

# Iterate over each line in the ARP table
echo "$ARP_TABLE" | while read -r line
do
  IP_ADDRESS=$(echo "$line" | awk '{print $1}')
  MAC_ADDRESS=$(echo "$line" | awk '{print $4}')
  DEVICE=$(echo "$line" | awk '{print $6}')
  
  # Extract the first 6 characters of the MAC address and convert to lowercase
  MAC_PREFIX=$(echo "$MAC_ADDRESS" | cut -d ":" -f 1-3 | tr '[:upper:]' '[:lower:]')
  
  # Search for the MAC prefix in the JSON file and extract the vendor name
  VENDOR_NAME="Unknown"
  VENDOR_ENTRY=$(cat /tmp/Vendors.json | grep -i -B 1 "\"pattern\": \"$MAC_PREFIX\"")
  if [ -n "$VENDOR_ENTRY" ]; then
    VENDOR_NAME=$(echo "$VENDOR_ENTRY" | grep -o '"name": "[^"]*' | cut -d '"' -f 4)
  fi
  
  # Output the custom formatted information for matched MAC address prefixes
  printf "%-15s %-17s %-12s %-15s\n" "$IP_ADDRESS" "$MAC_ADDRESS" "$DEVICE" "$VENDOR_NAME"
done
