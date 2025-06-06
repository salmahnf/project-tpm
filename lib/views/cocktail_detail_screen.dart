import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../models/cocktail_model.dart';
import '../services/session_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart'; // Tambahkan import untuk geocoding
import '../services/notification_service.dart';

class CocktailDetailScreen extends StatefulWidget {
  final CocktailModel cocktail;

  const CocktailDetailScreen({Key? key, required this.cocktail})
      : super(key: key);

  @override
  _CocktailDetailScreenState createState() => _CocktailDetailScreenState();
}

class _CocktailDetailScreenState extends State<CocktailDetailScreen> {
  final _storage = GetStorage();
  bool _isFavorite = false;
  Position? _currentPosition;
  final List<Marker> _markers = [];
  final MapController _mapController =
      MapController(); // Tambahkan controller untuk peta
  final TextEditingController _addressController =
      TextEditingController(); // Controller untuk input alamat

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
    _getCurrentLocation();
  }

  void _loadFavoriteStatus() {
    final favorites = _storage.read<List>('favorites') ?? [];
    setState(() {
      _isFavorite = favorites.contains(widget.cocktail.idDrink);
    });
  }

  // Fungsi untuk mendapatkan lokasi saat ini
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Layanan lokasi tidak diaktifkan. Mohon aktifkan.')),
      );
      // Set default location untuk Indonesia (Yogyakarta) jika service tidak aktif
      _setDefaultIndonesiaLocation();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin lokasi ditolak oleh pengguna.')),
        );
        _setDefaultIndonesiaLocation();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Izin lokasi ditolak selamanya. Anda perlu mengaktifkannya secara manual di pengaturan aplikasi.')),
      );
      _setDefaultIndonesiaLocation();
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10));

      // Cek apakah lokasi berada di Indonesia (koordinat kasar)
      if (_isLocationInIndonesia(position.latitude, position.longitude)) {
        setState(() {
          _currentPosition = position;
          _markers.clear();
          _markers.add(
            Marker(
              point: LatLng(position.latitude, position.longitude),
              width: 80,
              height: 80,
              child: const Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 40,
              ),
            ),
          );
        });
        print("Lokasi Saat Ini: ${position.latitude}, ${position.longitude}");
      } else {
        // Jika lokasi tidak di Indonesia (kemungkinan emulator), gunakan default Indonesia
        print("Lokasi tidak di Indonesia, menggunakan lokasi default");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Lokasi tidak terdeteksi di Indonesia, menggunakan lokasi default Yogyakarta')),
        );
        _setDefaultIndonesiaLocation();
      }
    } catch (e) {
      print("Error mendapatkan lokasi: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Gagal mendapatkan lokasi GPS, menggunakan lokasi default')),
      );
      _setDefaultIndonesiaLocation();
    }
  }

  // Fungsi untuk mengecek apakah lokasi berada di Indonesia
  bool _isLocationInIndonesia(double latitude, double longitude) {
    // Koordinat kasar batas Indonesia
    // Latitude: -11.0 sampai 6.0
    // Longitude: 95.0 sampai 141.0
    return latitude >= -11.0 &&
        latitude <= 6.0 &&
        longitude >= 95.0 &&
        longitude <= 141.0;
  }

  // Fungsi untuk set lokasi default Indonesia (Yogyakarta)
  void _setDefaultIndonesiaLocation() {
    // Koordinat Yogyakarta sebagai default
    double defaultLat = -7.7956;
    double defaultLng = 110.3695;

    setState(() {
      _currentPosition = Position(
        latitude: defaultLat,
        longitude: defaultLng,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
      _markers.clear();
      _markers.add(
        Marker(
          point: LatLng(defaultLat, defaultLng),
          width: 80,
          height: 80,
          child: const Icon(
            Icons.location_pin,
            color: Colors.orange, // Warna berbeda untuk default location
            size: 40,
          ),
        ),
      );
    });
    print("Menggunakan lokasi default Yogyakarta: $defaultLat, $defaultLng");
  }

  // Fungsi baru untuk geocoding alamat
  Future<void> _searchAndMoveToAddress(String address) async {
    if (address.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan alamat terlebih dahulu')),
      );
      return;
    }

    try {
      // Tampilkan loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Tambahkan "Indonesia" ke alamat untuk hasil yang lebih akurat
      String searchAddress = address;
      if (!address.toLowerCase().contains('indonesia') &&
          !address.toLowerCase().contains('id')) {
        searchAddress = "$address, Indonesia";
      }

      List<Location> locations = await locationFromAddress(searchAddress);

      // Tutup loading dialog
      Navigator.of(context).pop();

      if (locations.isNotEmpty) {
        // Filter hasil untuk memastikan lokasi di Indonesia
        Location? indonesiaLocation;
        for (Location loc in locations) {
          if (_isLocationInIndonesia(loc.latitude, loc.longitude)) {
            indonesiaLocation = loc;
            break;
          }
        }

        if (indonesiaLocation != null) {
          LatLng newCenter =
              LatLng(indonesiaLocation.latitude, indonesiaLocation.longitude);

          // Update marker
          setState(() {
            _markers.clear();
            _markers.add(
              Marker(
                point: newCenter,
                width: 80,
                height: 80,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.blue,
                  size: 40,
                ),
              ),
            );
          });

          // Pindahkan peta ke lokasi baru
          _mapController.move(newCenter, 15.0);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Berhasil menemukan alamat: $address')),
          );

          // Bersihkan input
          _addressController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Alamat tidak ditemukan di Indonesia')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alamat tidak ditemukan')),
        );
      }
    } catch (e) {
      // Tutup loading dialog jika masih terbuka
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      print("Error geocoding: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mencari alamat: ${e.toString()}')),
      );
    }
  }

  // Fungsi untuk kembali ke lokasi saat ini
  void _goToCurrentLocation() {
    if (_currentPosition != null) {
      LatLng currentLatLng =
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

      setState(() {
        _markers.clear();
        _markers.add(
          Marker(
            point: currentLatLng,
            width: 80,
            height: 80,
            child: const Icon(
              Icons.location_pin,
              color: Colors.red,
              size: 40,
            ),
          ),
        );
      });

      _mapController.move(currentLatLng, 15.0);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi saat ini belum tersedia')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ingredients = widget.cocktail.getIngredients();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.blue,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.black,
                  ),
                  onPressed: () async {
                    final user = await SessionService.getCurrentUser();

                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Silakan login untuk menyimpan favorit')),
                      );
                      return;
                    }

                    final key = 'favorites_${user.username}';
                    final box = GetStorage();
                    List<String> favorites =
                        box.read<List>(key)?.cast<String>() ?? [];

                    setState(() {
                      _isFavorite = !_isFavorite;
                    });

                    if (_isFavorite) {
  favorites.add(widget.cocktail.idDrink);
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Ditambahkan ke favorit')),
  );
  await showFavoriteNotification(widget.cocktail.strDrink);
  await scheduleReminderNotification(widget.cocktail.strDrink); // ✅ Tambahan ini
}
 else {
                      favorites.remove(widget.cocktail.idDrink);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dihapus dari favorit')),
                      );
                    }

                    box.write(key, favorites.toSet().toList());
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.cocktail.strDrinkThumb,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.local_bar,
                          size: 100,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cocktail Name
                  Text(
                    widget.cocktail.strDrink,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),

                  const SizedBox(height: 12),

                  // Tags Row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (widget.cocktail.strCategory != null) ...[
                        _buildTag(
                          widget.cocktail.strCategory!,
                          Colors.blue,
                          Icons.category,
                        ),
                      ],
                      if (widget.cocktail.strAlcoholic != null) ...[
                        _buildTag(
                          widget.cocktail.strAlcoholic!,
                          widget.cocktail.strAlcoholic == 'Alcoholic'
                              ? Colors.orange
                              : Colors.green,
                          widget.cocktail.strAlcoholic == 'Alcoholic'
                              ? Icons.local_bar
                              : Icons.no_drinks,
                        ),
                      ],
                      if (widget.cocktail.strGlass != null) ...[
                        _buildTag(
                          widget.cocktail.strGlass!,
                          Colors.purple,
                          Icons.wine_bar,
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Ingredients Section
                  if (ingredients.isNotEmpty) ...[
                    Text(
                      'Bahan-bahan',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: ingredients.asMap().entries.map((entry) {
                          int index = entry.key;
                          String ingredient = entry.value;

                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              border: index < ingredients.length - 1
                                  ? Border(
                                      bottom:
                                          BorderSide(color: Colors.grey[300]!))
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    ingredient,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Instructions Section
                  if (widget.cocktail.strInstructions != null &&
                      widget.cocktail.strInstructions!.trim().isNotEmpty) ...[
                    Text(
                      'Instruksi',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[100]!),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.receipt_long,
                                color: Colors.blue[700],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Cara Membuat',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.cocktail.strInstructions!,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // BAGIAN LOKASI DAN PETA (DIMODIFIKASI)
                  Text(
                    'Lokasi',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Tampilkan koordinat lokasi saat ini
                  if (_currentPosition != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.my_location, color: Colors.green[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Koordinat Lokasi Anda:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  'Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Input alamat dan tombol pencarian
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            hintText:
                                'Masukkan alamat (contoh: Jl. Malioboro, Yogyakarta)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.search),
                          ),
                          onSubmitted: (value) =>
                              _searchAndMoveToAddress(value),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () =>
                            _searchAndMoveToAddress(_addressController.text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(12),
                        ),
                        child: const Icon(Icons.search),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Tombol kembali ke lokasi saat ini
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _goToCurrentLocation,
                        icon: const Icon(Icons.my_location),
                        label: const Text('Lokasi Saya'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _currentPosition == null
                      ? const Center(child: CircularProgressIndicator())
                      : Container(
                          height:
                              300, // Tinggi diperbesar untuk visibilitas yang lebih baik
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: FlutterMap(
                              mapController:
                                  _mapController, // Tambahkan controller
                              options: MapOptions(
                                initialCenter: LatLng(
                                    _currentPosition!.latitude,
                                    _currentPosition!.longitude),
                                initialZoom: 15.0,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName:
                                      'com.salmaproject.cocktailapp',
                                ),
                                MarkerLayer(
                                  markers: _markers,
                                ),
                              ],
                            ),
                          ),
                        ),
                  const SizedBox(height: 24),

                  // Action Button
                  Container(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showShareDialog();
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Bagikan Resep'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color.withOpacity(0.8),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showShareDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bagikan Resep'),
          content:
              const Text('Bagikan resep koktail ini dengan teman-teman Anda!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Resep berhasil dibagikan!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Bagikan'),
            ),
          ],
        );
      },
    );
  }
}
