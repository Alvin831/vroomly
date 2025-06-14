import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LayarProfil extends StatefulWidget {
  @override
  _LayarProfilState createState() => _LayarProfilState();
}

class _LayarProfilState extends State<LayarProfil> {
  final _namaController = TextEditingController(text: 'John Doe');
  final _emailController = TextEditingController(text: 'john.doe@example.com');
  final _teleponController = TextEditingController(text: '+62 812 3456 7890');

  void _simpanProfil() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Profil berhasil disimpan!',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Color(0xFFB0A565),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Pengguna'),
        backgroundColor: Color(0xFF2F3032),
        foregroundColor: Color(0xFFEDE68A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFF383A56),
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Color(0xFFEDE68A),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'Nama',
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
                hintText: 'Masukkan nama Anda',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'Email',
              style: GoogleFonts.poppins(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2F3032),
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Masukkan email Anda',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20.0),
            Text(
              'Nomor Telepon',
              style: GoogleFonts.poppins(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2F3032),
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: _teleponController,
              decoration: InputDecoration(
                hintText: 'Masukkan nomor telepon Anda',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 30.0),
            Center(
              child: ElevatedButton(
                onPressed: _simpanProfil,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.save),
                    SizedBox(width: 8.0),
                    Text('Simpan Profil'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}