import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:epresensi_esolusindo/Screens/Absen/absen_post.dart';
import 'package:epresensi_esolusindo/Screens/Absen/absen_selesai_post.dart';
import 'package:epresensi_esolusindo/Screens/dashboard_screen.dart';
import 'package:epresensi_esolusindo/components/rounded_button_small.dart';
import 'package:epresensi_esolusindo/constants.dart';
import 'package:epresensi_esolusindo/core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:epresensi_esolusindo/services/location_services.dart';

class AbsenSelesaiWFScreen extends StatefulWidget {
  const AbsenSelesaiWFScreen({super.key});

  @override
  _AbsenSelesaiWFScreenState createState() => _AbsenSelesaiWFScreenState();
}

class _AbsenSelesaiWFScreenState extends State<AbsenSelesaiWFScreen> {
  final AbsenPost absenPost = AbsenPost();

  late GoogleMapController _controller;
  double la_polije = -8.1594718;
  double lo_polije = 113.720271;
  double Jarak = 0;
  bool _isMockLocation = false;
  double la = 0;
  double lo = 0;
  int statusLoading = 0;
  String NIP = "", Nama = "", UUID = "";
  bool ssHeader = false;

  var DataPegawai;

  @override
  void initState() {
    super.initState();
    getPref();
    getCurrentLocation();
  }

  Future<void> getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    UUID = prefs.getString("ID") ?? "";
    NIP = prefs.getString("NIP") ?? "";
    Nama = prefs.getString("Nama") ?? "";
    
    if (prefs.getDouble("LokasiLat") != null &&
        prefs.getDouble("LokasiLat")! > 0) {
      la_polije = prefs.getDouble("LokasiLat")!;
      lo_polije = prefs.getDouble("LokasiLng")!;
    }
    print("Login Pref: $UUID");
    getDataDash();
  }

  Future<String> getDataDash() async {
    try {
      if (UUID.isEmpty) {
        print("Error: UUID tidak ditemukan");
        return "";
      }

      var res = await http.get(
        Uri.parse("${Core().ApiUrl}Dash/get_dash/$UUID"),
        headers: {"Accept": "application/json"}
      ).timeout(Duration(seconds: 30));
      
      print("Status Code: ${res.statusCode}");
      print("Response Body: ${res.body}");
      
      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        setState(() {
          DataPegawai = resBody['data']["pegawai"];
        });
        print("Data Pegawai: $DataPegawai");
        print("ID Absen: ${DataPegawai?['idabsen']}");
      }
    } catch (e) {
      print("Error getting dash data: $e");
    }
    return "";
  }

  Future<dynamic> getCurrentLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("sl_wfh_selesai") ?? false) {
      _showPerizinan();
    }
    
    _isMockLocation = await LocationService.isMockLocation;
    print("fake GPS: $_isMockLocation");

    bool serviceEnabled;
    LocationPermission permission;

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
      Jarak = Geolocator.distanceBetween(la, lo, la_polije, lo_polije);
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
      
      // Container untuk info selesai WFH
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
                          Text(
                            (DataPegawai != null && DataPegawai['idabsen'] != null) 
                                ? "Sesi WFH Aktif" 
                                : "Tidak Ada Sesi WFH",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: (DataPegawai != null && DataPegawai['idabsen'] != null) 
                                    ? Colors.green 
                                    : Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            (DataPegawai != null && DataPegawai['idabsen'] != null)
                                ? "Siap untuk mengakhiri Work From Home"
                                : "Tidak ada sesi WFH yang sedang berjalan",
                            style: TextStyle(
                                fontSize: 14,
                                color: (DataPegawai != null && DataPegawai['idabsen'] != null) 
                                    ? Colors.green 
                                    : Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )))),
      
      // Button Selesai WFH
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
                        text: "SELESAI WFH",
                        width: size.width * 0.9,
                        color: (DataPegawai != null && DataPegawai['idabsen'] != null)
                            ? Colors.green
                            : Colors.blueGrey,
                        press: () async {
                          setState(() {
                            statusLoading = 1;
                          });
                          
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          
                          // Cek apakah ada sesi WFH aktif
                          if (DataPegawai == null || DataPegawai['idabsen'] == null) {
                            _showMyDialog("Error", "Tidak ada sesi WFH yang sedang berjalan. Silakan mulai WFH terlebih dahulu.");
                            setState(() {
                              statusLoading = 0;
                            });
                            return;
                          }
                          
                          if (prefs.getInt("status_spesial") == 1) {
                            // Status spesial - langsung selesai tanpa validasi tambahan
                            AbsenSelesaiPost.connectToApiNoPhoto(
                                    prefs.getString("ID")!,
                                    DataPegawai['idabsen'],
                                    la.toString(),
                                    lo.toString())
                                .then((value) {
                              if (value!.status_kode == 200) {
                                _showMyDialogSuccess("WFH Selesai", "Anda telah berhasil menyelesaikan Work From Home hari ini.");
                              } else {
                                _showMyDialog("Selesai WFH", value.message);
                              }
                              setState(() {
                                statusLoading = 0;
                              });
                            });
                          } else {
                            _isMockLocation = await LocationService.isMockLocation;
                            print("fake GPS: $_isMockLocation");
                            print("Lokasi: $la -- $lo");
                            
                            if (_isMockLocation == true) {
                              _showMyDialogFake();
                              setState(() {
                                statusLoading = 0;
                              });
                            } else {
                              // WFH tidak memerlukan validasi jarak seperti presensi harian
                              // Langsung proses selesai WFH
                              AbsenSelesaiPost.connectToApiNoPhoto(
                                      prefs.getString("ID")!,
                                      DataPegawai['idabsen'],
                                      la.toString(),
                                      lo.toString())
                                  .then((value) {
                                if (value!.status_kode == 200) {
                                  _showMyDialogSuccess("WFH Selesai", "Anda telah berhasil menyelesaikan Work From Home hari ini.");
                                } else {
                                  _showMyDialog("Selesai WFH", value.message);
                                }
                                setState(() {
                                  statusLoading = 0;
                                });
                              }).catchError((error) {
                                print("API Error: $error");
                                setState(() {
                                  statusLoading = 0;
                                });
                                _showMyDialog("Error", "Terjadi kesalahan koneksi. Silakan coba lagi.");
                              });
                            }
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
              backgroundColor: Colors.green,
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
                child: const Text('Oke'),
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
                  Navigator.of(context).pop();
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
                      "Aplikasi ini mengumpulkan data lokasi untuk mengaktifkan Selesai WFH."),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setBool("sl_wfh_selesai", false);
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