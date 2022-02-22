import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vetapp/models/mascota_model.dart';
import 'package:vetapp/services/auth_service.dart';
import 'package:vetapp/services/firebase.dart';
import 'package:vetapp/utils/my_colors.dart';
import 'package:vetapp/widgets/custom_input.dart';

class AgregarMascotaPage extends StatefulWidget {
  AgregarMascotaPage({Key? key}) : super(key: key);

  @override
  State<AgregarMascotaPage> createState() => _AgregarMascotaPageState();
}

class _AgregarMascotaPageState extends State<AgregarMascotaPage> {
  
  final nameCtlr = TextEditingController();
  File? _imageFile;

  @override
  Widget build(BuildContext context) {

    final _firebaseService = FirebaseService.fb;
    final _authService = Provider.of<AuthService>(context, listen: false);

    final picker = ImagePicker();


    Future pickImageGallery() async {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      setState(() {
        if(pickedFile != null){
          _imageFile = File(pickedFile.path);
        }
      });
    }
    Future pickImageCamera() async {
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      setState(() {
        if(pickedFile != null){
          _imageFile = File(pickedFile.path);
        }
      });
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Agregar una Mascota"),
        ),
        body: Column(
          children: [
            _InfoMascota(imageFile: _imageFile, nameCtlr: nameCtlr),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () async{
                    await pickImageCamera();
                  }, 
                  icon: Icon(Icons.camera_alt, color: MyColors.primaryColorDark)
                ),

                // Guardar la Mascota en la BD
                IconButton(
                  onPressed: () async{
                    if(nameCtlr.text == "") return;

                    String? urlImage;
                    if (_imageFile != null){
                      urlImage = await _firebaseService.saveImage(_imageFile!);                    
                    }
                    await _firebaseService.addMascota(
                      Mascota(
                        nombre: nameCtlr.text.trim(), 
                        vacunas: [], 
                        userId: _authService.usuario!.id,
                        image: urlImage
                      )
                    );
                    Navigator.pop(context);
                  }, 
                  icon: Icon(Icons.save, color: MyColors.primaryColorDark)
                ),
                // ********************************

                IconButton(
                  onPressed: () async{
                    await pickImageGallery();
                  }, 
                  icon: Icon(Icons.image, color: MyColors.primaryColorDark)
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _InfoMascota extends StatelessWidget {
  const _InfoMascota({
    Key? key,
    required File? imageFile,
    required this.nameCtlr,
  }) : _imageFile = imageFile, super(key: key);

  final File? _imageFile;
  final TextEditingController nameCtlr;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              _imageFile == null     
                ? Image(image: AssetImage('assets/images/noimage.png'), width: 280, height: 300)
                : Image.file(_imageFile!, width: 280, height: 300),

              SizedBox(height: 20),
              Align(alignment: Alignment.centerLeft, child: const Text("Nombre de la Mascota")),
              CustomInput(
                icon: Icons.favorite_sharp, 
                placeholder: "Nombre", 
                textController: nameCtlr
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}