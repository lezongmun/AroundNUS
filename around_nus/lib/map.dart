import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

import './drawer.dart';
import './circularbutton.dart';
import './searchbox.dart';

class MyMainPage extends StatefulWidget {
  MyMainPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyMainPageState createState() => _MyMainPageState();
}

class _MyMainPageState extends State<MyMainPage> {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  late GoogleMapController newGoogleMapController;
  late Position currentPosition;
  late LatLng currCoordinates =
      LatLng(currentPosition.latitude, currentPosition.longitude);
  var geoLocator = Geolocator();

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    // if latlng position out of range of NUS, set latlng position to _defaultCameraPos
    LatLng latlngPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        new CameraPosition(target: latlngPosition, zoom: 14.4746);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  static final CameraPosition _defaultCameraPos = CameraPosition(
    target: LatLng(1.2966, 103.7764),
    zoom: 14.4746,
  );

  Set<Marker> _markers = <Marker>{};

  bool _isMarker = false;

  // set marker for one other location
  void _setMarkers(LatLng point) {
    _isMarker = true;
    setState(() {
      // Pass to search info widget
      // add markers subsequently on taps
      _markers.add(
        Marker(
          markerId: MarkerId('Location'),
          position: point,
        ),
      );
    });
  }

  // function to call when user presses userLocation button
  void _userLocationButton() {
    _setMarkers(currCoordinates);
    locatePosition();
  }

  @override
  void initState() {
    super.initState();
    _setMarkers(LatLng(1.2966, 103.7764));
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      drawer: MenuDrawer(),
      drawerEnableOpenDragGesture: true,
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            // disable location button; make own button
            myLocationButtonEnabled: false,
            initialCameraPosition: _defaultCameraPos,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;
              // after position located, then setMarker
              locatePosition();
              _setMarkers(currCoordinates);
            },
            // enable location layer
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            // markers
            markers: _markers,
            onTap: (point) {
              if (_isMarker) {
                setState(() {
                  _markers.clear();
                  _setMarkers(point);
                });
              }
            },
            // camera target bounds ? to limit to NUS
          ),
          Positioned(
            top: 0.0,
            child: SearchBox(),
          ),
          Align(
            // User Location Button
            alignment: Alignment.bottomCenter,
            child: InkWell(
              onTap: _userLocationButton,
              child: CircularButton(),
            ),
          )
        ],
      ),
    );
  }
}
