// /// search screen backup
//
//
//
// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:flutter/material.dart';
// import 'package:polylinemap/components/const.dart';
// import 'package:polylinemap/components/network_utility.dart';
// import 'polylinemap.dart';
// import 'package:location/location.dart';
//
// class SearchLocationScreen extends StatefulWidget {
//   final String placePicker;
//
//   const SearchLocationScreen({
//     Key? key,
//     required this.placePicker,
//   }) : super(key: key);
//
//   @override
//   State<SearchLocationScreen> createState() => _SearchLocationScreenState();
// }
//
// class _SearchLocationScreenState extends State<SearchLocationScreen> {
//   bool isLoading = true;
//   List<String> boardingLocationSuggestions = [];
//   List<String> destinationLocationSuggestions = [];
//   TextEditingController boardingLocationController = TextEditingController();
//   TextEditingController destinationLocationController = TextEditingController();
//   String currentAddress = '';
//   Location location = Location();
//
//   @override
//   void initState() {
//     super.initState();
//     boardingLocationController.text = widget.placePicker;
//   }
//
//   void placeAutoComplete(String query, String field) async {
//     Uri uri =
//     Uri.https("maps.googleapis.com", 'maps/api/place/autocomplete/json', {
//       "input": query,
//       "key": GOOGLE_MAPS_API_KEY,
//     });
//
//     try {
//       String? response = await NetworkUtility.fetchUrl(uri);
//
//       if (response != null) {
//         Map<String, dynamic> data = json.decode(response);
//
//         List<dynamic> predictions = data['predictions'];
//         List<String> newSuggestions = predictions.map<String>((prediction) {
//           return prediction['description'];
//         }).toList();
//
//         // Update the corresponding suggestions list
//         setState(() {
//           if (field == 'boarding') {
//             boardingLocationSuggestions = newSuggestions;
//           } else if (field == 'destination') {
//             destinationLocationSuggestions = newSuggestions;
//           }
//         });
//
//         log(response);
//       }
//     } catch (error) {
//       log('Error fetching autocomplete data: $error');
//     }
//   }
//
//   void selectSuggestion(String suggestion, String field) {
//     // Set the selected suggestion in the appropriate text field
//     if (field == 'boarding') {
//       boardingLocationController.text = suggestion;
//     } else if (field == 'destination') {
//       destinationLocationController.text = suggestion;
//     }
//   }
//
//
//
//
//   // Future<void> getCurrentLocation() async {
//   //   try {
//   //     LocationData locationData = await location.getLocation();
//   //     print('Latitude: ${locationData.latitude}, Longitude: ${locationData.longitude}');
//   //   } catch (e) {
//   //     print('Error getting location: $e');
//   //   }
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       appBar: AppBar(
//         title: const Center(
//           child: Text(
//             "Search Screen",
//             style: TextStyle(color: Colors.black54),
//           ),
//         ),
//         backgroundColor: const Color(0xFFF6F7F9),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(left: 16, right: 16, top: 28),
//             child: Container(
//               height: 48,
//               decoration: const BoxDecoration(
//                   color: Color(0xFFF6F7F9),
//                   borderRadius: BorderRadius.all(Radius.circular(8))),
//               child: TextFormField(
//                 style: const TextStyle(color: Colors.black87),
//                 controller: boardingLocationController,
//                 onChanged: (value) {
//                   placeAutoComplete(value, 'boarding');
//                 },
//                 textInputAction: TextInputAction.search,
//                 decoration: InputDecoration(
//                     border: InputBorder.none,
//                     hintText: ' Enter Boarding Location',
//                     hintStyle: TextStyle(
//                       color: Colors.grey.shade400,
//                     ),
//                     suffixIcon: boardingLocationController.text.isNotEmpty
//                         ? IconButton(
//                         onPressed: () {
//                           boardingLocationSuggestions = [];
//                           boardingLocationController.clear();
//                         },
//                         icon: const Icon(
//                           Icons.clear_outlined,
//                           color: Colors.black54,
//                         ))
//                         : null,
//                     prefixIcon: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 12),
//                       child: Icon(
//                         Icons.pin_drop_rounded,
//                         color: Colors.grey.shade500,
//                       ),
//                     )),
//               ),
//             ),
//           ), // Enter Boarding Location
//
//           Padding(
//             padding:
//             const EdgeInsets.only(left: 16, right: 16, top: 18, bottom: 18),
//             child: Container(
//               height: 48,
//               decoration: const BoxDecoration(
//                   color: Color(0xFFF6F7F9),
//                   borderRadius: BorderRadius.all(Radius.circular(8))),
//               child: TextFormField(
//                 style: const TextStyle(color: Colors.black87),
//                 controller: destinationLocationController,
//                 onChanged: (value) {
//                   placeAutoComplete(value, 'destination');
//                 },
//                 textInputAction: TextInputAction.search,
//                 decoration: InputDecoration(
//                     border: InputBorder.none,
//                     hintText: ' Enter Destination Location',
//                     hintStyle: TextStyle(
//                       color: Colors.grey.shade400,
//                     ),
//                     suffixIcon: destinationLocationController.text.isNotEmpty
//                         ? IconButton(
//                         onPressed: () {
//                           setState(() {
//                             boardingLocationSuggestions = [];
//                             destinationLocationController.clear();
//                           });
//                         },
//                         icon: const Icon(
//                           Icons.clear_outlined,
//                           color: Colors.black54,
//                         ))
//                         : null,
//                     prefixIcon: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 12),
//                       child: Icon(
//                         Icons.pin_drop_rounded,
//                         color: Colors.grey.shade500,
//                       ),
//                     )),
//               ),
//             ),
//           ), // Enter Boarding Location
//
//           Padding(
//             padding:
//             const EdgeInsets.only(left: 16, right: 16, top: 18, bottom: 28),
//             child: GestureDetector(
//               onTap:(){
//                 String boardingLocation = boardingLocationController.text;
//                 String destinationLocation = destinationLocationController.text;
//
//                 if (boardingLocation.isNotEmpty && destinationLocation.isNotEmpty) {
//                   // Both fields are not empty, navigate to the next page
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => TrackingMap3(
//                         boardingLocation: boardingLocation,
//                         destinationLocation: destinationLocation,
//                       ),
//                     ),
//                   );
//                 } else {
//                   // Show alert if any field is empty
//                   showDialog(
//                     context: context,
//                     builder: (BuildContext context) {
//                       return AlertDialog(
//                         title: Text('Error'),
//                         content: Text('Please enter both boarding and destination locations.'),
//                         actions: <Widget>[
//                           TextButton(
//                             onPressed: () {
//                               Navigator.of(context).pop();
//                             },
//                             child: Text('OK'),
//                           ),
//                         ],
//                       );
//                     },
//                   );
//                 }
//               },
//               child: Container(
//                 height: 48,
//                 decoration: BoxDecoration(
//                     color: Colors.grey.shade200,
//                     borderRadius: const BorderRadius.all(Radius.circular(8))),
//                 child: const Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.gps_fixed,
//                       color: Colors.black54,
//                     ),
//                     SizedBox(
//                       width: 10,
//                     ),
//                     Text(
//                       "get a ride",
//                       style: TextStyle(color: Colors.black54, fontSize: 20),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           // Enter Destination Location
//
//           const Divider(height: 4, thickness: 4, color: Color(0xFFF6F7F9)),
//           // Divider
//
//           // boarding Suggestions list
//           Expanded(
//             child: ListView.builder(
//               itemCount: boardingLocationSuggestions.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(boardingLocationSuggestions[index],
//                       style: const TextStyle(color: Colors.black54)),
//                   onTap: () {
//                     selectSuggestion(
//                         boardingLocationSuggestions[index], 'boarding');
//                   },
//                 );
//               },
//             ),
//           ),
//
//           // destination Suggestions list
//           Expanded(
//             child: ListView.builder(
//               itemCount: destinationLocationSuggestions.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(destinationLocationSuggestions[index],
//                       style: const TextStyle(color: Colors.black54)),
//                   onTap: () {
//                     selectSuggestion(
//                         destinationLocationSuggestions[index], 'destination');
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
