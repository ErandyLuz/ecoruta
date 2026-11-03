// ARCHIVO DE RELLENO. Reemplázalo ejecutando en esta carpeta:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// Eso lo regenera con los datos reales de tu proyecto de Firebase.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => const FirebaseOptions(
        apiKey: 'REEMPLAZAR',
        appId: 'REEMPLAZAR',
        messagingSenderId: 'REEMPLAZAR',
        projectId: 'REEMPLAZAR',
      );
}
