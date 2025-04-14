import socket
import json
import time
import math
import random

def generate_flight_data():
    # Zaman bazlı yumuşak hareket için
    t = time.time()
    
    # Pitch: -20 ile +20 derece arasında sinüs dalgası (daha yavaş)
    pitch = 20 * math.sin(0.1 * t)  # Frekansı yarıya düşürdük
    
    # Roll: -30 ile +30 derece arasında sinüs dalgası (daha yavaş)
    roll = 30 * math.sin(0.05 * t)  # Frekansı yarıya düşürdük
    
    # Hafif türbülans efekti (10% şans ve daha hafif)
    if random.random() < 0.1:
        pitch += random.uniform(-1, 1)
        roll += random.uniform(-1.5, 1.5)
    
    # Değerleri sınırla
    pitch = max(-20, min(20, pitch))
    roll = max(-30, min(30, roll))
    
    return {
        'pitch': round(pitch, 2),
        'roll': round(roll, 2)
    }

def main():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    target_address = ('127.0.0.1', 5012)
    
    print("Flight Computer UDP Sunucusu başlatıldı...")
    print(f"Hedef: {target_address[0]}:{target_address[1]}")
    print("Ctrl+C ile kapatabilirsiniz.\n")
    
    try:
        while True:
            try:
                data = generate_flight_data()
                message = json.dumps(data)
                sock.sendto(message.encode(), target_address)
                print(f"Gönderilen: Pitch={data['pitch']:.1f}°, Roll={data['roll']:.1f}°")
                time.sleep(0.2)  # 5 Hz
            except Exception as e:
                print(f"Hata: {e}")
                time.sleep(1)
    except KeyboardInterrupt:
        print("\nSunucu kapatılıyor...")
    finally:
        sock.close()

if __name__ == "__main__":
    main() 