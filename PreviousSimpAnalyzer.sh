#!/bin/sh

# Specify the MAC address patterns to match (first 6 characters) and their corresponding names
MAC_PATTERN1="f8:d9:b8"
MAC_PATTERN2="ac:86:74"
MAC_NAME1="Datto Devices"
MAC_NAME2="Vendor 2 Devices"

# Specify the MAC address patterns for Tuya Devices
TUYA_MAC_PATTERNS="10:5a:17|10:d5:61|18:69:d8|1c:90:ff|38:1f:8d|50:8a:06|68:57:2d|70:89:76|7c:f6:66|84:e3:42|a0:92:08|cc:8c:bf|d4:a6:51|d8:1f:12|fc:67:1f"
TUYA_MAC_NAME="Tuya Devices"

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
  
  # Extract the first 6 characters of the MAC address
  MAC_PREFIX=$(echo "$MAC_ADDRESS" | cut -d ":" -f 1-3)
  
  # Check if the MAC address matches the specified patterns
  MATCHED="N/A"
  VENDOR_NAME="Unknown"
  
  if [ "$(echo "$MAC_PREFIX" | grep -E "^($MAC_PATTERN1|$MAC_PATTERN2)$")" ]; then
    MATCHED="Matched"
    VENDOR_NAME="$MAC_NAME1"
  fi
  
  if [ "$(echo "$MAC_PREFIX" | grep -E "^($TUYA_MAC_PATTERNS)$")" ]; then
    MATCHED="Matched"
    VENDOR_NAME="$TUYA_MAC_NAME"
  fi
  
  # Output the custom formatted information for matched MAC address prefixes
  printf "%-15s %-17s %-12s %-15s\n" "$IP_ADDRESS" "$MAC_ADDRESS" "$DEVICE" "$VENDOR_NAME"
done
