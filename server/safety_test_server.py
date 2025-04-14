import socket
import time

def main():
    # UDP sunucusu için soket oluştur
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    server_address = ('0.0.0.0', 5009)  # Tüm IP'lerden dinle

    try:
        server_socket.bind(server_address)
        print(f"Test sunucusu başlatıldı. Port: {server_address[1]}")
        print("Safety değerlerini dinliyorum...")

        while True:
            # Veriyi al
            data, address = server_socket.recvfrom(1024)
            message = data.decode('utf-8')
            
            # Zamanı al
            current_time = time.strftime("%H:%M:%S", time.localtime())
            
            # Gelen veriyi kontrol et
            if message.lower() == 'true':
                print(f"[{current_time}] Safety: ARMED (true) <- {address[0]}")
            elif message.lower() == 'false':
                print(f"[{current_time}] Safety: DISARMED (false) <- {address[0]}")
            else:
                print(f"[{current_time}] Bilinmeyen veri: {message} <- {address[0]}")

    except Exception as e:
        print(f"Hata oluştu: {e}")
    finally:
        server_socket.close()

if __name__ == "__main__":
    main() 