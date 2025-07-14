#!/bin/bash

# Define common variables
PASSWORD="*******"
REMOTE_DIR="/root/new_try"
REMOTE_SCRIPT="sudo ./automate_callee_v2.sh 100 pcap callee_v2.py 10.8.0.1 > callee_output_log.txt 2>&1"

# Hardcoded IP addresses
IPS=(
    
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


# Loop through each IP
for HOST in "${IPS[@]}"; do
    echo "Processing VM: $HOST"
    if [[ "$HOST" == "3.38.182.126" ]]; then
        # Use the identity file for sEOUL
        ssh -i "~/.ssh/voip-seoul.pem" -t ubuntu@$HOST "
            sudo tmux new-session -d -s automate_session 'cd $REMOTE_DIR && $REMOTE_SCRIPT'
        " && echo "[*]automationed machine : $HOST" || echo "[***]Failed automation"
    elif [[ "$HOST" == "78.12.113.236" ]]; then
        # Use the identity file for mexico
        ssh -i "~/.ssh/voip-mex.pem" -t ubuntu@$HOST "
            sudo tmux new-session -d -s automate_session 'cd $REMOTE_DIR && $REMOTE_SCRIPT'
        " && echo "[*]automationed machine : $HOST" || echo "[***]Failed automation"
    elif [[ "$HOST" == "3.28.252.237" ]]; then
        # Use the identity file for uae
        ssh -i "~/.ssh/voip-uae.pem" -t ubuntu@$HOST "
            sudo tmux new-session -d -s automate_session 'cd $REMOTE_DIR && $REMOTE_SCRIPT'
        " && echo "[*]automationed machine : $HOST" || echo "[***]Failed automation"
    elif [[ "$HOST" == "43.216.119.204" ]]; then
        # Use the identity file for malaysia
        ssh -i "~/.ssh/voip-malaysia.pem" -t ubuntu@$HOST "
            sudo tmux new-session -d -s automate_session 'cd $REMOTE_DIR && $REMOTE_SCRIPT'
        " && echo "[*]automationed machine : $HOST" || echo "[***]Failed automation"
    else
        # Use password-based SSH for other VMs
        sshpass -p "$PASSWORD" ssh -t root@$HOST "
            sudo tmux new-session -d -s automate_session 'cd $REMOTE_DIR && $REMOTE_SCRIPT'
        " && echo "[*]automationed machine : $HOST" || echo "[***]Failed automation"
    fi
    
    # echo "Processing VM: $HOST"

    
    # # Use password-based SSH for other VMs
    # sshpass -p "$PASSWORD" ssh -t root@$HOST "
    #     tmux new-session -d -s automate_session 'cd $REMOTE_DIR && $REMOTE_SCRIPT'
    # " && echo "Automation started in tmux on $HOST" || echo "Failed to start automation on $HOST"
            

done

echo "All VMs processed. Check tmux sessions on each VM for progress."
