import 'package:carousel_slider/carousel_slider.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../halaman/ReceiptPage.dart';

class TelevisionPage extends StatefulWidget {
  const TelevisionPage({super.key});

  @override
  State<TelevisionPage> createState() => _TelevisionPageState();
}

class _TelevisionPageState extends State<TelevisionPage> {
  String publishableKey = "pk_test_51QECHXCNWIn8eaORWblA6ccteZYVL1sVTXuK9CyVkobOMZ6oCk65A4UQsVDMFkn2B1FdFJNDpR3CDTGcYToqBuBl00M5RJ0N3M";
  String secretKey = "sk_test_51QECHXCNWIn8eaORcl5HjJk1KvOalz3C1MQeZRsNWoiwNDLetoluGHaYbIzeSyFWcraOjUePqrOcuLelFcoUJf7P00r3y60btb";

  double amount = 27900000; // Harga per produk
  int quantity = 1; // Jumlah produk yang ingin dibeli
  Map<String, dynamic>? IntentPaymentData;
  String customerName = ""; // Inisialisasi variabel customerName

  List<String> imageUrls = [
    'https://images.samsung.com/is/image/samsung/p6pim/id/qa55s95dakxxd/gallery/id-oled-s95d-qa55s95dakxxd-542132843?650_519_PNG',
    'https://images.samsung.com/is/image/samsung/p6pim/au/qa55s95dawxxy/gallery/au-oled-s95d-qa55s95dawxxy-540639642?720_576_JPG',
    'https://smartappliancesuk.com/cdn/shop/files/10263395_001_a4cf5d39-a662-4a10-acb4-16e6e757a05f_1200x1200.webp?v=1719724084',
  ];

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      customerName = user.displayName ?? user.email ?? "Nama Pengguna";
    }
  }

  showPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((val) {
        setState(() {
          IntentPaymentData = null;
        });
        savePurchaseToFirebase();
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
    }
  }

  savePurchaseToFirebase() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('purchases').add({
        'product': '55\'\' OLED S95D',
        'quantity': quantity,
        'total_price': amount * quantity,
        'customer_name': customerName,
        'timestamp': FieldValue.serverTimestamp(),
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

      return jsonDecode(responseFromStripeAPI.body);
    } catch (errorMsg) {
      if (kDebugMode) {
        print(errorMsg);
      }
    }
  }

  paymentSheetInitialization(amountToBeCharge, currency) async {
    try {
      IntentPaymentData = await makeIntentForPayment(amountToBeCharge, currency);

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          allowsDelayedPaymentMethods: true,
          paymentIntentClientSecret: IntentPaymentData!['client_secret'],
          style: ThemeMode.dark,
          merchantDisplayName: "Company Name",
        ),
      );

      showPaymentSheet();
    } catch (errorMsg, s) {
      if (kDebugMode) {
        print(s);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedAmount = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2).format(amount * quantity);

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            '55\'\' OLED S95D',
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
                // CarouselSlider untuk menampilkan gambar
                Center(
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 200,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      aspectRatio: 16 / 9,
                      viewportFraction: 0.8,
                    ),
                    items: imageUrls.map((url) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Image.network(
                            url,
                            fit: BoxFit.cover,
                            height: 200,
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Televisi Premium',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'TV OLED 4K premium: Warna cemerlang, kontras tinggi, prosesor XR, Dolby Vision, Dolby Atmos, dan Google TV untuk pengalaman sinematik.',
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
