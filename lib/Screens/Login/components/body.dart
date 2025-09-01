import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mobile_presensi_kdtg/Screens/Absen/absen_screen.dart';
import 'package:mobile_presensi_kdtg/Screens/Login/components/background.dart';
import 'package:mobile_presensi_kdtg/Screens/Login/post_login.dart';
import 'package:mobile_presensi_kdtg/Screens/dashboard_screen.dart';
import 'package:mobile_presensi_kdtg/Screens/screens.dart';
import 'package:mobile_presensi_kdtg/components/already_have_an_account_acheck.dart';
import 'package:mobile_presensi_kdtg/components/rounded_button.dart';
import 'package:mobile_presensi_kdtg/components/rounded_input_field.dart';
import 'package:mobile_presensi_kdtg/components/rounded_password_field.dart';
import 'package:flutter_svg/svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trust_location/trust_location.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  _Body createState() => _Body();
}

class _Body extends State<Body> {
  PostLogin postLogin = PostLogin();
  String pesan = "";
  final txtUsername = TextEditingController();
  final txtPassword = TextEditingController();
  String token = "123";
  int statusLoading = 0;

  @override
  void initState() {
    super.initState();
    cekFakeGPS();
    getToken();
  }

  cekFakeGPS() async {
    bool isMockLocation = await TrustLocation.isMockLocation;
    print("fake GPS :");
    print(isMockLocation);
  }

  void getToken() async {
    token = (await FirebaseMessaging.instance.getToken())!;
  }

  @override
Widget build(BuildContext context) {
  Size size = MediaQuery.of(context).size;
  return Background(
    child: Center(
      child: SingleChildScrollView(
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.asset(
                  "assets/images/logo_esolusindo.png",
                  width: size.width * 0.3,
                ),
                SizedBox(height: size.height * 0.03),
                const Text(
                  "HALAMAN LOGIN",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: size.height * 0.03),
                RoundedInputField(
                  hintText: "NIP / NIK atau SSO Email Anda",
                  IdCon: txtUsername,
                  onChanged: (String value) {},
                ),
                RoundedPasswordField(
                  IdCon: txtPassword,
                  hintText: "Password",
                ),
                Text(
                  pesan,
                  style: TextStyle(
                    color: Colors.redAccent.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 10),
                if (statusLoading == 1)
                  const CircularProgressIndicator()
                else
                  RoundedButton(
                    text: "LOGIN",
                    press: () async {
                      setState(() {
                        pesan = "Tunggu Sedang Proses";
                        statusLoading = 1;
                      });
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      token = "1231";
                      prefs.setString("token", token);
                      PostLogin.connectToApi(
                              txtUsername.text, txtPassword.text, token)
                          .then((value) {
                        setState(() {
                          pesan = value!.message;
                          statusLoading = 0;
                        });
                        if (value!.status_kode == 200) {
                          prefs.setBool("status_login", true);
                          prefs.setBool("sl_harian_masuk", true);
                          prefs.setBool("sl_harian_pulang", true);
                          prefs.setBool("sl_istirahat_keluar", true);
                          prefs.setBool("sl_istirahat_masuk", true);
                          prefs.setBool("sl_wfh_mulai", true);
                          prefs.setBool("sl_wfh_selesai", true);
                          prefs.setBool("sl_lokasi", true);
                          prefs.setBool("sl_kegiatan", true);
                          prefs.setBool("status_lokasi", true);
                          prefs.setString("ID", value.UUID);
                          prefs.setString("NIP", value.NIP);
                          prefs.setString("Nama", value.Pegawai);
                          prefs.setString("idKampus", value.IDKampus);
                          prefs.setString("Lokasi", value.NamaKampus);
                          prefs.setDouble("LokasiLat",
                              double.parse(value.LokasiLat));
                          prefs.setDouble("LokasiLng",
                              double.parse(value.LokasiLng));
                          prefs.setDouble(
                              "Radius", double.parse(value.Radius));
                          prefs.setInt("status_spesial",
                              int.parse(value.status_spesial));
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.fade,
                              child: const DashboardScreen(),
                            ),
                          );
                        }
                      });
                    },
                  ),
//                   RoundedButton(
//   text: "LOGIN",
//   press: () {
//     // Tampilkan pesan loading (opsional)
//     setState(() {
//       pesan = "Tunggu Sedang Proses";
//       statusLoading = 1;
//     });

//     // Tutup dialog jika ada
//     Navigator.of(context).pop();

//     // Pindah ke DashboardScreen
//     Navigator.push(
//       context,
//       PageTransition(
//         type: PageTransitionType.fade,
//         child: DashboardScreen(),
//       ),
//     );
//   },
// ),

              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}
