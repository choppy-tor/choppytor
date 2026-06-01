#!/bin/bash

# Check for the correct number of arguments
if [ $# -ne 4 ]; then
    echo "Usage: $0 <number of iterations> <capture_filename_variable> <CALLEE_SCRIPT> <TUNNEL_IP>"
    exit 1
fi

n=$1                 # Number of iterations
CAPTURE_FILENAME=$2  # Variable part of capture filename
CALLEE_SCRIPT=$3     # Path to callee Python script
TUNNEL_IP=$4         # Tunnel IP of the caller

TCP_PORT=98765
PESQ_BINARY_PATH="pesq"
REFERENCE_FILE="Julius2.wav"
SERVER_PID=0         # PID for the Python server
CALLEE_PID=0         # PID for the callee script

# Log file setup
log_file="data/test_callee_log.txt"
rm data.zip
rm -r ~/new_try/data/test_pcaps ~/new_try/data/test_callee_recordings ~/new_try/data/test_owd_logs
mkdir -p ~/new_try/data/test_pcaps ~/new_try/data/test_callee_recordings ~/new_try/data/test_owd_logs

echo "#, Timestamp, Guard_Node_IP, OWD_Callee, RTT_min, RTT_avg, RTT_max, RTT_mdev, Callee_PESQ_Raw, Callee_PESQ_MOS" > "$log_file"

tmux new-session -d -s iperf_session "iperf3 -s"

OUTPUT_FILE="callee_command.txt"
for ((i=0; i<n; i++)); do
    python3 Callee_message.py &
    SERVER_PID=$!
    echo "Callee server started with PID $SERVER_PID"

    echo "Callee Iteration $i of $n"
    echo "Waiting for start signal from caller..."
    
    while true; do
        if [[ -f "$OUTPUT_FILE" ]]; then
            command=$(cat "$OUTPUT_FILE")
            if [[ "$command" == "START" ]]; then
                echo "[*] Received START command"
                echo "Start signal received."
                
                # Run ping and extract RTT values, ensuring mdev does not include "ms"
                ping_result=$(ping -c 4 -W 2 10.8.0.2 | tail -1 | awk -F '=' '{print $2}' | awk -F '/' '{print $1, $2, $3, $4}')
                rtt_min=$(echo $ping_result | awk '{print $1}')
                rtt_avg=$(echo $ping_result | awk '{print $2}')
                rtt_max=$(echo $ping_result | awk '{print $3}')
                rtt_mdev=$(echo $ping_result | awk '{print $4}' | sed 's/ ms//')
                echo "$rtt_min $rtt_avg $rtt_max $rtt_mdev" > ~/new_try/data/owd_logs/owd_$i.txt
                echo "RTT Values: min=$rtt_min ms, avg=$rtt_avg ms, max=$rtt_max ms, mdev=$rtt_mdev ms"
                sleep 1
                
                pcap_filename_inside="data/test_pcaps/${CAPTURE_FILENAME}_callee_inside_$i.pcap"
                echo "Starting packet capture: $pcap_filename_inside"
                sudo tcpdump -i tun0 -s 85 host $TUNNEL_IP -w "$pcap_filename_inside" &
                in_tcp_dump_pid=$!

                echo "Starting callee script..."
                # python $CALLEE_SCRIPT $TUNNEL_IP 9001 1001 1234 30 8000 Julius2.wav rec/callee &
                python callee_v2.py 10.8.0.1 9001 1001 1234 30 8000 Julius2_v2.wav rec/callee &
                CALLEE_PID=$!
                
                > "$OUTPUT_FILE"
            elif [[ "$command" == "STOP" ]]; then
                echo "[*] Received STOP command"
                echo "Stopping packet capture and callee script...${CALLEE_PID}"
                kill $in_tcp_dump_pid
                kill $CALLEE_PID
                killall tcpdump

                mv rec/callee${i+1}.wav ~/new_try/data/test_callee_recordings/callee_recording_$i.wav
                rm ~/new_try/rec/callee${i+1}.wav

                callee_pesq_raw=0
                callee_pesq_mos=0
                if [ -f "data/test_callee_recordings/callee_recording_$i.wav" ]; then
                    callee_pesq_raw=$(./pesq +8000 $REFERENCE_FILE ~/new_try/data/test_callee_recordings/callee_recording_$i.wav | grep "Raw MOS" | awk '{print $7}')
                    callee_pesq_mos=$(./pesq +8000 $REFERENCE_FILE ~/new_try/data/test_callee_recordings/callee_recording_$i.wav | grep "Raw MOS" | awk '{print $8}')
                else
                    echo "file not found..."
                fi
                
                echo "RTT_min: $rtt_min ms, RTT_avg: $rtt_avg ms, RTT_max: $rtt_max ms, RTT_mdev: $rtt_mdev ms, PESQ_Raw: $callee_pesq_raw, PESQ_MOS: $callee_pesq_mos"
                
                RESULT_FILE="callee_results.txt"
                echo " $rtt_min $rtt_avg $rtt_max $rtt_mdev $callee_pesq_raw $callee_pesq_mos" > "$RESULT_FILE"
                echo "[*] RTT and PESQ results written to $RESULT_FILE"

                echo "$i, $timestamp, $TUNNEL_IP, $one_way_delay, $rtt_min, $rtt_avg, $rtt_max, $rtt_mdev, $callee_pesq_raw, $callee_pesq_mos" >> "$log_file"

                echo "Callee iteration $i completed."
                sleep 5
                > "$OUTPUT_FILE"
                break
            fi
        fi
        sleep 1
    done
    
    echo "[*] Stopping TCP server"
    kill $SERVER_PID
    rm "$OUTPUT_FILE"
    rm "$RESULT_FILE"

done

pkill iperf3
tmux kill-session -t iperf_session
zip -r data.zip data
echo "Callee operations completed $n times. Data stored in ~/new_try/data/."
