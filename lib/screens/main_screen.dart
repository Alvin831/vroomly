import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocketbase/pocketbase.dart';
import 'add_vehicle_screen.dart';

class LayarUtama extends StatefulWidget {
  @override
  _LayarUtamaState createState() => _LayarUtamaState();
}

class _LayarUtamaState extends State<LayarUtama> {
  List<RecordModel> kendaraan = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Initialize PocketBase with your server URL
  final pb = PocketBase('http://127.0.0.1:8090');

  @override
  void initState() {
    super.initState();
    _fetchKendaraan();
  }

  Future<void> _fetchKendaraan() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Fetching vehicle data from PocketBase');
      final response = await pb.collection('kendaraan').getList(
            page: 1,
            perPage: 50, // Adjust as needed
          );
      print('Fetch response: ${response.items.length} items retrieved');

      setState(() {
        kendaraan = response.items;
        _isLoading = false;
      });
    } catch (e) {
      print('Fetch error: $e');
      String errorMessage = 'Gagal mengambil data kendaraan';
      if (e is ClientException) {
        errorMessage = e.response['message'] ?? 'Terjadi kesalahan server';
      } else {
        errorMessage = e.toString();
      }

      setState(() {
        _errorMessage = errorMessage;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ringkasan Kendaraan'),
        backgroundColor: Color(0xFF2F3032),
        foregroundColor: Color(0xFFEDE68A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _errorMessage!,
                                style: GoogleFonts.robotoMono(
                                  fontSize: 16.0,
                                  color: Color(0xFF383A56),
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 16.0),
                              ElevatedButton.icon(
                                onPressed: _fetchKendaraan,
                                icon: Icon(Icons.refresh),
                                label: Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        )
                      : kendaraan.isEmpty
                          ? Center(
                              child: Text(
                                'Belum ada kendaraan yang ditambahkan.',
                                style: GoogleFonts.robotoMono(
                                  fontSize: 16.0,
                                  color: Color(0xFF383A56),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: kendaraan.length,
                              itemBuilder: (context, index) {
                                final vehicle = kendaraan[index].data;
                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 8.0),
                                  color: Colors.white,
                                  elevation: 3,
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.directions_car,
                                      color: Color(0xFF383A56),
                                      size: 30.0,
                                    ),
                                    title: Text(
                                      vehicle['nama_kendaraan'] ?? '',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2F3032),
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Plat: ${vehicle['nomor_plat'] ?? ''}',
                                      style: GoogleFonts.robotoMono(
                                        fontSize: 14.0,
                                        color: Color(0xFF383A56),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LayarTambahKendaraan(),
                  ),
                );
                // Refresh the list after adding a new vehicle
                _fetchKendaraan();
              },
              icon: Icon(Icons.add),
              label: Text('Tambah Kendaraan'),
            ),
          ],
        ),
      ),
    );
  }
}