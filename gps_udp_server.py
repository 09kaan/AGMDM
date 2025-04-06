import socket
import time
import random

def main():
    # UDP sunucusu için soket oluştur
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    
    try:
        server_socket.bind(('0.0.0.0', 5007))
        print("GPS UDP Sunucusu başlatıldı. Port: 5007")
    except OSError:
        print("Port 5007 kullanımda!")
        return
    
    # Başlangıç koordinatları (İstanbul)
    latitude = 41.0082
    longitude = 28.9784
    altitude = 100.0
    
    try:
        while True:
            # Koordinatları daha belirgin şekilde değiştir
            latitude += random.uniform(-0.01, 0.01)  # Daha büyük değişim
            longitude += random.uniform(-0.01, 0.01)  # Daha büyük değişim
            altitude += random.uniform(-5, 5)  # Daha büyük yükseklik değişimi
            
            # Koordinatları string formatına dönüştür
            message = f"{latitude:.6f},{longitude:.6f},{altitude:.2f}"
            
            print(f"Gönderilen GPS verisi: {message}")
            
            # Veriyi port 5008'e gönder
            server_socket.sendto(message.encode(), ('127.0.0.1', 5008))
            
            # 2 saniye bekle
            time.sleep(2)
            
    except KeyboardInterrupt:
        print("\nSunucu kapatılıyor...")
    finally:
        server_socket.close()

if __name__ == "__main__":
    main() 