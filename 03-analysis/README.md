# Analysis

This directory contains the scripts, tools, reference audio, and intermediate outputs used to analyze the collected VoIP call data. The analysis includes codec-wise quality evaluation, location-wise evaluation, jitter analysis, jitter/delay extraction, PESQ computation, and throughput/one-way-delay analysis.

## Directory Structure

```text
analysis/
├── Codecwise-Analysis/
├── jitter-analysis/
├── jitter-delay-extractions/
├── Locatiowise-Analysis/
├── Original_audio.wav
├── pesq/
├── PESQ/
├── README.md
└── Throughput-OWD/
```

## Overview

The analysis workflow starts from the collected VoIP recordings and packet traces. The scripts in this directory extract packet-timing metrics, compute PESQ/MOS-LQO scores, and generate the results used for comparing VoIP performance across codecs, locations, and network conditions.

The main analysis components are:

1. Codec-wise analysis
2. Location-wise analysis
3. Jitter analysis
4. Jitter and delay extraction
5. PESQ computation
6. Throughput and one-way delay analysis

## 1. Codec-wise Analysis

Directory:

```text
Codecwise-Analysis/
```

This directory contains the scripts and outputs used to analyze VoIP quality across different codecs.

The codec-wise analysis compares the performance of different codecs such as OPUS, G.711, SPEEX, and GSM. PESQ/MOS-LQO scores are used to evaluate how each codec performs under the observed network conditions.

This analysis helps identify whether some codecs are more resilient to Tor-induced impairments than others.

## 2. Location-wise Analysis

Directory:

```text
Locatiowise-Analysis/
```

This directory contains the scripts and outputs used to analyze VoIP performance across different caller-callee location pairs.

The location-wise analysis studies how geographic placement, network paths, and Tor circuit characteristics affect call quality. It is used to compare performance across different experimental locations and identify location pairs where VoIP quality is relatively better or worse.

## 3. Jitter Analysis

Directory:

```text
jitter-analysis/
```

This directory contains scripts used to analyze packet jitter in the collected VoIP traces.

Jitter analysis is used to study packet timing instability during VoIP calls. The scripts compute and analyze jitter-related statistics such as mean jitter, median jitter, maximum jitter, jitter range, interquartile range, and standard deviation.

This analysis is important because packet timing distortion is one of the major factors affecting VoIP quality.

## 4. Jitter and Delay Extraction

Directory:

```text
jitter-delay-extractions/
```

This directory contains scripts for extracting jitter and delay-related metrics from packet-level traces.

The scripts process the collected network traces and derive timing metrics such as packet inter-arrival variation, jitter, and delay. These extracted metrics are used in later analysis to study the relationship between packet timing behavior and VoIP quality.


## 5. PESQ Computation

Directories:

```text
pesq/
PESQ/
```

These directories contain PESQ-related files used for computing speech quality scores.

Depending on the local setup, these directories may contain PESQ binaries, wrapper scripts, intermediate files, or output score files. PESQ/MOS-LQO values are used as the main objective speech quality metric in the analysis.

The general PESQ workflow is:

1. Use `Original_audio.wav` as the reference audio.
2. Use the recorded VoIP call audio as the degraded audio.
3. Run PESQ to compare the degraded recording against the reference.
4. Extract the MOS-LQO score from the PESQ output.
5. Use the extracted scores for codec-wise, location-wise, and overall quality analysis.

## 6. Throughput and One-Way Delay Analysis

Directory:

```text
Throughput-OWD/
```

This directory contains scripts and outputs related to throughput and one-way delay analysis.

Throughput measurements are used to check whether the network path provides sufficient bandwidth for VoIP traffic. One-way delay estimates are used to study whether delay alone explains the observed VoIP quality degradation.

These measurements are used alongside jitter and PESQ results to understand the broader network conditions during the experiments.

## Expected Inputs

The analysis scripts may require one or more of the following inputs:

* recorded VoIP audio files,
* packet traces,
* PESQ output files,
* jitter and delay metric files,
* throughput measurement files,
* caller/callee metadata,
* codec labels,
* location-pair labels.

The required input paths may vary across scripts. Update any machine-specific paths before running the scripts in a new environment.

## Expected Outputs

The scripts in this directory may generate:

* PESQ/MOS-LQO score files,
* jitter summary files,
* delay summary files,
* throughput summary files,
* codec-wise comparison plots,
* location-wise comparison plots,
* CDF plots,
* tables used in the paper,
* intermediate CSV files.

## Notes

The analysis scripts assume that the data collection phase has already been completed and that the required recordings and trace files are available in the expected directory structure.

Some scripts may contain local paths specific to the original experimental environment. These paths should be updated before reproducing the analysis on another machine.


