import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import intl untuk format angka
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firebase Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:carousel_slider/carousel_slider.dart'; // Import Carousel package
import '../halaman/ReceiptPage.dart';

class HeadphonePage extends StatefulWidget {
  const HeadphonePage({super.key});

  @override
  State<HeadphonePage> createState() => _HeadphonePageState();
}

class _HeadphonePageState extends State<HeadphonePage> {
  String publishableKey = "pk_test_51QECHXCNWIn8eaORWblA6ccteZYVL1sVTXuK9CyVkobOMZ6oCk65A4UQsVDMFkn2B1FdFJNDpR3CDTGcYToqBuBl00M5RJ0N3M";
  String secretKey = "sk_test_51QECHXCNWIn8eaORcl5HjJk1KvOalz3C1MQeZRsNWoiwNDLetoluGHaYbIzeSyFWcraOjUePqrOcuLelFcoUJf7P00r3y60btb";

  double amount = 665420; // Harga per produk
  int quantity = 1; // Jumlah produk yang ingin dibeli
  Map<String, dynamic>? IntentPaymentData;
  String customerName = ""; // Inisialisasi variabel customerName

  @override
  void initState() {
    super.initState();
    // Ambil nama pengguna yang sedang login
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      customerName = user.displayName ?? user.email ?? "Nama Pengguna";
    }
  }

  // Fungsi untuk menampilkan pembayaran menggunakan Stripe
  showPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((val) {
        setState(() {
          IntentPaymentData = null;
        });
        // Simpan transaksi ke Firebase setelah pembayaran berhasil
        savePurchaseToFirebase();

        // Navigasi ke halaman resi setelah pembayaran berhasil
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReceiptPage(amount: amount * quantity),
          ),
        );
      }).onError((errorMsg, sTrace) {
        if (kDebugMode) {
          print(errorMsg.toString() + sTrace.toString());
        }
      });
    } on StripeException catch (error) {
      if (kDebugMode) {
        print(error);
      }

      showDialog(
        context: context,
        builder: (c) => const AlertDialog(
          content: Text("Pembayaran dibatalkan."),
        ),
      );
    } catch (errorMsg) {
      if (kDebugMode) {
        print(errorMsg);
      }
      print(errorMsg.toString());
    }
  }

  // Fungsi untuk menyimpan data pembelian ke Firestore
  savePurchaseToFirebase() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      await firestore.collection('purchases').add({
        'product': 'Sony WH-CH520', // Nama produk yang dibeli
        'quantity': quantity, // Jumlah produk yang dibeli
        'total_price': amount * quantity, // Total harga produk
        'customer_name': customerName, // Nama pelanggan
        'timestamp': FieldValue.serverTimestamp(), // Timestamp pembelian
      });

      if (kDebugMode) {
        print("Transaksi berhasil disimpan ke Firestore");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Gagal menyimpan transaksi: $e");
      }
    }
  }

  makeIntentForPayment(amountToBeCharge, currency) async {
    try {
      Map<String, dynamic>? paymentInfo = {
        "amount": (int.parse(amountToBeCharge) * 100).toString(),
        "currency": currency,
        "payment_method_types[]": "card",
      };

      var responseFromStripeAPI = await http.post(
        Uri.parse("https://api.stripe.com/v1/payment_intents"),
        body: paymentInfo,
        headers: {
          "Authorization": "Bearer $secretKey",
          "Content-Type": "application/x-www-form-urlencoded",
        },
      );

      print("response from API = ${responseFromStripeAPI.body}");

      return jsonDecode(responseFromStripeAPI.body);
    } catch (errorMsg) {
      if (kDebugMode) {
        print(errorMsg);
      }
      print(errorMsg.toString());
    }
  }

  paymentSheetInitialization(amountToBeCharge, currency) async {
    try {
      IntentPaymentData = await makeIntentForPayment(amountToBeCharge, currency);

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          allowsDelayedPaymentMethods: true,
          paymentIntentClientSecret: IntentPaymentData!["client_secret"],
          style: ThemeMode.dark,
          merchantDisplayName: "Company Name",
        ),
      ).then((val) {
        print(val);
      });

      showPaymentSheet();
    } catch (errorMsg, s) {
      if (kDebugMode) {
        print(s);
      }
      print(errorMsg.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format angka dengan pemisah ribuan dan dua angka nol
    String formattedAmount = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2).format(amount * quantity);

    // Carousel images
    List<String> carouselImages = [
      'https://d1ncau8tqf99kp.cloudfront.net/converted/110590_original_local_504x441_v3_converted.webp',
      'https://d1ncau8tqf99kp.cloudfront.net/converted/110591_original_local_504x441_v3_converted.webp',
      'https://d1ncau8tqf99kp.cloudfront.net/converted/110592_original_local_504x441_v3_converted.webp',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Sony WH-CH520',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carousel slider
                CarouselSlider(
                  items: carouselImages.map((imageUrl) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Image.network(imageUrl, height: 200, fit: BoxFit.cover);
                      },
                    );
                  }).toList(),
                  options: CarouselOptions(
                    height: 200,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    aspectRatio: 16/9,
                    viewportFraction: 0.8,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Produk Premium',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Headphone nirkabel ringan: Baterai tahan 50 jam, driver 30mm, Bluetooth 5.2, mikrofon internal, dan kompatibel dengan Sony Headphones Connect.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Harga: $formattedAmount',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          if (quantity > 1) quantity--;
                        });
                      },
                    ),
                    Text(
                      '$quantity',
                      style: const TextStyle(fontSize: 24),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          quantity++;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      paymentSheetInitialization(
                        (amount * quantity).round().toString(),
                        "IDR",
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'Beli Sekarang',
                      style: TextStyle(
                        color: Colors.white,
                      ),
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
}
