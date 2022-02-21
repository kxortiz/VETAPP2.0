import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vetapp/services/auth_service.dart';
import 'package:vetapp/widgets/custom_input.dart';
import 'package:vetapp/widgets/logo.dart';
import 'package:vetapp/widgets/main_button.dart';

class RegistrarsePage extends StatelessWidget {
  const RegistrarsePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      //backgroundColor: Color(0xffF2F2F2),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Logo(titulo: "Registrarse"),
              
              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: InkWell(
                  onTap: () async {
                    try {
                      await authService.googleLogin();  
                      Navigator.pop(context);
                      
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(25)),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.4),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Image(image: AssetImage('assets/images/google_icon.png'), width: 45,),
                        SizedBox(width: 10),
                        Text("Ingresar con Google", style: TextStyle(fontSize: 17))
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
          
              const SizedBox(height: 30),

              const Text("o puedes registrarte con:"),

              const SizedBox(height: 30),
          
              _Form(),
              const SizedBox(height: 30),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Text("")//Labels(mensaje1: "¿Ya tienes cuenta?", mensaje2: "Ingresa ahora")
              ),
              const SizedBox(height: 30),

              const SizedBox( height: 1 ),
            ]
          ),
        ),
      )
    );
  }
}

class _Form extends StatefulWidget {
  @override
  __FormState createState() => __FormState();
}

class __FormState extends State<_Form> {

  bool error = false;
  String msg = "";
  
  final nombreCtlr = TextEditingController();
  final emailCtlr = TextEditingController();
  final passCtlr = TextEditingController();
  final passCtlrAgain = TextEditingController();

  
  @override
  Widget build(BuildContext context) {

    final authService = Provider.of<AuthService>(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: [
          CustomInput(
            icon: Icons.mail_outline,
            placeholder: "Nombre Completo",
            keyboardType: TextInputType.text,
            textController: nombreCtlr,
          ),
          CustomInput(
            icon: Icons.mail_outline,
            placeholder: "Correo",
            keyboardType: TextInputType.emailAddress,
            textController: emailCtlr,
          ),
          CustomInput(
            icon: Icons.lock_outline,
            placeholder: "Contraseña",    
            textController:passCtlr,
            isPassword: true,
          ),
          CustomInput(
            icon: Icons.lock_outline,
            placeholder: "Repita la Contraseña",    
            textController:passCtlrAgain,
            isPassword: true,
          ),
          
          const SizedBox(height: 30),
          
          (error) ?
            Column(
              children: [
                Text(msg, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 10)
              ],
            ):
            const SizedBox.shrink(),


          MainButton(
            text: "Registrarse",
            onPressed: () async{ 
              try {
                if(passCtlr.text.trim() == passCtlrAgain.text.trim()){
                  if(passCtlr.text.trim().length <= 7 ){
                    setState(() {
                      error = true;
                      msg = "Ha ocurrido un error, la longitud de la contraseña debe ser mayor a 8 caracteres";
                    });
                  }else{
                    if(nombreCtlr.text.trim().length <= 2){
                      setState(() {
                        error = true;
                        msg = "Debe especificar su nombre completo";
                      });
                    }else{
                      String resp = await authService.createUserWithEmailAndPassword(
                        nombreCtlr.text.trim(), 
                        emailCtlr.text.trim(), 
                        passCtlr.text.trim()
                      );
                      if(resp == "Ok") {
                        Navigator.pop(context);
                        return;
                      }
                      setState(() {
                        error = true;
                        msg = resp;
                      });
                    }
                  }

                }else{
                  setState(() {
                    error = true;
                    msg = "Ha ocurrido un error, revise que las contraseñas sean iguales e inténtelo más tarde";
                  });
                }
              } catch (e) {
                setState(() {
                  error = true;
                });
              }
            },
          ),
         ]
       )
    );
  }
}