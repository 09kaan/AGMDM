import socket
import time
import random

# Set up the UDP server
UDP_IP = "127.0.0.1"
UDP_PORT = 5005

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# Function to generate random compass data
def generate_compass_data():
    # Simulate compass data as an angle between 0 and 360 degrees
    return random.uniform(0, 360)

try:
    while True:
        # Generate dummy compass data
        compass_data = generate_compass_data()
        
        # Send the data as a string
        message = str(compass_data).encode('utf-8')
        sock.sendto(message, (UDP_IP, UDP_PORT))
        
        print(f"Sent compass data: {compass_data}")
        
        # Wait for a second before sending the next data
        time.sleep(1)
except KeyboardInterrupt:
    print("UDP server stopped.")
finally:
    sock.close() 