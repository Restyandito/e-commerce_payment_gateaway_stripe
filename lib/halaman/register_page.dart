import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _obscurePassword = true;

  // Fungsi untuk menyimpan data pengguna ke Firestore
  Future<void> _saveUserDetails(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'email': _emailController.text,
        'country': _countryController.text,
        'province': _provinceController.text,
        'city': _cityController.text,
        'postal_code': _postalCodeController.text,
        'uid': user.uid,  // Menyimpan UID pengguna
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat menyimpan data pengguna: $e')),
      );
    }
  }

  // Fungsi registrasi
  Future<void> _register() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Menyimpan data pengguna ke Firestore setelah registrasi berhasil
        await _saveUserDetails(user);

        // Jika registrasi berhasil, arahkan ke halaman login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registrasi berhasil!")),
        );
        Navigator.pop(context); // Kembali ke halaman login setelah registrasi berhasil
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Terjadi kesalahan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Daftar",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 40),

                // Input Email
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Masukkan email Anda",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Input Negara
                TextField(
                  controller: _countryController,
                  decoration: InputDecoration(
                    labelText: "Negara",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Input Provinsi
                TextField(
                  controller: _provinceController,
                  decoration: InputDecoration(
                    labelText: "Provinsi",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,  // Menyelaraskan kolom pada bagian atas
                  children: [
                    // Kolom untuk Kota
                    Container(
                      width: 150,  // Ukuran lebar tetap untuk kolom Kota
                      child: TextField(
                        controller: _cityController,
                        decoration: InputDecoration(
                          labelText: "Kota",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 44),  // Spasi antar kolom
                    Container(
                      width: 150,  // Ukuran lebar tetap untuk kolom Kode Pos
                      child: Padding(
                        padding: const EdgeInsets.only(left: 9.0),  // Menambahkan padding ke kanan
                        child: TextField(
                          controller: _postalCodeController,
                          decoration: InputDecoration(
                            labelText: "Kode Pos",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 5, // Membatasi panjang input kode pos
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Input Password
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Masukkan kata sandi Anda",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol Daftar
                ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // Gantilah angka ini sesuai keinginan
                    ),
                  ),
                  child: const Text(
                    "Daftar",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 24),

                // Tautan Masuk
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Sudah punya akun? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Kembali ke halaman login
                      },
                      child: const Text(
                        "Masuk",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
