# Tor Turns Talk Choppy: Why VoIP over Tor Doesn’t Always Work?
Voice over Internet Protocol (VoIP) enables voice communication over IP networks but faces significant privacy challenges, prompting users to explore anonymity networks like Tor. While historically considered unsuitable for real-time applications due to latency and bandwidth constraints, improved Tor performance has revived interest in its feasibility for VoIP. Earlier studies suggested that VoIP over Tor could achieve acceptable quality under favorable conditions. However, recent developments, including increased user traffic and distributed denial-of-service (DDoS) attacks, have strained the network, raising questions about its viability for real-time communications.

This study takes a fresh look at the feasibility of VoIP over Tor by analyzing call quality metrics, including Perceptual Evaluation of Speech Quality (PESQ) and One-Way Delay (OWD). Our findings reveal a significant decline in call quality, with only 16\% of calls achieving acceptable PESQ scores(>3.0) compared to 85% in prior studies. A detailed analysis highlights jitter as a potential factor in degraded call quality, with many calls exceeding acceptable thresholds. Additionally, we evaluate performance across codecs, geographic locations, and 2-hop Tor circuits, providing a comprehensive perspective. This work challenges earlier claims and underscores the limitations of VoIP over Tor in the current network conditions.

## Directory structure
The sample directory contains sample outputs of network traces and recorded audio. To calculate the jitter of the call received at the caller side, use caller.pcap, and vice versa.

The scripts directory includes the scripts used for data collection.

Original_audio.wav is the audio file used to initiate the calls from both sides.

client.ovpn provides a sample OpenVPN configuration file.

server.conf provides a sample OpenVPN server configuration file.

pesq is the binary used for calculating PESQ scores.

All cloud-hosted machines referenced in this dataset have been shut down and terminated.
