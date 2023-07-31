#!/bin/sh

# Download the JSON file to /tmp
curl -o /tmp/Vendors.json https://raw.githubusercontent.com/DattoCorn/DattoNetworkTools/main/Vendors.json

# Retrieve the ARP table
ARP_TABLE=$(cat /proc/net/arp)

# Print the custom column headers
printf "----------------------Simp Tool V2------------------------\n"
printf "%-15s %-17s %-12s %-15s\n" "IP Address" "HW Address" "Device" "Vendor"
printf "---------------------------------------------------------\n"

# Iterate over each line in the ARP table
echo "$ARP_TABLE" | while read -r line
do
  IP_ADDRESS=$(echo "$line" | awk '{print $1}')
  MAC_ADDRESS=$(echo "$line" | awk '{print $4}')
  DEVICE=$(echo "$line" | awk '{print $6}')
  
  # Extract the first 6 characters of the MAC address
  MAC_PREFIX=$(echo "$MAC_ADDRESS" | cut -d ":" -f 1-3)
  
  # Check if the MAC address matches the patterns in the JSON file
  VENDOR_NAME="Unknown"
  PATTERN_LINE=$(grep -n "\"$MAC_PREFIX\"" /tmp/Vendors.json | cut -d : -f 1)
  if [ -n "$PATTERN_LINE" ]; then
    NAME_LINE=$((PATTERN_LINE + 1))
    VENDOR_NAME=$(sed -n "${NAME_LINE}p" /tmp/Vendors.json | grep -oP '"name":\s*"\K[^"]+')
  fi
  
  # Output the custom formatted information for matched MAC address prefixes
  printf "%-15s %-17s %-12s %-15s\n" "$IP_ADDRESS" "$MAC_ADDRESS" "$DEVICE" "$VENDOR_NAME"
done
