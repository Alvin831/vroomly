import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocketbase/pocketbase.dart';
import 'pocketbase_service.dart'; // Import the singleton service

class LayarRegister extends StatefulWidget {
  @override
  _LayarRegisterState createState() => _LayarRegisterState();
}

class _LayarRegisterState extends State<LayarRegister> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Use the singleton PocketBase instance
  final PocketBaseService pbService = PocketBaseService();

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Validate input fields
      if (_nameController.text.isEmpty ||
          _emailController.text.isEmpty ||
          _passwordController.text.isEmpty) {
        throw Exception('Mohon lengkapi semua data!');
      }

      // Create user in PocketBase
      final userData = {
        'username': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'passwordConfirm': _passwordController.text,
        'name': _nameController.text,
      };

      final record = await pbService.pb.collection('users').create(body: userData);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Registrasi berhasil! Silakan login.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Color(0xFFB0A565),
        ),
      );

      // Navigate back to login
      Navigator.pop(context);
    } catch (e) {
      // Handle errors
      String errorMessage = 'Registrasi gagal!';
      
      if (e is ClientException) {
        errorMessage = e.response['message'] ?? 'Terjadi kesalahan server';
        if (e.response['data'] != null) {
          // Extract specific field errors
          Map<String, dynamic> errors = e.response['data'];
          if (errors.containsKey('email')) {
            errorMessage = 'Email sudah digunakan atau tidak valid';
          } else if (errors.containsKey('password')) {
            errorMessage = 'Password tidak memenuhi persyaratan';
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

  void _navigateToLogin() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Register',
                  style: GoogleFonts.poppins(
                    fontSize: 32.0,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2F3032),
                  ),
                ),
                SizedBox(height: 40.0),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama',
                    hintText: 'Masukkan nama Anda',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                SizedBox(height: 20.0),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Masukkan email Anda',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 20.0),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Masukkan kata sandi Anda',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_isPasswordVisible,
                ),
                SizedBox(height: 30.0),
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50.0),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Register'),
                ),
                SizedBox(height: 20.0),
                GestureDetector(
                  onTap: _navigateToLogin,
                  child: Text(
                    'Sudah punya akun? Login',
                    style: GoogleFonts.poppins(
                      fontSize: 14.0,
                      color: Color(0xFF2F3032),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}