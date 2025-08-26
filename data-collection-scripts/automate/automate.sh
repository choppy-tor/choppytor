#!/bin/bash

# Check for the correct number of arguments
if [ $# -ne 9 ]; then
    echo "Usage: $0 <number of iterations> <path to OVPN file> <path to Python script to get GUARD IP> <capture_filename_variable> <CALLER_SCRIPT> <TUNNEL_IP> <path to Python script to get MIDDLE IP> <path to Python script to get EXIT IP><Complete node file>"
    exit 1
fi

n=$1  # Number of iterations
OVPN_FILE=$2
PYTHON_SCRIPT_GUARD=$3
CAPTURE_FILENAME=$4
CALLER_SCRIPT=$5
TUNNEL_IP=$6
PYTHON_SCRIPT_MIDDLE=$7
PYTHON_SCRIPT_EXIT=$8
FIND_NODE=$9

LOG_FILE1="log.json"
rm -f "$LOG_FILE1"  # Delete log.json file at the start of each run
rm data.zip
rm -r /home/ubuntu/new_try/data/test_pcaps /home/ubuntu/new_try/data/test_caller_recordings /home/ubuntu/new_try/data/test_owd_logs

mkdir -p /home/ubuntu/new_try/data/test_pcaps /home/ubuntu/new_try/data/test_caller_recordings /home/ubuntu/new_try/data/test_owd_logs

# Start a JSON array in the log file
echo "[" > "$LOG_FILE1"

for ((i=0; i<n; i++)); do
    echo "Iteration $i of $n"
    timestamp=$(date -u +%Y-%m-%d_%H-%M-%S)

    while true; do
        openvpn --config "$OVPN_FILE" &
	vpn_id=$!
        sleep 15  # Wait for VPN connection
        if ip a show eth0 up &>/dev/null; then
            echo "VPN tunnel established."
            break
        else
            echo "VPN tunnel not established. Retrying..."
            pkill openvpn
	        kill $vpn_id
            sleep 5
        fi
    done

    # Run ping and extract RTT values, ensuring mdev does not include "ms"
    ping_result=$(ping -c 4 -W 2 10.8.0.1 | tail -1 | awk -F '=' '{print $2}' | awk -F '/' '{print $1, $2, $3, $4}')
    rtt_min=$(echo $ping_result | awk '{print $1}')
    rtt_avg=$(echo $ping_result | awk '{print $2}')
    rtt_max=$(echo $ping_result | awk '{print $3}')
    rtt_mdev=$(echo $ping_result | awk '{print $4}' | sed 's/ ms//')
    echo "$rtt_min $rtt_avg $rtt_max $rtt_mdev" > /home/ubuntu/new_try/data/owd_logs/owd_$i.txt
    echo "RTT Values: min=$rtt_min ms, avg=$rtt_avg ms, max=$rtt_max ms, mdev=$rtt_mdev ms"
    sleep 2
    
    python3 Caller_message.py "START"
    sleep 10
    find_node=$(python3 "$FIND_NODE")
    if [[ -n "$find_node" ]]; then
        guard_ip=$(echo "$find_node" | jq -r '.guard.ip')
        middle_ip=$(echo "$find_node" | jq -r '.middle.ip')
        exit_ip=$(echo "$find_node" | jq -r '.exit.ip')
    else
        echo "Error: Unable to retrieve Tor circuit information."
        pkill openvpn
        continue
    fi

    echo "Guard Node IP: $guard_ip, Middle Node IP: $middle_ip, Exit Node IP: $exit_ip"

    if [[ -n "$guard_ip" && -n "$middle_ip" && -n "$exit_ip" ]]; then
        pcap_filename_inside="data/test_pcaps/${CAPTURE_FILENAME}_inside_$i.pcap"
        echo "Starting packet capture: $pcap_filename_inside"
        # sudo tcpdump -i eth0 -s 85 host "$guard_ip" -w "$pcap_filename_outside" &
        # out_tcp_pid=$!
        sudo tcpdump -i tun0 host "$TUNNEL_IP" -w "$pcap_filename_inside" &
        in_tcp_pid=$!

        # pcap_filename_outside="data/test_pcaps/${CAPTURE_FILENAME}_caller_outside_$i.pcap"
        # echo "Starting packet capture: $pcap_filename_outside"
        # sudo tcpdump -i eth0 -s 85 host 170.64.142.156 -w "$pcap_filename_outside" &
        # out_tcp_dump_pid=$!
        python2.7 $CALLER_SCRIPT caller_recording 10.8.0.1 9001 1009 1234 1001 45 8000 Julius2.wav "$TUNNEL_IP"
        sleep 4
        # kill $in_tcp_pid 2>/dev/null
        killall tcpdump
        pkill python2.7
        mv caller_recording.wav /home/ubuntu/new_try/data/test_caller_recordings/caller_recording_$i.wav
    fi
    
    stop_response=$(python3 Caller_message.py "STOP")
    echo "$stop_response"
    numeric_line=$(echo "$stop_response" | grep -Eo "[0-9.]+ [0-9.]+ [0-9.]+ [0-9.]+ [0-9.]+ [0-9.]+$")
    echo $numeric_line
    read callee_rtt_min callee_rtt_avg callee_rtt_max callee_rtt_mdev callee_pesq_raw callee_pesq_mos <<< "$numeric_line"
    python3 kill-circ.py
    sleep 10
    iperf_output=$(iperf3 -c 10.8.0.1 -bidir)
    sender_bitrate=$(echo "$iperf_output" | grep 'sender' | awk '{print $7}')
    sender_unit=$(echo "$iperf_output" | grep 'sender' | awk '{print $8}')
    receiver_bitrate=$(echo "$iperf_output" | grep 'receiver' | awk '{print $7}')
    receiver_unit=$(echo "$iperf_output" | grep 'receiver' | awk '{print $8}')
    
    pkill openvpn
    kill $vpn_id
    caller_pesq_raw=0
    caller_pesq_mos=0

    # rm chunk_000.wav chunk_001.wav chunk_002.wav chunk_003.wav chunk_004.wav

    # ffmpeg -i /root/new_try/data/test_caller_recordings/caller_recording_$i.wav -f segment -segment_time 30 -c copy chunk_%03d.wav

    
    # if [ -f "chunk_000.wav" ]; then
    #     caller_pesq_raw_0=$(./pesq +8000 Julius2.wav chunk_000.wav | grep "Raw MOS" | awk '{print $7}' )
    #     caller_pesq_mos_0=$(./pesq +8000 Julius2.wav chunk_000.wav | grep "Raw MOS" | awk '{print $8}')
    # fi
    # if [ -f "chunk_001.wav" ]; then
    #     caller_pesq_raw_1=$(./pesq +8000 Julius2.wav chunk_001.wav | grep "Raw MOS" | awk '{print $7}' )
    #     caller_pesq_mos_1=$(./pesq +8000 Julius2.wav chunk_001.wav | grep "Raw MOS" | awk '{print $8}')
    # fi
    # if [ -f "chunk_002.wav" ]; then
    #     caller_pesq_raw_2=$(./pesq +8000 Julius2.wav chunk_002.wav | grep "Raw MOS" | awk '{print $7}' )
    #     caller_pesq_mos_2=$(./pesq +8000 Julius2.wav chunk_002.wav | grep "Raw MOS" | awk '{print $8}')
    # fi
    # if [ -f "chunk_003.wav" ]; then
    #     caller_pesq_raw_3=$(./pesq +8000 Julius2.wav chunk_003.wav | grep "Raw MOS" | awk '{print $7}' )
    #     caller_pesq_mos_3=$(./pesq +8000 Julius2.wav chunk_003.wav | grep "Raw MOS" | awk '{print $8}')
    # fi

    # caller_pesq_mos=$(python3 pesq_avg.py $caller_pesq_mos_0  $caller_pesq_mos_1  $caller_pesq_mos_2  $caller_pesq_mos_3)
    # caller_pesq_raw=$(python3 pesq_avg.py $caller_pesq_raw_0  $caller_pesq_raw_1  $caller_pesq_raw_2  $caller_pesq_raw_3)
    if [ -f "data/test_caller_recordings/caller_recording_$i.wav" ]; then
        caller_pesq_raw=$(./pesq +8000 Julius2.wav /home/ubuntu/new_try/data/test_caller_recordings/caller_recording_$i.wav | grep "Raw MOS" | awk '{print $7}' )
        caller_pesq_mos=$(./pesq +8000 Julius2.wav /home/ubuntu/new_try/data/test_caller_recordings/caller_recording_$i.wav | grep "Raw MOS" | awk '{print $8}')
    fi

    json_entry=$(jq -n \
        --arg iteration_no "$i" \
        --arg timestamp "$timestamp" \
        --arg guard_ip "$guard_ip" \
        --arg middle_ip "$middle_ip" \
        --arg exit_ip "$exit_ip" \
        --arg rtt_min "$rtt_min" \
        --arg rtt_avg "$rtt_avg" \
        --arg rtt_max "$rtt_max" \
        --arg rtt_mdev "$rtt_mdev" \
        --arg callee_rtt_min "$callee_rtt_min" \
        --arg callee_rtt_avg "$callee_rtt_avg" \
        --arg callee_rtt_max "$callee_rtt_max" \
        --arg callee_rtt_mdev "$callee_rtt_mdev" \
        --arg callee_pesq_raw "$callee_pesq_raw" \
        --arg callee_pesq_mos "$callee_pesq_mos" \
        --arg caller_pesq_raw "$caller_pesq_raw" \
        --arg caller_pesq_mos "$caller_pesq_mos" \
        --arg sender_bitrate "$sender_bitrate" \
        --arg sender_unit "$sender_unit" \
        --arg receiver_bitrate "$receiver_bitrate" \
        --arg receiver_unit "$receiver_unit" \
        '{
            iteration_no: $iteration_no,
            timestamp: $timestamp,
            path: {guard_node: $guard_ip, middle_node: $middle_ip, exit_node: $exit_ip},
            rtt: {min: $rtt_min, avg: $rtt_avg, max: $rtt_max, mdev: $rtt_mdev},
            callee_rtt: {min: $callee_rtt_min, avg: $callee_rtt_avg, max: $callee_rtt_max, mdev: $callee_rtt_mdev},
            pesq: {caller_raw: $caller_pesq_raw, caller_mos: $caller_pesq_mos, callee_raw: $callee_pesq_raw, callee_mos: $callee_pesq_mos},
            iperf: {sender: {bitrate: $sender_bitrate, unit: $sender_unit}, receiver: {bitrate: $receiver_bitrate, unit: $receiver_unit}}
        }')

    if [ "$i" -lt $((n - 1)) ]; then
        echo "$json_entry," >> "$LOG_FILE1"
    else
        echo "$json_entry" >> "$LOG_FILE1"
    fi
    sleep 10
done

echo "]" >> "$LOG_FILE1"
zip -r data.zip data
echo "Operation completed $n times. Data stored in $LOG_FILE1."
