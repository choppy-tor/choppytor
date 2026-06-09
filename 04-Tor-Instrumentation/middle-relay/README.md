# Tor Middle-Relay Instrumentation for Circuit Tagging and EWMA Scheduler Logs

This document describes the middle-relay changes made to Tor for the experimental artifact. The purpose of these changes is to let an instrumented middle relay receive one-time circuit tags from the Tor client and then log scheduler-related events for the corresponding circuits.

The implementation was done on Tor `0.4.8.21`.

---

## 1. Objective of the Middle-Relay Changes

The middle relay was modified to support two main tasks:

1. Receive and parse the experimental circuit tag sent by the Tor client.
2. Log internal scheduler events for tagged circuits, especially events related to Tor's EWMA circuit scheduler.

The client sends the tag only once per circuit. After the middle relay receives the tag, it associates the local circuit object with a traffic type such as VoIP or web. Later scheduler logs can then be mapped back to the traffic type using the circuit identifier.

---

## 2. High-Level Design

The middle relay handles a custom relay command:

```c
RELAY_COMMAND_EXPTAG
```

The payload begins with the magic string:

```c
#define EXPTAG_MAGIC0 'X'
#define EXPTAG_MAGIC1 'P'
#define EXPTAG_MAGIC2 'T'
#define EXPTAG_MAGIC3 'G'
```

The magic value `XPTG` is used to verify that the received relay command belongs to our experiment.

Once the tag is received, the middle relay records metadata in the circuit structure. This metadata is then used only for measurement and logging.

---

## 3. Files Modified in the Middle Relay

The middle-relay changes are mainly in Tor's relay-cell handling and circuit-scheduler code.

Typical files involved are:

```text
src/core/or/relay.h
src/core/or/relay.c
src/core/or/circuitlist.c
src/core/or/or_circuit_st.h
src/core/or/circuit_st.h
src/core/or/scheduler.c
src/core/or/scheduler_kist.c
src/core/or/scheduler_vanilla.c
```

The exact set of files depends on where the EWMA logging hooks are placed.

For EWMA-specific logging, the most relevant scheduler-related files are usually:

```text
src/core/or/scheduler.c
src/core/or/scheduler_vanilla.c
src/core/or/relay.c
```

---

## 4. Adding Per-Circuit Experimental Metadata

To remember the traffic type after receiving the tag, we added experimental metadata to the relay-side circuit structure.

Conceptually, each circuit stores:

```c
int exptag_seen;
int exptag_type;
uint64_t exptag_id;
```

The fields have the following meaning:

| Field | Meaning |
|---|---|
| `exptag_seen` | Whether this relay has received an experimental tag for the circuit |
| `exptag_type` | Traffic type: VoIP, web, or unknown |
| `exptag_id` | Identifier sent by the client for correlating logs |

Conceptual traffic-type values:

```c
#define EXPTAG_TYPE_NONE 0
#define EXPTAG_TYPE_VOIP 1
#define EXPTAG_TYPE_WEB  2
```

These fields are used only by the instrumented build.

---

## 5. Receiving the Experimental Relay Command

The middle relay receives relay cells through Tor's normal relay-cell processing path. The custom command is handled inside the relay command dispatcher.

The relevant function is typically:

```c
handle_relay_cell_command()
```

A new case is added for:

```c
RELAY_COMMAND_EXPTAG
```

Conceptual implementation:

```c
case RELAY_COMMAND_EXPTAG:
{
    if (rh.length < EXPTAG_PAYLOAD_LEN) {
        log_info(LD_OR, "EXPTAG short payload");
        return 0;
    }

    const uint8_t *p = (const uint8_t *)cell->payload;

    if (p[0] != EXPTAG_MAGIC0 ||
        p[1] != EXPTAG_MAGIC1 ||
        p[2] != EXPTAG_MAGIC2 ||
        p[3] != EXPTAG_MAGIC3) {
        log_info(LD_OR, "EXPTAG bad magic");
        return 0;
    }

    int tag_type = p[4];

    uint64_t tag_id = 0;
    memcpy(&tag_id, p + 5, sizeof(tag_id));

    circ->exptag_seen = 1;
    circ->exptag_type = tag_type;
    circ->exptag_id = tag_id;

    log_info(LD_OR,
             "EXPTAG middle recv circ=%p type=%s id=%" PRIu64,
             circ,
             exptag_type_to_string(tag_type),
             tag_id);

    return 0;
}
```

The exact field names may differ in the implementation, but the logic is the same: validate the payload, extract the type and identifier, attach the metadata to the local circuit, and log the event.

---

## 6. Why the Middle Relay Does Not Forward the Tag

The experimental tag is meant only for the instrumented middle relay. It is not required by the exit relay or destination.

After the middle relay receives and processes `RELAY_COMMAND_EXPTAG`, the command is consumed locally by the modified relay code.

The tag is therefore not forwarded as normal application data.

This is important because:

1. The tag is only a measurement marker.
2. It should not affect the destination application.
3. It avoids unnecessary propagation of experimental metadata.
4. It keeps the instrumentation localized to the private testbed.

In the artifact, this behavior is implemented by returning from the relay-command handler after processing the tag.

---

## 7. Logging the Initial Tag Event

When the middle relay receives the tag, it logs a line similar to:

```text
EXPTAG middle recv circ=0x56c016a92890 type=web id=13498108163233928593
```

or:

```text
EXPTAG middle recv circ=0x56c016a92a90 type=voip id=17232923151120760296
```

This line is the anchor used by the analysis pipeline. It maps:

```text
circ pointer / circuit identifier  ->  traffic type
```

Later scheduler logs may not include the traffic type directly. Instead, the analysis script reconstructs the flow type by joining later scheduler events with this initial tag log.

---

## 8. EWMA Scheduler Events Logged at the Middle Relay

The middle relay was also instrumented to log events related to Tor's EWMA scheduler.

The main events logged are:

| Event | Meaning |
|---|---|
| `active` | Circuit becomes active and eligible for scheduling |
| `inactive` | Circuit becomes inactive |
| `pick` | Scheduler selects a circuit |
| `xmit` | A cell is transmitted from the selected circuit |
| `qsize` | Queue size at the time of the event |
| `a` or `A-value` | EWMA priority value of the circuit |

Example log line:

```text
ewma_notify_circ_active(): EWMAA t_us=20138631204 ev=active circ=0x5b61f7b1c100 side=p a=47.409985 qsize=1 tag_seen=1 tag_type=none tag_id=0
```

The exact format may vary slightly, but each line is intended to capture:

```text
timestamp, event type, circuit identifier, direction/side, EWMA A-value, queue size
```

---

## 9. Logging Hook Locations

The scheduler-related log statements are placed around the functions that update circuit activity and choose circuits for transmission.

Typical functions of interest include:

```c
ewma_notify_circ_active()
ewma_notify_circ_inactive()
ewma_cmp_cmux()
circuitmux_set_num_cells()
circuitmux_attach_circuit()
scheduler_run()
```

Depending on the exact Tor version and scheduler configuration, the logs may be added in the circuitmux and scheduler paths.

A conceptual logging helper is:

```c
static void
exptag_log_ewma_event(const char *event,
                      circuit_t *circ,
                      const char *side,
                      double a_value,
                      int qsize)
{
    log_info(LD_SCHED,
             "EWMAA t_us=%" PRIu64
             " ev=%s circ=%p side=%s a=%f qsize=%d "
             "tag_seen=%d tag_type=%s tag_id=%" PRIu64,
             monotime_absolute_usec(),
             event,
             circ,
             side,
             a_value,
             qsize,
             circ->exptag_seen,
             exptag_type_to_string(circ->exptag_type),
             circ->exptag_id);
}
```

This helper uses Tor's built-in logging system through `log_info()`.

---

## 10. Use of Tor's Built-In Logging

The instrumentation uses Tor's existing logging infrastructure.

Typical logging calls are:

```c
log_info(...)
log_debug(...)
```

For the artifact, the relay's `torrc` should enable sufficiently verbose logs, for example:

```text
Log info file /var/lib/tor/info.log
```

or:

```text
Log info stdout
```

The log level must include the instrumentation messages. If the messages are logged with `log_info()`, then `Log info ...` is required.

---

## 11. Directionality: `side=p` and `side=n`

The same middle relay circuit has two sides:

```text
side=p
side=n
```

These indicate the previous-hop side and next-hop side of the relay circuit.

The experimental tag is received once, but after that the circuit can be observed in both directions. Scheduler events on both sides can be tracked using the same circuit identifier and the `side` field.

This is useful because the analysis can separate behavior toward the previous relay and toward the next relay.

---

## 12. Analysis Pipeline Assumption

The relay logs are analyzed in two stages.

First, the parser reads the `EXPTAG` lines:

```text
EXPTAG middle recv circ=... type=voip id=...
EXPTAG middle recv circ=... type=web id=...
```

This creates a mapping:

```text
circ -> flow_type
```

Second, the parser reads the scheduler logs:

```text
EWMAA t_us=... ev=active circ=... side=p a=... qsize=...
EWMAA t_us=... ev=pick   circ=... side=p a=... qsize=...
EWMAA t_us=... ev=xmit   circ=... side=p a=... qsize=...
```

The parser then assigns `flow_type` to each scheduler event using the circuit identifier.

This is why every scheduler log line does not need to explicitly include `voip` or `web`.

---

## 13. Artifact-Relevant Summary

The middle-relay changes can be summarized as follows:

1. Add support for the private relay command `RELAY_COMMAND_EXPTAG`.
2. Parse the payload beginning with the magic string `XPTG`.
3. Extract the traffic type and tag identifier.
4. Store the tag metadata in the local relay-side circuit object.
5. Log the initial tag event with the local circuit identifier.
6. Consume the tag locally so that it is not forwarded further.
7. Add EWMA scheduler logs for active, inactive, pick, and transmit events.
8. Use Tor's built-in logging system to write the instrumentation logs.
9. Reconstruct traffic type during offline analysis using the initial tag log.

---

## 14. Directory Structure

For the artifact, the middle-relay instrumentation can be organized as:

```text
middle-relay/
└── README-middle-relay-instrumentation.md
```

---

## 15. Recommended `torrc` Options for the Instrumented Middle Relay

A minimal middle-relay `torrc` for the private testbed may include:

```text
Nickname middle1
ORPort 9001
SocksPort 0
ControlPort 9051
CookieAuthentication 1
RunAsDaemon 1

Log info file /var/lib/tor/info.log
```

In a private Tor network, additional options such as directory authority configuration, relay fingerprints, and testing-network options are required. Those are described in the private Tor setup documentation.

---

## 16. How to Inspect the Middle-Relay Patch

If the artifact includes a clean Tor source tree and an instrumented source tree, the changes can be inspected using:

```bash
git diff tor-0.4.8.21-clean tor-0.4.8.21-middle-instrumented
```

If the artifact includes a patch:

```bash
git apply --check patch/tor-middle-exptag-ewma.patch
git apply patch/tor-middle-exptag-ewma.patch
```

To find the instrumentation points:

```bash
grep -R "EXPTAG" -n src/
grep -R "EWMAA" -n src/
grep -R "exptag" -n src/
```

---

## 17. Minimal README Text for the Repository

The middle relay was modified to receive a private experimental relay command sent by the Tor client. The command contains a payload beginning with the magic string `XPTG`, followed by a traffic type and tag identifier. When the middle relay receives this command, it marks the local circuit as VoIP or web and logs the mapping between the local circuit identifier and the traffic type. The tag is consumed locally and is not forwarded further. The relay also logs EWMA scheduler events such as circuit activation, deactivation, scheduler selection, and cell transmission. During offline analysis, the initial tag log is used to map later scheduler events to the corresponding traffic type.
