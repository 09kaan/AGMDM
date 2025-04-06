import socket
import time
import random
import os

# Set up the UDP server
UDP_IP = "127.0.0.1"
UDP_PORT = 5006

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# List of sample image paths (you can replace these with actual image paths)
sample_images = [
    "assets/images/camera1.jpg",
    "assets/images/camera2.jpg",
    "assets/images/camera3.jpg",
    "assets/images/camera4.jpg",
]

# Function to generate random camera data
def generate_camera_data():
    # Simulate camera data as an image path
    return random.choice(sample_images)

try:
    while True:
        # Generate dummy camera data
        camera_data = generate_camera_data()
        
        # Send the data as a string
        message = camera_data.encode('utf-8')
        sock.sendto(message, (UDP_IP, UDP_PORT))
        
        print(f"Sent camera data: {camera_data}")
        
        # Wait for a second before sending the next data
        time.sleep(1)
except KeyboardInterrupt:
    print("UDP server stopped.")
finally:
    sock.close() 