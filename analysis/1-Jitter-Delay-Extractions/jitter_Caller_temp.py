#!/usr/bin/env python3

import os
import glob
import struct
from scapy.all import rdpcap, IP, UDP
from tqdm import tqdm
from scapy.error import Scapy_Exception
import sys

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------
PCAP_DIR = sys.argv[1]
# PCAP_DIR = input("Enter the directory where your PCAPs are located: ").strip()
SOURCE_IP = "10.8.0.1"     # Optional filter on source IP, set to None if unused
RTP_PORT = 4000            # If you know the port, set it (e.g., 5004). Else None.
RTP_CLOCK_RATE = 8000      # Common for G.711 audio; adjust if needed

# ------------------------------------------------------------------------------
# RTP Header Parser
# ------------------------------------------------------------------------------
def parse_rtp_header(raw_data):
    if len(raw_data) < 12:
        raise ValueError("RTP data too short to contain a full RTP header")

    b1, b2 = struct.unpack('!BB', raw_data[0:2])
    version = (b1 >> 6) & 0x03
    padding = (b1 >> 5) & 0x01
    extension = (b1 >> 4) & 0x01
    cc = b1 & 0x0F
    marker = (b2 >> 7) & 0x01
    payload_type = b2 & 0x7F
    sequence_number = struct.unpack('!H', raw_data[2:4])[0]
    timestamp = struct.unpack('!I', raw_data[4:8])[0]
    ssrc = struct.unpack('!I', raw_data[8:12])[0]

    return (version, padding, extension, cc, marker, payload_type, 
            sequence_number, timestamp, ssrc)

# ------------------------------------------------------------------------------
# Main Logic
# ------------------------------------------------------------------------------
def main():
    pcap_pattern = os.path.join(PCAP_DIR, "pcap_capture_inside_*.pcap")
    pcap_files = glob.glob(pcap_pattern)

    if not pcap_files:
        print(f"No PCAP files found matching pattern: {pcap_pattern}")
        return

    # Initialize tqdm progress bar for the list of PCAP files
    with tqdm(total=len(pcap_files), desc="Processing PCAPs", unit="file") as pbar:
        for pcap_file in pcap_files:
            pbar.set_description(f"Processing {os.path.basename(pcap_file)}")
            try:
                packets = rdpcap(pcap_file)
            except Scapy_Exception as e:
                print(f"\nError reading {pcap_file}: {e}. Skipping.")
                pbar.update(1)
                continue
            except Exception as e:
                print(f"\nUnexpected error with {pcap_file}: {e}. Skipping.")
                pbar.update(1)
                continue

            arrival_and_timestamp = []
            for pkt in packets:
                if IP in pkt and UDP in pkt:
                    ip = pkt[IP]
                    udp = pkt[UDP]

                    if SOURCE_IP and ip.src != SOURCE_IP:
                        continue
                    if RTP_PORT is not None and udp.sport != RTP_PORT and udp.dport != RTP_PORT:
                        continue

                    raw_payload = bytes(udp.payload)
                    try:
                        rtp = parse_rtp_header(raw_payload)
                        _, _, _, _, _, _, _, rtp_ts, _ = rtp
                        arrival_time = float(pkt.time)
                        arrival_and_timestamp.append((arrival_time, rtp_ts))
                    except ValueError:
                        pass

            arrival_and_timestamp.sort(key=lambda x: x[0])

            if len(arrival_and_timestamp) < 2:
                pbar.update(1)
                continue

            # Compute jitter using RFC 3550 method
            prev_arrival, prev_ts = arrival_and_timestamp[0]
            prev_transit = prev_arrival - (prev_ts / RTP_CLOCK_RATE)
            J = 0.0
            jitter_values = [J]

            for i in range(1, len(arrival_and_timestamp)):
                arrival, rtp_ts = arrival_and_timestamp[i]
                current_transit = arrival - (rtp_ts / RTP_CLOCK_RATE)
                delta = abs(current_transit - prev_transit)
                J += (delta - J) / 16.0
                jitter_values.append(J)
                prev_transit = current_transit

            jitter_values_ms = [j * 1000 for j in jitter_values]

            # Compute inter-arrival delay (in milliseconds)
            inter_arrival_delays = [0.0]
            for i in range(1, len(arrival_and_timestamp)):
                delay = (arrival_and_timestamp[i][0] - arrival_and_timestamp[i - 1][0]) * 1000
                inter_arrival_delays.append(delay)

            # Save the jitter and delay values to a CSV
            base_name = os.path.basename(pcap_file)
            dir_name = os.path.dirname(pcap_file)
            output_filename = os.path.join(dir_name, f"{base_name}_jitter.csv")

            with open(output_filename, "w") as f_out:
                f_out.write("packet_index,jitter_ms,delay_ms\n")
                for idx, (j, d) in enumerate(zip(jitter_values_ms, inter_arrival_delays)):
                    f_out.write(f"{idx},{j:.3f},{d:.3f}\n")

            pbar.update(1)

if __name__ == "__main__":
    main()

