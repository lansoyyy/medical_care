import 'dart:async';
import 'dart:math';

import 'package:calendar_view/calendar_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medical_care/screens/chat_screen.dart';
import 'package:medical_care/services/add_event.dart';
import 'package:medical_care/utils/colors.dart';
import 'package:medical_care/utils/const.dart';
import 'package:medical_care/widgets/button_widget.dart';
import 'package:medical_care/widgets/text_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    getPharmacy().whenComplete(
      () {
        getEvents();
      },
    );
  }

  int index = 0;

  final cont = EventController();

  bool hasLoaded = false;

  Set<Marker> markers = {};

  Future getPharmacy() async {
    await FirebaseFirestore.instance
        .collection('Pharmacy')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        setState(() {
          markers.add(
            Marker(
              markerId: MarkerId(querySnapshot.docs[i].id),
              position: LatLng(querySnapshot.docs[i]['latitude'],
                  querySnapshot.docs[i]['longitude']),
              infoWindow: InfoWindow(
                title: querySnapshot.docs[i]['name'],
                snippet: querySnapshot.docs[i]['address'],
              ),
            ),
          );
        });
      }
    });
  }

  getEvents() async {
    await FirebaseFirestore.instance
        .collection('Events')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        setState(() {
          cont.add(CalendarEventData(
            title: querySnapshot.docs[i]['medicine'],
            date: DateTime(querySnapshot.docs[i]['year'],
                querySnapshot.docs[i]['month'], querySnapshot.docs[i]['day']),
            startTime: DateTime(
                querySnapshot.docs[i]['year'],
                querySnapshot.docs[i]['month'],
                querySnapshot.docs[i]['day'],
                querySnapshot.docs[i]['hour'],
                querySnapshot.docs[i]['minutes']),
            event: querySnapshot.docs[i]['medicine'],
          ));
        });
      }
    });
    setState(() {
      hasLoaded = true;
    });
  }

  void _showMedicationReminder(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image or Icon at the top
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D', // Replace with your own image
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Medication Reminder',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'It\'s time to take your medication. Don\'t forget to stay on track with your health!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey[300]),
              Row(
                children: [
                  Container(
                    height: 50,
                    width: 1,
                    color: Colors.grey[300],
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Add functionality for "Mark as Taken" here
                      },
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      body: hasLoaded
          ? StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Events')
                  .where('day', isEqualTo: DateTime.now().day)
                  .where('month', isEqualTo: DateTime.now().month)
                  .where('year', isEqualTo: DateTime.now().year)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return const Center(child: Text('Error'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Center(
                        child: CircularProgressIndicator(
                      color: Colors.black,
                    )),
                  );
                }

                final data = snapshot.requireData;
                if (data.docs.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (timeStamp) {
                      // _showMedicationReminder(context);
                    },
                  );
                }

                return Padding(
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
                          child: index == 0
                              ? MonthView(
                                  controller: cont,
                                  onEventTap: (event, date) async {
                                    await FirebaseFirestore.instance
                                        .collection('Events')
                                        .where('day', isEqualTo: date.day)
                                        .where('month', isEqualTo: date.month)
                                        .where('year', isEqualTo: date.year)
                                        .get()
                                        .then((QuerySnapshot querySnapshot) {
                                      medicationInfoDialog(
                                          querySnapshot.docs.first);
                                    });
                                  },
                                )
                              : WeekView(
                                  controller: cont,
                                  onEventTap: (event, date) async {
                                    await FirebaseFirestore.instance
                                        .collection('Events')
                                        .where('day', isEqualTo: date.day)
                                        .where('month', isEqualTo: date.month)
                                        .where('year', isEqualTo: date.year)
                                        .get()
                                        .then((QuerySnapshot querySnapshot) {
                                      medicationInfoDialog(
                                          querySnapshot.docs.first);
                                    });
                                  },
                                ),
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
                              onPressed: () {
                                medicationDialog();
                              },
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
                              onPressed: () async {
                                // for (int i = 0; i < brgys.length; i++) {
                                //   await FirebaseFirestore.instance
                                //       .collection('Pharmacy')
                                //       .doc()
                                //       .set(brgys[i]);
                                // }
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const ChatScreen()));
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
                                  onPressed: () async {
                                    final random = Random();
                                    int randomNumber = random.nextInt(31);

                                    final GoogleMapController controller =
                                        await _controller.future;

                                    await controller.animateCamera(
                                        CameraUpdate.newCameraPosition(
                                            CameraPosition(
                                                bearing: 192.8334901395799,
                                                target: LatLng(
                                                    brgys[randomNumber]
                                                        ['latitude'],
                                                    brgys[randomNumber]
                                                        ['longitude']),
                                                tilt: 59.440717697143555,
                                                zoom: 19.151926040649414)));
                                  },
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Expanded(
                                  child: GoogleMap(
                                    zoomControlsEnabled: true,
                                    mapType: MapType.normal,
                                    markers: markers,
                                    initialCameraPosition: _kGooglePlex,
                                    onMapCreated:
                                        (GoogleMapController controller) {
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
                );
              })
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(10.305644212839677, 123.89540050171668),
    zoom: 14.4746,
  );

  medicationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: StatefulBuilder(builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  TextWidget(
                    text: "Add a Medication",
                    fontSize: 20,
                    isBold: true,
                    align: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Section title
                  TextWidget(
                    text: "Medical Information",
                    fontSize: 16,
                    isBold: true,
                    align: TextAlign.start,
                  ),
                  const SizedBox(height: 16),

                  // Dropdown: Choose a Condition
                  _buildConditionDropdown("Choose a Condition"),

                  const SizedBox(height: 12),

                  // Dropdown: Choose a Medicine
                  _buildMedicineDropdown('Choose a Medicine'),

                  const SizedBox(height: 12),

                  // Input fields for duration and dosage
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                            "Duration (DD / MM / YY)", duration),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInputField("Dosage", dosage),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Section title
                  TextWidget(
                    text: "Medical Reminder",
                    fontSize: 16,
                    isBold: true,
                    align: TextAlign.start,
                  ),
                  const SizedBox(height: 16),

                  // Time and Date inputs
                  Row(
                    children: [
                      // Time Picker
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (pickedTime != null) {
                              // Handle selected time
                              print(
                                  "Selected Time: ${pickedTime.format(context)}");

                              setState(() {
                                pickedTimeNew = pickedTime;
                              });
                            }
                          },
                          child: _buildPickerField(pickedTimeNew == null
                              ? "00:00"
                              : "${pickedTimeNew!.hour}:${pickedTimeNew!.minute}"), // Custom method for picker styling
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Date Picker
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate:
                                  DateTime(2000), // Earliest date allowed
                              lastDate: DateTime(2100), // Latest date allowed
                            );
                            if (pickedDate != null) {
                              // Handle selected date
                              print(
                                  "Selected Date: ${pickedDate.toLocal().toString().split(' ')[0]}");

                              setState(() {
                                pickedDateNew = pickedDate;
                              });
                            }
                          },
                          child: _buildPickerField(pickedDateNew != null
                              ? "${pickedDateNew?.month} / ${pickedDateNew?.day}"
                              : "MM / DD"), // Custom method for picker styling
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Notes field
                  _buildInputField("Enter your Notes here", notes, maxLines: 4),

                  const SizedBox(height: 16),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        addEvent(
                          condition,
                          medicine,
                          duration.text,
                          dosage.text,
                          notes.text,
                          pickedTimeNew!.hour,
                          pickedTimeNew!.minute,
                          pickedDateNew!.day,
                          pickedDateNew!.month,
                          pickedDateNew!.year,
                        );
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreenAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: TextWidget(
                        text: "Save",
                        fontSize: 16,
                        color: Colors.black,
                        isBold: true,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  medicationInfoDialog(data) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: StatefulBuilder(builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title

                  // Section title
                  TextWidget(
                    text: "Medical Information",
                    fontSize: 24,
                    isBold: true,
                    align: TextAlign.start,
                  ),
                  const SizedBox(height: 10),

                  // Dropdown: Choose a Condition

                  TextWidget(
                    text: 'Condition',
                    fontSize: 12,
                    align: TextAlign.start,
                  ),
                  TextWidget(
                    text: data['condition'],
                    fontSize: 16,
                    isBold: true,
                    align: TextAlign.start,
                  ),

                  const SizedBox(height: 12),
                  TextWidget(
                    text: 'Medicine',
                    fontSize: 12,
                    align: TextAlign.start,
                  ),
                  // Dropdown: Choose a Medicine
                  TextWidget(
                    text: data['medicine'],
                    fontSize: 16,
                    isBold: true,
                    align: TextAlign.start,
                  ),

                  const SizedBox(height: 12),

                  // Input fields for duration and dosage
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            text: 'Duration',
                            fontSize: 12,
                            align: TextAlign.start,
                          ),
                          TextWidget(
                            text: data['duration'],
                            fontSize: 16,
                            isBold: true,
                            align: TextAlign.start,
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            text: 'Dosage',
                            fontSize: 12,
                            align: TextAlign.start,
                          ),
                          TextWidget(
                            text: data['dosage'],
                            fontSize: 16,
                            isBold: true,
                            align: TextAlign.start,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Notes field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: 'Medication Notes',
                        fontSize: 12,
                        align: TextAlign.start,
                      ),
                      TextWidget(
                        text: data['notes'],
                        fontSize: 16,
                        isBold: true,
                        align: TextAlign.start,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: TextWidget(
                        text: "Close",
                        fontSize: 16,
                        color: Colors.white,
                        isBold: true,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  TimeOfDay? pickedTimeNew;
  DateTime? pickedDateNew;
  Widget _buildPickerField(String hintText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            hintText,
            style: TextStyle(color: Colors.grey[600]),
          ),
          Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
        ],
      ),
    );
  }

  String condition = 'UTIs';
  String medicine = 'Paracetamol';
  Widget _buildConditionDropdown(String hintText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
        hint: Text(hintText),
        items: const [
          DropdownMenuItem(
              value: "UTIs", child: Text("Urinary Tract Infections (UTIs)")),
          DropdownMenuItem(
              value: "Skin Infections", child: Text("Skin Infections")),
          DropdownMenuItem(value: "Asthma", child: Text("Asthma")),
          DropdownMenuItem(value: "Pneumonia", child: Text("Pneumonia")),
          DropdownMenuItem(
              value: "COPD",
              child: Text("Chronic Obstructive Pulmonary Disease (COPD)")),
          DropdownMenuItem(value: "Malaria", child: Text("Malaria")),
          DropdownMenuItem(value: "Arthritis", child: Text("Arthritis")),
          DropdownMenuItem(
              value: "Heart Disease", child: Text("Heart Disease")),
          DropdownMenuItem(value: "Hepatitis", child: Text("Hepatitis")),
        ],
        onChanged: (value) {
          // Handle dropdown selection here
          print("Selected Medicine: $value");

          setState(() {
            condition = value.toString();
          });
        },
      ),
    );
  }

  // Helper method to create a dropdown with a medicine list
  Widget _buildMedicineDropdown(String hintText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
        hint: Text(hintText),
        items: const [
          DropdownMenuItem(value: "Paracetamol", child: Text("Paracetamol")),
          DropdownMenuItem(value: "Ibuprofen", child: Text("Ibuprofen")),
          DropdownMenuItem(value: "Amoxicillin", child: Text("Amoxicillin")),
          DropdownMenuItem(
              value: "Ciprofloxacin", child: Text("Ciprofloxacin")),
          DropdownMenuItem(value: "Metformin", child: Text("Metformin")),
          DropdownMenuItem(value: "Aspirin", child: Text("Aspirin")),
          DropdownMenuItem(value: "Lisinopril", child: Text("Lisinopril")),
          DropdownMenuItem(value: "Atorvastatin", child: Text("Atorvastatin")),
          DropdownMenuItem(value: "Omeprazole", child: Text("Omeprazole")),
          DropdownMenuItem(value: "Salbutamol", child: Text("Salbutamol")),
        ],
        onChanged: (value) {
          // Handle dropdown selection here
          print("Selected Medicine: $value");
          setState(() {
            medicine = value.toString();
          });
        },
      ),
    );
  }

  final duration = TextEditingController();
  final dosage = TextEditingController();
  final notes = TextEditingController();
  // Helper method to create an input field
  Widget _buildInputField(String hintText, TextEditingController cont,
      {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      controller: cont,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[300],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
