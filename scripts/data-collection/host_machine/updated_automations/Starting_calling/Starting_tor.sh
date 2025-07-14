#!/bin/bash

# Define common variables
PASSWORD="Vo123@IP"
REMOTE_DIR="/root/new_try"
REMOTE_DIR_TOKEN="/home/ubuntu/new_try"
REMOTE_SCRIPT="sudo ./automate_new.sh 50 ~/Caller.ovpn find_guard_node.py pcap_capture caller.py 10.8.0.2 find_middle_node.py find_exit_node.py node.py > caller_output_log.txt 2>&1"
REMOTE_SCRIPT_TOKEN="sudo ./automate_new.sh 50  /home/ubuntu/Caller.ovpn find_guard_node.py pcap_capture caller.py 10.8.0.2 find_middle_node.py find_exit_node.py node.py > caller_output_log.txt 2>&1"

# Hardcoded IP addresses
IPS=(
    "104.248.143.199"
    "170.64.217.19"
    "159.89.164.103"
    "157.245.193.205"
    "143.244.176.174"
    "107.170.14.165"
    "13.246.131.104" #Capetown
    "16.78.220.70" #JAKARTA
    "13.208.174.172" #OSAKA
    "15.228.228.58" #SauPaulo
    "51.17.159.192" #TeleAviv

)
# 


# Loop through each IP
for HOST in "${IPS[@]}"; do
    echo "Processing VM: $HOST"

    # Check if the VM requires the identity file (e.g., Capetown_Token)
    if [[ "$HOST" == "13.246.131.104" ]]; then
        # Use the identity file for Capetown_Token
        ssh -i "/home/drkill/Desktop/btp/keys/voip-CapeTown.pem" -t ubuntu@$HOST "
            tor
        " && echo "Automation started in tmux on $HOST" || echo "Failed to start automation on $HOST"
            # tmux new-session -d -s automate_session 'sudo su && cd $REMOTE_DIR_TOKEN && $REMOTE_SCRIPT_TOKEN'
        
    elif [[ "$HOST" == "16.78.220.70" ]]; then
        # Use the identity file for jakarta
        ssh -i "/home/drkill/Desktop/btp/keys/voip-jakarta.pem" -t ubuntu@$HOST "
            tor
        " && echo "Automation started in tmux on $HOST" || echo "Failed to start automation on $HOST"
    elif [[ "$HOST" == "13.208.174.172" ]]; then
        # Use the identity file for Osaka
        ssh -i "/home/drkill/Desktop/btp/keys/voip-osaka.pem" -t ubuntu@$HOST "
            tor
        " && echo "Automation started in tmux on $HOST" || echo "Failed to start automation on $HOST"
    elif [[ "$HOST" == "15.228.228.58" ]]; then
        # Use the identity file for SauPaulo
        ssh -i "/home/drkill/Desktop/btp/keys/voip-saopaulo.pem" -t ubuntu@$HOST "
            tor
        " && echo "Automation started in tmux on $HOST" || echo "Failed to start automation on $HOST"
    elif [[ "$HOST" == "51.17.159.192" ]]; then
        # Use the identity file for Teleaviv
        ssh -i "/home/drkill/Desktop/btp/keys/voip-telaviv.pem" -t ubuntu@$HOST "
            tor
        " && echo "Automation started in tmux on $HOST" || echo "Failed to start automation on $HOST"
    else
        # Use password-based SSH for other VMs
        sshpass -p "$PASSWORD" ssh -t root@$HOST "
            tor
        " && echo "Automation started in tmux on $HOST" || echo "Failed to start automation on $HOST"
# tmux new-session -d -s automate_session 'cd $REMOTE_DIR && $REMOTE_SCRIPT'
    fi

done

echo "All VMs processed. Check tmux sessions on each VM for progress."
