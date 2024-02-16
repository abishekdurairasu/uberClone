import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:ubercloneapp/components/network_utility.dart';

import '../../components/const.dart';
import '../map screen/polylinemap.dart';

class SearchLocationScreen extends StatefulWidget {
  final String placePicker;

  const SearchLocationScreen({
    Key? key,
    required this.placePicker,
  }) : super(key: key);

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  bool isLoading = true;
  List<String> boardingLocationSuggestions = [];
  List<String> destinationLocationSuggestions = [];
  TextEditingController boardingLocationController = TextEditingController();
  TextEditingController destinationLocationController = TextEditingController();
  String currentAddress = '';
  Location location = Location();

  @override
  void initState() {
    super.initState();
    boardingLocationController.text = widget.placePicker;
  }

  // placeAutoComplete

  void placeAutoComplete(String query, String field) async {
    Uri uri =
        Uri.https("maps.googleapis.com", 'maps/api/place/autocomplete/json', {
      "input": query,
      "key": GOOGLE_MAPS_API_KEY,
    });

    try {
      String? response = await NetworkUtility.fetchUrl(uri);

      if (response != null) {
        Map<String, dynamic> data = json.decode(response);

        List<dynamic> predictions = data['predictions'];
        List<String> newSuggestions = predictions.map<String>((prediction) {
          return prediction['description'];
        }).toList();

        // Update the corresponding suggestions list
        setState(() {
          if (field == 'boarding') {
            boardingLocationSuggestions = newSuggestions;
          } else if (field == 'destination') {
            destinationLocationSuggestions = newSuggestions;
          }
        });

        log(response);
      }
    } catch (error) {
      log('Error fetching autocomplete data: $error');
    }
  } // placeAutoComplete

  // Filter destination suggestions based on proximity to boarding location

  List<String> filterDestinationSuggestions() {
    double boardingLatitude = 0.0; // Set the actual boarding location latitude
    double boardingLongitude =
        0.0; // Set the actual boarding location longitude

    // Filter suggestions based on proximity (within 70 km from boarding location)
    return destinationLocationSuggestions.where((destination) {
      double destinationLatitude =
          0.0; // Set the actual destination location latitude
      double destinationLongitude =
          0.0; // Set the actual destination location longitude

      // Use the Haversine formula or any distance calculation logic to check proximity

      double distance = calculateDistance(
        boardingLatitude,
        boardingLongitude,
        destinationLatitude,
        destinationLongitude,
      );

      return distance <= 70.0; // 70 km is the proximity limit
    }).toList();
  } // Use the Haversine formula or any distance calculation logic to check proximity

  // Haversine formula for distance calculation

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return 50.0;
  } // Haversine formula for distance calculation

  // selectSuggestion

  void selectSuggestion(String suggestion, String field) {
    // Set the selected suggestion in the appropriate text field
    if (field == 'boarding') {
      boardingLocationController.text = suggestion;
    } else if (field == 'destination') {
      destinationLocationController.text = suggestion;
    }

    // Clear suggestions
    boardingLocationSuggestions = [];
    destinationLocationSuggestions = [];
    setState(() {});
  } // selectSuggestion

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Search Screen",
            style: TextStyle(color: Colors.black54),
          ),
        ),
        backgroundColor: const Color(0xFFF6F7F9),
      ),
      body: Column(
        children: [
          // searchbar

          Padding(
            padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.all(Radius.circular(20))),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    // Boarding location search filed

                    Padding(
                      padding: const EdgeInsets.all(0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_sharp,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 48,
                            width: MediaQuery.of(context).size.width - 86,
                            color: Colors.transparent,
                            child: TextFormField(
                              style: const TextStyle(color: Colors.black87),
                              controller: boardingLocationController,
                              onChanged: (value) {
                                placeAutoComplete(value, 'boarding');
                              },
                              textInputAction: TextInputAction.search,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: ' Enter Boarding Location',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                ),
                                suffixIcon: boardingLocationController
                                        .text.isNotEmpty
                                    ? IconButton(
                                        onPressed: () {
                                          boardingLocationController.clear();
                                        },
                                        icon: const Icon(
                                          Icons.clear_outlined,
                                          color: Colors.black54,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          )
                        ],
                      ),
                    ), // Boarding location search filed

                    // Divider

                    const Padding(
                      padding: EdgeInsets.only(left: 16.0, right: 16),
                      child: Divider(
                          height: 2, thickness: 2, color: Colors.black12),
                    ), // Divider

                    // destination location search filed

                    Padding(
                      padding: const EdgeInsets.all(0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_sharp,
                            color: Colors.lightGreen,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 48,
                            width: MediaQuery.of(context).size.width - 86,
                            color: Colors.transparent,
                            child: TextFormField(
                              style: const TextStyle(color: Colors.black87),
                              controller: destinationLocationController,
                              onChanged: (value) {
                                placeAutoComplete(value, 'destination');
                              },
                              textInputAction: TextInputAction.search,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: ' Enter Destination Location',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                ),
                                suffixIcon: destinationLocationController
                                        .text.isNotEmpty
                                    ? IconButton(
                                        onPressed: () {
                                          setState(() {
                                            destinationLocationController
                                                .clear();
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.clear_outlined,
                                          color: Colors.black54,
                                        ))
                                    : null,
                              ),
                            ),
                          )
                        ],
                      ),
                    ), // destination location search filed
                  ],
                ),
              ),
            ),
          ), // searchbar

          const SizedBox(height: 32), // SizedBox

          // Suggestions List
          Expanded(
            child: ListView.builder(
              itemCount: boardingLocationSuggestions.length +
                  filterDestinationSuggestions().length,
              itemBuilder: (context, index) {
                if (index < boardingLocationSuggestions.length) {
                  // Boarding location suggestions
                  return ListTile(
                    title: Text(
                      boardingLocationSuggestions[index],
                      style: const TextStyle(color: Colors.black54),
                    ),
                    onTap: () {
                      selectSuggestion(
                          boardingLocationSuggestions[index], 'boarding');
                    },
                  );
                } else {
                  // Destination location suggestions
                  int destinationIndex =
                      index - boardingLocationSuggestions.length;
                  List<String> filteredSuggestions =
                      filterDestinationSuggestions();
                  return ListTile(
                    title: Text(
                      filteredSuggestions[destinationIndex],
                      style: const TextStyle(color: Colors.black54),
                    ),
                    onTap: () {
                      selectSuggestion(
                          filteredSuggestions[destinationIndex], 'destination');
                    },
                  );
                }
              },
            ),
          ),

// Get a Ride Button
          Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 32, bottom: 28),
            child: GestureDetector(
              onTap: () {
                String boardingLocation = boardingLocationController.text;
                String destinationLocation = destinationLocationController.text;

                if (boardingLocation.isNotEmpty &&
                    destinationLocation.isNotEmpty) {
                  // Both fields are not empty, navigate to the next page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TrackingMap3(
                        boardingLocation: boardingLocation,
                        destinationLocation: destinationLocation,
                      ),
                    ),
                  );
                } else {
                  // Show alert if any field is empty
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: const Text(
                            'Please enter both boarding and destination locations.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Container(
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.gps_fixed,
                      color: Colors.black54,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "get a ride",
                      style: TextStyle(color: Colors.black54, fontSize: 20),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
