import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import '../consts.dart';

class MapPage extends StatefulWidget {
  final LatLng northEast;
  final LatLng southWest;
  final Function(LatLng) onLocationSelected;

  const MapPage({
    Key? key,
    required this.northEast,
    required this.southWest,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Location _locationController = Location();
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  final Set<Marker> _markers = {};
  LatLng? _selectedLocation;
  LatLng? _currentLocation;
  Map<PolylineId, Polyline> polylines = {};
  late StreamSubscription<LocationData> locationSubscription;
  static String googleApi = GOOGLES_MAPS_API_KEY; // Ensure to replace with your actual API key

  @override
  void initState() {
    super.initState();
    _setupMap();
    _setupLocation();
  }

  @override
  void dispose() {
    locationSubscription.cancel();
    super.dispose();
  }

  void _setupMap() {
    // Add a marker for the initial position (if required)
    _updateMarkers();
  }

  Future<void> _setupLocation() async {
    if (!await _locationController.serviceEnabled()) {
      await _locationController.requestService();
    }

    PermissionStatus permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    locationSubscription = _locationController.onLocationChanged.listen((LocationData currentLocation) {
      if (mounted && currentLocation.latitude != null && currentLocation.longitude != null) {
        LatLng newPosition = LatLng(currentLocation.latitude!, currentLocation.longitude!);
        setState(() {
          _currentLocation = newPosition;
        });
        _moveCameraToPosition(newPosition);
        _updateMarkers(); // Update markers including the current location
      }
    });
  }

  void _updateMarkers() {
    setState(() {
      _markers.clear();
      if (_currentLocation != null) {
        _markers.add(Marker(
          markerId: MarkerId('current_location'),
          position: _currentLocation!,
        ));
      }
      if (_selectedLocation != null) {
        _markers.add(Marker(
          markerId: MarkerId('selected_location'),
          position: _selectedLocation!,
          draggable: true,
          onDragEnd: (newPosition) {
            setState(() {
              _selectedLocation = newPosition;
              _drawPolyline(); // Redraw polyline after dragging
            });
          },
        ));
      }
    });
  }

  Future<void> _moveCameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition newCameraPosition = CameraPosition(target: pos, zoom: 13); // Zoom in to current location
    controller.animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
  }

  bool _isLocationInZone(LatLng location) {
    return location.latitude <= widget.northEast.latitude &&
        location.latitude >= widget.southWest.latitude &&
        location.longitude <= widget.northEast.longitude &&
        location.longitude >= widget.southWest.longitude;
  }

  void _drawPolyline() {
    if (_currentLocation != null && _selectedLocation != null) {
      getPolylinePoints(_currentLocation!, _selectedLocation!).then((coordinates) {
        generatePolyLineFromPoints(coordinates);
      });
    }
  }

  Future<List<LatLng>> getPolylinePoints(LatLng origin, LatLng destination) async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();

    List<PolylineResult> results = (await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: googleApi,
      request: PolylineRequest(
        origin: PointLatLng(origin.latitude, origin.longitude),
        destination: PointLatLng(destination.latitude, destination.longitude),
        mode: TravelMode.driving, // Change to your preferred travel mode
      ),
    )) as List<PolylineResult>;

    if (results.isNotEmpty) {
      for (var result in results) {
        if (result.points.isNotEmpty) {
          result.points.forEach((PointLatLng point) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          });
        }
      }
    } else {
      print("Failed to get polyline points");
    }

    return polylineCoordinates;
  }

  void generatePolyLineFromPoints(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("polyline");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: polylineCoordinates,
      width: 5,
    );
    if (mounted) {
      setState(() {
        polylines[id] = polyline;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              if (_selectedLocation != null) {
                widget.onLocationSelected(_selectedLocation!);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _mapController.complete(controller);
        },
        initialCameraPosition: CameraPosition(target: _currentLocation!, zoom: 12),
        markers: _markers,
        polylines: Set<Polyline>.of(polylines.values),
        onTap: (LatLng tappedPoint) {
          if (_isLocationInZone(tappedPoint)) {
            setState(() {
              _selectedLocation = tappedPoint;
              _updateMarkers();
              _drawPolyline(); // Draw polyline after selecting a new location
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please select a location within the allowed zone.')),
            );
          }
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
