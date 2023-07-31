#!/bin/sh

# Download the JSON file to /tmp folder
curl -o /tmp/Vendors.json https://raw.githubusercontent.com/DattoCorn/DattoNetworkTools/main/Vendors.json

# Function to get the vendor based on the MAC address prefix
get_vendor() {
    local mac_prefix="$1"
    grep -i "\"$mac_prefix\"" /tmp/Vendors.json | awk -F '"' '{print $4}'
}

# Print the custom column headers
printf "----------------------Simp Tool V1.4------------------------\n"
printf "%-15s %-17s %-12s %-15s\n" "IP Address" "HW Address" "Device" "Vendor"
printf "-----------------------------------------------------------\n"

# Process the /proc/net/arp file
cat /proc/net/arp | while read -r line; do
    # Skip the header line
    if echo "$line" | grep -q "IP address"; then
        continue
    fi

    ip_address=$(echo "$line" | awk '{print $1}')
    hw_address=$(echo "$line" | awk '{print $4}')
    device=$(echo "$line" | awk '{print $6}')
    mac_prefix=$(echo "$hw_address" | awk -F ':' '{print $1":"$2":"$3}')

    # Get the vendor information using the get_vendor function
    vendor=$(get_vendor "$mac_prefix")

    # Print the information in the desired format
    printf "%-15s %-17s %-12s %-15s\n" "$ip_address" "$hw_address" "$device" "$vendor"
done
