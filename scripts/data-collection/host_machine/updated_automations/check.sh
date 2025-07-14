#!/bin/bash

# Define common variables
PASSWORD="Vo123@IP"
REMOTE_DIR="/root/new_try"
REMOTE_DIR_TOKEN="/home/ubuntu/new_try"
REMOTE_SCRIPT="sudo ./automate_new.sh 1000 ~/Caller.ovpn find_guard_node.py pcap_capture caller.py 10.8.0.2 find_middle_node.py find_exit_node.py node.py > caller_output_log.txt 2>&1"
REMOTE_SCRIPT_TOKEN="sudo ./automate_new.sh 1000 /home/ubuntu/Caller.ovpn find_guard_node.py pcap_capture caller.py 10.8.0.2 find_middle_node.py find_exit_node.py node.py > caller_output_log.txt 2>&1"

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
    # Callee IP's
    
    "165.232.47.42"
    "165.227.163.156"
    "162.243.40.228"
    "134.122.46.221"
    "188.166.42.110"
    "209.38.87.162"
    "3.38.182.126" #Seoul
    "78.12.113.236" #Mexico
    "3.28.252.237" #UAE
    "43.216.119.204" #Malaysia
    "209.38.25.253"
)
# cd


# Loop through each IP
for HOST in "${IPS[@]}"; do
    echo "Processing VM: $HOST"

    # Check if the VM requires the identity file (e.g., Capetown_Token)
    if [[ "$HOST" == "13.246.131.104" ]]; then
        # Use the identity file for Capetown_Token
        ssh -i "~/.ssh/voip-CapeTown.pem" -t ubuntu@$HOST "
            sudo tor 
        " && echo "[*]Rebooted machine : $HOST" || echo "[***]Failed tor  $HOST"
                
        
    elif [[ "$HOST" == "16.78.220.70" ]]; then
        # Use the identity file for jakarta
        ssh -i "~/.ssh/voip-jakarta.pem" -t ubuntu@$HOST "
            sudo tor 
        " && echo "[*]Rebooted machine : $HOST" || echo "[***]Failed tor  $HOST"
    elif [[ "$HOST" == "13.208.174.172" ]]; then
        # Use the identity file for Osaka
        ssh -i "~/.ssh/voip-osaka.pem" -t ubuntu@$HOST "
            sudo tor 
        " && echo "[*]Rebooted machine : $HOST" || echo "[***]Failed tor  $HOST"
    elif [[ "$HOST" == "15.228.228.58" ]]; then
        # Use the identity file for SauPaulo
        ssh -i "~/.ssh/voip-saopaulo.pem" -t ubuntu@$HOST "
            sudo tor 
        " && echo "[*]Rebooted machine : $HOST" || echo "[***]Failed tor  $HOST"
    elif [[ "$HOST" == "51.17.159.192" ]]; then
        # Use the identity file for Teleaviv
        ssh -i "~/.ssh/voip-telaviv.pem" -t ubuntu@$HOST "
            sudo tor 
        " && echo "[*]Rebooted machine : $HOST" || echo "[***]Failed tor  $HOST"
    
            # tmux new-session -d -s automate_session 'cd $REMOTE_DIR && $REMOTE_SCRIPT'
    elif [[ "$HOST" == "3.38.182.126" ]]; then
        # Use the identity file for sEOUL
        ssh -i "~/.ssh/voip-seoul.pem" -t ubuntu@$HOST "
            sudo tor 
        " && echo "[*]Rebooted machine : $HOST" || echo "[***]Failed tor  $HOST"
    elif [[ "$HOST" == "78.12.113.236" ]]; then
        # Use the identity file for mexico
        ssh -i "~/.ssh/voip-mex.pem" -t ubuntu@$HOST "
            sudo tor 
        " && echo "[*]Rebooted machine : $HOST" || echo "[***]Failed tor  $HOST"
    elif [[ "$HOST" == "3.28.252.237" ]]; then
        # Use the identity file for uae
        ssh -i "~/.ssh/voip-uae.pem" -t ubuntu@$HOST "
        
            sudo tor 
        " && echo "[*]Rebooted machine : $HOST" || echo "[***]Failed tor  $HOST"
    elif [[ "$HOST" == "43.216.119.204" ]]; then
        # Use the identity file for malaysia
        ssh -i "~/.ssh/voip-malaysia.pem" -t ubuntu@$HOST "
            sudo tor 
        " && echo "[*]Rebooted machine : $HOST" || echo "[***]Failed tor  $HOST"
    else
        # Use password-based SSH for other VMs
        sshpass -p "$PASSWORD" ssh -t root@$HOST "
            sudo tor 
        " && echo "[*]Rebooted machine : $HOST" || echo "[***]Failed tor  $HOST"
    fi

done
# cd /usr/local/freeswitch/conf/ && cp vars.xml.bak vars.xml && service freeswitch restart


echo "All VMs processed. Check tmux sessions on each VM for progress."
