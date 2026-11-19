import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AvatarService {
  String? get currentUserId;

  Future<Uint8List?> loadAvatar(String userId);
  Future<Uint8List?> pickAvatar();
  Future<void> saveAvatar(String userId, Uint8List bytes);
}

class SupabaseAvatarService implements AvatarService {
  SupabaseAvatarService(this.client);

  static const maxBytes = 2 * 1024 * 1024;
  static const _readTimeout = Duration(seconds: 15);
  final SupabaseClient client;
  final _picker = ImagePicker();

  StorageFileApi get _bucket => client.storage.from('player-avatars');

  @override
  String? get currentUserId => client.auth.currentSession?.user.id;

  void _requireUser(String userId) {
    if (currentUserId != userId) throw StateError('La sesión cambió.');
  }

  @override
  Future<Uint8List?> loadAvatar(String userId) async {
    _requireUser(userId);
    // Una carpeta vacía distingue una cuenta nueva de un fallo de Storage.
    final files = await _bucket
        .list(
          path: userId,
          searchOptions: const SearchOptions(search: 'avatar'),
        )
        .timeout(_readTimeout);
    _requireUser(userId);
    if (!files.any((file) => file.name == 'avatar')) return null;

    final bytes = await _bucket
        .download(
          '$userId/avatar',
          cacheNonce: DateTime.now().microsecondsSinceEpoch.toString(),
        )
        .timeout(_readTimeout);
    _requireUser(userId);
    return bytes;
  }

  @override
  Future<Uint8List?> pickAvatar() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: false,
    );
    if (file == null) return null;
    _checkSize(await file.length());
    return file.readAsBytes();
  }

  @override
  Future<void> saveAvatar(String userId, Uint8List bytes) async {
    _requireUser(userId);
    _checkSize(bytes.length);
    final mimeType = _imageMimeType(bytes);
    await _checkDecodable(bytes);
    _requireUser(userId);
    await _bucket.uploadBinary(
      '$userId/avatar',
      bytes,
      fileOptions: FileOptions(
        upsert: true,
        contentType: mimeType,
        cacheControl: '0',
      ),
      retryAttempts: 0,
    );
    _requireUser(userId);
  }

  static void _checkSize(int length) {
    if (length > maxBytes) {
      throw const FormatException('La imagen debe pesar 2 MB o menos.');
    }
  }

  static String _imageMimeType(Uint8List bytes) {
    const pngHeader = [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a];
    if (bytes.length >= pngHeader.length &&
        listEquals(bytes.sublist(0, pngHeader.length), pngHeader)) {
      return 'image/png';
    }
    if (bytes.length >= 3 &&
        bytes[0] == 0xff &&
        bytes[1] == 0xd8 &&
        bytes[2] == 0xff) {
      return 'image/jpeg';
    }
    throw const FormatException('Elige una imagen JPG o PNG.');
  }

  static Future<void> _checkDecodable(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: 96,
        targetHeight: 96,
        allowUpscaling: false,
      );
      try {
        final frame = await codec.getNextFrame();
        frame.image.dispose();
      } finally {
        codec.dispose();
      }
    } catch (_) {
      throw const FormatException('No se pudo abrir la imagen. Elige otra.');
    }
  }
}
