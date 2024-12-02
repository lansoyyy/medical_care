import 'dart:async';

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medical_care/utils/colors.dart';
import 'package:medical_care/widgets/button_widget.dart';
import 'package:medical_care/widgets/text_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 125,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextWidget(
                    text: 'Calendar',
                    fontSize: 28,
                    fontFamily: 'Bold',
                  ),
                  const Expanded(
                    child: SizedBox(
                      height: 10,
                    ),
                  ),
                  ButtonWidget(
                    color: index == 0 ? Colors.green : Colors.white,
                    height: 25,
                    width: 75,
                    fontSize: 12,
                    label: 'Month',
                    onPressed: () {
                      setState(() {
                        index = 0;
                      });
                    },
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ButtonWidget(
                    color: index == 1 ? Colors.green : Colors.white,
                    height: 25,
                    width: 75,
                    fontSize: 12,
                    label: 'Week',
                    onPressed: () {
                      setState(() {
                        index = 1;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                height: 275,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: index == 0 ? const MonthView() : const WeekView(),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ButtonWidget(
                    height: 40,
                    width: 125,
                    fontSize: 13,
                    textColor: Colors.white,
                    color: Colors.green[400]!,
                    label: 'Add Medication',
                    onPressed: () {},
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ButtonWidget(
                    height: 40,
                    width: 125,
                    fontSize: 13,
                    textColor: Colors.white,
                    color: Colors.green[400]!,
                    label: 'Talk to a nurse',
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                height: 275,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      ButtonWidget(
                        height: 40,
                        width: 125,
                        fontSize: 13,
                        textColor: Colors.white,
                        color: Colors.green[400]!,
                        label: 'Locate Drugstore',
                        onPressed: () {},
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: GoogleMap(
                          zoomControlsEnabled: false,
                          mapType: MapType.normal,
                          initialCameraPosition: _kGooglePlex,
                          onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
}
