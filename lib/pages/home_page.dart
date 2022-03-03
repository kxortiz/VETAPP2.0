import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vetapp/pages/usuario_page.dart';
import 'package:vetapp/pages/administrador_page.dart';
import 'package:vetapp/services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    final _authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Seleccione un rol"),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  if (_authService.admin) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AdministradorPage()),
                    );
                  } else {
                    setState(() {
                      showAlertDialog(context);
                    });
                  }
                },
                child: Column(children: const [
                  Image(image: AssetImage('assets/images/admin.png')),
                  Text("Administrador",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ]),
              ),
              const SizedBox(height: 50),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UsuarioPage()),
                  );
                },
                child: Column(children: const [
                  Image(image: AssetImage('assets/images/user.png')),
                  Text("Usuario",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
                ]),
              ),
              const SizedBox(height: 25),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Salir",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  IconButton(
                    onPressed: () {
                      _authService.signOut();
                    },
                    icon: Icon(Icons.power_settings_new_rounded,
                        color: Colors.red[300]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

showAlertDialog(BuildContext context) {

  AlertDialog alert = AlertDialog(
    insetPadding: EdgeInsets.all(10),
    title: Row(
      children: [
        Icon(Icons.error_outline, size: 30, color: Colors.red[400]),
        const SizedBox(width: 10),
        const Expanded (
          child: Text("No tienes los Permisos",  maxLines: 2, overflow: TextOverflow.ellipsis)
        )
      ],
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min, 
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("No eres un usuario Administrador, prueba a ingresar en Usuario."), 
      ]   
    ),
    actions: [
      Align(
        alignment: Alignment.topCenter,
        child: ElevatedButton(
          onPressed: (){
            Navigator.pop(context);
          }, 
          child: Text("Ok")
        ),
      )
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
