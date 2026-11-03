import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// De dónde sale la llave de cifrado. En la app es el almacén seguro del
/// sistema; en las pruebas, una llave en memoria.
abstract class AlmacenLlave {
  Future<List<int>?> leer();
  Future<void> guardar(List<int> llave);
}

/// Guarda la llave en Android Keystore / iOS Keychain, nunca en texto plano.
class AlmacenLlaveSeguro implements AlmacenLlave {
  AlmacenLlaveSeguro([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  static const _clave = 'ecoruta_llave_aes';
  final FlutterSecureStorage _storage;

  @override
  Future<List<int>?> leer() async {
    final v = await _storage.read(key: _clave);
    return v == null ? null : base64Decode(v);
  }

  @override
  Future<void> guardar(List<int> llave) =>
      _storage.write(key: _clave, value: base64Encode(llave));
}

/// Cifra las notas personales con AES-256-GCM antes de mandarlas a la nube:
/// Firestore solo ve texto cifrado (nonce + texto + etiqueta de autenticación).
class ServicioCifrado {
  ServicioCifrado(this._almacen);

  final AlmacenLlave _almacen;
  final AesGcm _aes = AesGcm.with256bits();
  SecretKey? _llave;

  Future<SecretKey> _obtenerLlave() async {
    if (_llave != null) return _llave!;
    final guardada = await _almacen.leer();
    if (guardada != null) {
      return _llave = SecretKey(guardada);
    }
    final nueva = await _aes.newSecretKey();
    await _almacen.guardar(await nueva.extractBytes());
    return _llave = nueva;
  }

  Future<String> cifrar(String texto) async {
    final caja = await _aes.encrypt(
      utf8.encode(texto),
      secretKey: await _obtenerLlave(),
    );
    return base64Encode(caja.concatenation());
  }

  /// Lanza [SecretBoxAuthenticationError] si el texto fue alterado.
  Future<String> descifrar(String cifrado) async {
    final caja = SecretBox.fromConcatenation(
      base64Decode(cifrado),
      nonceLength: _aes.nonceLength,
      macLength: _aes.macAlgorithm.macLength,
    );
    final claro = await _aes.decrypt(caja, secretKey: await _obtenerLlave());
    return utf8.decode(claro);
  }
}
