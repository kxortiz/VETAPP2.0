import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:vetapp/pages/home_page.dart';
import 'package:vetapp/pages/login_page.dart';
import 'package:vetapp/services/auth_service.dart';

import 'models/usuario.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: ( _ ) => AuthService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const Inicio()
      ),
    );
  }
}

class Inicio extends StatelessWidget {
  const Inicio({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final authService = Provider.of<AuthService>(context);

    return SafeArea(
      child: StreamBuilder<Usuario?>(
        stream: authService.user,
        builder: ( _ , AsyncSnapshot<Usuario?> snapshot){
          
          if (snapshot.connectionState == ConnectionState.active) {
            final Usuario? usuario = snapshot.data;
            return usuario == null ? const LoginPage(): const HomePage();
          }else{
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
        },
      ),
    );
  }
}


