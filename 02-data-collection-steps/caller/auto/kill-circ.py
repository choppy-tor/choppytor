from stem import Signal
from stem.control import Controller
import json

TOR_CONTROL_PORT = 9051
TOR_PASSWORD = 'your_password_here'

def get_node_info(port=1194):
    with Controller.from_port(port=TOR_CONTROL_PORT) as controller:
        controller.authenticate(password=TOR_PASSWORD)
        for circ in controller.get_circuits():
            controller.close_circuit(circ.id)


get_node_info()