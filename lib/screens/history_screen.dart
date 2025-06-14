import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocketbase/pocketbase.dart';

class LayarRiwayat extends StatefulWidget {
  @override
  _LayarRiwayatState createState() => _LayarRiwayatState();
}

class _LayarRiwayatState extends State<LayarRiwayat> {
  List<RecordModel> kendaraan = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Initialize PocketBase with your server URL
  final pb = PocketBase('http://127.0.0.1:8090');

  @override
  void initState() {
    super.initState();
    _fetchRiwayat();
  }

  Future<void> _fetchRiwayat() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Fetching service history from PocketBase');
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
      String errorMessage = 'Gagal mengambil riwayat servis';
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
        title: Text('Riwayat Servis'),
        backgroundColor: Color(0xFF2F3032),
        foregroundColor: Color(0xFFEDE68A),
      ),
      body: _isLoading
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
                        onPressed: _fetchRiwayat,
                        icon: Icon(Icons.refresh),
                        label: Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : kendaraan.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada riwayat servis.',
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
                          margin: const EdgeInsets.all(8.0),
                          color: Colors.white,
                          elevation: 3,
                          child: ListTile(
                            leading: Icon(
                              Icons.directions_car,
                              color: Color(0xFF383A56),
                              size: 30.0,
                            ),
                            title: Text(
                              vehicle['nama_kendaraan'] ?? 'Kendaraan Tanpa Nama',
                              style: GoogleFonts.poppins(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2F3032),
                              ),
                            ),
                            subtitle: Text(
                              'Servis terakhir: ${vehicle['tanggal_service_terakhir'] ?? 'Tidak tersedia'}',
                              style: GoogleFonts.robotoMono(
                                fontSize: 14.0,
                                color: Color(0xFF383A56),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}