import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vetapp/pages/registrarse_page.dart';
import 'package:vetapp/services/auth_service.dart';
import 'package:vetapp/widgets/custom_input.dart';
import 'package:vetapp/widgets/labels.dart';
import 'package:vetapp/widgets/logo.dart';
import 'package:vetapp/widgets/main_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

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
              const Logo(titulo: "Login"),
              
              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: InkWell(
                  onTap: () async {
                    await authService.googleLogin();  
                  },
                  child: Container(
                    width: double.infinity,
                    height: 55,
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
          
              const SizedBox(height: 30),

              const Text("o puedes ingresar con"),

              const SizedBox(height: 30),
          
              _Form(),
              const SizedBox(height: 30),
              InkWell(
                onTap: (){
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const RegistrarsePage())
                  );
                },
                child: const Labels(ruta: "register", mensaje1: "¿No tienes cuenta?", mensaje2: "Crea una ahora")
              ),
              const SizedBox(height: 30),
              const Text("Terminos y condiciones de uso", style: TextStyle(fontWeight: FontWeight.w200),),
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
  
  final emailCtlr = TextEditingController();
  final passCtlr = TextEditingController();
  
  @override
  Widget build(BuildContext context) {

    final authService = Provider.of<AuthService>(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: [
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
          
          const SizedBox(height: 30),
          
          MainButton(
            text: "Ingresar",
            onPressed: () async{ 
              authService.signInWithEmailAndPassword(emailCtlr.text.trim(), passCtlr.text.trim());
            },
          ),
         ]
       )
    );
  }
}