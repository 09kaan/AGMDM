import 'package:flutter/material.dart';
import 'package:agmdm/CameraContainer.dart';
import 'package:agmdm/GpsContainer.dart';
import 'package:agmdm/Log1Container.dart';
import 'package:agmdm/SignalStrengthContainer.dart';
import 'package:agmdm/BatteryContainer.dart';
import 'package:agmdm/CompassContainer.dart';
import 'package:agmdm/FlightComputerContainer.dart';
import 'package:agmdm/Log2Container.dart';
import 'package:agmdm/Log3Container.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AGMDM_UI(),
  ));
}

class AGMDM_UI extends StatefulWidget {
  const AGMDM_UI({super.key});

  @override
  State<AGMDM_UI> createState() => _AGMDMState();
}

class _AGMDMState extends State<AGMDM_UI> {
  late Battery batterycontainer;
  late CameraContainer cameracontainer;
  late Compasscontainer compasscontainer;
  late FlightComputer flightcomputercontainer;
  late GPSContainer gpscontainer;
  late Log1 log1container;
  late Log2 log2container;
  late Log3 log3container;
  late SignalStrengthContainer signalstrengthcontainer;

  final GlobalKey scaffoldKey = GlobalKey();
  final GlobalKey<Log1State> log1Key = GlobalKey<Log1State>();

  void addLog(String message) {
    log1Key.currentState?.addLog(message);
  }

  @override
  void initState() {
    super.initState();
    batterycontainer = Battery(state: this);
    cameracontainer = CameraContainer(state: this);
    compasscontainer = Compasscontainer(state: this);
    flightcomputercontainer = FlightComputer(state: this);
    gpscontainer = GPSContainer(state: this);
    log1container = Log1(key: log1Key, state: this);
    log2container = Log2(state: this);
    log3container = Log3(state: this);
    signalstrengthcontainer = SignalStrengthContainer(state: this);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFF201F1F),
      body: SafeArea(
        top: true,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Align(
                alignment: const AlignmentDirectional(0, 0),
                child: Container(
                  width: 1920,
                  height: 1080,
                  decoration: const BoxDecoration(
                    color: Color(0xFF201F1F),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: const AlignmentDirectional(-1, 0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Align(
                                    alignment: const AlignmentDirectional(-1, 0),
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          10, 10, 0, 0),
                                      child: cameracontainer,
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Align(
                                        alignment: const AlignmentDirectional(0, 0),
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(
                                              19, 30, 0, 10),
                                          child: log1container,
                                        ),
                                      ),
                                      Align(
                                        alignment: const AlignmentDirectional(0, 0),
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(
                                              19, 10, 0, 0),
                                          child: log2container,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: const AlignmentDirectional(-1, 0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Align(
                                alignment: const AlignmentDirectional(-0.24, 1),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      50, 10, 0, 0),
                                  child: gpscontainer,
                                ),
                              ),
                              Align(
                                alignment: const AlignmentDirectional(-0.24, 1),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      75, 10, 0, 0),
                                  child: compasscontainer,
                                ),
                              ),
                              Align(
                                alignment: const AlignmentDirectional(-0.24, 1),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      75, 15, 0, 0),
                                  child: flightcomputercontainer,
                                ),
                              ),
                              Align(
                                alignment: const AlignmentDirectional(-0.24, 1),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      75, 10, 0, 0),
                                  child: signalstrengthcontainer,
                                ),
                              ),
                              Align(
                                alignment: const AlignmentDirectional(-0.24, 1),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      50, 10, 10, 0),
                                  child: batterycontainer,
                                ),
                              ),
                              Align(
                                alignment: const AlignmentDirectional(-0.24, 1),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      69, 10, 10, 0),
                                  child: log3container,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}