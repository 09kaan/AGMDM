import cv2
import socket
import numpy as np
import time
import struct

def split_frame(frame_data, chunk_size=60000):
    return [frame_data[i:i + chunk_size] for i in range(0, len(frame_data), chunk_size)]

def main():
    # UDP sunucusu için soket oluştur
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    server_socket.bind(('0.0.0.0', 5006))
    print("Kamera UDP Sunucusu başlatıldı. Port: 5006")

    # Kamera başlat
    cap = cv2.VideoCapture(0)  # 0 varsayılan kamera
    
    # Kamera çözünürlüğünü ayarla
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)
    
    # Kamera kalite ayarlarını yap
    cap.set(cv2.CAP_PROP_AUTOFOCUS, 1)  # Otomatik odaklama
    cap.set(cv2.CAP_PROP_BRIGHTNESS, 128)  # Normal parlaklık
    cap.set(cv2.CAP_PROP_CONTRAST, 128)  # Normal kontrast
    
    if not cap.isOpened():
        print("Kamera açılamadı!")
        return

    try:
        while True:
            # Kameradan görüntü al
            ret, frame = cap.read()
            if not ret:
                print("Görüntü alınamadı")
                continue

            # Görüntüyü yeniden boyutlandır
            frame = cv2.resize(frame, (1280, 720), interpolation=cv2.INTER_LINEAR)
            
            # Görüntüyü JPEG formatına dönüştür
            _, buffer = cv2.imencode('.jpg', frame, [cv2.IMWRITE_JPEG_QUALITY, 90])
            frame_data = buffer.tobytes()
            
            # Görüntüyü parçalara böl
            chunks = split_frame(frame_data)
            total_chunks = len(chunks)
            
            # Her parçayı gönder
            for i, chunk in enumerate(chunks):
                # Paket başlığı: toplam parça sayısı, parça numarası, parça verisi
                header = struct.pack('!II', total_chunks, i)
                packet = header + chunk
                
                try:
                    server_socket.sendto(packet, ('192.168.31.69', 5006))
                except Exception as e:
                    print(f"Gönderme hatası: {e}")
                    continue
                
                # Küçük bir bekleme ekle
                time.sleep(0.001)
            
            # FPS kontrolü için bekleme
            time.sleep(0.033)
            
    except KeyboardInterrupt:
        print("\nSunucu kapatılıyor...")
    finally:
        cap.release()
        server_socket.close()

if __name__ == "__main__":
    main() 