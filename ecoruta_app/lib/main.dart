import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/cifrado.dart';
import 'datos/api_aire.dart';
import 'datos/repositorios_firebase.dart';
import 'datos/servicio_acciones.dart';
import 'firebase_options.dart';

/// Se cambia al compilar: --dart-define=URL_JUEGO=https://...
const _urlJuego = String.fromEnvironment(
  'URL_JUEGO',
  defaultValue: 'https://TU-USUARIO.github.io/ecoruta/',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(EcoRutaApp(
    deps: Dependencias(
      auth: RepositorioAuthFirebase(),
      acciones: ServicioAcciones(
        RepositorioAccionesFirestore(),
        ServicioCifrado(AlmacenLlaveSeguro()),
      ),
      aire: ApiCalidadAire(),
      urlJuego: Uri.parse(_urlJuego),
    ),
  ));
}
