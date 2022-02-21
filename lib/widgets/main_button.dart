import 'package:flutter/material.dart';
import 'package:vetapp/utils/my_colors.dart';

class MainButton extends StatelessWidget {

  final String text;
  final VoidCallback? onPressed;

  // ignore: use_key_in_widget_constructors
  const MainButton({
    required this.text, 
    this.onPressed
  }); 

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 3,
        primary: MyColors.primaryColor,
        shape: const StadiumBorder(),
      ),
      onPressed: onPressed,
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: Center(
          child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 17)),
        ),
      ),
    );
  }
}