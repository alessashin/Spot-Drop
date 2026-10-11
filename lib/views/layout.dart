import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class ResponsiveMainLayout extends StatefulWidget {
  const ResponsiveMainLayout({super.key});

  @override
  State<ResponsiveMainLayout> createState() => _ResponsiveMainLayoutState();
}

class _ResponsiveMainLayoutState extends State<ResponsiveMainLayout> {
  int _selectedIndex = 0;
  String _selectedCategory = 'All';
  double _searchRadiusKm = 1.5;

  // Map & Distance Controllers
  final MapController _mapController = MapController();
  final Distance _distance = const Distance();

  // 1. Change _userLocation from final to non-final with a default fallback
  LatLng _userLocation = const LatLng(7.1907, 125.4553);
  bool _isLoadingLocation = true;
  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  // 2. ADD _fetchCurrentLocation HELPER METHOD HERE
  Future<void> _fetchCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _isLoadingLocation = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _isLoadingLocation = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) setState(() => _isLoadingLocation = false);
      return;
    }

    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (mounted) {
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });

      // FIX: Wait for the frame to build before moving the MapController
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _mapController.move(_userLocation, 14.0);
        }
      });
    }
  }

  // Category Names
  final List<String> _categories = [
    'All',
    'Tools',
    'Camping',
    'Garden',
    'Kitchen',
    'Party',
  ];

  // Defined Color Palettes per Category
  final Map<String, Map<String, Color>> _themeColors = {
    'Tools': {'primary': Colors.teal.shade700, 'bg': Colors.teal.shade50},
    'Camping': {'primary': Colors.orange.shade800, 'bg': Colors.orange.shade50},
    'Garden': {'primary': Colors.green.shade700, 'bg': Colors.green.shade50},
    'Kitchen': {'primary': Colors.blue.shade800, 'bg': Colors.blue.shade50},
    'Party': {'primary': Colors.pink.shade700, 'bg': Colors.pink.shade100},
    'Storage': {'primary': Colors.purple.shade700, 'bg': Colors.purple.shade100},
    'Default': {'primary': Colors.grey.shade700, 'bg': Colors.grey.shade100},
  };

  // mga potang inang data
  final List<Map<String, dynamic>> _items = [
    {
      'title': 'Bosch Cordless Power Drill',
      'category': 'Tools',
      'owner': 'Alex M. ',
      'type': 'Borrow',
      'status': 'Available Today',
      'icon': Icons.build_rounded,
      'latLng': const LatLng(7.1940, 125.4580),
    },
    {
      'title': '4-Person Camping Tent',
      'category': 'Camping',
      'owner': 'Sarah K.',
      'type': 'Borrow',
      'status': 'Available Weekend',
      'icon': Icons.cabin_rounded,
      'latLng': const LatLng(7.1880, 125.4520), // ~0.5 km away
    },
    {
      'title': 'Electric Lawn Mower',
      'category': 'Garden',
      'owner': 'David L.',
      'type': 'Borrow',
      'status': 'Available Today',
      'icon': Icons.grass_rounded,
      'latLng': const LatLng(7.1860, 125.4590), // ~0.7 km away
    },
    {
      'title': 'High-Yield Blender (Ninja)',
      'category': 'Kitchen',
      'owner': 'Maya B.',
      'type': 'Borrow',
      'status': 'Borrowable',
      'icon': Icons.soup_kitchen_rounded,
      'latLng': const LatLng(7.1915, 125.4560), // ~0.1 km away
    },
    {
      'title': 'Moving Cardboard Boxes (x10)',
      'category': 'Storage',
      'owner': 'Elena R.',
      'type': 'Giveaway',
      'status': 'Free Pick Up',
      'icon': Icons.inventory_2_rounded,
      'latLng': const LatLng(7.1895, 125.4545), // ~0.2 km away
    },
    {
      'title': 'Portable JBL Party Speaker',
      'category': 'Party',
      'owner': 'Chris T. ',
      'type': 'Borrow',
      'status': 'Active Booking',
      'icon': Icons.speaker_rounded,
      'latLng': const LatLng(7.2100, 125.4700), // ~2.8 km away
    },
  ];

  // dri mo request
  final List<Map<String, dynamic>> _loanRequests = [
    {
      'title': 'Bosch Cordless Power Drill',
      'owner': 'Alex M.',
      'dates': 'Oct 4 - Oct 6, 2026',
      'status': 'ACTIVE',
      'statusColor': Colors.orange,
      'icon': Icons.build_rounded,
      'dueText': 'Return due in 2 days',
    },
    {
      'title': '4-Person Camping Tent',
      'owner': 'Sarah K.',
      'dates': 'Oct 10 - Oct 12, 2026',
      'status': 'PENDING',
      'statusColor': Colors.blue,
      'icon': Icons.cabin_rounded,
      'dueText': 'Waiting for owner approval',
    },
    {
      'title': 'High-Yield Blender (Ninja)',
      'owner': 'Maya B.',
      'dates': 'Sep 25 - Sep 27, 2026',
      'status': 'RETURNED',
      'statusColor': Colors.green,
      'icon': Icons.soup_kitchen_rounded,
      'dueText': 'Completed safely',
    },
  ];

  void _showExpandedMapDialog(BuildContext context, List<Map<String, dynamic>> items) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog.fullscreen(
          child: Scaffold(
            appBar: AppBar(
              title: Text('Neighborhood Search (${_searchRadiusKm.toStringAsFixed(1)} km)'),
              backgroundColor: Colors.teal.shade700,
              foregroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: FlutterMap(
              options: MapOptions(
                initialCenter: _userLocation,
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.spot_drop',
                  maxZoom: 19,
                ),
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _userLocation,
                      radius: _searchRadiusKm * 1000,
                      useRadiusInMeter: true,
                      color: Colors.teal.withOpacity(0.15),
                      borderColor: Colors.teal.shade700,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userLocation,
                      width: 90,
                      height: 55,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.my_location_rounded, color: Colors.blueAccent, size: 30),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: const BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.all(Radius.circular(6)),
                            ),
                            child: const Text('You are here', style: TextStyle(color: Colors.white, fontSize: 10)),
                          ),
                        ],
                      ),
                    ),
                    ...items.map((item) {
                      final catTheme = _themeColors[item['category']] ?? _themeColors['Default']!;
                      return Marker(
                        point: item['latLng'] as LatLng,
                        width: 95,
                        height: 60,
                        child: _buildMapPin(
                          item['title'] as String,
                          catTheme['primary']!,
                          item['icon'] as IconData,
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF4EF),
      body: Stack(
        children: [
          // background first
          _buildColorfulBackgroundDecoration(),

          IndexedStack(
            index: _selectedIndex,
            children: [
              _buildBrowseTab(),
              _buildGeoSearchTab(),
              _buildRequestsTab(),
            ],
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: Colors.teal.shade800,
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Share Item',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 15,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: NavigationBar(
          backgroundColor: Colors.white,
          indicatorColor: Colors.teal.shade100,
          selectedIndex: _selectedIndex,
          onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront, color: Colors.teal),
              label: 'Browse',
            ),
            NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map, color: Colors.teal),
              label: 'Geo Search',
            ),
            NavigationDestination(
              icon: Icon(Icons.swap_horiz_outlined),
              selectedIcon: Icon(Icons.swap_horiz, color: Colors.teal),
              label: 'Requests',
            ),
          ],
        ),
      ),
    );
  }

  // lingin2 sa likod
  Widget _buildColorfulBackgroundDecoration() {
    return Stack(
      children: [
        Positioned(
          top: -50,
          left: -50,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(color: Colors.pink.shade100, shape: BoxShape.circle),
          ),
        ),
        Positioned(
          bottom: 100,
          right: -80,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(color: Colors.orange.shade100, shape: BoxShape.circle),
          ),
        ),
        Positioned(
          top: 300,
          left: 40,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: Colors.teal.shade100, shape: BoxShape.circle),
          ),
        ),
      ],
    );
  }


  Widget _buildGradientHeader(String title, String subtitle) {
    return Container(
      height: 140,
      width: double.infinity,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 50),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.teal.shade800,
            Colors.green.shade700,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  shadows: [Shadow(color: Colors.black.withAlpha(50), blurRadius: 4)],
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.teal.shade100),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 26),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // tab 1
  Widget _buildBrowseTab() {
    final filteredItems = _selectedCategory == 'All'
        ? _items
        : _items.where((item) => item['category'] == _selectedCategory).toList();

    return Column(
      children: [
        _buildGradientHeader('SpotDrop', 'Maplewood Community • 0.5 km radius'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.shade300, width: 1.5),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8, offset: const Offset(0, 3))
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search tools, camping gear, boxes...',
                      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: Colors.orange),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // chipsss
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = category == _selectedCategory;
                      final catTheme = _themeColors[category] ?? _themeColors['Default']!;

                      return ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        selectedColor: catTheme['primary'],
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.normal,
                          fontSize: 13,
                        ),
                        side: isSelected ? BorderSide.none : BorderSide(color: catTheme['primary']!.withAlpha(100)),
                        onSelected: (_) {
                          setState(() => _selectedCategory = category);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 22),

                const Text(
                  'Community Goods Nearby',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 14),

                // listahan
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    final catTheme = _themeColors[item['category']] ?? _themeColors['Default']!;

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(color: catTheme['primary']!.withAlpha(80)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Row(
                          children: [
                            Container(
                              width: 65,
                              height: 65,
                              decoration: BoxDecoration(
                                color: catTheme['bg'],
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: catTheme['primary']!.withAlpha(120)),
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                color: catTheme['primary'],
                                size: 34,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: item['type'] == 'Giveaway'
                                              ? Colors.purple.shade700
                                              : catTheme['primary'],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          (item['type'] as String).toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        item['status'] as String,
                                        style: TextStyle(fontSize: 11, color: catTheme['primary']),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item['title'] as String,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Icon(Icons.person_outline, size: 13, color: Colors.grey.shade600),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          item['owner'] as String,
                                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // map but kailangan e api, same sa gibuhat ni sir, so ilisan ni siya
  Widget _buildGeoSearchTab() {
    final filteredItems = _items.where((item) {
      final double distKm = _distance.as(
        LengthUnit.Kilometer,
        _userLocation,
        item['latLng'] as LatLng,
      );
      return distKm <= _searchRadiusKm;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGradientHeader('Geo Radius Search', 'Explore interactive neighborhood map'),
          const SizedBox(height: 16),

          // 1. Search Radius Slider Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.teal.shade200),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.radar_rounded, color: Colors.teal.shade800),
                        const SizedBox(width: 8),
                        const Text('Search Radius:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text(
                      '${_searchRadiusKm.toStringAsFixed(1)} km',
                      style: TextStyle(fontWeight: FontWeight.w900, color: Colors.teal.shade800),
                    ),
                  ],
                ),
                Slider(
                  value: _searchRadiusKm,
                  min: 0.5,
                  max: 5.0,
                  divisions: 9,
                  activeColor: Colors.teal.shade700,
                  inactiveColor: Colors.teal.shade100,
                  onChanged: (val) => setState(() => _searchRadiusKm = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Interactive Map Container (250 height prevents overflow)
          Container(
            height: 250,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.teal.shade300, width: 2),
            ),
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _userLocation,
                    initialZoom: 14.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.spot_drop',
                      maxZoom: 19,
                    ),
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: _userLocation,
                          radius: _searchRadiusKm * 1000,
                          useRadiusInMeter: true,
                          color: Colors.teal.withOpacity(0.15),
                          borderColor: Colors.teal.shade700,
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _userLocation,
                          width: 90,
                          height: 55,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.my_location_rounded, color: Colors.blueAccent, size: 28),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: const BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.all(Radius.circular(6)),
                                ),
                                child: const Text('You are here', style: TextStyle(color: Colors.white, fontSize: 9)),
                              ),
                            ],
                          ),
                        ),
                        ...filteredItems.map((item) {
                          final catTheme = _themeColors[item['category']] ?? _themeColors['Default']!;
                          return Marker(
                            point: item['latLng'] as LatLng,
                            width: 95,
                            height: 60,
                            child: GestureDetector(
                              onTap: () {
                                _mapController.move(item['latLng'] as LatLng, 16.0);
                              },
                              child: _buildMapPin(
                                item['title'] as String,
                                catTheme['primary']!,
                                item['icon'] as IconData,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: FloatingActionButton.small(
                    heroTag: 'expand_map_btn',
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.teal.shade800,
                    child: const Icon(Icons.fullscreen_rounded, size: 24),
                    onPressed: () => _showExpandedMapDialog(context, filteredItems),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. Bottom Cards Section
          Text(
            'Items Pinpointed Nearby',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: filteredItems.isEmpty
                ? Center(
              child: Text(
                'No items found within ${_searchRadiusKm.toStringAsFixed(1)} km',
                style: const TextStyle(color: Colors.grey),
              ),
            )
                : ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filteredItems.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, idx) {
                final item = filteredItems[idx];
                final catTheme = _themeColors[item['category']] ?? _themeColors['Default']!;
                final double dist = _distance.as(
                  LengthUnit.Kilometer,
                  _userLocation,
                  item['latLng'] as LatLng,
                );

                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    _mapController.move(item['latLng'] as LatLng, 16.0);
                  },
                  child: Container(
                    width: 230,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: catTheme['primary']!.withAlpha(80)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: catTheme['bg'], borderRadius: BorderRadius.circular(10)),
                          child: Icon(item['icon'] as IconData, color: catTheme['primary'], size: 28),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(item['title'] as String, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text('${item['owner']} (${dist.toStringAsFixed(1)} km away)', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 4. Map Pin Helper Method (KEPT)
  Widget _buildMapPin(String label, Color color, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black26)]),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: color)),
          child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
        ),
      ],
    );
  }

  // dre mag request, pede rani ilisan kay g kapoi ko
  Widget _buildRequestsTab() {
    return Column(
      children: [
        _buildGradientHeader('Requests Manager', 'Digital borrowing & lending log'),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _loanRequests.length,
            itemBuilder: (context, index) {
              final req = _loanRequests[index];
              final Color statusColor = req['statusColor'] as Color;

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(color: statusColor.withAlpha(120), width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: statusColor.withAlpha(30),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(req['icon'] as IconData, color: statusColor, size: 30),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        req['title'] as String,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        req['status'] as String,
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text('Owner: ${req['owner']}', style: const TextStyle(fontSize: 12, color: Colors.black87)),
                                const SizedBox(height: 2),
                                Text(req['dates'] as String, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.timer_outlined, size: 14, color: statusColor),
                              const SizedBox(width: 4),
                              Text(req['dueText'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor)),
                            ],
                          ),
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: statusColor,
                              side: BorderSide(color: statusColor),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            ),
                            child: const Text('View Logs', style: TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Custom Painter for Map Grid Background
class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.teal.withAlpha(25)
      ..strokeWidth = 1.5;

    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 30) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}