import os
import re
import pandas as pd
from scapy.all import rdpcap, UDP, raw
from scapy.layers.rtp import RTP
from concurrent.futures import ProcessPoolExecutor
from tqdm import tqdm


# Configuration
ROOT_DIR = "/home/jithin/data/IMC/NewData/Tor"
RTP_PORT = 4000
OUTPUT_BASE = "/home/jithin/data/IMC/Analysis/data/owd/tor"


def extract_iteration(filename):
    match = re.search(r'(\d+)', filename)
    return match.group(1) if match else None


def extract_rtp_packets(pcap_file):
    try:
        packets = rdpcap(pcap_file)
    except Exception as e:
        return {}, f"Error reading {pcap_file}: {e}"

    rtp_map = {}
    for pkt in packets:
        if UDP in pkt:
            udp = pkt[UDP]
            if udp.dport != RTP_PORT and udp.sport != RTP_PORT:
                continue
            try:
                rtp = RTP(raw(udp.payload))
                seq = rtp.sequence
                ts = float(pkt.time)
                if seq not in rtp_map:
                    rtp_map[seq] = []
                rtp_map[seq].append(ts)
            except Exception:
                continue
    return rtp_map, None


def process_iteration(args):
    key, caller_file, callee_file, output_dir = args

    caller_rtp, err1 = extract_rtp_packets(caller_file)
    callee_rtp, err2 = extract_rtp_packets(callee_file)

    if err1 or err2:
        return

    records = []
    for seq in set(caller_rtp.keys()) & set(callee_rtp.keys()):
        for ct in caller_rtp[seq]:
            for rt in callee_rtp[seq]:
                owd = (ct - rt) * 1000  # ms
                records.append({"seq": seq, "owd_ms": owd})

    if records:
        df = pd.DataFrame(records)
        df.to_csv(os.path.join(output_dir, f"iteration_{key}_owd.csv"), index=False)


def main():
    caller_paths = []
    callee_paths = []

    for dirpath, dirnames, filenames in os.walk(ROOT_DIR):
        if os.path.basename(dirpath) == "test_pcaps":
            if "caller" in dirpath:
                caller_paths.append(dirpath)
            elif "callee" in dirpath:
                callee_paths.append(dirpath)

    paired_dirs = []
    for caller_dir in caller_paths:
        base = caller_dir.split("caller")[0]
        for callee_dir in callee_paths:
            if callee_dir.startswith(base):
                paired_dirs.append((caller_dir, callee_dir, base))
                break

    tasks = []
    for caller_dir, callee_dir, base in paired_dirs:
        caller_pcaps = {extract_iteration(f): os.path.join(caller_dir, f) for f in os.listdir(caller_dir) if f.endswith(".pcap")}
        callee_pcaps = {extract_iteration(f): os.path.join(callee_dir, f) for f in os.listdir(callee_dir) if f.endswith(".pcap")}
        common_keys = set(caller_pcaps) & set(callee_pcaps)

        output_dir = os.path.join(OUTPUT_BASE, os.path.relpath(base, ROOT_DIR))
        os.makedirs(output_dir, exist_ok=True)

        for key in common_keys:
            caller_file = caller_pcaps[key]
            callee_file = callee_pcaps[key]
            tasks.append((key, caller_file, callee_file, output_dir))

    with ProcessPoolExecutor() as executor:
        list(tqdm(executor.map(process_iteration, tasks), total=len(tasks), desc="Processing all pairs"))


main()

