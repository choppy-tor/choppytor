#!/bin/bash

# Base tmux session name
MAIN_SESSION="jit_callee"

# Array of dataset paths
DATASETS=(
"/home/haxor/data/IMC/NewData/Tor/AsiaCCS-Tor/batch-5/stockholm_frank_G711/callee/data/test_pcaps"
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
