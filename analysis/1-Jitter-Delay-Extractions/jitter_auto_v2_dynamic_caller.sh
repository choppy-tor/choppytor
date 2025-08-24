#!/bin/bash

# Base tmux session name
MAIN_SESSION="jit_caller"

# Array of dataset paths
DATASETS=(
"/home/jithin/data/IMC/NewData/Piyush/oneway_3hop_opus-20250531T114753Z-1-001/oneway_3hop_opus/1Frank-Lond/caller/data/test_pcaps"
"/home/jithin/data/IMC/NewData/Piyush/oneway_3hop_opus-20250531T114753Z-1-001/oneway_3hop_opus/2sydney-frank/caller/data/test_pcaps"
"/home/jithin/data/IMC/NewData/Piyush/oneway_3hop_opus-20250531T114753Z-1-001/oneway_3hop_opus/3Bangl-nyc/caller/data/test_pcaps"
"/home/jithin/data/IMC/NewData/Piyush/oneway_3hop_opus-20250531T114753Z-1-001/oneway_3hop_opus/4singapore-nyc/caller/data/test_pcaps"
"/home/jithin/data/IMC/NewData/Piyush/oneway_3hop_opus-20250531T114753Z-1-001/oneway_3hop_opus/5sans-amster/caller/data/test_pcaps"
"/home/jithin/data/IMC/NewData/Piyush/oneway_3hop_opus-20250531T114753Z-1-001/oneway_3hop_opus/6nyc-syd/caller/data/test_pcaps"
"/home/jithin/data/IMC/NewData/Piyush/oneway_3hop_opus-20250531T114753Z-1-001/oneway_3hop_opus/7CapeTown-Seoul/caller/data/test_pcaps"
"/home/jithin/data/IMC/NewData/Piyush/oneway_3hop_opus-20250531T114753Z-1-001/oneway_3hop_opus/8Jakarta-Mexico/caller/data/test_pcaps"
"/home/jithin/data/IMC/NewData/Piyush/oneway_3hop_opus-20250531T114753Z-1-001/oneway_3hop_opus/9Osaka-UAE/caller/data/test_pcaps"
"/home/jithin/data/IMC/NewData/Piyush/oneway_3hop_opus-20250531T114753Z-1-001/oneway_3hop_opus/10SauPaul-malaysia/caller/data/test_pcaps"
"/home/jithin/data/IMC/NewData/Piyush/oneway_3hop_opus-20250531T114753Z-1-001/oneway_3hop_opus/11TelAviv-Sydney3/caller/data/test_pcaps"
)

# Create the main tmux session (detached)
tmux new-session -d -s "$MAIN_SESSION" -n "main_window"

# Open each dataset processing in a new tmux window
for i in "${!DATASETS[@]}"; do
    WINDOW_NAME="jitter_$i"

    # Create a new tmux window
    tmux new-window -t "$MAIN_SESSION" -n "$WINDOW_NAME"

    # Run the script inside that window
    tmux send-keys -t "$MAIN_SESSION:$WINDOW_NAME" "python3 jitter_dynamic_Caller.py ${DATASETS[i]}" C-m
done

# Select the first window by default
tmux select-window -t "$MAIN_SESSION:0"

# Attach to the main tmux session
tmux attach-session -t "$MAIN_SESSION"
