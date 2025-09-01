import 'package:flutter/material.dart';
import 'package:mobile_presensi_kdtg/Screens/Absen/absen_screen.dart';
import 'package:mobile_presensi_kdtg/Screens/LokasiKampus/components/background.dart';
import 'package:mobile_presensi_kdtg/Screens/Login/post_login.dart';
import 'package:mobile_presensi_kdtg/Screens/LokasiKampus/lokasi_kampus_post.dart';
import 'package:mobile_presensi_kdtg/Screens/dashboard_screen.dart';
import 'package:mobile_presensi_kdtg/components/already_have_an_account_acheck.dart';
import 'package:mobile_presensi_kdtg/components/rounded_button.dart';
import 'package:mobile_presensi_kdtg/components/rounded_date_field.dart';
import 'package:mobile_presensi_kdtg/components/rounded_input_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mobile_presensi_kdtg/constants.dart';
import 'package:mobile_presensi_kdtg/core.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_presensi_kdtg/components/rounded_password_field.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  List users = [];
  bool isLoading = false;
  String? error;
  
  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> fetchUser() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      var response = await http.get(
        Uri.parse(Core().ApiUrl + "Kampus/get_list"),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 10)); // Tambahkan timeout
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (!mounted) return;
      
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        
        // Validasi struktur response
        if (jsonData != null && jsonData['data'] != null) {
          var items = jsonData['data'];
          setState(() {
            users = List.from(items); // Pastikan ini adalah List yang valid
            isLoading = false;
            error = null;
          });
        } else {
          setState(() {
            users = [];
            isLoading = false;
            error = "Format data tidak valid";
          });
        }
      } else {
        setState(() {
          users = [];
          isLoading = false;
          error = "Server error: ${response.statusCode}";
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      if (!mounted) return;
      
      setState(() {
        users = [];
        isLoading = false;
        error = "Gagal memuat data: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: getBody(),
    );
  }

  Widget getBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
            ),
            SizedBox(height: 16),
            Text('Memuat data kampus...'),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchUser,
              child: Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Tidak ada data kampus',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchUser,
              child: Text('Muat Ulang'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchUser,
      child: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return getCard(users[index]);
        },
      ),
    );
  }

  Widget getCard(item) {
    if (item == null) return SizedBox.shrink();
    
    String namaKampus = item['nama_kampus']?.toString() ?? 'Nama Kampus Tidak Tersedia';
    String idKampus = item['idkampus']?.toString() ?? '';
    
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListTile(
          leading: Image.asset(
            "assets/images/all_menu.png",
            height: 60,
            width: 60,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.school,
                size: 60,
                color: kPrimaryColor,
              );
            },
          ),
          title: Text(
            namaKampus,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text('ID: $idKampus'),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () => _selectKampus(item),
        ),
      ),
    );
  }

  Future<void> _selectKampus(item) async {
    try {
      // Validasi data yang diperlukan
      if (item['nama_kampus'] == null || 
          item['idkampus'] == null ||
          item['latitude'] == null || 
          item['longtitude'] == null || 
          item['radius'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data kampus tidak lengkap'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      // Simpan data ke SharedPreferences dengan error handling
      await prefs.setString("Lokasi", item['nama_kampus'].toString());
      await prefs.setString("idKampus", item['idkampus'].toString());
      
      // Parse koordinat dengan error handling
      try {
        double lat = double.parse(item['latitude'].toString());
        double lng = double.parse(item['longtitude'].toString());
        double radius = double.parse(item['radius'].toString());
        
        await prefs.setDouble("LokasiLat", lat);
        await prefs.setDouble("LokasiLng", lng);
        await prefs.setDouble("Radius", radius);
      } catch (e) {
        print('Error parsing coordinates: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error dalam data koordinat kampus'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Panggil API dengan error handling
      try {
        await LokasiKampusPost.connectToApi(item['idkampus'].toString());
        
        if (!mounted) return;
        
        // Navigate ke dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      } catch (e) {
        print('Error connecting to API: $e');
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghubungkan ke server'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error in _selectKampus: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan saat memilih kampus'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}