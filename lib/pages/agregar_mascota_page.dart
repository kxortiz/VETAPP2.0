import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vetapp/models/mascota_model.dart';
import 'package:vetapp/services/auth_service.dart';
import 'package:vetapp/services/firebase.dart';
import 'package:vetapp/utils/my_colors.dart';
import 'package:vetapp/widgets/custom_input.dart';

class AgregarMascotaPage extends StatefulWidget {

  final QueryDocumentSnapshot<Mascota>? mascotaDocument;

  AgregarMascotaPage({
    Key? key,
    this.mascotaDocument,
  }) : super(key: key);

  @override
  State<AgregarMascotaPage> createState() => _AgregarMascotaPageState();
}

class _AgregarMascotaPageState extends State<AgregarMascotaPage> {
  
  File? _imageFile;
  bool guardando = false;
  late TextEditingController nameCtlr;

  bool editandoImagen = false;

  @override
  void initState() {
    
    if(widget.mascotaDocument == null){
      nameCtlr = TextEditingController();
    }else{
      nameCtlr = TextEditingController(text: widget.mascotaDocument!.data().nombre);
    }
    super.initState();
  }

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
          title: widget.mascotaDocument != null ? Text("Editando una Mascota") : Text("Agregar una Mascota"),
        ),
        body: Column(
          children: [
            _InfoMascota(imageFile: _imageFile, nameCtlr: nameCtlr, mascotaDocument: widget.mascotaDocument, editandoImagen: editandoImagen),

            guardando ? 
            Column(
              children: [
                const SizedBox(height: 10),
                const Text("Guardando"),
                CircularProgressIndicator(),
              ],
            ) : SizedBox.shrink(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () async{
                    await pickImageCamera();
                    setState(() {
                      editandoImagen = true;
                    });
                  }, 
                  icon: Icon(Icons.camera_alt, color: MyColors.primaryColorDark)
                ),

                // Guardar la Mascota en la BD
                IconButton(
                  onPressed: () async{

                    if(guardando) return;

                    if(nameCtlr.text == "") return;

                    setState(() {
                      guardando = true;
                    });

                    String? urlImage;
                    if (_imageFile != null){
                      urlImage = await _firebaseService.saveImage(_imageFile!);                    
                    }

                    if (widget.mascotaDocument == null){
                      await _firebaseService.addMascota(
                        Mascota(
                          nombre: nameCtlr.text.trim(), 
                          vacunas: [], 
                          userId: _authService.usuario!.id,
                          image: urlImage
                        )
                      );
                    }

                    else{
                      await _firebaseService.updateMascota(
                        widget.mascotaDocument!.id, 
                        {
                          "nombre": nameCtlr.text.trim(),
                          "image": urlImage
                        }
                      );
                    }

                    Navigator.pop(context);
                  }, 
                  icon: widget.mascotaDocument == null ? 
                    Icon(Icons.save, color: MyColors.primaryColorDark)
                    : Icon(Icons.edit, color: MyColors.primaryColorDark)
                ),
                // ********************************

                IconButton(
                  onPressed: () async{
                    await pickImageGallery();
                    setState(() {
                      editandoImagen = true;
                    });
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
    required this.editandoImagen,
    this.mascotaDocument
  }) : _imageFile = imageFile, super(key: key);

  final bool editandoImagen;
  final File? _imageFile;
  final TextEditingController nameCtlr;
  final QueryDocumentSnapshot<Mascota>? mascotaDocument;

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

              mascotaDocument == null ?
                _imageFile == null     
                  ? Image(image: AssetImage('assets/images/noimage.png'), width: 280, height: 300)
                  : Image.file(_imageFile!, width: 280, height: 300)

                : 
                  (!editandoImagen && mascotaDocument!.data().image != null) ? 
                    FadeInImage(
                      placeholder: AssetImage('assets/images/jar-loading.gif'),
                      image: NetworkImage(mascotaDocument!.data().image!),
                      fit: BoxFit.cover,
                    )
                    : (!editandoImagen && mascotaDocument!.data().image == null) ?
                      Image(image: AssetImage('assets/images/noimage.png'), width: 280, height: 300)
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