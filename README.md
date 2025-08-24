# Tor Turns Talk Choppy: Why VoIP over Tor Doesn’t Always Work?

## Abstract
Voice over Internet Protocol (VoIP) enables voice communication over IP networks but faces significant privacy challenges, prompting users to explore anonymity networks like Tor. While historically considered unsuitable for real-time applications due to latency and bandwidth constraints, improved Tor performance has revived interest in its feasibility for VoIP. Earlier studies suggested that VoIP over Tor could achieve acceptable quality under favorable conditions. However, recent developments, including increased user traffic and distributed denial-of-service (DDoS) attacks, have strained the network, raising questions about its viability for real-time communications.

This study takes a fresh look at the feasibility of VoIP over Tor by analyzing call quality metrics, including Perceptual Evaluation of Speech Quality (PESQ) and One-Way Delay (OWD). Our findings reveal a significant decline in call quality, with only 16% of calls achieving acceptable PESQ scores(>3.0) compared to 85% in prior studies. A detailed analysis highlights jitter as a potential factor in degraded call quality, with many calls exceeding acceptable thresholds. Additionally, we evaluate performance across codecs, geographic locations, and 2-hop Tor circuits, providing a comprehensive perspective. This work challenges earlier claims and underscores the limitations of VoIP over Tor in the current network conditions.

## 1. System Set up and Data Collection

- **VoIP Server**: FreeSWITCH based VoIP server that handles all VoIP-related functionalities. [Seting up VoIP server](./readme/VoIP-server.md).
- **VoIP Client**: Placing the VoIP calls using the clients  [Seting up VoIP clients](./readme/VoIP-client.md).

Once the VoIP clients are setup, one would act as call initiator(caller) and the other one as receiver(callee). The scripts for placing the calls are present under the directory [DataCollection](./DataCollection). The follwoign commands can be used to place the calls:

- *Caller*: python2.7 caller.py audio 10.8.0.1 9001 1001 1234 1008 45 8000 Julius2.wav 10.8.0.2
- *Callee*: python callee.py 10.8.0.1 9001 1008 1234 30 8000 Julius2.wav recording_

1. Calculate the PESQ scores using the script "test_pesq.py" under the directory [PESQ_check](PESQ_check). Make sure you provide the correct reference audio sample.
2. Plot the scores using "PESQ_plot.ipynb"

## License

This project is licensed under the XYZ License - see the [LICENSE.md](./LICENSE.md) file for details (if you have one).
