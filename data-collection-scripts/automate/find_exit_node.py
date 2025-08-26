from stem import Signal
from stem.control import Controller

# Configuration for accessing the Tor control port
TOR_CONTROL_PORT = 9051
TOR_PASSWORD = 'your_password_here'  # Set this to your Tor Control Port password

def find_circuit_for_port(port):
    with Controller.from_port(port=TOR_CONTROL_PORT) as controller:
        controller.authenticate(password=TOR_PASSWORD)  # Authenticate to the control port

        for circ in controller.get_circuits():
            if circ.status != 'BUILT':
                continue  # Skip circuits that are not fully established

            for stream in controller.get_streams():
                if stream.status == 'SUCCEEDED' and stream.target_port == port:
                    if stream.circ_id == circ.id:
#                        guard_node_fingerprint = circ.path[2][0]  # Get the fingerprint of the >                        guard_node = controller.get_network_status(guard_node_fingerprint)
#                        middle_node_fingerprint = circ.path[1][0]  # Get the fingerprint of th>
#                        middle_node = controller.get_network_status(middle_node_fingerprint)
                        exit_node_fingerprint = circ.path[2][0]  # Get the fingerprint of the >
                        exit_node = controller.get_network_status(exit_node_fingerprint)
#                        print(guard_node.address) # Print only the guard node's IP address
#                        print(middle_node.address)
                        print(exit_node.address)


if __name__ == "__main__":
    target_port = 1194  # VPN port, commonly OpenVPN
    find_circuit_for_port(target_port)
