// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart' as leaflet;
// import 'package:flutter_map/src/layer/marker_layer.dart' as leaflet_marker;
// import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
// import 'package:google_geocoding_api/google_geocoding_api.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:latlong2/latlong.dart' as loc;
// import 'package:location/location.dart';
// import 'package:polylinemap/components/const.dart';
//
// import 'loctionSearch_screen.dart';
//
// class TestApp extends StatefulWidget {
//   const TestApp({Key? key}) : super(key: key);
//
//   @override
//   TestAppState createState() => TestAppState();
// }
//
// class TestAppState extends State<TestApp> {
//   final Completer<GoogleMapController> _controller = Completer();
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   TextEditingController PlacePickTextController = TextEditingController();
//   late List<DragMarker> _dragMarkers = [];
//   List<leaflet_marker.Marker> _constantMarkers = [];
//   BitmapDescriptor? markerIcon2;
//   String reversedResults = '';
//   LocationData? currentLocation;
//   Location location = Location();
//
//   @override
//   void initState() {
//     super.initState();
//     _createMarkers();
//     _getLatLng();
//     getCurrentLocation();
//   }
//
//   void _createMarkers() {
//     _dragMarkers.add(
//       DragMarker(
//         key: GlobalKey<DragMarkerWidgetState>(),
//         point: const loc.LatLng(11.0152363, 77.0267801),
//         size: const Size(75, 50),
//         builder: (_, pos, ___) {
//           return Card(
//             color: Colors.amber,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   pos.latitude.toStringAsFixed(3),
//                   style: const TextStyle(color: Colors.white),
//                 ),
//                 Text(
//                   pos.longitude.toStringAsFixed(3),
//                   style: const TextStyle(color: Colors.white),
//                 ),
//               ],
//             ),
//           );
//         },
//         onDragEnd: (details, position) => _onDragEnd(details, position),
//       ),
//     );
//
//     _constantMarkers.add(
//       const leaflet_marker.Marker(
//         width: 30.0,
//         height: 30.0,
//         point: loc.LatLng(11.0252363, 77.0367801),
//         child:  Icon(
//           Icons.location_on,
//           color: Colors.red,
//           size: 30,
//         ),
//       ),
//     );
//
//     _constantMarkers.add(
//       const leaflet_marker.Marker(
//         width: 30.0,
//         height: 30.0,
//         point: loc.LatLng(11.0052370, 77.0167881),
//         child:  Icon(
//           Icons.location_on,
//           color: Colors.red,
//           size: 30,
//         ),
//       ),
//     );
//
//
//     _constantMarkers.add(
//       const leaflet_marker.Marker(
//         width: 30.0,
//         height: 30.0,
//         point: loc.LatLng(11.0015800, 77.0277890),
//         child:  Icon(
//           Icons.location_on,
//           color: Colors.red,
//           size: 30,
//         ),
//       ),
//     );
//
//  _constantMarkers.add(
//       const leaflet_marker.Marker(
//         width: 30.0,
//         height: 30.0,
//         point: loc.LatLng(11.0162203, 77.0287701),
//         child:  Icon(
//           Icons.location_on,
//           color: Colors.red,
//           size: 30,
//         ),
//       ),
//     );
//
//     _constantMarkers.add(
//       const leaflet_marker.Marker(
//         width: 30.0,
//         height: 30.0,
//         point: loc.LatLng(11.0015140, 77.0277901),
//         child:  Icon(
//           Icons.location_on,
//           color: Colors.red,
//           size: 30,
//         ),
//       ),
//     );
//
//
//     _constantMarkers.add(
//       const leaflet_marker.Marker(
//         width: 30.0,
//         height: 30.0,
//         point: loc.LatLng(11.0015572, 77.0277990),
//         child:  Icon(
//           Icons.location_on,
//           color: Colors.red,
//           size: 30,
//         ),
//       ),
//     );
//
//     _constantMarkers.add(
//       const leaflet_marker.Marker(
//         width: 30.0,
//         height: 30.0,
//         point: loc.LatLng(11.0016372, 77.0177890),
//         child:  Icon(
//           Icons.location_on,
//           color: Colors.red,
//           size: 30,
//         ),
//       ),
//     );
//
//     _constantMarkers.add(
//       const leaflet_marker.Marker(
//         width: 30.0,
//         height: 30.0,
//         point: loc.LatLng(11.0015272, 77.0066890),
//         child:  Icon(
//           Icons.location_on,
//           color: Colors.red,
//           size: 30,
//         ),
//       ),
//     );
//
//   }
//
//   void _onDragEnd(DragEndDetails details, loc.LatLng position) async {
//     try {
//       loc.LatLng pos = _dragMarkers.first.point;
//
//       final reversedSearchResults = await GoogleGeocodingApi(GOOGLE_MAPS_API_KEY)
//           .reverse('${pos.latitude},${pos.longitude}', language: 'en');
//
//       setState(() {
//         PlacePickTextController.text =
//             reversedSearchResults.results.first.formattedAddress ?? '';
//       });
//
//       print(PlacePickTextController.text);
//     } catch (e) {
//       print('Error: $e');
//     }
//   }
//
//
//
//   Future<void> _getLatLng() async {
//     const String googleApiKey = GOOGLE_MAPS_API_KEY;
//     const bool isDebugMode = true;
//     final api = GoogleGeocodingApi(googleApiKey, isLogged: isDebugMode);
//
//     try {
//       loc.LatLng pos = _dragMarkers.first.point;
//
//       final reversedSearchResults = await api.reverse(
//         '${pos.latitude},${pos.longitude}',
//         language: 'en',
//       );
//       setState(() {
//         PlacePickTextController.text =
//             reversedSearchResults.results.first.formattedAddress ?? '';
//       });
//       print(PlacePickTextController.text);
//     } catch (e) {
//       print('Error: $e');
//     }
//   }
//
//   void addCustomIcons() async {
//     markerIcon2 = await BitmapDescriptor.fromAssetImage(
//       const ImageConfiguration(size: Size(0.2, 0.4)),
//       "android/assets/auto.png",
//     ).then((icon) {
//       setState(() {
//         markerIcon2 = icon;
//       });
//       return null;
//     });
//   }
//   //
//   void getCurrentLocation() async {
//     try {
//       LocationData currentLocationData = await location.getLocation();
//       setState(() {
//         currentLocation = currentLocationData;
//         cameraToPosition(
//             LatLng(currentLocation!.latitude!, currentLocation!.longitude!));
//       });
//     } catch (e) {
//       print("Error getting location: $e");
//     }
//   }
//
//   Future<void> cameraToPosition(LatLng position) async {
//     final GoogleMapController controller = await _controller.future;
//     CameraPosition newCameraPosition =
//     CameraPosition(target: position, zoom: 16);
//     await controller
//         .animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       extendBodyBehindAppBar: true,
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(126.0),
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.only(left: 16, right: 16, top: 6),
//             child: Row(
//               children: [
//                 GestureDetector(
//                   onTap: () {
//                     _scaffoldKey.currentState?.openDrawer();
//                   },
//                   child: Container(
//                     height: 48,
//                     width: 48,
//                     decoration: const BoxDecoration(
//                         shape: BoxShape.circle, color: Colors.white),
//                     child: const Center(
//                       child: Icon(
//                         Icons.menu,
//                         color: Colors.black54,
//                         size: 28,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 6),
//                 Container(
//                   height: 48,
//                   width: MediaQuery.of(context).size.width - 86,
//                   decoration: const BoxDecoration(
//                       borderRadius: BorderRadius.all(Radius.circular(20)),
//                       color: Colors.white),
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 12, bottom: 8),
//                     child: TextField(
//                       style: const TextStyle(color: Colors.black54),
//                       controller: PlacePickTextController,
//                       decoration: const InputDecoration(
//                         border: InputBorder.none,
//                       ),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//       drawer: Drawer(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16.0),
//         ),
//         backgroundColor: Colors.white70,
//         child: ListView(
//           padding: const EdgeInsets.all(0),
//           children: [
//             DrawerHeader(
//               decoration: const BoxDecoration(
//                 color: Colors.amber,
//               ),
//               child: UserAccountsDrawerHeader(
//                 decoration: BoxDecoration(color: Colors.amberAccent),
//                 accountName: const Text(
//                   "Radaz",
//                   style: TextStyle(fontSize: 18, color: Colors.black54),
//                 ),
//                 accountEmail: const Text(
//                   "Support@radaz.in",
//                   style: TextStyle(color: Colors.black54),
//                 ),
//                 currentAccountPictureSize: const Size.square(50),
//                 currentAccountPicture: CircleAvatar(
//                   backgroundColor: Colors.amberAccent.shade400,
//                   child: Text(
//                     "RZ",
//                     style: TextStyle(fontSize: 24.0, color: Colors.yellow.shade50),
//                   ),
//                 ),
//               ),
//             ),
//             ListTile(
//               leading: const Icon(Icons.person, color: Colors.black54),
//               title: const Text(
//                 ' My Profile ',
//                 style: TextStyle(color: Colors.black54),
//               ),
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.edit, color: Colors.black54),
//               title: const Text(
//                 ' Edit Profile ',
//                 style: TextStyle(color: Colors.black54),
//               ),
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.logout, color: Colors.black54),
//               title: const Text(
//                 'LogOut',
//                 style: TextStyle(color: Colors.black54),
//               ),
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),
//           ],
//         ),
//       ),
//       body: Stack(
//         children: [
//           leaflet.FlutterMap(
//             options: const leaflet.MapOptions(
//               initialCenter: loc.LatLng(11.0152363, 77.0267801),
//               initialZoom: 15,
//             ),
//             children: [
//               leaflet.TileLayer(
//                 urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//               ),
//               leaflet_marker.MarkerLayer(markers: _constantMarkers),
//               // Add draggable marker to the map
//               DragMarkers(markers: _dragMarkers, alignment: Alignment.topCenter),
//             ],
//           ),
//           DraggableScrollableSheet(
//             maxChildSize: 0.4,
//             initialChildSize: 0.2,
//             minChildSize: 0.2,
//             builder: (BuildContext context, ScrollController scrollController) {
//               return Container(
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade100,
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(40),
//                     topRight: Radius.circular(40),
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     Container(
//                       color: Colors.white70,
//                       child: Text(reversedResults),
//                     ),
//                     Center(
//                       child: Padding(
//                         padding: const EdgeInsets.only(left: 16, right: 16),
//                         child: GestureDetector(
//                           onTap: () {
//                             _getLatLng();
//                             print(PlacePickTextController.text);
//                             // Navigator.push(
//                             //   context,
//                             //   MaterialPageRoute(
//                             //     builder: (context) => SearchLocationScreen(
//                             //         placePicker: PlacePickTextController.text),
//                             //   ),
//                             // );
//                           },
//                           child: Container(
//                             height: 48,
//                             decoration: BoxDecoration(
//                               color: Colors.grey.shade200,
//                               borderRadius:
//                               const BorderRadius.all(Radius.circular(24)),
//                             ),
//                             child: const Center(
//                               child: Text(
//                                 'Where are you going ?',
//                                 style: TextStyle(
//                                   color: Colors.black54,
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
