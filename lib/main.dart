import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller = Completer();
  final _searchController = TextEditingController();

  final CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(35.68944, 139.69167),
    zoom: 14.4746,
  );

  final Marker _kTokyoMarker = Marker(
      markerId: const MarkerId("_kTokyo"),
      infoWindow: const InfoWindow(title: "東京都"),
      icon: BitmapDescriptor.defaultMarker,
      position: const LatLng(35.68944, 139.69167),
      onTap: () {});

  final CameraPosition _kKanagawa = const CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(35.44778, 139.6425),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  final Marker _kKanagawaMarker = const Marker(
    markerId: MarkerId("kanagawa"),
    infoWindow: InfoWindow(title: "世田谷"),
    icon: BitmapDescriptor.defaultMarker,
    position: LatLng(35.646544, 139.6532351),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Google Maps"),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        markers: {
          Marker(
              markerId: MarkerId("_kTokyo"),
              infoWindow: InfoWindow(title: "東京都"),
              icon: BitmapDescriptor.defaultMarker,
              position: LatLng(35.68944, 139.69167),
              onTap: () {
                setState(() {
                  _settingModalBottomSheet(context);
                });
              }),
          _kKanagawaMarker
        },
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),

      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _goToTheLake,
      //   label: Text('To the lake!'),
      //   icon: Icon(Icons.directions_boat),
      // ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kKanagawa));
  }

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.black,
        elevation: 30,
        constraints: const BoxConstraints(
            minHeight: double.infinity, minWidth: double.infinity),
        builder: (BuildContext bc) {
          return Column(
            children: [
              buildHeader(context),
              const Expanded(
                  flex: 3,
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          "東京....",
                          style: TextStyle(color: Colors.white, fontSize: 50),
                        ),
                      )
                    ],
                  )),
            ],
          );
        });
  }

  Widget buildHeader(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 16,
            ),
            Center(
              child: Container(
                width: 70,
                height: 8,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }
}
