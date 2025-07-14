import socket
import sys
import time

# Client configuration
SERVER_HOST = "165.232.47.42"  # Replace with callee's IP address
SERVER_PORT = 4589
RETRY_COUNT = 5  # Number of retries
RETRY_DELAY = 2  # Delay between retries in seconds

def send_message(message):
    for attempt in range(RETRY_COUNT):
        try:
            print(f"[*] Attempt {attempt + 1} to connect to {SERVER_HOST}:{SERVER_PORT}")
            client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            client_socket.setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)
            client_socket.connect((SERVER_HOST, SERVER_PORT))

            client_socket.send(message.encode())
            print(f"[Sent] {message}")

            response = client_socket.recv(1024).decode()
            print(f"[Received] {response}")

            client_socket.close()
            return  # Exit after successful connection
        except ConnectionRefusedError:
            print(f"[Error] Connection refused. Retrying in {RETRY_DELAY} seconds...")
            time.sleep(RETRY_DELAY)

    print("[Error] Failed to connect to the server after multiple attempts.")
    sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python Caller_message.py <message>")
        sys.exit(1)

    message_to_send = sys.argv[1]
    send_message(message_to_send)
