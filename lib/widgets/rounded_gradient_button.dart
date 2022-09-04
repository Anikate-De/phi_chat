import 'package:flutter/material.dart';

class RoundedGradientTextButton extends StatelessWidget {
  final String text;
  final void Function()? onPressed;

  const RoundedGradientTextButton(
      {required this.text, required this.onPressed, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: const ButtonStyle(
        splashFactory: NoSplash.splashFactory,
      ),
      onPressed: () {},
      child: Container(
        alignment: Alignment.center,
        width: 300,
        height: 60,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            gradient: const LinearGradient(colors: [
              Color.fromRGBO(29, 215, 249, 1.0),
              Color.fromRGBO(10, 122, 236, 1.0)
            ])),
        child: Container(
          width: 296,
          height: 56,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(40)),
          child: Material(
            type: MaterialType.transparency,
            color: Colors.transparent,
            child: InkWell(
              customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
              splashColor: const Color.fromRGBO(10, 122, 236, 0.5),
              highlightColor: Colors.transparent,
              onTap: onPressed,
              child: Center(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontFamily: 'Handlee',
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 3,
                    color: Color.fromRGBO(21, 176, 249, 1.0),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
