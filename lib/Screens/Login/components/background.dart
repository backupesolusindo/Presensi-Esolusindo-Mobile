import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final Widget child;
  const Background({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      height: size.height,
      color: Colors.blue[700],
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              "assets/images/blob_left.png",
              width: size.width * 0.5,
              color: Colors.blue[600],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/images/vector_kecil_kanan.png",
              width: size.width * 0.5,
              fit: BoxFit.cover,
            ),
          ),
          child,
        ],
      ),
    );
  }
}