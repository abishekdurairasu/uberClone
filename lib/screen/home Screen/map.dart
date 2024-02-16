import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_geocoding_api/google_geocoding_api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';


import '../../components/const.dart';
import '../place Search Screen/loctionSearch_screen.dart';

class TrackingMap2 extends StatefulWidget {
  const TrackingMap2({Key? key}) : super(key: key);

  @override
  State<TrackingMap2> createState() => _TrackingMap2State();
}

class _TrackingMap2State extends State<TrackingMap2> {
  final Completer<GoogleMapController> _controller = Completer();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController PlacePickTextController = TextEditingController();
  Location location = Location();
  LocationData? currentLocation;

  MapType currentMapType = MapType.normal;
  BitmapDescriptor? markerIcon1;
  BitmapDescriptor? markerIcon2;
  LatLng sourceLocation = const LatLng(0, 0);
  Set<Marker> _markers = {};
  Set<Marker> _constantMarkers = {}; // Add this set for constant markers

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    addCustomIcons();
    getCurrentLocation();
    // _getLatLng();
    // Add this line to initialize _markers
  }

  // _getLatLng

  Future<void> _getLatLng() async {
    try {
      if (_markers.isNotEmpty) {
        LatLng pos = _markers.first.position;

        final reversedSearchResults =
            await GoogleGeocodingApi(GOOGLE_MAPS_API_KEY).reverse(
          '${pos.latitude},${pos.longitude}',
          language: 'en',
        );

        setState(() {
          PlacePickTextController.text =
              reversedSearchResults.results.first.formattedAddress ?? '';
        });

        print(PlacePickTextController.text);
      } else {
        print('Error: _markers is empty');
      }
    } catch (e) {
      print('Error: $e');
    }
  } // _getLatLng

// _onDragEnd
  void _onDragEnd(LatLng position) async {
    try {
      final reversedSearchResults =
          await GoogleGeocodingApi(GOOGLE_MAPS_API_KEY).reverse(
        '${position.latitude},${position.longitude}',
        language: 'en',
      );

      setState(() {
        PlacePickTextController.text =
            reversedSearchResults.results.first.formattedAddress ?? '';

        _markers = _markers.map((marker) {
          if (marker.markerId == const MarkerId("currentLocation")) {
            return marker.copyWith(positionParam: position);
          }
          return marker;
        }).toSet();

        _getLatLng();
      });

      log(PlacePickTextController.text);
    } catch (e) {
      log('Error: $e');
    }
  }

  // requestLocationPermission
  Future<void> requestLocationPermission() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      bool serviceRequested = await location.requestService();
      if (!serviceRequested) {
        return;
      }
    }

    PermissionStatus permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        return;
      }
    }
  } // requestLocationPermission

  // getCurrentLocation

  void getCurrentLocation() async {
    try {
      LocationData currentLocationData = await location.getLocation();
      setState(() {
        currentLocation = currentLocationData;
        cameraToPosition(
            LatLng(currentLocation!.latitude!, currentLocation!.longitude!));
      });

      _updateMarkers();
      _getLatLng(); // Add this line to fetch the initial address
    } catch (e) {
      print("Error getting location: $e");
    }
  } // getCurrentLocation

  // _updateMarkers

  void _updateMarkers() {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId("currentLocation"),
          position: currentLocation != null
              ? LatLng(
                  currentLocation!.latitude!,
                  currentLocation!.longitude!,
                )
              : sourceLocation,
          icon: markerIcon1 ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: "Picking Location", // Provide the title as a String
            snippet: PlacePickTextController
                .text, // Optionally, provide a snippet as a String
          ),
          draggable: true,
          onDragEnd: (details) => _onDragEnd(details),
        ),
      };

      // constant multi markers

      _constantMarkers = {
        Marker(
          markerId: const MarkerId("constantMarker1"),
          position: const LatLng(11.050833, 77.046089),
          icon: markerIcon2 ?? BitmapDescriptor.defaultMarker,
          infoWindow: const InfoWindow(title: "Marker 1"),
        ),
        Marker(
          markerId: const MarkerId("constantMarker2"),
          position: const LatLng(11.048706, 77.047119),
          icon: markerIcon2 ?? BitmapDescriptor.defaultMarker,
          infoWindow: const InfoWindow(title: "Marker 2"),
        ),
        Marker(
          markerId: const MarkerId("marker3"),
          position: const LatLng(11.047863, 77.046132),
          icon: markerIcon2 ?? BitmapDescriptor.defaultMarker,
          infoWindow: const InfoWindow(title: "Marker 3"),
        ),
        Marker(
          markerId: const MarkerId("marker4"),
          position: const LatLng(11.047505, 77.044952),
          icon: markerIcon2 ?? BitmapDescriptor.defaultMarker,
          infoWindow: const InfoWindow(title: "Marker 4"),
        ),
        Marker(
          markerId: const MarkerId("marker5"),
          position: const LatLng(11.050184, 77.046862),
          icon: markerIcon2 ?? BitmapDescriptor.defaultMarker,
          infoWindow: const InfoWindow(title: "Marker 5"),
        ),
        Marker(
          markerId: const MarkerId("marker6"),
          position: const LatLng(11.049847, 77.047462),
          icon: markerIcon2 ?? BitmapDescriptor.defaultMarker,
          // Use default if markerIcon2 is null
          infoWindow: const InfoWindow(title: "Marker 6"),
        ),
        Marker(
          markerId: const MarkerId("marker7"),
          position: const LatLng(11.049384, 77.048020),
          icon: markerIcon2 ?? BitmapDescriptor.defaultMarker,
          infoWindow: const InfoWindow(title: "Marker 7"),
        ),

        // ...
      };
      _getLatLng();
    });
  }

  // addCustomIcons

  void addCustomIcons() async {
    try {
      markerIcon1 = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(),
        "assets/images/placeMarker.png",
      );
      markerIcon2 = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(),
        "assets/images/car3.png",
      );

      setState(() {
        markerIcon1 = markerIcon1;
        markerIcon2 = markerIcon2;
      });
      _updateMarkers();
    } catch (e) {
      log("Error: $e");
    }
  } // addCustomIcons

  // cameraToPosition

  Future<void> cameraToPosition(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    CameraPosition newCameraPosition =
        CameraPosition(target: position, zoom: 16);
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
  } // cameraToPosition

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,

      //appBar

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(126.0),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 6),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white),
                    child: const Center(
                      child: Icon(
                        Icons.menu,
                        color: Colors.black54,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  height: 48,
                  width: MediaQuery.of(context).size.width - 86,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Colors.white),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 8),
                    child: TextField(
                      readOnly: true,
                      style: const TextStyle(color: Colors.black54),
                      controller: PlacePickTextController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      // appBar

      //Drawer

      drawer: Drawer(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        backgroundColor: Colors.white,
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            // DrawerHeader

            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.amber,
              ),
              child: UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                    color: Colors.amberAccent,
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                accountName: const Text(
                  "Radaz",
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
                accountEmail: const Text(
                  "Support@radaz.in",
                  style: TextStyle(color: Colors.black54),
                ),
                currentAccountPictureSize: const Size.square(50),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.amberAccent.shade400,
                  child: Text(
                    "RZ",
                    style:
                        TextStyle(fontSize: 24.0, color: Colors.yellow.shade50),
                  ),
                ),
              ),
            ),

            // DrawerBody
            // My Profile

            ListTile(
              leading: const Icon(Icons.person, color: Colors.black54),
              title: const Text(
                ' My Profile ',
                style: TextStyle(color: Colors.black54),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ), // My Profile

            // Rating

            ListTile(
              leading: const Icon(Icons.star, color: Colors.black54),
              title: const Text(
                ' Rating ',
                style: TextStyle(color: Colors.black54),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ), // My Profile

            // Payment

            ListTile(
              leading: const Icon(Icons.payment, color: Colors.black54),
              title: const Text(
                ' Payment ',
                style: TextStyle(color: Colors.black54),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ), // My Profile

            // Edit Profile

            ListTile(
              leading: const Icon(Icons.edit, color: Colors.black54),
              title: const Text(
                ' Edit Profile ',
                style: TextStyle(color: Colors.black54),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ), // Edit Profile

            // Settings

            ListTile(
              leading: const Icon(Icons.edit, color: Colors.black54),
              title: const Text(
                ' Settings ',
                style: TextStyle(color: Colors.black54),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ), // Edit Profile

            //LogOut

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.black54),
              title: const Text(
                'LogOut',
                style: TextStyle(color: Colors.black54),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ), //LogOut
          ],
        ),
      ),

      // Body

      body: Stack(
        children: [
          // GoogleMap

          if (currentLocation == null)
            const Center(
                child: CircularProgressIndicator(
              color: Colors.amberAccent,
              value: 0.5,
            ))
          else
            GoogleMap(
              onMapCreated: (controller) {
                _controller.complete(controller);
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    currentLocation!.latitude!, currentLocation!.longitude!),
                zoom: 14,
              ),
              myLocationEnabled: false,
              trafficEnabled: true,
              mapType: currentMapType,
              markers: {..._constantMarkers, ..._markers},
            ),

          // DraggableScrollableSheet

          DraggableScrollableSheet(
            maxChildSize: 0.4,
            initialChildSize: 0.2,
            minChildSize: 0.2,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    Center(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 16, right: 16, top: 48),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchLocationScreen(
                                    placePicker: PlacePickTextController.text),
                              ),
                            );
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(24)),
                            ),
                            child: const Center(
                              child: Text(
                                'Where are you going ?',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
