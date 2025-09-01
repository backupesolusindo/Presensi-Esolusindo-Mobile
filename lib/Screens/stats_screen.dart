import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/material.dart';
import 'package:mobile_presensi_kdtg/config/palette.dart';
import 'package:mobile_presensi_kdtg/config/styles.dart';
import 'package:mobile_presensi_kdtg/constants.dart';
import 'package:mobile_presensi_kdtg/data/data.dart';
import 'package:mobile_presensi_kdtg/widgets/widgets.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: CBackground,
        // appBar: CustomAppBar(),
        body: Stack(
          children: [
            // Positioned(
            //   top: 0,
            //   right: 0,
            //   child: Image.asset(
            //     "assets/images/dash_tr.png",
            //     height: size.height * 0.4,
            //   ),
            // ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Image.asset(
                "assets/images/vector_kecil_kanan.png",
                height: size.height * 0.4,
                width: size.width,
                fit: BoxFit.fill,
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: Image.asset(
                "assets/images/main_top.png",
                color: Colors.blue[200],
                height: size.height * 0.4,
                width: size.width,
                fit: BoxFit.fill,
              ),
            ),
            CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: <Widget>[
                _buildHeader(),
                const SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  sliver: SliverToBoxAdapter(
                    child: StatsGrid(),
                  ),
                ),
                // SliverPadding(
                //   padding: const EdgeInsets.only(top: 20.0),
                //   sliver: SliverToBoxAdapter(
                //     child: CovidBarChart(covidCases: covidUSADailyNewCases),
                //   ),
                // ),
              ],
            )
          ],
        ));
  }

  SliverPadding _buildHeader() {
    return const SliverPadding(
      padding: EdgeInsets.only(
          left: 20.0, right: 20.0, bottom: 20.0, top: 40.0),
      sliver: SliverToBoxAdapter(
        child: Text(
          'Statistik Presensi',
          style: TextStyle(
            color: CText,
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
