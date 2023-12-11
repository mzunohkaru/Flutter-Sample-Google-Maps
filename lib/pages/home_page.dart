import 'package:flutter/material.dart';
import 'package:google_maps_sample/pages/basic_page.dart';
import 'package:google_maps_sample/pages/location_tracking_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const BasicMapPage();
                    },
                  ),
                );
              },
              icon: const Icon(Icons.map_outlined),
              label: const Text('Basic Map Page'),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const LocationTracking();
                    },
                  ),
                );
              },
              icon: const Icon(Icons.location_pin),
              label: const Text('Location Tracking Page'),
            ),
          ],
        ),
      ),
    );
  }
}
