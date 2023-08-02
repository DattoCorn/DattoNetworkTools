#!/bin/sh

echo " ╔╦╗┌─┐┌┬┐┌┬┐┌─┐  ╔╗╔┌─┐┌┬┐┬ ┬┌─┐┬─┐┬┌─┬┌┐┌┌─┐  ╦ ╔╦╗╔═╗  ╔╦╗┌─┐┌─┐┬  "
echo "  ║║├─┤ │  │ │ │  ║║║├┤  │ ││││ │├┬┘├┴┐│││││ ┬  ║  ║ ║╣    ║ │ ││ ││  "
echo " ═╩╝┴ ┴ ┴  ┴ └─┘  ╝╚╝└─┘ ┴ └┴┘└─┘┴└─┴ ┴┴┘└┘└─┘  ╩═╝╩ ╚═╝   ╩ └─┘└─┘┴─┘"

echo "Datto Networking LTE Tool V2.3"

# Attempt to get the device type
if cat /etc/datto/model >/dev/null 2>&1; then
    model=$(cat /etc/datto/model)
else
    model="D200"
fi

if echo "$model" | grep -q "DNA"; then
    modemmanager_cmd="/etc/init.d/dna-modemmanager"
elif [ "$model" = "D200" ]; then
    modemmanager_cmd="/etc/init.d/d200-modemmanager"
else
    echo "Unsupported device model. Exiting script."
    exit 1
fi

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

while true; do
    # Step 1
    run_cmd "modemstatus --verbose"

    # Step 2
    if run_cmd "ping -I lte0 8.8.8.8 -c 3"; then
        echo "LTE is working. Exiting script."
        exit 0 # Exit the script with a success code
        
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
         exit 0 # Exit the script with a success code
        
    fi

    # Step 7
    run_cmd "sequans-gpio-reset"

    # Step 8
    run_cmd "modemreconnect"

    # Step 9
    if run_cmd "ping -I lte0 8.8.8.8 -c 3"; then
        echo "LTE is working after sequans-gpio-reset. Exiting script."
         exit 0 # Exit the script with a success code
        
    fi

    # Step 10
    run_cmd "${modemmanager_cmd} stop"

    # Step 11
    echo "Running: pymm"
    pymm &
    sleep 60
    kill $!
    echo "pymm - Completed"
    echo "----------------------------------------------------"

    # Step 12
    run_cmd "${modemmanager_cmd} start"

    # Step 13
    if run_cmd "ping -I lte0 8.8.8.8 -c 3"; then
        echo "LTE is working after Pymm -modemmanager restart was accomplished. Exiting script."
        exit 0
    else
        echo "LTE still not working. Restarting the script in 10 seconds. Also please have partner check the antenas of the LTE"
        sleep 10
    fi
done
