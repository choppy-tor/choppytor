# OpenVPN Tunnel Setup

This document describes the OpenVPN tunnel configuration used in our VoIP experiments. OpenVPN was used to tunnel VoIP traffic between the client side and the FreeSWITCH VoIP server. For Tor-based experiments, the OpenVPN client was configured to route the tunnel through the local Tor SOCKS proxy.

## 1. Overview

The setup uses a point-to-point OpenVPN tunnel with TCP transport.

* OpenVPN server VPN IP: `10.8.0.1`
* OpenVPN client VPN IP: `10.8.0.2`
* OpenVPN server port: `1194`
* Transport protocol: TCP
* Tor SOCKS proxy: `127.0.0.1:9050`

For Tor-routed experiments, the OpenVPN client connects to the server through the Tor SOCKS proxy using the `socks-proxy` option.

## 2. OpenVPN Client Configuration

Save the following configuration as:

```text
configs/openvpn/client.conf
```

```conf
dev tun
proto tcp-client
remote <VPN_SERVER_PUBLIC_IP> 1194
socks-proxy 127.0.0.1 9050
daemon
port 1194
ifconfig 10.8.0.2 10.8.0.1
route-nopull
tcp-nodelay

cipher none
auth none
compress stub
keepalive 10 60
persist-tun
verb 4
```

### Notes on the Client Configuration

* `remote <VPN_SERVER_PUBLIC_IP> 1194` specifies the public IP address and port of the OpenVPN server.
* `socks-proxy 127.0.0.1 9050` routes the OpenVPN TCP connection through the local Tor SOCKS proxy.
* `ifconfig 10.8.0.2 10.8.0.1` assigns the client and server VPN tunnel endpoints.
* `route-nopull` prevents OpenVPN from automatically modifying the default routing table.
* `tcp-nodelay` disables Nagle's algorithm for the OpenVPN TCP connection.
* `cipher none` and `auth none` were used because the tunnel was used only for controlled experimental routing, not for confidentiality or integrity protection.

## 3. OpenVPN Server Configuration

Save the following configuration as:

```text
configs/openvpn/server.conf
```

```conf
dev tun
ifconfig 10.8.0.1 10.8.0.2
proto tcp-server
port 1194
daemon

cipher none
auth none
compress stub
persist-key
persist-tun
tcp-nodelay

keepalive 10 60
verb 4
```

### Notes on the Server Configuration

* `proto tcp-server` starts OpenVPN in TCP server mode.
* `port 1194` specifies the listening port.
* `ifconfig 10.8.0.1 10.8.0.2` assigns the server and client VPN tunnel endpoints.
* `tcp-nodelay` disables Nagle's algorithm for the OpenVPN TCP connection.
* `persist-key` and `persist-tun` keep the tunnel state across restarts.

## 4. Starting the OpenVPN Server

On the server machine, run:

```bash
sudo openvpn --config configs/openvpn/server.conf
```

If the configuration file is stored elsewhere, provide the corresponding path:

```bash
sudo openvpn --config /path/to/server.conf
```

## 5. Starting the OpenVPN Client

Before starting the client for Tor-routed experiments, ensure that Tor is running locally and exposing a SOCKS proxy at:

```text
127.0.0.1:9050
```

Then start the OpenVPN client:

```bash
sudo openvpn --config configs/openvpn/client.conf
```

If the configuration file is stored elsewhere, provide the corresponding path:

```bash
sudo openvpn --config /path/to/client.conf
```

## 6. Verifying the Tunnel

After starting both the server and client, verify that the tunnel interface is created:

```bash
ip addr
```

Check whether the client can reach the server-side VPN endpoint:

```bash
ping 10.8.0.1
```

Check whether the server can reach the client-side VPN endpoint:

```bash
ping 10.8.0.2
```

## 7. Use with FreeSWITCH

The OpenVPN tunnel was used to carry SIP and RTP traffic between the VoIP client and the FreeSWITCH server. The FreeSWITCH server should be configured to listen on the appropriate VPN-side IP address used in the experiment.

## Notes

Replace `<VPN_SERVER_PUBLIC_IP>` with the public IP address of the OpenVPN server before running the client configuration.

Before making the repository public, remove or anonymize public IP addresses, usernames, passwords, private keys, and machine-specific paths.

