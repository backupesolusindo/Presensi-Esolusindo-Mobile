import 'package:flutter/material.dart';
import 'package:mobile_presensi_kdtg/components/text_field_container.dart';
import '../constants.dart';

class RoundedPasswordField extends StatefulWidget {
  final String hintText;
  final TextEditingController IdCon;

  const RoundedPasswordField(
      {Key? key, required this.hintText, required this.IdCon})
      : super(key: key);

  @override
  _RoundedPasswordField createState() => _RoundedPasswordField();
}

class _RoundedPasswordField extends State<RoundedPasswordField> {
  bool passVisible = true;
  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
  child: TextFormField(
    controller: widget.IdCon,
    obscureText: passVisible,
    cursorColor: kPrimaryColor,
    keyboardType: TextInputType.visiblePassword,
    style: const TextStyle(fontSize: 16),
    decoration: InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      hintText: widget.hintText,
      hintStyle: const TextStyle(color: Colors.grey),
      prefixIcon: const Icon(
        Icons.lock_outline,
        color: kPrimaryColor,
      ),
      suffixIcon: IconButton(
        icon: Icon(
          passVisible ? Icons.visibility_off : Icons.visibility,
          color: kPrimaryColor,
        ),
        onPressed: () {
          setState(() {
            passVisible = !passVisible;
          });
        },
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    ),
    validator: (String? value) {
      if (value == null || value.isEmpty) {
        return "Password Harus Diisi";
      }
      return null;
    },
  ),
);

  }
}