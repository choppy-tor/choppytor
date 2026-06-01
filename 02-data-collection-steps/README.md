# Data Collection

This directory contains the scripts and audio samples used for collecting VoIP call data. The data collection setup is divided into two parts: caller-side scripts and callee-side scripts.

## Directory Structure

```text
02-data-collection/
├── caller/
│   ├── caller.py
│   ├── audio-samples/
│   └── auto/
└── callee/
    ├── callee.py
    └── audio-samples/
```

## 1. Caller-Side Data Collection

The `caller/` directory contains the scripts used to initiate VoIP calls from the caller side.

### 1.1 `caller.py`

The `caller.py` script is responsible for placing a VoIP call. Once the call is connected, the script plays out the selected audio sample through the established call.

This script is used as the main caller-side component in the experiment.

### 1.2 Audio Samples

The audio samples used for placing calls are included in the caller-side directory. These samples are played during the call after the connection is established.

```text
caller/audio-samples/
```

### 1.3 Automation Scripts

The `caller/auto/` directory contains scripts for automating the data collection process.

These scripts handle tasks such as:

* automating repeated VoIP calls,
* recording call audio,
* managing Tor paths,
* running PESQ calculations,
* organizing collected outputs.

```text
caller/auto/
```

The automation scripts were used to run multiple iterations of the experiment and reduce manual intervention during data collection.

## 2. Callee-Side Data Collection

The `callee/` directory contains the scripts used on the callee side.

### 2.1 `callee.py`

The `callee.py` script is responsible for answering incoming VoIP calls. Once the call is connected, it plays out the recorded audio from the callee side.

This allows the experiment to collect audio recordings and quality measurements from both ends of the call.

### 2.2 Audio Samples

The audio samples used by the callee are also included in the callee-side directory.

```text
callee/audio-samples/
```

## 3. Data Collection Workflow

The overall data collection workflow is as follows:

1. Start the VoIP server and required network tunnel.
2. Start the callee-side script to listen for and answer incoming calls.
3. Run the caller-side script to place a call.
4. After the call is connected, the selected audio sample is played.
5. The call audio is recorded.
6. Automation scripts repeat the process across multiple iterations.
7. The collected recordings are processed for PESQ and related quality metrics.
8. Tor path information is handled by the automation scripts where applicable.

## 4. Notes

The scripts in this directory assume that the system setup, including FreeSWITCH, OpenVPN, and Tor, has already been completed.

The audio samples included in this directory were used as input speech samples for the VoIP experiments. Different samples may result in different objective quality scores, depending on how each sample responds to network impairments.

Before making the repository public, remove or anonymize any machine-specific paths, IP addresses, credentials, private keys, or temporary experimental outputs.

