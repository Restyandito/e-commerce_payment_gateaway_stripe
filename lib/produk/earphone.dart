import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';  // Import intl untuk format angka
import 'package:cloud_firestore/cloud_firestore.dart';  // Import Firebase Firestore
import 'package:firebase_auth/firebase_auth.dart';  // Import Firebase Auth
import 'package:carousel_slider/carousel_slider.dart'; // Import carousel_slider
import '../halaman/ReceiptPage.dart';

class EarphonePage extends StatefulWidget {
  const EarphonePage({super.key});

  @override
  State<EarphonePage> createState() => _EarphonePageState();
}

class _EarphonePageState extends State<EarphonePage> {
  String publishableKey = "pk_test_51QECHXCNWIn8eaORWblA6ccteZYVL1sVTXuK9CyVkobOMZ6oCk65A4UQsVDMFkn2B1FdFJNDpR3CDTGcYToqBuBl00M5RJ0N3M";
  String secretKey = "sk_test_51QECHXCNWIn8eaORcl5HjJk1KvOalz3C1MQeZRsNWoiwNDLetoluGHaYbIzeSyFWcraOjUePqrOcuLelFcoUJf7P00r3y60btb";

  double amount = 200000;  // Harga per produk
  int quantity = 1;  // Jumlah produk yang ingin dibeli
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
        'product': 'TWS ANKER R50i',  // Nama produk yang dibeli
        'quantity': quantity,   // Jumlah produk yang dibeli
        'total_price': amount * quantity,  // Total harga produk
        'customer_name': customerName,  // Nama pelanggan
        'timestamp': FieldValue.serverTimestamp(),  // Timestamp pembelian
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

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'TWS ANKER R50i',
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
                // Carousel Slider for product images
                CarouselSlider(
                  options: CarouselOptions(
                    height: 240,
                    autoPlay: true,
                    enlargeCenterPage: true,
                  ),
                  items: [
                    'https://ankerindonesia.com/cdn/shop/products/aa1207d9-e146-4759-8140-917dbb7c2b09-a3949h11-soundcore-r50i-black-1-2.jpg?v=1709833731',
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSF71Qlp48HlGA2Bc54UBbqbnNkyOi-OlAz_CK3Hv74yRAdoxuNaT5rEka_mcmQEAXdLoI&usqp=CAU',
                    'https://ankerindonesia.com/cdn/shop/files/A3959_pink_670x670_b8d25367-6174-4fe8-a133-f93941815451.jpg?v=1724215970&width=1445',
                  ].map((url) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Image.network(
                          url,
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width,
                        );
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Produk Terbaik',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Suara jernih dan bass mendalam, Noise Cancelling: Reduksi hingga 42dB dengan sistem aktif & teknologi adaptif.',
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
