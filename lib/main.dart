import 'package:flutter/material.dart';
import 'package:google_maps_sample/pages/location_tracking_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Google Maps Demo',
      home: LocationTracking(),
    );
  }
}