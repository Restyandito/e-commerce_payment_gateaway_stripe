import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:flutter_payment_gateaway_stripe/produk/headphone.dart';
import 'package:flutter_payment_gateaway_stripe/produk/smartwatch.dart';
import 'package:flutter_payment_gateaway_stripe/produk/television.dart';
import '../produk/earphone.dart';
import 'dart:ui';
import 'package:intl/intl.dart';  // Import intl untuk format angka

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Fungsi untuk log out
  Future<void> _logOut(BuildContext context) async {
    // Membuat dialog dengan latar belakang hitam pudar
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Stack(
          children: [
            // Latar belakang hitam pudar
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: ModalBarrier(
                dismissible: true,
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text("Konfirmasi Log Out"),
              content: const Text(
                "Apakah Anda yakin ingin keluar?",
                style: TextStyle(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Menutup dialog
                  },
                  child: const Text("Batal"),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance.signOut();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Logout berhasil!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pushReplacementNamed(context, '/login');
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Log out gagal: $e")),
                      );
                    }
                  },
                  child: const Text("Keluar"),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk hapus akun
  Future<void> _deleteAccount(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Stack(
          children: [
            // Latar belakang hitam pudar
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: ModalBarrier(
                dismissible: true,
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text("Konfirmasi Hapus Akun"),
              content: const Text(
                "Apakah Anda yakin ingin menghapus akun Anda? Tindakan ini tidak dapat dibatalkan.",
                style: TextStyle(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Menutup dialog
                  },
                  child: const Text("Batal"),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance.currentUser?.delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Akun berhasil dihapus."),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pushReplacementNamed(context, '/login');
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Hapus akun gagal: $e")),
                      );
                    }
                  },
                  child: const Text("Hapus"),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> sliderImages = [
      'https://www.hp.com/content/dam/sites/worldwide/personal-computers/consumer/gaming/gaming-gateway/Hero%20banner%20Desktop@3x.jpg',
      'https://www.blibli.com/friends-backend/wp-content/uploads/2023/08/B800245-Cover-Cara-Memilih-PC-Gaming-yang-Bagus-scaled.jpg',
      'https://cdn.mos.cms.futurecdn.net/cuC6EjnkCFm8t5AfZriFmC.jpg',
      'https://i.ytimg.com/vi/M1NG3oWfafQ/hq720.jpg?sqp=-oaymwEhCK4FEIIDSFryq4qpAxMIARUAAAAAGAElAADIQj0AgKJD&rs=AOn4CLAut7UyQ9wG6WfZBdcNHxC3JKl25Q',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Selamat Datang!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        actions: [
          PopupMenuButton<int>(
            onSelected: (value) {
              if (value == 1) {
                _logOut(context); // Log out
              } else if (value == 2) {
                _deleteAccount(context); // Hapus akun
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<int>(
                value: 1,
                child: Text("Log Out"),
              ),
              const PopupMenuItem<int>(
                value: 2,
                child: Text("Hapus Akun"),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          CarouselSlider(
            options: CarouselOptions(
              height: 200, // Menambah tinggi slider jika diperlukan
              autoPlay: true,
              enlargeCenterPage: true,
              aspectRatio: 16 / 9, // Memastikan rasio gambar tetap proporsional
              autoPlayInterval: const Duration(seconds: 3),
            ),
            items: sliderImages.map((imageUrl) {
              return Builder(
                builder: (BuildContext context) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width, // Menggunakan lebar penuh layar
                    ),
                  );
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                itemCount: 4, // Jumlah produk yang tersedia
                itemBuilder: (context, index) {
                  // Daftar produk
                  List<Map<String, dynamic>> products = [
                    {
                      'name': 'TWS Anker R50i',
                      'price': 200000,
                      'image': 'https://ankerindonesia.com/cdn/shop/products/aa1207d9-e146-4759-8140-917dbb7c2b09-a3949h11-soundcore-r50i-black-1-2.jpg?v=1709833731',
                      'route': const EarphonePage(),
                    },
                    {
                      'name': 'Sony WH-CH520',
                      'price': 665420,
                      'image': 'https://d1ncau8tqf99kp.cloudfront.net/converted/110590_original_local_504x441_v3_converted.webp',
                      'route': const HeadphonePage(),
                    },
                    {
                      'name': 'Galaxy Watch 7',
                      'price': 5000000,
                      'image': 'https://img01.ztat.net/article/spp-media-p1/55dff45e5ffd4ec394f6a0e63d624348/ed8787b350c74c44b46ff18459df76a1.jpg?imwidth=1800',
                      'route': const SmartwatchPage(),
                    },
                    {
                      'name': '55’’ OLED S95D',
                      'price': 27900000,
                      'image': 'https://liptons.ca/cdn/shop/files/1_76428e85-0d0b-46ca-b44f-694f9f568be3.png?v=1717441501',
                      'route': const TelevisionPage(),
                    },
                  ];

                  // Ambil data produk berdasarkan index
                  final product = products[index];

                  // Format harga dengan pemisah ribuan dan koma
                  String formattedPrice = NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(product['price']);

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => product['route']),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
                            child: Image.network(
                              product['image'],
                              height: 150,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            formattedPrice,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
