import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:vetapp/models/cita_model.dart';
import 'package:vetapp/pages/cita_datos_page.dart';
import 'package:vetapp/services/firebase.dart';

class EscanearQR extends StatefulWidget {
  const EscanearQR({Key? key}) : super(key: key);

  @override
  State<EscanearQR> createState() => _EscanearQRState();
}

class _EscanearQRState extends State<EscanearQR> {

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  bool scanReady = false;
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {

    void goToScreen() async{
      final String codigo = result!.code.toString().trim();
      Cita? cita = await FirebaseService.fb.consultarCita(codigo);

      if (cita != null){

        Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => CitaDatosPage(cita: cita, id: codigo))
        );
      
      }
    }

    if(scanReady){
      goToScreen();
    }

    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: (MediaQuery.of(context).size.width < 400 ||
                    MediaQuery.of(context).size.height < 400)
                ? 200.0
                : 300.0
              ),
            ),
          ), 
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Text(
                      'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
                  : const Text('Escanea el Código'),
            ),
          )
        ],
      ),
    );
  }


  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) async {

      if(!scanReady){

        setState(() {
          scanReady = true;
          result = scanData;   
        });
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}