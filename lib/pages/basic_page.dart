import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BasicMapPage extends StatefulWidget {
  const BasicMapPage({super.key});

  @override
  State<BasicMapPage> createState() => _BasicMapPageState();
}

class _BasicMapPageState extends State<BasicMapPage> {
  final Completer<GoogleMapController> _controller = Completer();

  final CameraPosition cpSinjyuku = const CameraPosition(
    target: LatLng(35.68944, 139.69167),
    zoom: 14.4746,
  );

  final CameraPosition cpOkubo = const CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(35.700977060076, 139.7002506574),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    final Marker SinjyukuMarker = Marker(
        markerId: const MarkerId("_sinjyuku"),
        infoWindow: const InfoWindow(title: "東京 新宿"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        position: const LatLng(35.68944, 139.69167),
        onTap: () {
          setState(() {
            _showSnackBar(context, 'マーカーがタップされました');
          });
        });

    final Marker IkebukuroMarker = Marker(
        markerId: const MarkerId("_ikebukuro"),
        infoWindow: const InfoWindow(title: "東京 池袋"),
        icon: BitmapDescriptor.defaultMarker,
        position: const LatLng(35.7277503, 139.7108977),
        onTap: () {
          setState(() {
            _showSnackBar(context, 'マーカーがタップされました');
          });
        });

    final Polyline sinjyukuToIkebukuro = Polyline(
        polylineId: const PolylineId("_sinjyuku_to_ikebukuro"),
        color: Colors.red,
        points: [SinjyukuMarker.position, IkebukuroMarker.position],
        width: 2,
        consumeTapEvents: true,
        onTap: () {
          setState(() {
            _showSnackBar(context, 'ポリラインがタップされました');
          });
        });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Maps"),
        actions: [
          IconButton(
              onPressed: () {
                _goToThePosition(cpSinjyuku);
              },
              icon: const Icon(Icons.location_searching_sharp))
        ],
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        markers: {SinjyukuMarker, IkebukuroMarker},
        polylines: {sinjyukuToIkebukuro},
        initialCameraPosition: cpSinjyuku,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _goToThePosition(cpOkubo);
        },
        label: const Text('新大久保へ'),
        icon: const Icon(Icons.location_on_outlined),
      ),
    );
  }

  Future _goToThePosition(CameraPosition cameraPosition) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  void _showSnackBar(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(title),
      ),
    );
  }
}
