import 'dart:io';
import 'dart:ui';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobile_presensi_kdtg/Screens/Profil/upload_post.dart';
import 'package:mobile_presensi_kdtg/Screens/dashboard_screen.dart';
import 'package:mobile_presensi_kdtg/components/rounded_button_small.dart';
import 'package:mobile_presensi_kdtg/constants.dart';
import 'package:mobile_presensi_kdtg/core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Foto_Profil extends StatefulWidget {
  const Foto_Profil({super.key});

  @override
  _Foto_ProfilState createState() => _Foto_ProfilState();
}

class _Foto_ProfilState extends State<Foto_Profil> {
  File? _image; // <-- diganti dari late File _image;
  final picker = ImagePicker();
  late String UUID;
  String NamaPegawai = "Nama Pegawai";
  String NIP = "-";
  String Foto = "desain/POLIJE_mini.png";
  String Email = "", Unit = "";
  dynamic DataPegawai;

  @override
  void initState() {
    super.initState();
    getDataDash();
  }

  Future<String> getDataDash() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    UUID = prefs.getString("ID")!;
    var res = await http.get(
      Uri.parse("${Core().ApiUrl}Dash/get_dash/$UUID"),
      headers: {"Accept": "application/json"},
    );
    var resBody = json.decode(res.body);

    // cek struktur response
    if (resBody['data'] is List && (resBody['data'] as List).isEmpty) {
      // data kosong
      print("Data kosong: ${resBody['message']}");
      setState(() {
        NamaPegawai = "Gagal memuat";
        NIP = "-";
        Email = "";
        Unit = "";
        Foto = "desain/POLIJE_mini.png";
      });
    } else {
      var data = resBody['data'];
      if (data is String) data = json.decode(data);

      if (data is Map && data.containsKey('pegawai')) {
        DataPegawai = data['pegawai'];
        setState(() {
          NamaPegawai = DataPegawai['nama_pegawai'] ?? "Nama Pegawai";
          NIP = DataPegawai['NIP'] ?? "-";
          Email = DataPegawai['email'] ?? "";
          Unit = DataPegawai['unit'] ?? "";
          Foto = DataPegawai['foto_profil'] ?? "desain/POLIJE_mini.png";
        });
      }
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final image = _image; // local variable agar bisa dipromosikan
    return Container(
      color: Colors.white,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              "assets/images/blob_left.png",
              width: size.width * 0.35,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset(
              "assets/images/blob_right.png",
              width: size.width * 0.35,
            ),
          ),
          Column(
            children: [
              SizedBox(height: size.height * 0.15),
              const Text(
                "Upload Foto Profil Anda yang Baru, "
                "Dengan cara klik foto profil Anda, Pilih Foto dan Upload",
                style: TextStyle(
                  fontSize: 18.0,
                  color: kDarkPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _show,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                  child: image == null
                      ? Image.network(
                          Core().Url + Foto,
                          width: size.width * 0.8,
                          height: size.width * 0.8,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image, size: 100),
                        )
                      : Image.file(
                          image,
                          width: size.width * 0.8,
                          height: size.width * 0.8,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 4, top: 8),
                child: RoundedButtonSmall(
                  text: "UPLOAD FOTO",
                  color: kPrimaryColor,
                  press: () async {
                    if (image == null) {
                      _showMyDialog(
                        "Upload Foto Profil",
                        "Pilih Foto terlebih dahulu dengan cara klik foto profil Anda",
                      );
                      return;
                    }
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    UploadPost.connectToApi(
                      prefs.getString("ID")!,
                      image, // <-- sudah non-nullable karena dicek di atas
                    ).then((value) {
                      if (value?.status_kode == 200) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DashboardScreen(),
                          ),
                        );
                      } else {
                        _showMyDialog("Upload Foto Profil", value?.message ?? "");
                      }
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 4, top: 32),
                child: RoundedButtonSmall(
                  text: "Kembali",
                  color: ColorLight,
                  press: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      maxHeight: 380,
      maxWidth: 540,
    );
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    } else {
      print('No image selected.');
    }
  }

  Future<void> getFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _image = File(result.files.single.path!));
    } else {
      print('No image selected.');
    }
  }

  Future<void> _show() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: AlertDialog(
          title: const Text("UPLOAD IMAGE"),
          content: const SingleChildScrollView(
            child: ListBody(children: [
              Text("Pilih File Dari Sumber?"),
            ]),
          ),
          actions: [
            TextButton(
              child: const Text('CAMERA'),
              onPressed: () async {
                Navigator.pop(context);
                await getImage();
              },
            ),
            TextButton(
              child: const Text('GALLERY'),
              onPressed: () async {
                Navigator.pop(context);
                await getFile();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMyDialog(String title, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(children: [Text(message)]),
          ),
          actions: [
            TextButton(
              child: const Text('Keluar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}