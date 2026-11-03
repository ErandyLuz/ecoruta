import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'modelos.dart';
import 'repositorios.dart';

class RepositorioAuthFirebase implements RepositorioAuth {
  RepositorioAuthFirebase([FirebaseAuth? auth])
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  Stream<String?> cambiosDeSesion() =>
      _auth.authStateChanges().map((u) => u?.uid);

  @override
  Future<void> iniciarSesion(String correo, String contrasena) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: correo.trim(), password: contrasena);
    } on FirebaseAuthException catch (e) {
      throw _traducir(e);
    }
  }

  @override
  Future<void> registrar(String correo, String contrasena) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: correo.trim(), password: contrasena);
      await cred.user?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _traducir(e);
    }
  }

  @override
  Future<void> cerrarSesion() => _auth.signOut();

  ErrorAuth _traducir(FirebaseAuthException e) {
    switch (e.code) {
      case 'too-many-requests':
        return const ErrorAuth('Demasiados intentos. Espera unos minutos.');
      case 'network-request-failed':
        return const ErrorAuth('Sin conexión a internet.');
      case 'weak-password':
        return const ErrorAuth('La contraseña es muy débil.');
      case 'email-already-in-use':
        // Mismo mensaje que un fallo de registro cualquiera: no confirmamos
        // a terceros qué correos tienen cuenta.
        return const ErrorAuth('No se pudo crear la cuenta.');
      default:
        return const ErrorAuth('Correo o contraseña incorrectos.');
    }
  }
}

class RepositorioAccionesFirestore implements RepositorioAcciones {
  RepositorioAccionesFirestore([FirebaseFirestore? db])
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _acciones(String uid) =>
      _db.collection('usuarios').doc(uid).collection('acciones');

  @override
  Stream<List<AccionEco>> observar(String uid) => _acciones(uid)
      .orderBy('fecha', descending: true)
      .limit(100)
      .snapshots()
      .map((s) =>
          s.docs.map((d) => AccionEco.desdeMapa(d.id, d.data())).toList());

  @override
  Future<void> agregar(String uid, AccionEco accion) =>
      _acciones(uid).add(accion.aMapa());

  @override
  Future<void> eliminar(String uid, String idAccion) =>
      _acciones(uid).doc(idAccion).delete();

  @override
  Stream<List<PuntoReciclaje>> puntosReciclaje() => _db
      .collection('puntos_reciclaje')
      .limit(50)
      .snapshots()
      .map((s) =>
          s.docs.map((d) => PuntoReciclaje.desdeMapa(d.data())).toList());
}
