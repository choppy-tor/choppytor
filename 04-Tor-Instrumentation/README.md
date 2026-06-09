# Tor Instrumentation

This directory documents the Tor source-code instrumentation used in our experiments. The instrumentation was added to identify and trace circuits carrying VoIP and web traffic inside Tor.

The implementation introduces a custom relay command, `RELAY_COMMAND_EXPTAG`, which is used to tag selected circuits during experiments. The tag is sent once per circuit and is used only for measurement purposes.

## Directory Structure

```text
tor-instrumentation/
├── README.md
├── client-side.md
├── middle-relay.md
└── notes.md
```

## Overview

The instrumentation consists of two main parts:

1. **Client-side instrumentation**

   * Identifies circuits corresponding to selected traffic types.
   * Tags circuits based on the destination port.
   * Sends an experiment tag cell once per circuit.

2. **Middle-relay instrumentation**

   * Receives the experiment tag cell.
   * Stores the tag information in the relay-side circuit state.
   * Logs the circuit type and tag identifier.
   * Does not forward the experiment tag cell further.

## Traffic Types

The experiment distinguishes between two traffic types:

| Traffic type |   Port | Tag value |
| ------------ | -----: | --------: |
| Web          |   `80` |       `1` |
| VoIP/OpenVPN | `1194` |       `2` |

The OpenVPN tunnel carrying VoIP traffic used TCP port `1194`. Therefore, circuits carrying traffic to port `1194` were tagged as VoIP circuits.

## Custom Relay Command

The instrumentation defines a new relay command:

```c
#define RELAY_COMMAND_EXPTAG 250
```

The experiment tag payload has the following structure:

```text
"XPTG" + version + type + tag_id
```

The payload size is 14 bytes:

| Field        |    Size | Description              |
| ------------ | ------: | ------------------------ |
| Magic string | 4 bytes | `XPTG`                   |
| Version      |  1 byte | Experiment tag version   |
| Type         |  1 byte | Web or VoIP              |
| Tag ID       | 8 bytes | Random 64-bit identifier |

## Client-Side Changes

Client-side changes are documented in:

```text
client-side.md
```

The main client-side changes are made in:

```text
src/core/or/or.h
src/core/or/circuituse.c
src/core/or/conflux.c
```

The client-side code identifies the traffic type using the destination port. If the destination port corresponds to web traffic or VoIP traffic, the client sends a custom experiment tag cell once for that circuit.

## Middle-Relay Changes

Middle-relay changes are documented in:

```text
middle-relay.md
```

The main middle-relay changes are made in:

```text
src/core/or/or.h
src/core/or/or_circuit_st.h
src/core/or/relay.c
src/core/or/conflux.c
```

The middle relay receives the experiment tag cell, extracts the traffic type and tag identifier, stores them in the relay-side circuit structure, and logs the received tag.

The experiment tag cell is used only for measurement and is not forwarded to the next relay.

## Conflux Handling

The new relay command is excluded from Conflux multiplexing by adding `RELAY_COMMAND_EXPTAG` to the command handling in:

```text
src/core/or/conflux.c
```

This suppresses warnings related to unknown relay commands and ensures that experiment tag cells are not multiplexed.

## Tor Version

The instrumentation was applied to:

```text
Tor 0.4.8.21
```

## Notes

This instrumentation is intended only for controlled experimental measurements. It should not be used in production Tor deployments.

