import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocketbase/pocketbase.dart';
import 'login_screen.dart'; // Adjust the import based on your file structure
import 'pocketbase_service.dart'; // Import the singleton service

class LayarProfil extends StatefulWidget {
  @override
  _LayarProfilState createState() => _LayarProfilState();
}

class _LayarProfilState extends State<LayarProfil> {
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _teleponController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  String? _profilePictureUrl;
  bool _isEditing = false; // Status untuk mode edit

  // Use the singleton PocketBase instance
  final PocketBaseService pbService = PocketBaseService();

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadData();
  }

  Future<void> _checkAuthAndLoadData() async {
    print('Checking auth state: isValid=${pbService.pb.authStore.isValid}, token=${pbService.pb.authStore.token}');

    // Redirect to login if not authenticated
    if (!pbService.pb.authStore.isValid || pbService.pb.authStore.token.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LayarLogin()),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sesi login tidak ditemukan. Silakan login kembali.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Color(0xFF383A56),
          ),
        );
      });
      return;
    }

    // Load user data from authStore
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final userData = Map<String, dynamic>.from(pbService.pb.authStore.model?.data ?? {});
      print('User data from authStore: $userData');

      _namaController.text = userData['name']?.toString() ?? '';
      _emailController.text = userData['email']?.toString() ?? '';
      _teleponController.text = userData['phone']?.toString() ?? '';

      setState(() {
        _isLoading = false;
      });

      await _fetchUserData();
    } catch (e) {
      print('Load data error: $e');
      setState(() {
        _errorMessage = 'Gagal memuat data profil: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final userId = pbService.pb.authStore.model?.id;
      if (userId == null) {
        throw Exception('User ID tidak ditemukan.');
      }

      print('Fetching fresh user data with ID: $userId');
      final user = await pbService.pb.collection('users').getOne(userId);
      print('Fresh user data fetched: ${user.data}');

      // Fetch profile picture
      try {
        final profilePictures = await pbService.pb.collection('profile_pictures').getFullList(
          filter: 'user = "$userId"',
        );
        if (profilePictures.isNotEmpty) {
          final profilePicture = profilePictures.first;
          final imageFileName = profilePicture.data['image'];
          if (imageFileName != null && imageFileName is String && imageFileName.isNotEmpty) {
            _profilePictureUrl = pbService.pb.getFileUrl(profilePicture, imageFileName).toString();
            print('Profile picture URL: $_profilePictureUrl');
          } else {
            _profilePictureUrl = null;
            print('No valid image file found in profile picture record: ${profilePicture.data}');
          }
        } else {
          _profilePictureUrl = null;
          print('No profile picture found for user: $userId');
        }
      } catch (e) {
        print('Profile picture fetch error: $e');
        _profilePictureUrl = null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal mengambil foto profil: ${e.toString()}',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Color(0xFF383A56),
          ),
        );
      }

      setState(() {
        _namaController.text = user.data['name']?.toString() ?? '';
        _emailController.text = user.data['email']?.toString() ?? '';
        _teleponController.text = user.data['phone']?.toString() ?? '';
      });
    } catch (e) {
      print('Fetch error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal mengambil data terbaru: ${e.toString()}',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Color(0xFF383A56),
        ),
      );
    }
  }

  Future<void> _simpanProfil() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Validate input
      if (_namaController.text.isEmpty || _emailController.text.isEmpty) {
        throw Exception('Nama dan email tidak boleh kosong.');
      }

      final userId = pbService.pb.authStore.model?.id;
      if (userId == null) {
        throw Exception('User ID tidak ditemukan.');
      }

      // Prepare updated data
      final updatedData = {
        'name': _namaController.text,
        'email': _emailController.text,
        if (_teleponController.text.isNotEmpty) 'phone': _teleponController.text,
      };

      print('Updating user data with ID: $userId, data: $updatedData');
      await pbService.pb.collection('users').update(userId, body: updatedData);

      // Update authStore with new data
      final user = await pbService.pb.collection('users').getOne(userId);
      pbService.pb.authStore.save(pbService.pb.authStore.token, user);

      setState(() {
        _isEditing = false; // Kembali ke mode view setelah simpan
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Profil berhasil disimpan!',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Color(0xFFB0A565),
        ),
      );
    } catch (e) {
      print('Save error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menyimpan profil: ${e.toString()}',
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

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _teleponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Pengguna'),
        backgroundColor: Color(0xFF2F3032),
        foregroundColor: Color(0xFFEDE68A),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: _toggleEditMode,
              color: Color(0xFFEDE68A),
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFFB0A565),
              ),
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
                        onPressed: _checkAuthAndLoadData,
                        icon: Icon(Icons.refresh),
                        label: Text('Coba Lagi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFB0A565),
                          foregroundColor: Color(0xFF2F3032),
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Color(0xFF383A56),
                          backgroundImage: _profilePictureUrl != null
                              ? NetworkImage(_profilePictureUrl!)
                              : null,
                          child: _profilePictureUrl == null
                              ? Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Color(0xFFEDE68A),
                                )
                              : null,
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
                        enabled: _isEditing, // Aktifkan hanya saat edit
                        decoration: InputDecoration(
                          hintText: 'Masukkan nama Anda',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
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
                        enabled: _isEditing, // Aktifkan hanya saat edit
                        decoration: InputDecoration(
                          hintText: 'Masukkan email Anda',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
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
                        enabled: _isEditing, // Aktifkan hanya saat edit
                        decoration: InputDecoration(
                          hintText: 'Masukkan nomor telepon Anda',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 30.0),
                      Center(
                        child: _isEditing
                            ? ElevatedButton(
                                onPressed: _simpanProfil,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.save),
                                    SizedBox(width: 8.0),
                                    Text('Simpan'),
                                  ],
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF383A56),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 30.0,
                                    vertical: 15.0,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              )
                            : SizedBox.shrink(), // Sembunyikan tombol saat tidak edit
                      ),
                    ],
                  ),
                ),
    );
  }
}