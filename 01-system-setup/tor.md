# Tor Setup

This document describes the Tor setup used in our VoIP-over-Tor experiments. Tor was installed by following the official Tor documentation. The OpenVPN client was then configured to route its TCP connection through the local Tor SOCKS proxy.

## 1. Tor Version

The experiments used the following Tor version:

```text
Tor 0.4.8.21
```
## 2. Torrc 
ControlPort 9051
CookieAuthentication 0
RunAsDaemon 1
