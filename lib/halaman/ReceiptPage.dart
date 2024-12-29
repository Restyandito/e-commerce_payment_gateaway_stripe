import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // Import intl untuk format angka
import 'package:cloud_firestore/cloud_firestore.dart';  // Import Firebase Firestore
import 'package:firebase_auth/firebase_auth.dart';  // Import Firebase Auth

class ReceiptPage extends StatelessWidget {
  final double amount;

  const ReceiptPage({Key? key, required this.amount}) : super(key: key);

  // Fungsi untuk mengambil data alamat dari Firestore
  Future<String> _getUserAddress(User user) async {
    String customerAddress = "Alamat tidak tersedia";  // Default value if not found
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        String city = doc['city'] ?? "Kota tidak ditemukan";
        String country = doc['country'] ?? "Negara tidak ditemukan";
        String postalCode = doc['postal_code'] ?? "Kode Pos tidak ditemukan";
        String province = doc['province'] ?? "Provinsi tidak ditemukan";
        customerAddress = "$city, $province, $postalCode, $country";
      }
    } catch (e) {
      customerAddress = "Gagal memuat alamat.";
    }
    return customerAddress;
  }

  @override
  Widget build(BuildContext context) {
    // Format angka dengan pemisah ribuan dan dua angka nol
    String formattedAmount = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2).format(amount);

    // Ambil nama pengguna dari Firebase Auth
    User? user = FirebaseAuth.instance.currentUser;
    String customerName = user?.displayName ?? user?.email ?? "Nama Pengguna";

    // Ambil timestamp pembelian
    String formattedTimestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    // Gunakan FutureBuilder untuk menunggu pengambilan alamat pengguna
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resi Pembayaran'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Center( // Gunakan Center untuk menempatkan semua widget di tengah layar
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,  // Mengatur semua elemen dalam Column agar terpusat
              crossAxisAlignment: CrossAxisAlignment.center, // Untuk menyesuaikan konten secara horizontal
              children: [
                // Judul dan icon resi
                Icon(
                  Icons.receipt_long,
                  size: 80,
                  color: Colors.green,
                ),
                const SizedBox(height: 10),
                Text(
                  'Resi Pembayaran',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Inter',  // Menambahkan font Inter
                  ),
                  textAlign: TextAlign.center,  // Memastikan teks judul berada di tengah
                ),
                const SizedBox(height: 10),

                // Timestamp Pembelian
                Text(
                  formattedTimestamp,
                  style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,  // Menempatkan timestamp di tengah
                ),
                const Divider(
                  color: Colors.black,
                  height: 20,
                  thickness: 1,
                ),

                // Informasi pembayaran
                SizedBox(height: 20),
                Text(
                  'Nama Pembeli: $customerName',
                  style: TextStyle(fontSize: 16, fontFamily: 'Inter'),  // Menggunakan font Inter
                  textAlign: TextAlign.center,  // Memastikan teks nama pembeli di tengah
                ),
                const SizedBox(height: 10),
                FutureBuilder<String>(
                  future: _getUserAddress(user!), // Ambil alamat dari Firestore
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text(
                        "Memuat alamat...",
                        textAlign: TextAlign.center,  // Memastikan teks alamat di tengah
                      );
                    } else if (snapshot.hasError) {
                      return Text(
                        "Terjadi kesalahan saat memuat alamat.",
                        textAlign: TextAlign.center,  // Memastikan teks error alamat di tengah
                      );
                    } else if (snapshot.hasData) {
                      return Text(
                        'Alamat Pengiriman: ${snapshot.data}',
                        style: TextStyle(fontSize: 16, fontFamily: 'Inter'),  // Menggunakan font Inter
                        textAlign: TextAlign.center,  // Memastikan teks alamat di tengah
                      );
                    } else {
                      return Text(
                        'Alamat Pengiriman: Tidak ditemukan',
                        style: TextStyle(fontSize: 16, fontFamily: 'Inter'),  // Menggunakan font Inter
                        textAlign: TextAlign.center,  // Memastikan teks alamat di tengah
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
                Divider(
                  color: Colors.black.withOpacity(0.5),
                  height: 20,
                  thickness: 1,
                ),

                // Menambahkan SizedBox untuk mengatur jarak
                SizedBox(height: 10),  // Menambah jarak agar Total Pembayaran lebih ke bawah

                // Detail harga
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,  // Menjaga posisi harga tetap terpusat
                  children: [
                    Text(
                      'Total Pembayaran',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Inter'),  // Menggunakan font Inter
                    ),
                    const SizedBox(width: 10),
                    Text(
                      formattedAmount,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Inter'),  // Menggunakan font Inter
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(
                  color: Colors.black.withOpacity(0.5),
                  height: 20,
                  thickness: 1,
                ),

                // Tombol Kembali
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home_page');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    minimumSize: Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    'Kembali ke Beranda',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Inter'),  // Menggunakan font Inter
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
