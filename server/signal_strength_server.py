import socket
import json
import time
import random

def main():
    # UDP soketi oluştur
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    server_socket.bind(('127.0.0.1', 5013))
    print('Sinyal gücü test server başlatıldı (Port: 5013)')

    try:
        while True:
            # Rastgele sinyal gücü değeri oluştur (-30 ile -90 dBm arası)
            signal_strength = random.randint(-90, -30)
            
            # Veriyi JSON formatında hazırla
            data = {
                'signal_strength': signal_strength,
                'timestamp': time.time()
            }
            
            # Veriyi JSON string'e çevir
            message = json.dumps(data)
            
            # Veriyi farklı bir porta gönder
            server_socket.sendto(message.encode(), ('127.0.0.1', 5014))
            print(f'Gönderilen sinyal gücü: {signal_strength} dBm')
            
            # 1 saniye bekle
            time.sleep(1)
            
    except KeyboardInterrupt:
        print('\nServer kapatılıyor...')
    finally:
        server_socket.close()

if __name__ == '__main__':
    main() 