import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocketbase/pocketbase.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'pocketbase_service.dart'; // Import the singleton service

class LayarLogin extends StatefulWidget {
  @override
  _LayarLoginState createState() => _LayarLoginState();
}

class _LayarLoginState extends State<LayarLogin> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Use the singleton PocketBase instance
  final PocketBaseService pbService = PocketBaseService();

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Validate input fields
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        throw Exception('Mohon masukkan email dan kata sandi!');
      }

      // Attempt to authenticate user with PocketBase
      print('Attempting login with email: ${_emailController.text}');
      final authData = await pbService.pb.collection('users').authWithPassword(
            _emailController.text.trim(),
            _passwordController.text,
          );

      print('Auth response: ${authData.toString()}');
      print('Auth store valid: ${pbService.pb.authStore.isValid}');

      // If authentication is successful, navigate to HomeScreen
      if (pbService.pb.authStore.isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Login berhasil!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Color(0xFFB0A565),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        throw Exception('Autentikasi gagal: Token tidak valid');
      }
    } catch (e) {
      // Handle errors with detailed logging
      String errorMessage = 'Login gagal!';
      print('Login error: $e');

      if (e is ClientException) {
        print('ClientException details: ${e.response}');
        errorMessage = e.response['message'] ?? 'Terjadi kesalahan server';
        if (e.response['data'] != null) {
          Map<String, dynamic> errors = e.response['data'];
          if (errors.containsKey('identity') || errors.containsKey('password')) {
            errorMessage = 'Email atau kata sandi salah!';
          } else if (errors.containsKey('email')) {
            errorMessage = 'Email tidak ditemukan atau belum diverifikasi';
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

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LayarRegister()),
    );
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
                  'Login',
                  style: GoogleFonts.poppins(
                    fontSize: 32.0,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2F3032),
                  ),
                ),
                SizedBox(height: 40.0),
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
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50.0),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Login'),
                ),
                SizedBox(height: 20.0),
                GestureDetector(
                  onTap: _navigateToRegister,
                  child: Text(
                    'Belum punya akun? Register',
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}