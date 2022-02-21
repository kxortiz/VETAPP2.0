  import 'package:flutter/material.dart';
import 'package:vetapp/utils/my_colors.dart';

class CustomInput extends StatelessWidget {

  final IconData icon;
  final String placeholder;
  final TextEditingController textController;
  final TextInputType keyboardType;
  final bool isPassword;
  final Color? color;

  const CustomInput({
    required this.icon, 
    required this.placeholder, 
    required this.textController, 
    this.keyboardType = TextInputType.text, 
    this.isPassword = false,
    this.color,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: MyColors.primaryOpacityColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        //cursorColor: Colors.white,
        //style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        obscureText: isPassword,
        controller: textController,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: placeholder,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(15),
          hintStyle: const TextStyle(color: Colors.black),
          prefixIcon: Icon(
            icon,
            color: MyColors.primaryColor,
          )
        ),
      ),
    );
  }
}