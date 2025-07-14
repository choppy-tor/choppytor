#!/bin/bash

# Define the password for SSH
PASSWORD=*****
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

for HOST in "${IPS[@]}"; do
    if [[ "$HOST" == "3.38.182.126" ]]; then
        # echo "Processing VM: $HOST"
        # # Use the identity file for sEOUL

        # ssh -i "~/.ssh/voip-seoul.pem" -t ubuntu@$HOST "
        #     sudo tmux new-session -d -s automate_session 'cd /usr/local/freeswitch/conf && rm vars.xml'
            
        # " 
        # ssh -i "~/.ssh/voip-seoul.pem" -t ubuntu@$HOST  "
        #     sudo service freeswitch restart
        echo "Processing VM LLLL: $HOST"

        ssh -i "~/.ssh/voip-seoul.pem" -t ubuntu@$HOST "
            sudo tmux new-session -d -s automate_session 'cd /usr/local/freeswitch/conf && rm vars.xml'
        " 
        scp -i "~/.ssh/voip-seoul.pem" "/mnt/c/Users/ASUS/Desktop/btp/vars/vars.xml" ubuntu@$HOST:"/home/ubuntu"

        ssh -i "~/.ssh/voip-seoul.pem" -t ubuntu@$HOST "
            sudo tmux new-session -d -s automate_session 'sudo mv /home/ubuntu/vars.xml /usr/local/freeswitch/conf/' "

        ssh -i "~/.ssh/voip-seoul.pem" -t ubuntu@$HOST  "
            sudo service freeswitch restart
        "
        
    elif [[ "$HOST" == "78.12.113.236" ]]; then
        # Use the identity file for mexico
        # echo "Processing VM: $HOmex.    # ssh -i "~/.ssh/voip-mex.pem" -t ubuntu@$HOST "
        #     sudo tmux new-session -d -s automate_session 'cd /usr/local/freeswitch/conf && rm vars.xml'
            
        # " 
        # ssh -i "~/.ssh/voip-mex.pem" -t ubuntu@$HOST  "
        #     sudo service freeswitch restart
        echo "Processing VM LLLL: $HOST"

        ssh -i "~/.ssh/voip-mex.pem" -t ubuntu@$HOST "
            sudo tmux new-session -d -s automate_session 'cd /usr/local/freeswitch/conf && rm vars.xml'
        " 
        scp -i "~/.ssh/voip-mex.pem" "/mnt/c/Users/ASUS/Desktop/btp/vars/vars.xml" ubuntu@$HOST:"/home/ubuntu"

        ssh -i "~/.ssh/voip-mex.pem" -t ubuntu@$HOST "
            sudo tmux new-session -d -s automate_session 'sudo mv /home/ubuntu/vars.xml /usr/local/freeswitch/conf/' "

        ssh -i "~/.ssh/voip-mex.pem" -t ubuntu@$HOST  "
            sudo service freeswitch restart
        "
        
    elif [[ "$HOST" == "3.28.252.237" ]]; then
        # # Use the identity file for uae
        # echo "Processing VM: $HOST"

        # ssh -i "~/.ssh/voip-uae.pem" -t ubuntu@$HOST "
        #     sudo tmux new-session -d -s automate_session 'cd /usr/local/freeswitch/conf && rm vars.xml'

        # " 
        # ssh -i "~/.ssh/voip-uae.pem" -t ubuntu@$HOST  "
        #     sudo service freeswitch restart
        # "
        echo "Processing VM LLLL: $HOST"

        ssh -i "~/.ssh/voip-uae.pem" -t ubuntu@$HOST "
            sudo tmux new-session -d -s automate_session 'cd /usr/local/freeswitch/conf && rm vars.xml'
        " 
        scp -i "~/.ssh/voip-uae.pem" "/mnt/c/Users/ASUS/Desktop/btp/vars/vars.xml" ubuntu@$HOST:"/home/ubuntu"

        ssh -i "~/.ssh/voip-uae.pem" -t ubuntu@$HOST "
            sudo tmux new-session -d -s automate_session 'sudo mv /home/ubuntu/vars.xml /usr/local/freeswitch/conf/' "

        ssh -i "~/.ssh/voip-uae.pem" -t ubuntu@$HOST  "
            sudo service freeswitch restart
        "
    elif [[ "$HOST" == "43.216.119.204" ]]; then
        # Use the identity file for malaysia
        echo "Processing VM LLLL: $HOST"

        ssh -i "~/.ssh/voip-malaysia.pem" -t ubuntu@$HOST "
            sudo tmux new-session -d -s automate_session 'cd /usr/local/freeswitch/conf && rm vars.xml'
        " 
        scp -i "~/.ssh/voip-malaysia.pem" "/mnt/c/Users/ASUS/Desktop/btp/vars/vars.xml" ubuntu@$HOST:"/home/ubuntu"

        ssh -i "~/.ssh/voip-malaysia.pem" -t ubuntu@$HOST "
            sudo tmux new-session -d -s automate_session 'sudo mv /home/ubuntu/vars.xml /usr/local/freeswitch/conf/' "

        ssh -i "~/.ssh/voip-malaysia.pem" -t ubuntu@$HOST  "
            sudo service freeswitch restart
        "
    else
        echo "Processing VM: $HOST"

        sshpass -p "$PASSWORD" ssh -t root@$HOST "
            cd /usr/local/freeswitch/conf && rm vars.xml
        "

        sshpass -p "Vo123@IP" scp -o StrictHostKeyChecking=no -r /mnt/c/Users/ASUS/Desktop/btp/vars/vars.xml root@$HOST:/usr/local/freeswitch/conf



        sshpass -p "$PASSWORD" ssh -t root@$HOST "
            service freeswitch restart
        "
    fi
    # echo "Processing VM: $HOST"

    # sshpass -p "$PASSWORD" ssh -t root@$HOST "
    #     cd /usr/local/freeswitch/conf && rm vars.xml
    # "

    # sshpass -p "Vo123@IP" scp -o StrictHostKeyChecking=no -r /mnt/c/Users/ASUS/Desktop/btp/vars/vars.xml root@$HOST:/usr/local/freeswitch/conf



    # sshpass -p "$PASSWORD" ssh -t root@$HOST "
    #     service freeswitch restart
    # "
done


