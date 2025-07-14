#!/bin/bash

# Define the password for SSH
PASSWORD=Vo123@IP
IPS=(
    "165.232.47.42"
    "165.227.163.156"
    "162.243.40.228"
    "134.122.46.221"
    "188.166.42.110"
    "209.38.87.162"
    "209.38.166.20"
    "167.71.141.226"
    "157.245.47.36"
    "68.183.93.191"
    "209.38.25.253"
)

for HOST in "${IPS[@]}"; do
    echo "Processing VM: $HOST"

    sshpass -p "$PASSWORD" ssh -t root@$HOST "
        cd new_try && rm callee_command.txt
    "

done


