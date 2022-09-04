import 'package:flutter/material.dart';

class RoundedTextField extends StatelessWidget {
  final Function(String) onChanged;
  final bool error;
  final String errorText;
  final bool obscure;
  final String labelText;

  const RoundedTextField(
      {required this.onChanged,
      required this.error,
      required this.errorText,
      required this.obscure,
      required this.labelText,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: TextField(
        style: const TextStyle(
            fontFamily: 'Handlee',
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 2),
        onChanged: onChanged,
        obscuringCharacter: '•',
        obscureText: obscure,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          errorText: error ? errorText : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
          enabled: true,
          labelText: labelText,
        ),
      ),
    );
  }
}
