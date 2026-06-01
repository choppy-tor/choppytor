# VoIP over Tor Artifact Repository

This repository contains the artifacts used for our VoIP-over-Tor experiments. The repository includes setup instructions, data collection scripts, analysis scripts, Tor instrumentation details, processed datasets, and a small sample of raw data.

The goal of this artifact is to help reproduce the experimental workflow and inspect the scripts, configurations, and data used in the study.

> **Note:** The directory tree shown in this repository is partial. Some raw data files are represented only as samples because the complete dataset is large.

## Repository Structure

```text
.
├── 01-system-setup/
├── 02-data-collection-steps/
├── 03-analysis/
├── 04-Tor-Instrumentation/
└── 05-data/
```

## 1. System Setup

Directory:

```text
01-system-setup/
```

This directory contains setup instructions and configuration files required to prepare the experimental environment.

It includes documentation for:

* [FreeSWITCH setup](01-system-setup/freeswitch.md)
* [OpenVPN setup](01-system-setup/openvpn.md)
* [Tor setup](01-system-setup/tor.md)
* [VoIP client setup](01-system-setup/voip-client.md)

The `configs/` directory contains configuration files for FreeSWITCH, OpenVPN, PJSIP, and Tor.

```text
01-system-setup/
├── configs/
│   ├── freeswitch/
│   ├── openvpn/
│   ├── pjsip/
│   └── tor/
├── freeswitch.md
├── openvpn.md
├── tor.md
└── voip-client.md
```

## 2. Data Collection Steps

Directory:

```text
02-data-collection-steps/
```

This directory contains the caller-side and callee-side scripts used for collecting VoIP call data.

The data collection setup is divided into two main components:

* `caller/`: scripts used to place calls and automate caller-side data collection.
* `callee/`: scripts used to answer calls and play/record audio on the callee side.

```text
02-data-collection-steps/
├── caller/
│   ├── audio-samples/
│   └── auto/
├── callee/
│   ├── audio-samples/
│   ├── automate_callee.sh
│   └── callee.py
├── pesq/
└── README.md
```

The caller-side automation scripts handle tasks such as repeated call placement, recording, Tor path handling, circuit management, and PESQ calculation. The callee-side scripts answer incoming calls and play the selected audio samples.

The audio samples used in the experiments are included under the `audio-samples/` directories.

## 3. Analysis

Directory:

```text
03-analysis/
```

This directory contains the scripts, notebooks, plots, and intermediate outputs used for analyzing the collected VoIP data.

The analysis includes:

* codec-wise PESQ analysis,
* location-wise PESQ analysis,
* jitter analysis,
* jitter and delay extraction,
* PESQ score processing,
* throughput and one-way delay analysis.

```text
03-analysis/
├── Codecwise-Analysis/
├── jitter-analysis/
├── jitter-delay-extractions/
├── Locatiowise-Analysis/
├── PESQ/
├── Throughput-OWD/
└── README.md
```

The analysis outputs include PDF plots, CSV summaries, and Jupyter notebooks used to generate the results.

## 4. Tor Instrumentation

Directory:

```text
04-Tor-Instrumentation/
```

This directory documents the Tor source-code instrumentation used to identify and trace VoIP and web circuits inside Tor.

```text
04-Tor-Instrumentation/
├── client/
│   └── README.md
├── middle-relay/
│   └── README.md
└── README.md
```

The instrumentation introduces a custom relay command, `RELAY_COMMAND_EXPTAG`, to tag selected circuits during controlled experiments. The client-side instrumentation tags circuits based on traffic type, while the middle-relay instrumentation receives and logs the tag information.

This instrumentation was used only for controlled measurements and is not intended for production Tor deployments.

## 5. Data

Directory:

```text
05-data/
```

This directory contains processed data, instrumentation logs, and a small sample of raw experimental data.

```text
05-data/
├── Extracted-Data/
├── Instrumentation-data/
└── Sample-Raw-Data/
```

### Extracted Data

```text
05-data/Extracted-Data/
```

This directory contains processed CSV files used for analysis, including:

* `Tor-data.csv`
* `Non-tor-data.csv`
* `Two-hop-Tor-data.csv`

These files contain extracted metrics used in the paper-level analysis.

### Instrumentation Data

```text
05-data/Instrumentation-data/
```

This directory contains sample logs generated from the Tor instrumentation.

For example:

```text
sample-middle-node.log
```

### Sample Raw Data

```text
05-data/Sample-Raw-Data/
```

This directory contains a small sample of raw data from the experiments, including recorded audio files and packet captures.

The complete raw dataset is large, so only representative samples are included in this repository.

## Typical Workflow

A typical reproduction workflow is:

1. Follow the setup instructions in `01-system-setup/`.
2. Use the scripts in `02-data-collection-steps/` to collect caller/callee recordings and packet traces.
3. Use the scripts in `03-analysis/` to extract metrics and generate plots.
4. Refer to `04-Tor-Instrumentation/` for details about the modified Tor source-code instrumentation.
5. Use the processed files in `05-data/Extracted-Data/` for direct analysis.

## Notes

Some scripts may contain paths specific to the original experimental environment. These paths should be updated before running the scripts on a new machine.


