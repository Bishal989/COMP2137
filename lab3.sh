#!/bin/bash  # This specifies that the script should be run in the bash shell

# This checks for the verbose flag in the first argument
VERBOSE=0  # This initializes verbose mode to off
if [[ "$1" == "-verbose" ]]; then
    VERBOSE=1  # This enables verbose mode if -verbose is passed
fi

# This function runs commands on remote servers
run_on_server() {
    local server=$1  # This assigns the first argument to the server variable
    local name=$2  # This assigns the second argument to the name variable
    local ip=$3  # This assigns the third argument to the IP variable
    local hostentry_name=$4  # This assigns the fourth argument to the host entry name variable
    local hostentry_ip=$5  # This assigns the fifth argument to the host entry IP variable

    # This copies the configure-host.sh script to the remote server
    scp configure-host.sh remoteadmin@$server:/root
    # This runs the configure-host.sh script on the remote server with the provided parameters
    ssh remoteadmin@$server -- /root/configure-host.sh -verbose -name "$name" -ip "$ip" -hostentry "$hostentry_name" "$hostentry_ip"
}

# This runs the configuration on the first server
run_on_server "server1-mgmt" "loghost" "192.168.16.3" "webhost" "192.168.16.4"
# This runs the configuration on the second server
run_on_server "server2-mgmt" "webhost" "192.168.16.4" "loghost" "192.168.16.3"

# This updates the local /etc/hosts file with the loghost entry
./configure-host.sh -hostentry loghost 192.168.16.3
# This updates the local /etc/hosts file with the webhost entry
./configure-host.sh -hostentry webhost 192.168.16.4
