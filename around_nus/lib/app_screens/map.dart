import 'package:around_nus/blocs/application_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../common_widgets/drawer.dart';
import '../map_widgets/circularbutton.dart';
import '../map_widgets/searchbox.dart';
import '../map_widgets/turnonlocation.dart';

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

    //if latlng position out of range of NUS, set latlng position to _defaultCameraPos
    LatLng latlngPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        new CameraPosition(target: latlngPosition, zoom: 14.4746);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

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
    locatePosition();
    _setMarkers(currCoordinates);
  }

  @override
  void initState() {
    super.initState();
    // get User Search; same as searchdirections
    _setMarkers(LatLng(1.2966, 103.7764));
    locatePosition();
  }

  @override
  Widget build(BuildContext context) {
    final applicationBloc = Provider.of<ApplicationBloc>(context);
    CameraPosition _initialCameraPosition;
    if (applicationBloc.currentLocation == null) {
      _initialCameraPosition =
          CameraPosition(target: LatLng(1.2966, 103.7764), zoom: 14);
    } else {
      _initialCameraPosition = CameraPosition(
          target: LatLng(applicationBloc.currentLocation!.latitude,
              applicationBloc.currentLocation!.longitude),
          zoom: 14);
    }

    // This method is rerun every time setState is called
    return Scaffold(
      appBar: AppBar(
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
            //initialCameraPosition: _defaultCameraPos,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;
              // after position located, then setMarker
              //locatePosition();
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
            left: 0.5,
            right: 0.5,
            // child: SearchBox(),
            child: TextField(
              decoration: InputDecoration(
                  hintText: "Search Location", suffixIcon: Icon(Icons.search)),
              onChanged: (value) => applicationBloc.searchPlaces(value),
            ),
          ),
          Align(
            // User Location Button
            alignment: Alignment.bottomCenter,
            child: InkWell(
              //onTap: _userLocationButton,
              onTap: _userLocationButton,
              child: CircularButton(),
            ),
          ),
          if (applicationBloc.searchResults != null &&
              applicationBloc.searchResults!.length != 0)
            Container(
                height: 415.0,
                width: double.infinity,
                decoration: BoxDecoration(
                    backgroundBlendMode: BlendMode.darken,
                    color: Colors.black.withOpacity(0.6))),
          if (applicationBloc.searchResults != null &&
              applicationBloc.searchResults!.length != 0)
            Container(
                height: 415.0,
                child: ListView.builder(
                    itemCount: applicationBloc.searchResults!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          applicationBloc.searchResults![index].description,
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }))
        ],
      ),
    );
  }
}
