# The Monitored Mile: Safeguarding VoIP Calls over Tor Against Surveillance

## General Overview
The research project focuses on identifying VoIP streams within Tor. Its primary objective is to implement a transformational defense strategy, safeguarding against surveillance by adversaries. This repository provides an in-depth guide, covering aspects such as setting up and configuring the system's various components. It delves into attack strategies, from basic throughput-based detection to ML-based attack models, and also outlines methods to counteract these attacks.

## 1. System Set up

- **VoIP Server**: FreeSWITCH based VoIP server that handles all VoIP-related functionalities. [Seting up VoIP server](./VoIP-server.md).
- **VoIP Client**: Placing the VoIP calls using the clients  [Seting up VoIP clients](./VoIP-client.md).

## 2. How to place a single VoIP call between two peers?

Once the VoIP clients are setup, one would act as call initiator(caller) and the other one as receiver(callee). The scripts for placing the calls are present under the directory [DataCollection](./DataCollection). The follwoign commands can be used to place the calls:
- *Caller*: python2.7 ~/caller/caller.py ~/caller/audio 10.8.0.1 9001 1001 1234 1008 45 8000 ~/caller/Julius2.wav 10.8.0.2
- *Callee*: python callee.py 10.8.0.1 9001 1008 1234 30 8000 Julius2.wav recording_

## 3. Data Collection(V,D,VD)

Use the script(main.py) under the directory [DataCollection](./DataCollection) for automated data collection for various traffic categories.

## 4. Throughput Analysis

A throughput based analysis reveals VoIP alone flows. For extracting the througput and perform the analysis by plotting refer the [steps](./ThroughputAnalysis/ReadMe.md).

## 5. Feature Exraction, constructing the attack models and testing the defense.
The time and volume related features were extracted, models were built and detected VoIP flows(even when ther are intersperesed), and tested gaianst defense. Refer [steps](./ML_Attack_Defense_testing/ReadMe.md)

## 6. Defense Source code and execution 
Devised a solution involving the “smart” transmission of cover traffic that confuses the ML-model to misclassify VoIP bearing flows as HTTP downloads. Refer [steps](Defense/ReadMe.md)

## 7. PESQ Calculation
1. Calculate the PESQ scores using the script "test_pesq.py" under the directory [PESQ_check](PESQ_check). Make sure you provide the correct reference audio sample.
2. Plot the scores using "PESQ_plot.ipynb"

## License

This project is licensed under the XYZ License - see the [LICENSE.md](./LICENSE.md) file for details (if you have one).
