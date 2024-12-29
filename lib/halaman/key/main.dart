import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:firebase_core/firebase_core.dart';
import '../home_page.dart';
import '../login_page.dart';


void main() async {
  // Pastikan Firebase diinisialisasi terlebih dahulu sebelum menjalankan aplikasi
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  // Inisialisasi Firebase
  Stripe.publishableKey = "pk_test_51QECHXCNWIn8eaORWblA6ccteZYVL1sVTXuK9CyVkobOMZ6oCk65A4UQsVDMFkn2B1FdFJNDpR3CDTGcYToqBuBl00M5RJ0N3M";  // Ganti dengan kunci Stripe Anda
  await Stripe.instance.applySettings(); // Apply Stripe settings

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Menambahkan Named Routes
      initialRoute: '/login',  // Set rute awal ke halaman login
      routes: {
        '/': (context) => const LoginPage(), // Halaman utama setelah login
        '/login': (context) => const LoginPage(), // Halaman login
        '/home_page': (context) => HomePage(), // Menambahkan route untuk halaman home_page
      },
    );
  }
}
