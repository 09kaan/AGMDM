import socket
import json
import time
import random
import math
import struct
import threading

class AllInOneServer:
    def __init__(self):
        # UDP soketleri oluştur
        self.flight_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.gps_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.log_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.signal_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.compass_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        
        # Portları ayarla (0.0.0.0 tüm IP'lerden bağlantı kabul eder)
        self.flight_socket.bind(('0.0.0.0', 5022))  # Farklı port
        self.gps_socket.bind(('0.0.0.0', 5028))    # Farklı port
        self.log_socket.bind(('0.0.0.0', 5030))    # Farklı port
        self.signal_socket.bind(('0.0.0.0', 5033)) # Farklı port
        self.compass_socket.bind(('0.0.0.0', 5025)) # Farklı port
        
        # Hedef adresler ve portlar
        self.target_address = '192.168.31.69'  # Client'ın IP adresi
        self.target_ports = {
            'flight': 5012,  # Client'ın dinlediği port
            'gps': 5008,     # Client'ın dinlediği port
            'log': 5010,     # Client'ın dinlediği port
            'signal': 5014,  # Client'ın dinlediği port
            'compass': 5005  # Client'ın dinlediği port
        }
        
        # Log mesajları
        self.logs = [
            "Target-1 acquired at 279° - Confidence: 95%",
            "Target-2 detected at 200° - Distance: 800m",
            "Autonomous mode engaged - PID optimization active",
            "Maneuver params: Speed=45KTS, Alt=1200m, Bank=15°",
            "Navigation optimal - Path correction ΔΘ=2.3°"
        ]

    def generate_flight_data(self):
        t = time.time()
        pitch = 20 * math.sin(0.1 * t)
        roll = 30 * math.sin(0.05 * t)
        
        if random.random() < 0.1:
            pitch += random.uniform(-1, 1)
            roll += random.uniform(-1.5, 1.5)
        
        pitch = max(-20, min(20, pitch))
        roll = max(-30, min(30, roll))
        
        return {
            'pitch': round(pitch, 2),
            'roll': round(roll, 2)
        }

    def generate_gps_data(self):
        # İstanbul koordinatları etrafında rastgele hareket
        base_lat = 41.0082
        base_lon = 28.9784
        base_alt = 100.0
        
        # Küçük rastgele değişimler
        lat = base_lat + random.uniform(-0.001, 0.001)
        lon = base_lon + random.uniform(-0.001, 0.001)
        alt = base_alt + random.uniform(-10, 10)
        
        return lat, lon, alt

    def flight_computer_thread(self):
        print("Flight Computer server başlatıldı...")
        while True:
            try:
                data = self.generate_flight_data()
                message = json.dumps(data)
                self.flight_socket.sendto(message.encode(), (self.target_address, self.target_ports['flight']))
                print(f"Flight Computer verisi gönderildi: {data}")
                time.sleep(0.2)  # 5 Hz
            except Exception as e:
                print(f"Flight Computer hatası: {e}")
                time.sleep(1)

    def gps_thread(self):
        print("GPS server başlatıldı...")
        while True:
            try:
                lat, lon, alt = self.generate_gps_data()
                data = struct.pack('!fff', lat, lon, alt)
                self.gps_socket.sendto(data, (self.target_address, self.target_ports['gps']))
                print(f"GPS verisi gönderildi: Lat: {lat}, Lon: {lon}, Alt: {alt}")
                time.sleep(2)
            except Exception as e:
                print(f"GPS hatası: {e}")
                time.sleep(1)

    def log_thread(self):
        print("Log server başlatıldı...")
        while True:
            try:
                log = random.choice(self.logs)
                self.log_socket.sendto(log.encode('utf-8'), (self.target_address, self.target_ports['log']))
                print(f"Log gönderildi: {log}")
                time.sleep(random.randint(1, 5))
            except Exception as e:
                print(f"Log hatası: {e}")
                time.sleep(1)

    def signal_strength_thread(self):
        print("Signal Strength server başlatıldı...")
        while True:
            try:
                signal_strength = random.randint(-90, -30)
                data = {
                    'signal_strength': signal_strength,
                    'timestamp': time.time()
                }
                message = json.dumps(data)
                self.signal_socket.sendto(message.encode(), (self.target_address, self.target_ports['signal']))
                print(f"Signal Strength verisi gönderildi: {signal_strength} dBm")
                time.sleep(1)
            except Exception as e:
                print(f"Signal Strength hatası: {e}")
                time.sleep(1)

    def compass_thread(self):
        print("Compass server başlatıldı...")
        while True:
            try:
                compass_data = random.uniform(0, 360)
                message = str(compass_data).encode('utf-8')
                self.compass_socket.sendto(message, (self.target_address, self.target_ports['compass']))
                print(f"Compass verisi gönderildi: {compass_data}°")
                time.sleep(1)
            except Exception as e:
                print(f"Compass hatası: {e}")
                time.sleep(1)

    def start(self):
        print("Tüm serverlar başlatılıyor...")
        
        # Thread'leri başlat
        threads = [
            threading.Thread(target=self.flight_computer_thread),
            threading.Thread(target=self.gps_thread),
            threading.Thread(target=self.log_thread),
            threading.Thread(target=self.signal_strength_thread),
            threading.Thread(target=self.compass_thread)
        ]
        
        for thread in threads:
            thread.daemon = True
            thread.start()
        
        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            print("\nServerlar kapatılıyor...")
            self.flight_socket.close()
            self.gps_socket.close()
            self.log_socket.close()
            self.signal_socket.close()
            self.compass_socket.close()

if __name__ == "__main__":
    server = AllInOneServer()
    server.start() 