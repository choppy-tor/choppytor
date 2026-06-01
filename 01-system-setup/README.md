# System Setup

This section contains the setup instructions and configuration details required for reproducing the VoIP experiments.

The system setup is divided into four parts:

1. [OpenVPN Setup](openvpn.md)
2. [Tor Setup](tor.md)
3. [FreeSWITCH Setup](freeswitch.md)
4. [VoIP Client Setup](voip-client.md)

## Overview

The experiments use FreeSWITCH as the VoIP server and PJSIP-based clients for placing and receiving calls. OpenVPN is used as the tunnel between the clients and the VoIP server. For Tor-based experiments, the OpenVPN client is configured to route traffic through the local Tor SOCKS proxy.

## Directory Contents

- `openvpn.md`: OpenVPN client and server configuration.
- `tor.md`: Tor installation and SOCKS proxy setup.
- `freeswitch.md`: FreeSWITCH VoIP server installation and configuration.
- `voip-client.md`: VoIP caller/callee client setup and call execution.

## Notes

Configuration values such as public IP addresses, local IP addresses, usernames, passwords, private keys, and machine-specific paths should be removed or anonymized before making the repository public.
