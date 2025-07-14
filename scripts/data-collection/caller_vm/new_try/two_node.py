from stem import Signal
from stem.control import Controller
import json

TOR_CONTROL_PORT = 9051
TOR_PASSWORD = 'your_password_here'

def get_node_info(port=1194):
    with Controller.from_port(port=TOR_CONTROL_PORT) as controller:
        controller.authenticate(password=TOR_PASSWORD)
        for circ in controller.get_circuits():
            if circ.status != 'BUILT':
                continue
            for stream in controller.get_streams():
                if stream.status == 'SUCCEEDED' and stream.target_port == port:
                    if stream.circ_id == circ.id:
                        guard_fpr, exit_fpr = circ.path[0][0], circ.path[1][0]
                        guard_ip = controller.get_network_status(guard_fpr).address
                        # middle_ip = controller.get_network_status(middle_fpr).address
                        exit_ip = controller.get_network_status(exit_fpr).address
                        return json.dumps({
                            "guard": {"fingerprint": guard_fpr, "ip": guard_ip},
                            # "middle": {"fingerprint": middle_fpr, "ip": middle_ip},
                            "exit": {"fingerprint": exit_fpr, "ip": exit_ip}
                        })
print(get_node_info())
