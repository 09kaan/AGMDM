import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class GPSContainer extends StatefulWidget {
  final dynamic state;

  GPSContainer({required this.state});

  @override
  _GPSContainerState createState() => _GPSContainerState();
}

class _GPSContainerState extends State<GPSContainer> {
  String _latitude = '0.0';
  String _longitude = '0.0';
  String _altitude = '0.0';
  late RawDatagramSocket _socket;
  final MapController _mapController = MapController();
  LatLng _currentPosition = LatLng(41.0082, 28.9784); // İstanbul koordinatları
  StreamController<LatLng> _positionController = StreamController<LatLng>.broadcast();

  @override
  void initState() {
    super.initState();
    _setupUdpListener();
    
    // Konum değişikliklerini dinle
    _positionController.stream.listen((LatLng newPosition) {
      if (mounted) {
        setState(() {
          _currentPosition = newPosition;
        });
        _mapController.move(newPosition, 15);
        print('Harita yeni konuma taşındı: ${newPosition.latitude}, ${newPosition.longitude}');
      }
    });
  }

  void _setupUdpListener() async {
    try {
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 5008);
      print('GPS dinleyici başlatıldı. Port: 5008');
      
      _socket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? datagram = _socket.receive();
          if (datagram != null) {
            try {
              // Binary veriyi oku
              ByteData byteData = ByteData.sublistView(datagram.data);
              double lat = byteData.getFloat32(0, Endian.big);
              double lon = byteData.getFloat32(4, Endian.big);
              double alt = byteData.getFloat32(8, Endian.big);
              
              print('Yeni konum alındı: $lat, $lon, $alt');
              
              if (mounted) {
                setState(() {
                  _latitude = lat.toStringAsFixed(6);
                  _longitude = lon.toStringAsFixed(6);
                  _altitude = alt.toStringAsFixed(2);
                  _currentPosition = LatLng(lat, lon);
                });
                
                // Haritayı güncelle
                _mapController.move(_currentPosition, 15);
                print('Harita güncellendi: ${_currentPosition.latitude}, ${_currentPosition.longitude}');
              }
            } catch (e) {
              print('Veri işleme hatası: $e');
            }
          }
        }
      });
    } catch (e) {
      print('Port 5008 bağlantı hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(110),
        shape: BoxShape.rectangle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(110),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _currentPosition,
                zoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition,
                      width: 30,
                      height: 30,
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      'X: $_latitude',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      'Y: $_longitude',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      'Z: $_altitude m',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _positionController.close();
    _socket.close();
    _mapController.dispose();
    super.dispose();
  }
}
