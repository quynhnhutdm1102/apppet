import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController mapController = MapController();

  LatLng currentLocation = const LatLng(10.8231, 106.6297);

  bool isLoading = true;

  List<Marker> markers = [];

  // =========================
  // DỮ LIỆU THÚ Y THẬT
  // =========================
  final List<Map<String, dynamic>> vetPlaces = [
    {
      "name": "Thuốc thú y Hiền",
      "address": "49/9A Bùi Công Trừng, Đông Thạnh, Hóc Môn",
      "lat": 10.912637,
      "lon": 106.679388,
    },

    {
      "name": "Phòng Khám Thú Y Bảo Bối",
      "address": "807 Hà Huy Giáp, Thạnh Xuân, Quận 12",
      "lat": 10.889817,
      "lon": 106.685396,
    },

    {
      "name": "Phòng khám thú cưng bs Quý",
      "address": "Số 7 TL54, An Phú Đông, Quận 12",
      "lat": 10.898188,
      "lon": 106.690095,
    },

    {
      "name": "Phòng khám thú y Thu Hằng",
      "address": "118 Châu Văn Tiếp, Lái Thiêu, Bình Dương",
      "lat": 10.903481,
      "lon": 106.698044,
    },

    {
      "name": "Phòng Khám Thú Y Tín Thơ 1",
      "address": "2 Hoàng Hoa Thám, Lái Thiêu, Bình Dương",
      "lat": 10.904010,
      "lon": 106.699675,
    },
  ];

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  // =========================
  // LẤY GPS
  // =========================
  Future<void> getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Hãy bật GPS")));

        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      currentLocation = LatLng(position.latitude, position.longitude);

      createMarkers();

      setState(() {
        isLoading = false;
      });

      // Zoom tới vị trí hiện tại
      mapController.move(currentLocation, 15);
    } catch (e) {
      print("Lỗi GPS: $e");
    }
  }

  // =========================
  // TẠO MARKER
  // =========================
  void createMarkers() {
    markers.clear();

    // Marker vị trí hiện tại
    markers.add(
      Marker(
        point: currentLocation,
        width: 80,
        height: 80,
        child: GestureDetector(
          onTap: () {
            // Zoom tới vị trí hiện tại
            mapController.move(currentLocation, 17);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Đây là vị trí của bạn")),
            );
          },
          child: const Icon(Icons.my_location, color: Colors.blue, size: 40),
        ),
      ),
    );

    // Marker thú y
    for (var place in vetPlaces) {
      final lat = place["lat"];
      final lon = place["lon"];

      markers.add(
        Marker(
          point: LatLng(lat, lon),
          width: 80,
          height: 80,
          child: GestureDetector(
            onTap: () {
              showPlaceDetail(place);
            },
            child: const Icon(Icons.pets, color: Colors.red, size: 40),
          ),
        ),
      );
    }
  }

  // =========================
  // HIỆN CHI TIẾT
  // =========================
  void showPlaceDetail(Map<String, dynamic> place) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 260,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place["name"],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(place["address"]),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final url =
                        "https://www.google.com/maps/dir/?api=1&destination=${place["lat"]},${place["lon"]}";

                    await launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    );
                  },

                  icon: const Icon(Icons.directions),

                  label: const Text("Chỉ đường"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pet Map"), centerTitle: true),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: mapController,

                  options: MapOptions(
                    initialCenter: currentLocation,
                    initialZoom: 15,
                  ),

                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                      userAgentPackageName: 'com.example.app_quanlythucung',
                    ),

                    MarkerLayer(markers: markers),
                  ],
                ),

                // NÚT ZOOM
                Positioned(
                  right: 10,
                  top: 20,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        mini: true,
                        heroTag: "zoomIn",
                        onPressed: () {
                          final currentZoom = mapController.camera.zoom;

                          mapController.move(
                            mapController.camera.center,
                            currentZoom + 1,
                          );
                        },
                        child: const Icon(Icons.add),
                      ),

                      const SizedBox(height: 10),

                      FloatingActionButton(
                        mini: true,
                        heroTag: "zoomOut",
                        onPressed: () {
                          final currentZoom = mapController.camera.zoom;

                          mapController.move(
                            mapController.camera.center,
                            currentZoom - 1,
                          );
                        },
                        child: const Icon(Icons.remove),
                      ),
                    ],
                  ),
                ),
              ],
            ),

      // NÚT GPS
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() {
            isLoading = true;
          });

          await getLocation();
        },

        child: const Icon(Icons.my_location),
      ),
    );
  }
}
