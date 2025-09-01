// import 'package:mobile_presensi_kdtg/circular_profile_avatar.dart';
import 'dart:convert';

import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:mobile_presensi_kdtg/Screens/Login/login_screen.dart';
import 'package:mobile_presensi_kdtg/Screens/Login/post_logout.dart';
import 'package:mobile_presensi_kdtg/Screens/Profil/foto_profil.dart';
import 'package:mobile_presensi_kdtg/constants.dart';
import 'package:mobile_presensi_kdtg/core.dart';
import 'package:mobile_presensi_kdtg/utils/custom_clipper.dart';
import 'package:mobile_presensi_kdtg/widgets/top_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfilUser extends StatefulWidget {
  @override
  _ProfilUserState createState() => _ProfilUserState();
}

class _ProfilUserState extends State<ProfilUser> {
  String UUID = "";
  String NamaPegawai = "Nama Pegawai";
  String NIP = "-";
  String Foto = "desain/POLIJE_mini.png";
  String Email = "", Unit = "";
  var DataPegawai;
  int jmlPre = 0, jmlCuti = 0, jmlKegiatan = 0;
  int statusLoading = 0;

  @override
  void initState() {
    // TODO: implement initState
    // WidgetsBinding.instance.addPostFrameCallback(getPref());
    super.initState();
    getDataDash();
  }

  Future<String> getDataDash() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    UUID = prefs.getString("ID")!;
    var res = await http.get(Uri.parse(Core().ApiUrl + "Dash/get_dash/" + UUID),
        headers: {"Accept": "application/json"});
    var resBody = json.decode(res.body);
    setState(() {
      DataPegawai = resBody['data']["pegawai"];
      jmlCuti = resBody['data']['jmlCutiBln'];
      jmlKegiatan = resBody['data']['jmlKegiatanBln'];
      jmlPre = resBody['data']['jmlPresensiBln'];
      NamaPegawai = DataPegawai["nama_pegawai"];
      NIP = DataPegawai["NIP"];
      Email = DataPegawai["email"];
      Unit = DataPegawai["unit"];
      Foto = DataPegawai["foto_profil"];
    });
    print(resBody);
    return "";
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      // Background gradient
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFE9ECEF),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // Header tak besarin
              Container(
                height: 320.0, // Tinggi tambah 20
                width: size.width,
                child: Stack(
                  children: <Widget>[
                    Container(),
                    ClipPath(
                      clipper: MyCustomClipper(),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color.fromARGB(234, 14, 100, 230), // Biru tua
                              Color.fromARGB(223, 56, 143, 230),
                              Color.fromARGB(255, 122, 182, 231),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.apartment_rounded,
                                size: 64,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Kantor",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment(0, 1),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          // Profile avatar shadow overlay
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return Foto_Profil();
                                }));
                              },
                              child: CircularProfileAvatar(
                                Core().Url + Foto,
                                borderWidth: 6.0, // Border dibesarin
                                borderColor: Colors.white,
                                radius: 65.0, // Radius dibesarin sedikit
                              ),
                            ),
                          ),
                          SizedBox(height: 12.0),
                          //
                          Text(
                            NamaPegawai,
                            style: TextStyle(
                              fontSize: 24.0, // Font size dibesarin
                              fontWeight: FontWeight.w800, // Weight diperberat
                              color: Colors.black87,
                              shadows: [
                                Shadow(
                                    blurRadius: 4,
                                    color: Colors.white.withOpacity(0.8),
                                    offset: Offset(0, 1)),
                              ],
                            ),
                          ),
                          SizedBox(height: 6.0),
                          // NIP dengan background chip
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              NIP,
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Card informasi
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    //  informasi personal
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 12),
                        child: Text(
                          'Informasi Personal',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    _ModernCartItem("Email", Email, Icons.mail_outline_rounded,
                        kPrimaryColor),
                    _ModernCartItem("Unit", Unit, Icons.location_city_rounded,
                        kPrimaryColor),

                    SizedBox(height: 24),

                    //  statistik bulanan
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 12),
                        child: Text(
                          'Statistik Bulan Ini',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),

                    // Card statistik
                    _ModernCartItem("Jumlah Presensi", jmlPre.toString(),
                        Icons.alarm_on_outlined, kPrimaryColor),

                    _ModernCartItem("Jumlah Kegiatan", jmlKegiatan.toString(),
                        Icons.directions_walk_outlined, kPrimaryColor),

                    _ModernCartItem("Jumlah Cuti", jmlCuti.toString(),
                        Icons.home_work_rounded, kPrimaryColor),
                  ],
                ),
              ),

              SizedBox(height: 40), //
            ],
          ),
        ),
      ),
    );
  }

  // Desain card modern untuk informasi personal
  Container _ModernCartItem(
      String title, String value, IconData iconData, Color iconColor) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0), //
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08), //
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0), // P
        child: Row(
          children: <Widget>[
            //
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                size: 24.0,
                color: iconColor,
              ),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    value.isEmpty ? "-" : value,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //
  Container _cartItem(String title, String number, String unit,
      IconData iconData, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.8),
                    color.withOpacity(0.6),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                iconData,
                size: 26.0,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    textBaseline: TextBaseline.alphabetic,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    children: [
                      Text(
                        number,
                        style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        unit,
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method lama untuk referensi (tidak dipakai di desain baru)
  Container _CartItem(String Title, String Ket, Icon _icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 4,
            offset: Offset(4, 4), // Shadow position
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 21.0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _icon,
            SizedBox(width: 24.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  Ket,
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4.0),
                Text(
                  Title,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
