import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:epresensi_esolusindo/Screens/Absen/absen_post.dart';
import 'package:epresensi_esolusindo/Screens/dashboard_screen.dart';
import 'package:epresensi_esolusindo/components/rounded_button_small.dart';
import 'package:epresensi_esolusindo/constants.dart';
import 'package:epresensi_esolusindo/core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:epresensi_esolusindo/services/location_services.dart';

class AbsenWFScreen extends StatefulWidget {
  const AbsenWFScreen({super.key});

  @override
  _AbsenWFScreenState createState() => _AbsenWFScreenState();
}

class _AbsenWFScreenState extends State<AbsenWFScreen> {
  final AbsenPost absenPost = AbsenPost();

  late GoogleMapController _controller;
  double la_polije = -8.1594718;
  double lo_polije = 113.720271;
  double Jarak = 0;
  bool _isMockLocation = false;
  double la = 0;
  double lo = 0;
  int statusLoading = 0;
  late String Nama = "", NIP = "", JamMasuk = "", idJadwal = "";
  late SharedPreferences prefs;
  bool ssHeader = false;

  List DataJadwal = List.empty();

  @override
  void initState() {
    super.initState();
    getDataPegawai();
    getCurrentLocation();
  }

  Future<void> getDataPegawai() async {
    try {
      prefs = await SharedPreferences.getInstance();
      String? UUID = prefs.getString("ID");
      
      if (UUID == null || UUID.isEmpty) {
        print("Error: UUID tidak ditemukan");
        setState(() {
          DataJadwal = [];
        });
        return;
      }
      
      print("UUID: $UUID");
      
      // PERBAIKAN 1: Tambahkan timeout dan error handling yang lebih baik
      var res = await http.get(
        Uri.parse("${Core().ApiUrl}Dash/set_jadwal_WFH/$UUID"),
        headers: {"Accept": "application/json"}
      ).timeout(Duration(seconds: 30)); // Tambahkan timeout
      
      print("Status Code: ${res.statusCode}");
      print("Response Body: ${res.body}");
      
      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        print("Full Response: $resBody");
        
        setState(() {
          // PERBAIKAN 2: Cek response structure sesuai dengan API PHP
          if (resBody != null && 
              resBody['data'] != null && 
              resBody['data']["jadwal"] != null) {
            
            // Pastikan jadwal adalah List
            if (resBody['data']["jadwal"] is List) {
              DataJadwal = resBody['data']["jadwal"];
            } else {
              // Jika bukan list, mungkin object tunggal, buat jadi list
              DataJadwal = [resBody['data']["jadwal"]];
            }
            
            // Set nilai default jika ada data
            if (DataJadwal.isNotEmpty) {
              // PERBAIKAN 3: Gunakan null safety yang lebih baik
              var firstSchedule = DataJadwal[0];
              JamMasuk = firstSchedule['jam_masuk']?.toString() ?? "";
              idJadwal = firstSchedule['idjadwal_masuk']?.toString() ?? "";
              
              print("JamMasuk: $JamMasuk");
              print("idJadwal: $idJadwal");
            } else {
              JamMasuk = "";
              idJadwal = "";
              print("DataJadwal kosong dari API");
            }
          } else {
            DataJadwal = [];
            JamMasuk = "";
            idJadwal = "";
            print("Struktur response tidak sesuai");
          }
          
          // PERBAIKAN 4: Cek juga response message
          if (resBody['message'] != null && resBody['message']['status'] != 200) {
            print("API Error: ${resBody['message']['message']}");
            // Tampilkan error message ke user
            _showMyDialog("Error", resBody['message']['message'] ?? "Terjadi kesalahan");
          }
        });
      } else {
        print("Error: Status code ${res.statusCode}");
        setState(() {
          DataJadwal = [];
        });
        // PERBAIKAN 5: Tampilkan error ke user
        _showMyDialog("Error", "Gagal mengambil data jadwal. Status: ${res.statusCode}");
      }
    } on SocketException {
      // PERBAIKAN 6: Handle network errors
      print("Error: No internet connection");
      setState(() {
        DataJadwal = [];
      });
      _showMyDialog("Error", "Tidak ada koneksi internet. Periksa koneksi Anda.");
    } on FormatException {
      // Handle JSON parsing errors
      print("Error: Invalid JSON format");
      setState(() {
        DataJadwal = [];
      });
      _showMyDialog("Error", "Format data tidak valid.");
    } catch (e) {
      print("Error getting data pegawai: $e");
      setState(() {
        DataJadwal = [];
      });
      _showMyDialog("Error", "Terjadi kesalahan: $e");
    }
  }

  Future<dynamic> getCurrentLocation() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("sl_wfh_mulai") ?? false) {
      _showPerizinan();
    }
    
    _isMockLocation = await LocationService.isMockLocation;
    print("fake GPS :");
    print(_isMockLocation);

    Nama = prefs.getString("Nama") ?? "";
    NIP = prefs.getString("NIP") ?? "";
    
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    
    final geoposition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      la = geoposition.latitude;
      lo = geoposition.longitude;
      ssHeader = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: Stack(children: <Widget>[
      if (!ssHeader)
        const Center(
          child: CircularProgressIndicator(),
        ),
      if (ssHeader)
        GoogleMap(
          myLocationEnabled: true,
          initialCameraPosition: CameraPosition(
            target: LatLng(la, lo),
            zoom: 16.0,
          ),
          markers: <Marker>{
            Marker(
              markerId: const MarkerId('marker_1'),
              position: LatLng(la, lo),
              consumeTapEvents: true,
              infoWindow: const InfoWindow(
                title: 'Lokasi Anda',
                snippet: "Presensi WFH Anda",
              ),
              onTap: () {
                print("Marker tapped");
              },
            ),
          },
          mapType: MapType.hybrid,
          polygons: <Polygon>{
            Polygon(
                polygonId: const PolygonId("Area Polije"),
                points: const <LatLng>[
                  LatLng(-8.159848, 113.720521),
                  LatLng(-8.161228, 113.723176),
                  LatLng(-8.160425, 113.723687),
                  LatLng(-8.161215, 113.725171),
                  LatLng(-8.154612, 113.725997),
                  LatLng(-8.153624, 113.723426),
                ],
                strokeWidth: 2,
                strokeColor: Colors.blue,
                fillColor: Colors.blue.withOpacity(0.1))
          },
          onTap: (location) => print('onTap: $location'),
          onCameraMove: (cameraUpdate) => print('onCameraMove: $cameraUpdate'),
          compassEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            _controller = controller;
            Future.delayed(const Duration(seconds: 2)).then(
              (_) {
                controller.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      bearing: 0,
                      target: LatLng(la, lo),
                      tilt: 30.0,
                      zoom: 18,
                    ),
                  ),
                );
                controller
                    .getVisibleRegion()
                    .then((bounds) => print("bounds: ${bounds.toString()}"));
              },
            );
          },
        ),
      
      // Header dengan info pegawai
      Positioned(
          child: AnimatedOpacity(
        opacity: ssHeader ? 1 : 0,
        duration: const Duration(milliseconds: 500),
        child: AnimatedContainer(
          padding: const EdgeInsets.only(
              left: 20.0, right: 20.0, bottom: 10.0, top: 40.0),
          margin: ssHeader ? const EdgeInsets.only(top: 0) : const EdgeInsets.only(top: 30),
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastEaseInToSlowEaseOut,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    width: size.width,
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.white70,
                          blurRadius: 4,
                          offset: Offset(2, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          Nama,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: CText),
                        ),
                        Text(
                          (NIP == "") ? "-" : NIP,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: CText),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Work From Home",
                          style: TextStyle(
                            fontSize: 14, 
                            color: CSuccess,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      )),
      
      // Container untuk dropdown jadwal
      Positioned(
          bottom: 80,
          width: size.width,
          child: AnimatedOpacity(
              opacity: ssHeader ? 1 : 0,
              duration: const Duration(milliseconds: 500),
              child: AnimatedContainer(
                  margin: ssHeader
                      ? const EdgeInsets.only(bottom: 0)
                      : const EdgeInsets.only(bottom: 30),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.fastEaseInToSlowEaseOut,
                  child: Container(
                    margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.white70,
                          blurRadius: 4,
                          offset: Offset(2, 4),
                        ),
                      ],
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: <Widget>[
                          const Text(
                            "Pilih Jadwal Work From Home",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: CSuccess),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            child: DataJadwal.isNotEmpty
                                ? DropdownButton(
                                    hint: const Text("Jadwal Kerja : ",
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black)),
                                    dropdownColor: Colors.white,
                                    icon: const Icon(Icons.arrow_drop_down),
                                    iconSize: 24,
                                    isExpanded: true,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 12),
                                    items: DataJadwal.map<DropdownMenuItem<String>>((item) {
                                      return DropdownMenuItem<String>(
                                        value: item['idjadwal_masuk']?.toString() ?? "",
                                        child: Text(
                                          "${item['nama'] ?? 'Jadwal Tidak Tersedia'} (${item['jam_masuk'] ?? ''} - ${item['jam_pulang'] ?? ''})", 
                                          style: const TextStyle(fontSize: 12)
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (newVal) {
                                      setState(() {
                                        idJadwal = newVal as String;
                                        // PERBAIKAN 7: Cari jadwal yang sesuai dengan lebih aman
                                        try {
                                          var selectedSchedule = DataJadwal.firstWhere(
                                            (item) => item['idjadwal_masuk'].toString() == idJadwal
                                          );
                                          JamMasuk = selectedSchedule['jam_masuk']?.toString() ?? "";
                                          print("Selected Jam: $JamMasuk");
                                        } catch (e) {
                                          print("Error finding schedule: $e");
                                          JamMasuk = "";
                                        }
                                      });
                                    },
                                    value: (idJadwal.isEmpty) ? null : idJadwal,
                                  )
                                : const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16.0),
                                    child: Text(
                                      "Tidak ada jadwal WFH tersedia",
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ),
                          ),
                          // PERBAIKAN 8: Tambahkan tombol refresh
                          if (DataJadwal.isEmpty)
                            ElevatedButton(
                              onPressed: () {
                                getDataPegawai();
                              },
                              child: const Text("Refresh Jadwal"),
                            ),
                        ],
                      ),
                    ),
                  )))),
      
      // Button Mulai WFH
      Positioned(
          bottom: 20,
          width: size.width,
          child: AnimatedOpacity(
              opacity: ssHeader ? 1 : 0,
              duration: const Duration(milliseconds: 500),
              child: AnimatedContainer(
                margin: ssHeader
                    ? const EdgeInsets.only(bottom: 0)
                    : const EdgeInsets.only(bottom: 30),
                duration: const Duration(milliseconds: 500),
                curve: Curves.fastEaseInToSlowEaseOut,
                child: (statusLoading == 1)
                    ? const Center(child: CircularProgressIndicator())
                    : RoundedButtonSmall(
                        text: "MULAI WFH",
                        width: size.width * 0.9,
                        color: DataJadwal.isNotEmpty && idJadwal.isNotEmpty
                            ? kPrimaryColor
                            : Colors.blueGrey,
                        press: () async {
                          if (idJadwal.isEmpty) {
                            _showMyDialog("Error", "Silakan pilih jadwal kerja terlebih dahulu");
                            return;
                          }
                          
                          setState(() {
                            statusLoading = 1;
                          });
                          
                          _isMockLocation = await LocationService.isMockLocation;
                          print("fake GPS :");
                          print(_isMockLocation);
                          
                          if (_isMockLocation == true) {
                            _showMyDialogFake();
                            setState(() {
                              statusLoading = 0;
                            });
                          } else {
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            
                            // Panggil API tanpa parameter image
                            AbsenPost.connectToApiNoPhoto(
                                    prefs.getString("ID")!,
                                    la.toString(),
                                    lo.toString(),
                                    "4",
                                    "2",
                                    idJadwal,
                                    JamMasuk)
                                .then((value) {
                              if (value!.status_kode == 200) {
                                _showMyDialogSuccess("WFH Berhasil", "Anda sudah berhasil memulai Work From Home.");
                              } else {
                                _showMyDialog("Absensi WFH", value.message);
                              }
                              setState(() {
                                statusLoading = 0;
                              });
                            });
                          }
                        },
                      ),
              ))),
      
      // Floating Action Button untuk refresh lokasi
      Positioned(
          bottom: size.height * 0.24,
          right: 8,
          child: SizedBox(
            width: 50,
            child: FloatingActionButton(
              onPressed: () {
                getCurrentLocation();
                _controller.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      bearing: 0,
                      target: LatLng(la, lo),
                      tilt: 30.0,
                      zoom: 18,
                    ),
                  ),
                );
                _controller
                    .getVisibleRegion()
                    .then((bounds) => print("bounds: ${bounds.toString()}"));
              },
              backgroundColor: kPrimaryColor,
              child: const Icon(Icons.my_location),
            ),
          ))
    ]));
  }

  Future<void> _showMyDialog(String Title, String Keterangan) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: AlertDialog(
            title: Text(Title),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(Keterangan),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showMyDialogFake() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: AlertDialog(
            title: const Text("FAKE GPS"),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text("HARAP UNINSTALL FAKE GPS ANDA !!!"),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Keluar'),
                onPressed: () {
                  exit(0);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // FUNGSI BARU UNTUK DIALOG SUKSES
  Future<void> _showMyDialogSuccess(String title, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(message),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Oke'),
                onPressed: () {
                  // Tutup dialog terlebih dahulu
                  Navigator.of(context).pop();
                  // Kemudian navigasi ke Dashboard
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return const DashboardScreen();
                  }));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showPerizinan() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: AlertDialog(
            title: const Text("PERIZINAN AKSES LOKASI"),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      "Aplikasi ini mengumpulkan data lokasi untuk mengaktifkan Mulai WFH."),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setBool("sl_wfh_mulai", false);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}