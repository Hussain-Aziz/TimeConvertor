// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'package:TimeConvertor/data/time_zone_data.dart';
import 'package:TimeConvertor/main.dart';
import 'package:TimeConvertor/services/sql_database.dart';
import 'package:TimeConvertor/utils/extensions.dart';
import 'package:TimeConvertor/utils/limit_range.dart';
import 'package:TimeConvertor/utils/streams.dart';
import 'package:TimeConvertor/utils/valid_timezones.dart';
import 'package:TimeConvertor/widgets/conditional_info.dart';
import 'package:flutter/services.dart';
import 'package:TimeConvertor/services/get_tz_from_api.dart';
import 'package:TimeConvertor/env/env.dart';
import 'package:TimeConvertor/widgets/input_field.dart';
import 'package:TimeConvertor/widgets/submit_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:place_picker/place_picker.dart';
import 'package:search_choices/search_choices.dart';
import 'package:geolocator/geolocator.dart';

class InputNewLocationPage extends StatefulWidget {
  const InputNewLocationPage({super.key});

  @override
  State<InputNewLocationPage> createState() => _InputNewLocationPageState();
}

class _InputNewLocationPageState extends State<InputNewLocationPage> {
  final nameController = TextEditingController();
  final rawOffsetController = TextEditingController();
  String name = "";
  static const List<String> timeZoneChooseOptionsList = [
    "None",
    "Location",
    "Zone Name",
    "UTC Offset"
  ];

  int? selectedOffset;

  String tzSelectionDropdownValue = timeZoneChooseOptionsList.first;
  String timeZoneDropDownChooseValue = ValidTimeZones.validTimeZones.first;

  bool isGettingFromDB = false;

  String selectedAddress = "";
  String selectedZoneName = "";
  String selectedZoneAbreviation = "";
  String selectZoneIsInDST = "";

  @override
  void initState() {
    super.initState();
    nameController.addListener(setName);
    rawOffsetController.addListener(setOffset);
  }

  @override
  void dispose() {
    nameController.dispose();
    rawOffsetController.dispose();
    super.dispose();
  }

  void setName() {
    setState(() {
      name = nameController.text;
    });
  }

  void setOffset() {
    int? offset;

    if (rawOffsetController.text.isEmpty) {
      offset = null;
    } else {
      offset = (double.parse(rawOffsetController.text) * 3600).toInt();
    }

    setState(() {
      selectedOffset = offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,

      ///for the free back button
      appBar: AppBar(
        title: const Text("Add new location"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Center(
              child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              standardLabelText("Place Name"),
              InputField(
                  controller: nameController,
                  prefixIcon: const Icon(Icons.abc_outlined),
                  prompt: "Enter place name"),
              const SizedBox(
                height: 60,
              ),
              standardLabelText("Method of selecting time zone"),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: DropdownButton<String>(
                    value: tzSelectionDropdownValue,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    style:
                        GoogleFonts.poppins(color: Colors.blue, fontSize: 18),
                    underline: Container(
                      height: 2,
                      color: Colors.blue,
                    ),
                    onChanged: (String? value) {
                      // This is called when the user selects an item.
                      setState(() => tzSelectionDropdownValue = value!);
                      resetVariables();
                    },
                    items: timeZoneChooseOptionsList.mapToDropdownMenuItem()),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                  child: Container(
                alignment: Alignment.topCenter,
                child: LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  if (tzSelectionDropdownValue ==
                      timeZoneChooseOptionsList[0]) {
                    //None
                    return Container();
                  }
                  if (tzSelectionDropdownValue ==
                      timeZoneChooseOptionsList[1]) {
                    return locationSelection(context);
                  }
                  if (tzSelectionDropdownValue ==
                      timeZoneChooseOptionsList[2]) {
                    return zoneNameSelection();
                  }
                  if (tzSelectionDropdownValue ==
                      timeZoneChooseOptionsList[3]) {
                    return rawUtcOffsetSelection();
                  }

                  return const Placeholder(); //should never come here
                }),
              )),
              Container(
                margin: const EdgeInsets.only(bottom: 30, top: 10),
                child: SubmitButton(
                  label: "Add place",
                  onPressed: saveTZAndLeave,
                  isAcceptableInput: isReadyToLeave,
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  void saveTZAndLeave() {
    TimeZoneData newZone = TimeZoneData.empty();
    newZone.name = name;
    newZone.offset = selectedOffset!;

    if (tzSelectionDropdownValue == timeZoneChooseOptionsList[1]) {
      newZone.zoneName = selectedZoneName;
    }
    if (tzSelectionDropdownValue == timeZoneChooseOptionsList[2]) {
      newZone.zoneName = timeZoneDropDownChooseValue;
    }

    final id = getIt.get<TimeZoneDataStream>().addAndSetId(newZone);

    newZone.id = id;
    SQLDatabase.add(database, newZone);
    Navigator.pop(context);
  }

  bool isReadyToLeave() {
    return name.isNotEmpty &&
        (tzSelectionDropdownValue != timeZoneChooseOptionsList[0] ||
            (tzSelectionDropdownValue == timeZoneChooseOptionsList[1] &&
                selectedOffset != null &&
                selectedAddress.isNotEmpty &&
                selectedZoneName.isNotEmpty &&
                selectZoneIsInDST.isNotEmpty &&
                selectedZoneAbreviation.isNotEmpty &&
                !isGettingFromDB) ||
            (tzSelectionDropdownValue == timeZoneChooseOptionsList[2] &&
                timeZoneDropDownChooseValue.isNotEmpty &&
                timeZoneDropDownChooseValue != "None" &&
                !isGettingFromDB) ||
            (tzSelectionDropdownValue == timeZoneChooseOptionsList[3] &&
                selectedOffset != null));
  }

  void resetVariables({bool resetGettingFromDB = false}) {
    setState(() {
      selectedAddress = "";
      selectedZoneName = "";
      selectedZoneAbreviation = "";
      selectZoneIsInDST = "";
      selectedOffset = null;
      timeZoneDropDownChooseValue = "None";

      if (resetGettingFromDB) {
        isGettingFromDB = false;
      }
    });
  }

  String getDisplayOffset() {
    double offset = (selectedOffset ?? 0) / 3600;
    String ret = "";
    if (!offset.isNegative) {
      ret += "+";
    }

    if (offset % 1 == 0) {
      ret += offset.toInt().toString();
    } else {
      ret += offset.toString();
    }

    ret += "h";

    return ret;
  }

  Column rawUtcOffsetSelection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 20),
          alignment: Alignment.centerLeft,
          child: Text(
            "Enter Raw UTC Offset",
            style: GoogleFonts.poppins(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: InputField(
            controller: rawOffsetController,
            prompt: "Input UTC Offset",
            prefixIcon: const Icon(Icons.numbers),
            textInputType: TextInputType.number,
            textInputFormatters: [
              LengthLimitingTextInputFormatter(6),
              LimitRange(-12, 12),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.centerLeft,
          child: Text(
            "Note: Without a zone name, the app cannot automatically update time zone in the future when it changes (eg. when DST status changes)",
            style: GoogleFonts.poppins(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Column zoneNameSelection() {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        standardLabelText("Select Time Zone"),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SearchChoices.single(
              items: ValidTimeZones.validTimeZones.mapToDropdownMenuItem(
                  style: GoogleFonts.poppins(fontSize: 18)),
              isExpanded: true,
              hint: "Select Zone",
              searchHint: "Choose Zone",
              icon: const Icon(Icons.arrow_downward),
              onClear: () {
                setState(() {
                  timeZoneDropDownChooseValue = "None";
                  selectedOffset = null;
                });
              },
              underline: () => const Divider(
                thickness: 2,
                color: Colors.blue,
              ),
              value: timeZoneDropDownChooseValue,
              onChanged: (value) async {
                if (value == "None") {
                  setState(() {
                    timeZoneDropDownChooseValue = value;
                    selectedOffset = null;
                  });
                } else {
                  try {
                    setState(() {
                      isGettingFromDB = true;
                    });

                    final zoneOffset =
                        await GetTZFromAPI.getUTCOffsetByZoneFromTimeZoneDB(value);

                    //if its not reset by something else, do the set state
                    if (isGettingFromDB) {
                      setState(() {
                        isGettingFromDB = false;
                      });
                    }
                    setState(() {
                      timeZoneDropDownChooseValue = value;
                      selectedOffset = zoneOffset;
                    });
                  } catch (e) {
                    resetVariables();
                  }
                }
              },
            )),
        const SizedBox(
          height: 20,
        ),
        ConditionalInfo(
            isVisible: () => timeZoneDropDownChooseValue != "None",
            textHeader: "UTC Offset: ",
            textDesc: getDisplayOffset()),
        Visibility(
          visible: isGettingFromDB,
          child: const SpinKitCircle(
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Stack locationSelection(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Center(
              child: SubmitButton(
                label: "Select Location",
                onPressed: () async {
                  LocationResult? result;
                  try {
                    Position? pos;
                    if (await Geolocator.isLocationServiceEnabled()) {
                      if ([
                        LocationPermission.always,
                        LocationPermission.whileInUse
                      ].contains(await Geolocator.checkPermission())) {
                        pos = await Geolocator.getLastKnownPosition();
                      }
                    }
                    result = await Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      if (pos != null) {
                        return PlacePicker(
                          Env.mapAPI,
                          defaultLocation: LatLng(pos.latitude, pos.longitude),
                        );
                      } else {
                        return PlacePicker(
                          Env.mapAPI,
                        );
                      }
                    }));
                    if (result != null && result.latLng != null) {
                      final lat = result.latLng?.latitude;
                      final lng = result.latLng?.longitude;

                      setState(() {
                        isGettingFromDB = true;

                        selectedAddress =
                            "${result?.formattedAddress.toString()}";
                      });

                      final tzdbResponse =
                          await GetTZFromAPI.getZoneDataFromPosition(
                              lat!, lng!);

                      //if its not reset by something else, do the set state
                      if (isGettingFromDB) {
                        setState(() {
                          isGettingFromDB = false;
                          selectedZoneName = tzdbResponse['zoneName'];
                          selectedOffset = tzdbResponse['gmtOffset'];
                          selectedZoneAbreviation =
                              tzdbResponse['abbreviation'];
                          selectZoneIsInDST =
                              tzdbResponse['dst'] == "0" ? "No" : "Yes";
                        });
                      }
                    }
                  } catch (e) {
                    resetVariables(resetGettingFromDB: true);
                  }
                },
                isAcceptableInput: () {
                  return true;
                },
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                  child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      "Selected Address:",
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      selectedAddress.isEmpty ? "None" : selectedAddress,
                      style: GoogleFonts.poppins(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ConditionalInfo(
                      isVisible: () => selectedZoneName.isNotEmpty,
                      textHeader: "Time Zone Name: ",
                      textDesc: selectedZoneName),
                  ConditionalInfo(
                      isVisible: () => selectedOffset != null,
                      textHeader: "UTC Offset: ",
                      textDesc: getDisplayOffset()),
                  ConditionalInfo(
                      isVisible: () => selectedZoneAbreviation.isNotEmpty,
                      textHeader: "Time Zone Abreviation: ",
                      textDesc: selectedZoneAbreviation),
                  ConditionalInfo(
                      isVisible: () => selectZoneIsInDST.isNotEmpty,
                      textHeader: "In Daylight Savings: ",
                      textDesc: selectZoneIsInDST),
                ],
              )),
            )
          ],
        ),
        Align(
          alignment: const Alignment(-0.2, 0),
          child: Visibility(
            visible: isGettingFromDB,
            child: const SpinKitCircle(
              color: Colors.blue,
            ),
          ),
        )
      ],
    );
  }

  Container standardLabelText(String text) {
    return Container(
      padding: const EdgeInsets.only(left: 20),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 18,
        ),
      ),
    );
  }
}
