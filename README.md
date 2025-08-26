# Tor Turns Talk Choppy: Why VoIP over Tor Doesn’t Always Work?

## Abstract
Voice over Internet Protocol (VoIP) enables voice communication over IP networks but faces significant privacy challenges, prompting users to explore anonymity networks like Tor. While historically considered unsuitable for real-time applications due to latency and bandwidth constraints, improved Tor performance has revived interest in its feasibility for VoIP. Earlier studies suggested that VoIP over Tor could achieve acceptable quality under favorable conditions. However, recent developments, including increased user traffic and distributed denial-of-service (DDoS) attacks, have strained the network, raising questions about its viability for real-time communications.

This study takes a fresh look at the feasibility of VoIP over Tor by analyzing call quality metrics, including Perceptual Evaluation of Speech Quality (PESQ) and One-Way Delay (OWD). Our findings reveal a significant decline in call quality, with only 16% of calls achieving acceptable PESQ scores(>3.0) compared to 85% in prior studies. A detailed analysis highlights jitter as a potential factor in degraded call quality, with many calls exceeding acceptable thresholds. Additionally, we evaluate performance across codecs, geographic locations, and 2-hop Tor circuits, providing a comprehensive perspective. This work challenges earlier claims and underscores the limitations of VoIP over Tor in the current network conditions.

## 1. Data
Our data contains two directories.
- **Sample Raw Data**: The directory contains raw data of the network traces in PCAP format and the recorded audio files in wav format. Please note that we have provided only some sample data due to storage restrictions.

- **Extracted Data**: The directory contains the extratced data from the PCAPs and the recorded audio files in CSV format. The files contains the follwing fields:
    1. Tor status: Whether the call is directed through Tor or not.
    2. Codec: Codec used for placing the calls.
    3. PESQ RAW: Direct output of the PESQ algorithm before any mapping or calibration. Available for caller and callee recordings.
    4. PESQ MOS: This is the mapped version of the scores MOS-LQO (Listening Quality Objective) so that results better correlate with human Mean Opinion Scores from listening experiments. We used this metric for the ananlysis. Available for both caller and callee recordings.
    5. Jitter Statistics: Various statistical values of caller and callee side jitter values are included. This includes mean, median, maximum, range(max-min), Inter-Quartile-Range(IQR) and the standard deviations of the jitter values of individual call.

- **Sample-VPN-Config-FIles**: The directroy contains sample VPN configuration files to connect to the VoIP/VPN server for placing the VoIP calls. The callee is co-located with the VoIP server.


## 2. System Set up and Data Collection

- **VoIP Server**: FreeSWITCH based VoIP server that handles all VoIP-related functionalities. [Seting up VoIP server](./readme/VoIP-server.md).
- **VoIP Client**: Placing the VoIP calls using the clients  [Seting up VoIP clients](./readme/VoIP-client.md).

Once the VoIP clients are setup, one would act as call initiator(caller) and the other one as receiver(callee). The scripts for placing the calls are present under the directory [scripts](./data-collection-scripts). The follwoign commands can be used to place the calls:

Caller: 
```bash
python2.7 caller.py audio 10.8.0.1 9001 1001 1234 1008 45 8000 Julius2.wav 10.8.0.2
```

Callee:
```bash
python callee.py 10.8.0.1 9001 1008 1234 30 8000 Julius2.wav recording_
```

PESQ for a recorded audio file can be calaulated as follows:
```bash
./pesq +8000 <reference-file> <degraded-file>
```

To automate the data collection, use the script [automate.sh](./data-collection-scripts/automate/automate.sh). All required scripts are provided in the same directory.
```bash
./automate.sh <number of iterations> <path to OVPN file> <path to Python script to get GUARD IP> <capture_filename_variable> <CALLER_SCRIPT> <TUNNEL_IP> <path to Python script to get MIDDLE IP> <path to Python script to get EXIT IP><Complete node file>
```
