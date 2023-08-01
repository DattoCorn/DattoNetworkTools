#!/bin/sh

# Path to the DHCP leases file
DHCP_LEASES_FILE="/tmp/dhcp.leases"

# Check if the file exists
if [ ! -f "$DHCP_LEASES_FILE" ]; then
  echo "File $DHCP_LEASES_FILE not found!"
  exit 1
fi

# Output file in CSV format
OUTPUT_FILE="network_map.csv"

# Print the header to the CSV file
echo "Lease Time,MAC Address,IP Address,Hostname" > $OUTPUT_FILE

# Iterate through the file and extract the information
while read line; do
  LEASE_TIME=$(echo $line | cut -d ' ' -f 1)
  MAC_ADDRESS=$(echo $line | cut -d ' ' -f 2)
  IP_ADDRESS=$(echo $line | cut -d ' ' -f 3)
  HOSTNAME=$(echo $line | cut -d ' ' -f 4)

  # Print the information to the CSV file
  echo "$LEASE_TIME,$MAC_ADDRESS,$IP_ADDRESS,$HOSTNAME" >> $OUTPUT_FILE
done < $DHCP_LEASES_FILE

echo "Network map has been created in $OUTPUT_FILE"
