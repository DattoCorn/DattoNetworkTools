#!/bin/sh
echo "Simp Analyzer 1.3"

# Check device model
if cat /etc/datto/model >/dev/null 2>&1; then
    model=$(cat /etc/datto/model)
else
    model="D200"
fi

# Decide which jq binary to use based on the model
if [ "$model" = "D200" ]; then
    JQ_PATH="jq"
else
    JQ_PATH="./jq-Linux64"
fi

# Download the JSON file to /tmp
curl -k -o /tmp/Vendors.json https://raw.githubusercontent.com/DattoCorn/DattoNetworkTools/main/Vendors.json
curl -k -L -o /tmp/jq-Linux64 https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
chmod +x /tmp/jq-Linux64

# Retrieve the ARP table
ARP_TABLE=$(cat /proc/net/arp)

# Print the custom column headers
printf "----------------------Simp Tool V1.3------------------------\n"
printf "%-15s %-17s %-12s %-15s %-30s\n" "IP Address" "HW Address" "Device" "Vendor" "Potential Problems"
printf "----------------------------------------------------------------------------------------------\n"

# Iterate over each line in the ARP table
echo "$ARP_TABLE" | while read -r line
do
  IP_ADDRESS=$(echo "$line" | awk '{print $1}')
  MAC_ADDRESS=$(echo "$line" | awk '{print $4}')
  DEVICE=$(echo "$line" | awk '{print $6}')
  
  # Extract the first 6 characters of the MAC address and convert to uppercase
  MAC_PREFIX=$(echo "$MAC_ADDRESS" | cut -d ":" -f 1-3 | tr '[:lower:]' '[:upper:]')
  
  # Search for the MAC prefix in the JSON file and extract the vendor name and potential problems using the jq binary
  VENDOR_DATA=$($JQ_PATH -r --arg MAC_PREFIX "$MAC_PREFIX" '.vendors[] | select((.pattern | ascii_upcase) | contains($MAC_PREFIX | ascii_upcase)) | {name: .name, problems: .potentialProblems}' /tmp/Vendors.json)

  VENDOR_NAME=$(echo "$VENDOR_DATA" | jq -r '.name')
  PROBLEMS=$(echo "$VENDOR_DATA" | jq -r '.problems')

  if [ -z "$VENDOR_NAME" ]; then
      VENDOR_NAME="Unknown"
  fi

  # If there is no problems data or it's "null" (which is how jq returns absent JSON keys), leave it blank
  if [ -z "$PROBLEMS" ] || [ "$PROBLEMS" = "null" ]; then
      PROBLEMS=""
  fi

  # Output the custom formatted information for matched MAC address prefixes
  printf "%-15s %-17s %-12s %-15s %-30s\n" "$IP_ADDRESS" "$MAC_ADDRESS" "$DEVICE" "$VENDOR_NAME" "$PROBLEMS"
done
