import 'package:flutter/material.dart';
import 'package:epresensi_esolusindo/Screens/Laporan/Lembur/components/body.dart';

class LaporanLemburScreen extends StatelessWidget {
  const LaporanLemburScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Laporan Lembur",
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ),
      body: const Body(),
    );
  }
}
