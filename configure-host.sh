#!/bin/bash  # This specifies that the script should be run in the bash shell

# This function handles signals (ignores TERM, HUP, and INT signals)
trap '' TERM HUP INT

# This initializes a variable for verbose mode (0 means off)
VERBOSE=0

# This function logs messages
log_message() {
    # This checks if verbose mode is enabled
    if [ $VERBOSE -eq 1 ]; then
        echo "$1"  # This prints the message to the console
    fi
    logger "$1"  # This logs the message to the system log
}

# This parses command line arguments
while [[ "$#" -gt 0 ]]; do  # This continues while there are arguments left to process
    case $1 in  # This checks the first argument
        -verbose) VERBOSE=1 ;;  # This enables verbose mode if -verbose is passed
        -name) desiredName="$2"; shift ;;  # This sets desiredName to the next argument
        -ip) desiredIPAddress="$2"; shift ;;  # This sets desiredIPAddress to the next argument
        -hostentry) desiredHostEntryName="$2"; desiredHostEntryIP="$3"; shift 2 ;;  # This sets host entry name and IP
        *) echo "Unknown parameter passed: $1"; exit 1 ;;  # This handles unknown parameters
    esac
    shift  # This moves to the next argument
done

# This function updates the hostname
update_hostname() {
    currentName=$(cat /etc/hostname)  # This gets the current hostname
    # This checks if the current hostname is different from the desired name
    if [ "$currentName" != "$desiredName" ]; then
        echo "$desiredName" > /etc/hostname  # This updates the hostname file
        sed -i "s/^$currentName/$desiredName/" /etc/hosts  # This updates the /etc/hosts file
        log_message "Hostname changed from $currentName to $desiredName"  # This logs the change
    fi
}

# This function updates the IP address
update_ip() {
    currentIP=$(grep -w "$(hostname)" /etc/hosts | awk '{print $1}')  # This gets the current IP address
    # This checks if the current IP address is different from the desired IP address
    if [ "$currentIP" != "$desiredIPAddress" ]; then
        sed -i "s/^$currentIP/$desiredIPAddress/" /etc/hosts  # This updates the /etc/hosts file
        # This updates netplan configuration (assuming netplan is used)
        sed -i "s/$currentIP/$desiredIPAddress/" /etc/netplan/*.yaml  # This updates the netplan configuration
        log_message "IP address changed from $currentIP to $desiredIPAddress"  # This logs the change
        netplan apply  # This applies the netplan changes
    fi
}

# This function updates /etc/hosts with a new host entry
update_hostentry() {
    # This checks if the desired host entry does not already exist
    if ! grep -q "$desiredHostEntryName" /etc/hosts; then
        echo "$desiredHostEntryIP $desiredHostEntryName" >> /etc/hosts  # This adds the new host entry
        log_message "Added host entry: $desiredHostEntryName with IP $desiredHostEntryIP"  # This logs the addition
    fi
}

# This executes functions based on provided arguments
if [ ! -z "$desiredName" ]; then  # This checks if a desired name was provided
    update_hostname  # This calls the function to update the hostname
fi

if [ ! -z "$desiredIPAddress" ]; then  # This checks if a desired IP address was provided
    update_ip  # This calls the function to update the IP address
fi

if [ ! -z "$desiredHostEntryName" ] && [ ! -z "$desiredHostEntryIP" ]; then  # This checks if both host entry name and IP were provided
    update_hostentry  # This calls the function to update the host entry
fi
