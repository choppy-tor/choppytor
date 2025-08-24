#!/bin/bash

# Base tmux session name
MAIN_SESSION="jit_callee"

# Array of dataset paths
DATASETS=(
"/home/jithin/data/IMC/NewData/Piyush/oneway_g711_2hop-20250529T164542Z-1-001/oneway_g711_2hop/1Frank-Lond/callee/data/test_pcaps"
"/home/jithin/data/IMC/NewData/Piyush/oneway_g711_2hop-20250529T164542Z-1-001/oneway_g711_2hop/2sydney-frank/callee/data/test_pcaps"
"/home/jithin/data/IMC/NewData/Piyush/oneway_g711_2hop-20250529T164542Z-1-001/oneway_g711_2hop/3Bangl-nyc/callee/data/test_pcaps"
"/home/jithin/data/IMC/NewData/Piyush/oneway_g711_2hop-20250529T164542Z-1-001/oneway_g711_2hop/4singapore-nyc/callee/data/test_pcaps"
"/home/jithin/data/IMC/NewData/Piyush/oneway_g711_2hop-20250529T164542Z-1-001/oneway_g711_2hop/5sans-amster/callee/data/test_pcaps"
"/home/jithin/data/IMC/NewData/Piyush/oneway_g711_2hop-20250529T164542Z-1-001/oneway_g711_2hop/6nyc-syd/callee/data/test_pcaps"
"/home/jithin/data/IMC/NewData/Piyush/oneway_g711_2hop-20250529T164542Z-1-001/oneway_g711_2hop/7CapeTown-Seoul/callee/data/test_pcaps"
"/home/jithin/data/IMC/NewData/Piyush/oneway_g711_2hop-20250529T164542Z-1-001/oneway_g711_2hop/8Jakarta-Mexico/callee/data/test_pcaps"
"/home/jithin/data/IMC/NewData/Piyush/oneway_g711_2hop-20250529T164542Z-1-001/oneway_g711_2hop/9Osaka-UAE/callee/data/test_pcaps"
"/home/jithin/data/IMC/NewData/Piyush/oneway_g711_2hop-20250529T164542Z-1-001/oneway_g711_2hop/10SauPaul-malaysia/callee/data/test_pcaps"
"/home/jithin/data/IMC/NewData/Piyush/oneway_g711_2hop-20250529T164542Z-1-001/oneway_g711_2hop/11TelAviv-Sydney3/callee/data/test_pcaps"

)

# Create the main tmux session (detached)
tmux new-session -d -s "$MAIN_SESSION" -n "main_window"

# Open each dataset processing in a new tmux window
for i in "${!DATASETS[@]}"; do
    WINDOW_NAME="jitter_$i"

    # Create a new tmux window
    tmux new-window -t "$MAIN_SESSION" -n "$WINDOW_NAME"

    # Run the script inside that window
    tmux send-keys -t "$MAIN_SESSION:$WINDOW_NAME" "python3 jitter_Callee_temp.py ${DATASETS[i]}" C-m
done

# Select the first window by default
tmux select-window -t "$MAIN_SESSION:0"

# Attach to the main tmux session
tmux attach-session -t "$MAIN_SESSION"
