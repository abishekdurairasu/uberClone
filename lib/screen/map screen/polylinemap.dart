import 'dart:async';
import 'dart:math' show cos, sqrt, asin;

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_geocoding_api/google_geocoding_api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../../components/const.dart';
import '../place Search Screen/loctionSearch_screen.dart';

class TrackingMap3 extends StatefulWidget {
  final String boardingLocation;
  final String destinationLocation;

  const TrackingMap3({
    Key? key,
    required this.boardingLocation,
    required this.destinationLocation,
  }) : super(key: key);

  @override
  State<TrackingMap3> createState() => _TrackingMap3State();
}

class _TrackingMap3State extends State<TrackingMap3> {
  final Completer<GoogleMapController> _controller = Completer();
  Location location = Location();
  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  MapType currentMapType = MapType.normal;
  BitmapDescriptor? markerIcon2;
  LatLng sourceLocation = const LatLng(11.030554, 76.967007);
  LatLng destination = const LatLng(11.026667, 77.041667);
  Set<Marker> _markers = {};

  // int maxLength = 10 ;
  late Timer _timer;
  late double totalDistance;
  late String estimatedTime;
  TextEditingController boardingLocationController = TextEditingController();
  TextEditingController destinationLocationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    _getLatLng();
    addCustomIcons();
    getCurrentLocation();
    getPolylinePoint();
    calculateDistance();
    _updateMarkers();

    boardingLocationController.text = widget.boardingLocation;
    destinationLocationController.text = widget.destinationLocation;
    totalDistance = 0.0;
    estimatedTime = '';

    // Set up a timer to update distance and time every 30 seconds (adjust as needed)
    _timer = Timer.periodic(const Duration(seconds: 30), (Timer timer) {
      updateDistanceAndTime();
    });
  }

// _getLatLng

  Future<void> _getLatLng() async {
    const String googleApiKey = GOOGLE_MAPS_API_KEY;
    final api = GoogleGeocodingApi(googleApiKey);

    try {
      final boardingResults =
          await api.search(widget.boardingLocation, language: 'en');
      final destinationResults =
          await api.search(widget.destinationLocation, language: 'en');

      if (boardingResults.results.isEmpty ||
          destinationResults.results.isEmpty) {
        // Handle case when location is not found
        print('Error: Location not found');
        return;
      }

      setState(() {
        sourceLocation = LatLng(
          boardingResults.results.first.geometry!.location.lat,
          boardingResults.results.first.geometry!.location.lng,
        );

        destination = LatLng(
          destinationResults.results.first.geometry!.location.lat,
          destinationResults.results.first.geometry!.location.lng,
        );
      });
      // getPolylinePoint();

      print("sourceLocation: $sourceLocation");
      print("destination: $destination");
    } catch (e) {
      print('Error: $e');
    }
  } // _getLatLng

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
    } catch (e) {
      print("Error getting location: $e");
    }
  } // getCurrentLocation

  // getPolylinePoint

  void getPolylinePoint() async {
    try {
      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        GOOGLE_MAPS_API_KEY,
        PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        PointLatLng(destination.latitude, destination.longitude),
        travelMode: TravelMode.driving,
      );

      if (result.points.isNotEmpty) {
        setState(() {
          polylineCoordinates.clear();
          for (var point in result.points) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          }
        });
      }
      _updateMarkers();
      calculateDistance();
    } catch (e) {
      print("Error getting polyline points: $e");
    }
  } // getPolylinePoint

  // calculateDistance

  void calculateDistance() {
    double newTotalDistance = 0.0;

    for (int i = 0; i < polylineCoordinates.length - 1; i++) {
      newTotalDistance += coordinateDistance(
        polylineCoordinates[i].latitude,
        polylineCoordinates[i].longitude,
        polylineCoordinates[i + 1].latitude,
        polylineCoordinates[i + 1].longitude,
      );
    }

    setState(() {
      totalDistance = newTotalDistance;
    });

    print('Total distance: ${totalDistance.toStringAsFixed(2)} km');
  } // calculateDistance

  //coordinateDistance

  double coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    var distance = 12742 * asin(sqrt(a));
    return distance;
  } // coordinateDistance

// _updateMarkers

  void _updateMarkers() {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId("source"),
          position: sourceLocation,
          icon: BitmapDescriptor.defaultMarker,
        ),
        Marker(
          markerId: const MarkerId("currentLocation"),
          position: currentLocation != null
              ? LatLng(currentLocation!.latitude!, currentLocation!.longitude!)
              : sourceLocation,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
        Marker(
          markerId: const MarkerId("destination"),
          position: destination,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      };
    });
  } // _updateMarkers

// addCustomIcons

  void addCustomIcons() async {
    markerIcon2 = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(0.2, 0.4)),
      "assets/images/auto.png",
    ).then((icon) {
      setState(() {
        markerIcon2 = icon;
      });
      return null;
    });
  } // addCustomIcons

  // cameraToPosition

  Future<void> cameraToPosition(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    CameraPosition newCameraPosition =
        CameraPosition(target: position, zoom: 16);
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
  } // cameraToPosition

// calculateEstimatedTime

  String calculateEstimatedTime() {
    // Assuming an average speed in km/h (adjust as needed)
    double averageSpeed = 20.0; // in kilometers per hour

    double timeInHours =
        totalDistance / averageSpeed; // Calculate time in hours

    int timeInMinutes = (timeInHours * 60).round(); // Convert time to minutes

    int hours = timeInMinutes ~/ 60; // Format the time as hours and minutes
    int minutes = timeInMinutes % 60; // Format the time as hours and minutes

    return '$hours h $minutes min';
  } // calculateEstimatedTime

  // updateDistanceAndTime

  void updateDistanceAndTime() {
    // Recalculate distance and estimated time here
    // calculateDistance();
    estimatedTime =
        calculateEstimatedTime(); // Update estimated time based on your calculation
  } // updateDistanceAndTime

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar

      appBar: AppBar(
        title: const Center(
            child:
                Text('Booking app', style: TextStyle(color: Colors.black54))),
        backgroundColor: const Color(0xFFF6F7F9),
      ),

      // body

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
                target: sourceLocation,
                zoom: 14,
              ),
              myLocationEnabled: true,
              trafficEnabled: true,
              mapType: currentMapType,

              // polylines

              polylines: {
                Polyline(
                  polylineId: const PolylineId("route"),
                  visible: true,
                  points: polylineCoordinates,
                  color: Colors.amber,
                  width: 10,
                )
              },

              // markers

              markers: _markers,
            ),

          // DraggableScrollableSheet

          DraggableScrollableSheet(
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // searchbar

                    Padding(
                      padding:
                          const EdgeInsets.only(top: 40, left: 16, right: 16),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SearchLocationScreen(
                                placePicker: '',
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20))),
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
                                        width:
                                            MediaQuery.of(context).size.width -
                                                86,
                                        color: Colors.transparent,
                                        child: TextField(
                                          readOnly: true,
                                          // maxLength: maxLength,
                                          // obscureText: true,
                                          style: const TextStyle(
                                              color: Colors.black54),
                                          controller:
                                              boardingLocationController,
                                          textInputAction:
                                              TextInputAction.search,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText:
                                                ' Enter Boarding Location',
                                            hintStyle: TextStyle(
                                              color: Colors.grey.shade400,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ), // Boarding location search filed

                                // Divider

                                const Padding(
                                  padding:
                                      EdgeInsets.only(left: 16.0, right: 16),
                                  child: Divider(
                                      height: 2,
                                      thickness: 2,
                                      color: Colors.black12),
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
                                        width:
                                            MediaQuery.of(context).size.width -
                                                86,
                                        color: Colors.transparent,
                                        child: TextField(
                                          readOnly: true,
                                          style: const TextStyle(
                                              color: Colors.black54),
                                          controller:
                                              destinationLocationController,
                                          textInputAction:
                                              TextInputAction.search,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText:
                                                ' Enter Destination Location',
                                            hintStyle: TextStyle(
                                              color: Colors.grey.shade400,
                                            ),
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
                      ),
                    ), // searchbar

                    // distance and time calculation card

                    Padding(
                      padding:
                          const EdgeInsets.only(left: 16, right: 16, top: 20),
                      child: Container(
                        height: 180,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20))),
                        child: Column(
                          children: [
                            Container(
                              height: 80,
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(20),
                                    topLeft: Radius.circular(20)),
                                image: DecorationImage(
                                  image: AssetImage("assets/images/card.jpg"),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10, top: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    // Corrected the spelling
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    // Corrected the spelling
                                    children: [
                                      Text(
                                        'Distance ${totalDistance.toStringAsFixed(2)} km',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      Text(
                                        'Estimated time $estimatedTime',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ) // distance and time calculation card
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
