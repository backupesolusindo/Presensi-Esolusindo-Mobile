import 'package:flutter/material.dart';
import 'package:mobile_presensi_kdtg/components/text_field_container.dart';
import 'package:mobile_presensi_kdtg/constants.dart';

class RoundedInputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final TextEditingController IdCon;
  final ValueChanged<String> onChanged;
  const RoundedInputField({
    Key? key,
    required this.hintText,
    required this.IdCon,
    this.icon = Icons.person,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
  child: TextField(
    controller: IdCon,
    onChanged: onChanged,
    cursorColor: kPrimaryColor,
    style: const TextStyle(fontSize: 16),
    decoration: InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(
        icon,
        color: kPrimaryColor,
      ),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kPrimaryColor, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: kPrimaryColor, width: 2),
      ),
    ),
  ),
);

  }
}