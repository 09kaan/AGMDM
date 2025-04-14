import socket
import time
import random

def main():
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    server_address = ('127.0.0.1', 5010)

    logs = [
        "Target-1 acquired at 279° - Confidence: 95%",
        "Target-2 detected at 200° - Distance: 800m",
        "Autonomous mode engaged - PID optimization active",
        "Maneuver params: Speed=45KTS, Alt=1200m, Bank=15°",
        "Navigation optimal - Path correction ΔΘ=2.3°"
    ]

    print(f"Log sunucusu başlatıldı. Port: {server_address[1]}")
    print(f"Hedef IP: {server_address[0]}")
    print("Rastgele loglar gönderiliyor...")

    try:
        while True:
            log = random.choice(logs)
            current_time = time.strftime("%H:%M:%S", time.localtime())
            message = f"{log}"
            server_socket.sendto(message.encode('utf-8'), server_address)
            print(f"Gönderilen log: {message}")
            time.sleep(random.randint(1, 5))
    except Exception as e:
        print(f"Hata oluştu: {e}")
    finally:
        server_socket.close()

if __name__ == "__main__":
    main() 