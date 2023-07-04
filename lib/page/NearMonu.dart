import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:http/http.dart' as http;
import 'nearby_response.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NearMonu extends StatefulWidget {
  @override
  _NearMonuState createState() => _NearMonuState();
}

class _NearMonuState extends State<NearMonu> {
  double _latitudine = 41.123516;
  double _longitudine = 16.872554;

  NearbyResponse nearbyResponse = NearbyResponse();
  Completer<GoogleMapController> _mapController = Completer();

  void _onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      controller.showMarkerInfoWindow(MarkerId('currentLocation'));
    });
  }

  void _getCurrentLocation() async {
    try {
      LocationPermission permission = await geo.Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return;
      }

      geo.Position position = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _latitudine = position.latitude;
        _longitudine = position.longitude;
      });
      updateMapAndPlaces();
    } catch (e) {
      print(e);
    }
  }

  void _updateCameraPosition() async {
    final GoogleMapController controller = await _mapController.future;
    final CameraPosition newPosition = CameraPosition(
      target: LatLng(_latitudine, _longitudine),
      zoom: 17.0,
    );
    controller.animateCamera(CameraUpdate.newCameraPosition(newPosition));
  }

  Set<Marker> _createMarkers() {
    Set<Marker> markers = Set<Marker>();

    // Aggiungi il marker per la posizione attuale
    markers.add(
      Marker(
        markerId: MarkerId('currentLocation'),
        position: LatLng(_latitudine, _longitudine),
        icon: BitmapDescriptor.defaultMarkerWithHue(120),
        infoWindow: InfoWindow(
          title: 'Posizione attuale',
        ),
      ),
    );

    // Aggiungi i marcatori per i luoghi vicini
    if (nearbyResponse.results != null) {
      for (int i = 0; i < nearbyResponse.results!.length; i++) {
        Results result = nearbyResponse.results![i];
        markers.add(
          Marker(
            markerId: MarkerId(result.name!),
            position: LatLng(
              result.geometry!.location!.lat!,
              result.geometry!.location!.lng!,
            ),
            infoWindow: InfoWindow(
              title: result.name!,
            ),
          ),
        );
      }
    }

    return markers;
  }

  void getNearbyPlaces() async {
    var url = Uri.parse('https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${_latitudine.toString()},${_longitudine.toString()}&radius=200&type=tourist_attraction&key=AIzaSyBMKW_Sa0VGRwsSFQNV5uURtVz7dw_bOpU');
    var response = await http.get(url);
    setState(() {
      nearbyResponse = NearbyResponse.fromJson(jsonDecode(response.body));
      print(nearbyResponse);
    });
    
  }

  void updateMapAndPlaces() async {
    getNearbyPlaces();
    _updateCameraPosition();
  }

  StreamSubscription? _getPositionSubscription;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _getPositionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: LatLng(_latitudine, _longitudine),
                zoom: 17.0,
              ),
              onMapCreated: _onMapCreated,
              markers: _createMarkers(),
            ),
          ),
          ElevatedButton(
            child: Text('Aggiorna Posizione'),
            onPressed: () {
              _getCurrentLocation();
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (nearbyResponse.results != null)
                    for (int i = 0; i < nearbyResponse.results!.length; i++)
                      nearbyPlacesWidget(nearbyResponse.results![i])
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget nearbyPlacesWidget(Results results) {
    return Container(
      width: MediaQuery.of(this.context).size.width,
      margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Text("Name: " + results.name!),
        Text("Location: " +
            results.geometry!.location!.lat.toString() +
            ", " +
            results.geometry!.location!.lng.toString()),
        Text(results.openingHours != null ? "Open" : "Closed"),
      ]),
    );
  }
}
