import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocketbase/pocketbase.dart';

class LayarTambahKendaraan extends StatefulWidget {
  @override
  _LayarTambahKendaraanState createState() => _LayarTambahKendaraanState();
}

class _LayarTambahKendaraanState extends State<LayarTambahKendaraan> {
  final _namaController = TextEditingController();
  final _tipeController = TextEditingController();
  final _nomorPlatController = TextEditingController();
  final _catatanController = TextEditingController();
  DateTime? _tanggalTerpilih;
  DateTime? _tanggalPengingat;
  bool _isLoading = false;

  // Initialize PocketBase with your server URL
  final pb = PocketBase('http://127.0.0.1:8090');

  Future<void> simpanKendaraan() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Validate input fields
      if (_namaController.text.isEmpty ||
          _tipeController.text.isEmpty ||
          _nomorPlatController.text.isEmpty ||
          _tanggalTerpilih == null ||
          _tanggalPengingat == null) {
        throw Exception('Mohon lengkapi semua data!');
      }

      // Prepare data for PocketBase
      final kendaraanData = {
        'nama_kendaraan': _namaController.text.trim(),
        'jenis_kendaraan': _tipeController.text.trim(),
        'nomor_plat': _nomorPlatController.text.trim(),
        'catatan': _catatanController.text.trim(),
        'tanggal_service_terakhir': _tanggalTerpilih!.toIso8601String().split('T')[0],
        'tanggal_pengingat': _tanggalPengingat!.toIso8601String().split('T')[0],
      };

      print('Attempting to save vehicle data: $kendaraanData');
      await pb.collection('kendaraan').create(body: kendaraanData);
      print('Vehicle saved successfully');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Kendaraan berhasil disimpan!',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Color(0xFFB0A565),
        ),
      );

      // Clear fields and navigate back
      _namaController.clear();
      _tipeController.clear();
      _nomorPlatController.clear();
      _catatanController.clear();
      setState(() {
        _tanggalTerpilih = null;
        _tanggalPengingat = null;
      });
      Navigator.pop(context);
    } catch (e) {
      // Handle errors
      String errorMessage = 'Gagal menyimpan kendaraan!';
      print('Save error: $e');

      if (e is ClientException) {
        print('ClientException details: ${e.response}');
        errorMessage = e.response['message'] ?? 'Terjadi kesalahan server';
        if (e.response['data'] != null) {
          Map<String, dynamic> errors = e.response['data'];
          if (errors.containsKey('nomor_plat')) {
            errorMessage = 'Nomor plat sudah digunakan';
          }
        }
      } else {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Color(0xFF383A56),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Kendaraan'),
        backgroundColor: Color(0xFF2F3032),
        foregroundColor: Color(0xFFEDE68A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Nama Kendaraan',
              style: GoogleFonts.poppins(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2F3032),
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: _namaController,
              decoration: InputDecoration(
                hintText: 'Contoh: Toyota Avanza',
                prefixIcon: Icon(Icons.directions_car),
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'Jenis Kendaraan',
              style: GoogleFonts.poppins(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2F3032),
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: _tipeController,
              decoration: InputDecoration(
                hintText: 'Contoh: Sedan, SUV',
                prefixIcon: Icon(Icons.category),
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'Nomor Plat',
              style: GoogleFonts.poppins(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2F3032),
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: _nomorPlatController,
              decoration: InputDecoration(
                hintText: 'Contoh: B 1234 XYZ',
                prefixIcon: Icon(Icons.confirmation_number),
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'Catatan Tambahan',
              style: GoogleFonts.poppins(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2F3032),
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: _catatanController,
              decoration: InputDecoration(
                hintText: 'Opsional',
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'Tanggal Servis Terakhir',
              style: GoogleFonts.poppins(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2F3032),
              ),
            ),
            SizedBox(height: 8.0),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _tanggalTerpilih = date;
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Color(0xFF383A56)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _tanggalTerpilih == null
                          ? 'Pilih Tanggal'
                          : '${_tanggalTerpilih!.toLocal()}'.split(' ')[0],
                      style: GoogleFonts.robotoMono(
                        fontSize: 16.0,
                        color: Color(0xFF383A56),
                      ),
                    ),
                    Icon(
                      Icons.calendar_today,
                      color: Color(0xFFB0A565),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'Tanggal Pengingat',
              style: GoogleFonts.poppins(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2F3032),
              ),
            ),
            SizedBox(height: 8.0),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() {
                    _tanggalPengingat = date;
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Color(0xFF383A56)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _tanggalPengingat == null
                          ? 'Pilih Tanggal'
                          : '${_tanggalPengingat!.toLocal()}'.split(' ')[0],
                      style: GoogleFonts.robotoMono(
                        fontSize: 16.0,
                        color: Color(0xFF383A56),
                      ),
                    ),
                    Icon(
                      Icons.calendar_today,
                      color: Color(0xFFB0A565),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30.0),
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : simpanKendaraan,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.save),
                    SizedBox(width: 8.0),
                    Text('Simpan Kendaraan'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _tipeController.dispose();
    _nomorPlatController.dispose();
    _catatanController.dispose();
    super.dispose();
  }
}