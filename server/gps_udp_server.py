import socket
import time
import struct
import os

def read_gps_value(file_path, default_value):
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            # Son satırı oku
            lines = file.readlines()
            if not lines:
                print(f"Uyarı: {file_path} dosyası boş, varsayılan değer kullanılıyor")
                return default_value
            
            # Son satırı al
            last_line = lines[-1].strip()
            if not last_line:
                print(f"Uyarı: {file_path} dosyasında geçerli değer bulunamadı")
                return default_value
                
            try:
                # Sadece sayısal karakterleri al
                content = ''.join(c for c in last_line if c.isdigit() or c == '.' or c == '-')
                if not content:
                    print(f"Uyarı: {file_path} dosyasında geçerli sayı bulunamadı")
                    return default_value
                value = float(content)
                return value
            except ValueError:
                print(f"Uyarı: {file_path} dosyasında geçersiz değer: {last_line}")
                return default_value
    except FileNotFoundError:
        print(f"Uyarı: {file_path} dosyası bulunamadı, varsayılan değer kullanılıyor")
        return default_value
    except Exception as e:
        print(f"Uyarı: {file_path} okunurken hata oluştu: {e}")
        return default_value

def write_gps_value(file_path, value):
    try:
        with open(file_path, 'w', encoding='utf-8') as file:
            file.write(str(value))
            print(f"Değer yazıldı: {file_path} -> {value}")
    except Exception as e:
        print(f"Uyarı: {file_path} yazılırken hata oluştu: {e}")

def main():
    # UDP sunucusu için soket oluştur
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    
    # GPS veri dosyalarının yolları
    latitude_file = "gps_data/latitude.txt"
    longitude_file = "gps_data/longitude.txt"
    altitude_file = "gps_data/altitude.txt"

    # GPS veri klasörünü oluştur
    os.makedirs("gps_data", exist_ok=True)
    print("GPS veri klasörü oluşturuldu: gps_data")

    # Varsayılan değerler
    default_latitude = 41.0082  # İstanbul
    default_longitude = 28.9784
    default_altitude = 100.0

    # Dosyaları oluştur ve varsayılan değerleri yaz
    write_gps_value(latitude_file, default_latitude)
    write_gps_value(longitude_file, default_longitude)
    write_gps_value(altitude_file, default_altitude)
    
    # Port çakışması durumunda farklı portlar dene
    ports = [5007, 5008, 5009, 5010]
    for port in ports:
        try:
            server_socket.bind(('0.0.0.0', port))
            print(f"GPS UDP Sunucusu başlatıldı. Port: {port}")
            break
        except OSError:
            print(f"Port {port} kullanımda, diğer port deneniyor...")
            continue
    else:
        print("Tüm portlar kullanımda!")
        return

    try:
        while True:
            # GPS verilerini dosyalardan oku
            latitude = read_gps_value(latitude_file, default_latitude)
            longitude = read_gps_value(longitude_file, default_longitude)
            altitude = read_gps_value(altitude_file, default_altitude)

            # Verileri paketle
            data = struct.pack('!fff', latitude, longitude, altitude)
            
            # Veriyi gönder
            try:
                server_socket.sendto(data, ('192.168.31.69', 5008))
                print(f"GPS verisi gönderildi: Lat: {latitude}, Lon: {longitude}, Alt: {altitude}")
                print(f"Binary veri: {data.hex()}")
            except Exception as e:
                print(f"Gönderme hatası: {e}")
            
            # 2 saniye bekle
            time.sleep(2)
            
    except KeyboardInterrupt:
        print("\nSunucu kapatılıyor...")
    finally:
        server_socket.close()

if __name__ == "__main__":
    main() 