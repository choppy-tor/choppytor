#!/bin/bash

# Define the password for SSH
PASSWORD=Vo123@IP

# Group 1: Frank-Lond Caller (New Session)
tmux new-session -d -s scp_session_1 "sshpass -p $PASSWORD scp -r root@104.248.143.199:/root/new_try/data.zip /home/drkill/Desktop/btp/data_logger/loggr/1Frank-Lond/caller/ && \
sshpass -p $PASSWORD scp -r root@104.248.143.199:/root/new_try/log.json /home/drkill/Desktop/btp/data_logger/loggr/1Frank-Lond/caller/ "

# Group 2: Frank-Lond Callee (New Session)
tmux new-session -d -s scp_session_2 "sshpass -p $PASSWORD scp -r root@165.232.47.42:/root/new_try/data.zip /home/drkill/Desktop/btp/data_logger/loggr/1Frank-Lond/callee/ "

# Group 3: Sydney-Frank Caller (New Session)
tmux new-session -d -s scp_session_3 "sshpass -p $PASSWORD scp -r root@170.64.217.19:/root/new_try/data.zip /home/drkill/Desktop/btp/data_logger/loggr/2sydney-frank/caller/ && \
sshpass -p $PASSWORD scp -r root@170.64.217.19:/root/new_try/log.json /home/drkill/Desktop/btp/data_logger/loggr/2sydney-frank/caller/ "

# Group 4: Sydney-Frank Callee (New Session)
tmux new-session -d -s scp_session_4 "sshpass -p $PASSWORD scp -r root@165.227.163.156:/root/new_try/data.zip /home/drkill/Desktop/btp/data_logger/loggr/2sydney-frank/callee/ "

# Group 5: Bangl-NYC Caller (New Session)
tmux new-session -d -s scp_session_5 "sshpass -p $PASSWORD scp -r root@159.89.164.103:/root/new_try/data.zip /home/drkill/Desktop/btp/data_logger/loggr/3Bangl-nyc/caller/ && \
sshpass -p $PASSWORD scp -r root@159.89.164.103:/root/new_try/log.json /home/drkill/Desktop/btp/data_logger/loggr/3Bangl-nyc/caller/ "

# Group 6: Bangl-NYC Callee (New Session)
tmux new-session -d -s scp_session_6 "sshpass -p $PASSWORD scp -r root@162.243.40.228:/root/new_try/data.zip /home/drkill/Desktop/btp/data_logger/loggr/3Bangl-nyc/callee/ "

# Group 7: Singapore-NYC Caller (New Session)
tmux new-session -d -s scp_session_7 "sshpass -p $PASSWORD scp -r root@157.245.193.205:/root/new_try/data.zip /home/drkill/Desktop/btp/data_logger/loggr/4singapore-nyc/caller/ && \
sshpass -p $PASSWORD scp -r root@157.245.193.205:/root/new_try/log.json /home/drkill/Desktop/btp/data_logger/loggr/4singapore-nyc/caller/ "

# Group 8: Singapore-NYC Callee (New Session)
tmux new-session -d -s scp_session_8 "sshpass -p $PASSWORD scp -r root@134.122.46.221:/root/new_try/data.zip /home/drkill/Desktop/btp/data_logger/loggr/4singapore-nyc/callee/ "

# # Group 9: Sans-Amsterdam Caller (New Session)
tmux new-session -d -s scp_session_9 "sshpass -p $PASSWORD scp -r root@143.244.176.174:/root/new_try/data.zip /home/drkill/Desktop/btp/data_logger/loggr/5sans-amster/caller/ && \
sshpass -p $PASSWORD scp -r root@143.244.176.174:/root/new_try/log.json /home/drkill/Desktop/btp/data_logger/loggr/5sans-amster/caller/ "

# Group 10: Sans-Amsterdam Callee (New Session)
tmux new-session -d -s scp_session_10 "sshpass -p $PASSWORD scp -r root@188.166.42.110:/root/new_try/data.zip /home/drkill/Desktop/btp/data_logger/loggr/5sans-amster/callee/ "

#Group 11: NYC-Sydney Caller (New Session)
tmux new-session -d -s scp_session_11 "sshpass -p $PASSWORD scp -r root@107.170.14.165:/root/new_try/data.zip /home/drkill/Desktop/btp/data_logger/loggr/6nyc-syd/caller/ && \
sshpass -p $PASSWORD scp -r root@107.170.14.165:/root/new_try/log.json /home/drkill/Desktop/btp/data_logger/loggr/6nyc-syd/caller/ "

# Group 12: NYC-Sydney Callee (New Session)
tmux new-session -d -s scp_session_12 "sshpass -p $PASSWORD scp -r root@209.38.87.162:/root/new_try/data.zip /home/drkill/Desktop/btp/data_logger/loggr/6nyc-syd/callee/ "

# Group 13: CapeTown-Seoul Caller
tmux new-session -d -s scp_session_13 "scp -r -i /home/drkill/Desktop/btp/keys/voip-CapeTown.pem ubuntu@13.246.131.104:~/new_try/data.zip /home/drkill/Desktop/btp/data_logger/loggr/7CapeTown-frank/caller/ && \
scp -r -i /home/drkill/Desktop/btp/keys/voip-CapeTown.pem ubuntu@13.246.131.104:~/new_try/log.json /home/drkill/Desktop/btp/data_logger/loggr/7CapeTown-frank/caller/ "

# Group 14: CapeTown-Seoul Callee
tmux new-session -d -s scp_session_14 "scp -r -i /home/drkill/Desktop/btp/keys/voip-seoul.pem ubuntu@3.38.182.126:~/new_try/data.zip /home/drkill/Desktop/btp/data_logger/loggr/7CapeTown-frank/callee/ "

# Group 15: 8Jakarta-Mexico Caller
tmux new-session -d -s scp_session_15 "scp -r -i /home/drkill/Desktop/btp/keys/voip-jakarta.pem ubuntu@16.78.220.70:~/new_try/data.zip /home/drkill/Desktop/btp/data_logger/loggr/8Jakarta-London2/caller/ && \
scp -r -i /home/drkill/Desktop/btp/keys/voip-jakarta.pem ubuntu@16.78.220.70:~/new_try/log.json /home/drkill/Desktop/btp/data_logger/loggr/8Jakarta-London2/caller/ "

# Group 16: 8Jakarta-Mexico Callee
tmux new-session -d -s scp_session_16 "scp -r -i /home/drkill/Desktop/btp/keys/voip-mex.pem ubuntu@78.12.113.236:~/new_try/data.zip /home/drkill/Desktop/btp/data_logger/loggr/8Jakarta-London2/callee/ "

# Group 17: 9Osaka-UAE Caller
tmux new-session -d -s scp_session_17 "scp -r -i /home/drkill/Desktop/btp/keys/voip-osaka.pem ubuntu@13.208.174.172:~/new_try/data.zip /home/drkill/Desktop/btp/data_logger/loggr/9Osaka-London3/caller/ && \
scp -r -i /home/drkill/Desktop/btp/keys/voip-osaka.pem ubuntu@13.208.174.172:~/new_try/log.json /home/drkill/Desktop/btp/data_logger/loggr/9Osaka-London3/caller/ "

# Group 18: 9Osaka-UAE Callee
tmux new-session -d -s scp_session_18 "scp -r -i /home/drkill/Desktop/btp/keys/voip-uae.pem ubuntu@3.28.252.237 :~/new_try/data.zip /home/drkill/Desktop/btp/data_logger/loggr/9Osaka-London3/callee/ "

# Group 19: 10SauPaul-malaysia Caller
tmux new-session -d -s scp_session_19 "scp -r -i /home/drkill/Desktop/btp/keys/voip-saopaulo.pem ubuntu@15.228.228.58:~/new_try/data.zip /home/drkill/Desktop/btp/data_logger/loggr/10SauPaul-Bangalore2/caller/ && \
scp -r -i /home/drkill/Desktop/btp/keys/voip-saopaulo.pem ubuntu@15.228.228.58:~/new_try/log.json /home/drkill/Desktop/btp/data_logger/loggr/10SauPaul-Bangalore2/caller/ "

# Group 20: 10SauPaul-malaysia Callee
tmux new-session -d -s scp_session_20 "scp -r -i /home/drkill/Desktop/btp/keys/voip-malaysia.pem ubuntu@43.216.119.204:~/new_try/data.zip /home/drkill/Desktop/btp/data_logger/loggr/10SauPaul-Bangalore2/callee/ "

# Group 21: 11TelAviv-Sydney3 Caller
tmux new-session -d -s scp_session_21 "scp -r -i /home/drkill/Desktop/btp/keys/voip-telaviv.pem ubuntu@51.17.159.192:~/new_try/data.zip /home/drkill/Desktop/btp/data_logger/loggr/11TelAviv-Sydney3/caller/ && \
scp -r -i /home/drkill/Desktop/btp/keys/voip-telaviv.pem ubuntu@51.17.159.192:~/new_try/log.json /home/drkill/Desktop/btp/data_logger/loggr/11TelAviv-Sydney3/caller/ "

# Group 22: 11TelAviv-Sydney3 Callee
tmux new-session -d -s scp_session_22 "sshpass -p $PASSWORD scp -r root@209.38.25.253:/root/new_try/data.zip /home/drkill/Desktop/btp/data_logger/loggr/11TelAviv-Sydney3/callee/ 
"

# # Group 23: Frank-Lond Caller (New Session)
# tmux new-session -d -s scp_session_23 "sshpass -p $PASSWORD scp -r root@104.248.43.56:/root/new_try/data.zip /home/drkill/Desktop/btp/data_logger/loggr/OG_Frank-Lond/caller/ && \
# sshpass -p $PASSWORD scp -r root@104.248.43.56:/root/new_try/log.json /home/drkill/Desktop/btp/data_logger/loggr/OG_Frank-Lond/caller/ && \
# sshpass -p $PASSWORD scp -r root@104.248.43.56:/root/new_try/caller_output_log.txt /home/drkill/Desktop/btp/data_logger/loggr/OG_Frank-Lond/caller/"

# # Group 24: Frank-Lond Callee (New Session)
# tmux new-session -d -s scp_session_24 "sshpass -p $PASSWORD scp -r root@167.99.207.114:/root/new_try/data.zip /home/drkill/Desktop/btp/data_logger/loggr/OG_Frank-Lond/callee/ && \
# sshpass -p $PASSWORD scp -r root@167.99.207.114:/root/new_try/callee_output_log.txt /home/drkill/Desktop/btp/data_logger/loggr/OG_Frank-Lond/callee/"



# List all running tmux sessions
tmux list-sessions
