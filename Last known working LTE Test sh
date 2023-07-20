#!/bin/sh
echo "Datto Networking LTE Tool V1.3"

# Function to echo and then run a command
run_cmd() {
    echo "Running: $1"
    eval $1
    local status=$?
    if [ $status -eq 0 ]; then
        echo "$1 - Success"
    else
        echo "$1 - Failed"
    fi
    echo "----------------------------------------------------"
    return $status
}

# Step 1
run_cmd "modemstatus --verbose"

# Step 2
if run_cmd "ping -I lte0 8.8.8.8 -c 3"; then
    echo "LTE is working. Exiting script."
    exit 0
fi

# Step 3
run_cmd "lsusb -t"

# Step 4
run_cmd "modemreboot"

# Step 5
run_cmd "modemreconnect"

# Step 6
if run_cmd "ping -I lte0 8.8.8.8 -c 3"; then
    echo "LTE is working after modem reconnect. Exiting script."
    exit 0
fi

# Step 7
run_cmd "sequans-gpio-reset"

# Step 8
run_cmd "modemreconnect"

# Step 9
if run_cmd "ping -I lte0 8.8.8.8 -c 3"; then
    echo "LTE is working after sequans-gpio-reset. Exiting script."
    exit 0
fi

# Step 10
run_cmd "/etc/init.d/dna-modemmanager stop"

# Step 11
echo "Running: pymm"
pymm &
sleep 60
kill $!
echo "pymm - Completed"
echo "----------------------------------------------------"

# Step 12
run_cmd "/etc/init.d/dna-modemmanager start"

# Step 13
if run_cmd "ping -I lte0 8.8.8.8 -c 3"; then
    echo "LTE is working after dna-modemmanager restart. Exiting script."
    exit 0
else
    echo "LTE still not working. Please check the device."
    exit 1
fi
