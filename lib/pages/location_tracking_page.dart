import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_sample/api/google_map_api.dart';
import 'package:location/location.dart';

class LocationTracking extends StatefulWidget {
  const LocationTracking({Key? key}) : super(key: key);

  @override
  _LocationTrackingState createState() => _LocationTrackingState();
}

class _LocationTrackingState extends State<LocationTracking> {
  MapType m = MapType.normal;
  // 出発地点の座標 (新宿)
  LatLng sourceLocation = const LatLng(35.68944, 139.69167);
  // 目的地の座標 (新大久保)
  LatLng destinationLatlng = const LatLng(35.700977060076, 139.7002506574);

  // Googleマップのコントローラーを非同期に管理します
  final Completer<GoogleMapController> _controller = Completer();

  // マップ上のマーカーを保持するSet
  final Set<Marker> _marker = Set<Marker>();

  // マップ上のポリライン（経路）を保持するSet
  Set<Polyline> _polylines = Set<Polyline>();
  // ポリラインの座標を保持するリスト
  List<LatLng> polylineCoordinates = [];
  // ポリラインの点を計算するためのオブジェクト
  late PolylinePoints polylinePoints;

  // 位置情報の変更を監視するためのストリーム
  late StreamSubscription<LocationData> subscription;

  // 現在地の位置情報
  LocationData? currentLocation;
  // 目的地の位置情報
  late LocationData destinationLocation;

  // 位置情報を取得するためのオブジェクト
  late Location location;

  @override
  void initState() {
    super.initState();

    location = Location();
    polylinePoints = PolylinePoints();

    // 位置情報の変更の監視を開始
    subscription = location.onLocationChanged.listen((clocation) {
      currentLocation = clocation;

      updatePinsOnMap();
    });

    // 初期の位置情報を設定
    setInitialLocation();
  }

  void setInitialLocation() async {
    // 現在位置の取得
    await location.getLocation().then((value) {
      currentLocation = value;
      setState(() {});
    });

    destinationLocation = LocationData.fromMap({
      "latitude": destinationLatlng.latitude,
      "longitude": destinationLatlng.longitude,
    });
  }

  // マップ上にマーカーを表示
  void showLocationPins() {
    var sourceposition = LatLng(
        currentLocation!.latitude ?? 0.0, currentLocation!.longitude ?? 0.0);

    var destinationPosition =
        LatLng(destinationLatlng.latitude, destinationLatlng.longitude);

    _marker.add(Marker(
        markerId: const MarkerId('sourcePosition'),
        infoWindow: const InfoWindow(title: "東京 新宿"),
        icon: BitmapDescriptor.defaultMarker,
        position: sourceposition,
        onTap: () {
          debugPrint('東京 新宿のマーカーをタップしました');
        }));

    _marker.add(
      Marker(
          markerId: const MarkerId('destinationPosition'),
          infoWindow: const InfoWindow(title: "東京 新大久保"),
          icon: BitmapDescriptor.defaultMarker,
          position: destinationPosition,
          onTap: () {
            debugPrint('東京 新大久保のマーカーをタップしました');
          }),
    );

    // setPolylinesInMap();
  }

  // 出発地点から目的地までの経路（ポリライン）をマップ上に表示
  void setPolylinesInMap() async {
    var result = await polylinePoints.getRouteBetweenCoordinates(
      GoogleMapApi().url,
      PointLatLng(
          currentLocation!.latitude ?? 0.0, currentLocation!.longitude ?? 0.0),
      PointLatLng(destinationLatlng.latitude, destinationLatlng.longitude),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((pointLatLng) {
        polylineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    setState(() {
      _polylines.add(Polyline(
        width: 5,
        polylineId: PolylineId('polyline'),
        color: Colors.blueAccent,
        points: polylineCoordinates,
      ));
    });
  }

  // 現在地のマーカーを更新
  void updatePinsOnMap() async {
    CameraPosition cameraPosition = CameraPosition(
      zoom: 14,
      // tilt: 80,
      // bearing: 30,
      target: LatLng(
          currentLocation!.latitude ?? 0.0, currentLocation!.longitude ?? 0.0),
    );

    final GoogleMapController controller = await _controller.future;

    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    var sourcePosition = LatLng(
        currentLocation!.latitude ?? 0.0, currentLocation!.longitude ?? 0.0);

    setState(() {
      _marker.removeWhere((marker) => marker.mapsId.value == 'sourcePosition');

      _marker.add(Marker(
        markerId: const MarkerId('sourcePosition'),
        position: sourcePosition,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition = CameraPosition(
      zoom: 14,
      // tilt: 80,
      // bearing: 30,
      target: currentLocation != null
          ? LatLng(currentLocation!.latitude ?? 0.0,
              currentLocation!.longitude ?? 0.0)
          : const LatLng(0.0, 0.0),
    );

    return SafeArea(
      child: Scaffold(
        body: currentLocation == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : GoogleMap(
                myLocationButtonEnabled: true,
                compassEnabled: true,
                markers: _marker,
                polylines: _polylines,
                mapType: m,
                initialCameraPosition: initialCameraPosition,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);

                  showLocationPins();
                },
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
        floatingActionButton: buildFloatingActionButton(),
      ),
    );
  }

  SpeedDial buildFloatingActionButton() {
    return SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        spacing: 3,
        mini: false,
        openCloseDial: ValueNotifier<bool>(false),
        childPadding: const EdgeInsets.all(5),
        spaceBetweenChildren: 4,
        buttonSize: const Size(56.0, 56.0),
        label: const Text("Open"),
        activeLabel: const Text("Close"),
        childrenButtonSize: const Size(56.0, 56.0),
        visible: true,
        direction: SpeedDialDirection.down,
        switchLabelPosition: false,
        closeManually: false,
        renderOverlay: true,
        useRotationAnimation: true,
        elevation: 8.0,
        animationCurve: Curves.elasticInOut,
        isOpenOnStart: false,
        shape: const StadiumBorder(),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.satellite_alt_outlined),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            label: '衛星',
            onTap: () {
              setState(() {
                m = MapType.satellite;
              });
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.map_outlined),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            label: 'ノーマル',
            onTap: () {
              setState(() {
                m = MapType.normal;
              });
            },
          ),
           SpeedDialChild(
            child: const Icon(Icons.terrain_outlined),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            label: '地形',
            onTap: () {
              setState(() {
                m = MapType.terrain;
              });
            },
          ),
           SpeedDialChild(
            child: const Icon(Icons.eco_sharp),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            label: 'ハイブリッド',
            onTap: () {
              setState(() {
                m = MapType.hybrid;
              });
            },
          ),
        ],
      );
  }

  @override
  void dispose() {
    // 位置情報の変更の監視を終了
    subscription.cancel();
    super.dispose();
  }
}
