import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vetapp/models/cita_model.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CitaDatosPage extends StatefulWidget {

  const CitaDatosPage({
    required this.cita,
    required this.id,
    Key? key
  }) : super(key: key);

  final Cita cita;
  final String id;

  @override
  State<CitaDatosPage> createState() => _CitaDatosPageState();
}

class _CitaDatosPageState extends State<CitaDatosPage> {

  //late Uint8List _imageFile;

  ScreenshotController screenshotController = ScreenshotController(); 

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              Screenshot(
                controller: screenshotController,
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
              
                      Text("Nombre: ${widget.cita.nombre}", style: const TextStyle(fontSize: 14)),
                      Text("Correo: ${widget.cita.correo}", style: const TextStyle(fontSize: 14)),
                      Text("Fecha: ${widget.cita.dia}", style: const TextStyle(fontSize: 14)),
                      Text("Hora: ${widget.cita.hora}", style: const TextStyle(fontSize: 14)),
              
                      const SizedBox(height: 50),
              
                      QrImage(
                        data: widget.id,
                        version: QrVersions.auto,
                        size: 170.0,
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 50),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async{

                      // final directory = (await getApplicationDocumentsDirectory ()).path; //from path_provide package
                      // String fileName = DateTime.now().microsecondsSinceEpoch.toString();
                      
                      // screenshotController.captureAndSave(
                      //   directory, //set path where screenshot will be saved
                      //   fileName:fileName 
                      // );

                      // print(directory);
                      // print("Imagen Guaradada");

                      await screenshotController.capture(delay: const Duration(milliseconds: 10)).then((image) async {
                        if (image != null) {
                          final directory = await getApplicationDocumentsDirectory();
                          final imagePath = await File('${directory.path}/image.png').create();
                          await imagePath.writeAsBytes(image);

                          /// Share Plugin
                          await Share.shareFiles([imagePath.path]);

                          final result = await ImageGallerySaver.saveImage(
                            image,
                            quality: 60,
                            name: "hello");
                            print(result);
                            print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaa");

                          }
                      });
                     

                      // await screenshotController.capture(delay: const Duration(milliseconds: 10)).then((image) async{
                      //   if (image != null) {
                      //     final directory = (await getApplicationDocumentsDirectory()).path;
                      //     String fileName = DateTime.now().microsecondsSinceEpoch.toString();
                      //     //path = '$directory';
                      //     //final imagePath = await File('${directory.path}/image.png').create();
                          
                          
                      //     //await imagePath.writeAsBytes(image);
                        

                      //     // await ImageGallerySaver.saveImage(
                      //     //   image,
                      //     // );

                      //     // /// Share Plugin
                      //     // await Share.shareFiles([imagePath.path]);
                      //   }
                      // });
                    },
                    child: const Text("Compartir")
                  ),

                  const SizedBox(width: 20),

                  ElevatedButton(
                    onPressed: () async{
                      await screenshotController.capture().then((image) async{
                        if (image != null) {
                          await ImageGallerySaver.saveImage(
                            image,
                          );
                        }
                      });
                    },
                    child: const Text("Guardar")
                  ),
                ],
              )
            ],
          ),
    
        ),
      ),
    );
  }
}