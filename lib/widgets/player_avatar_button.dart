import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../services/avatar_service.dart';

class PlayerAvatarButton extends StatefulWidget {
  const PlayerAvatarButton({super.key, required this.service});

  final AvatarService service;

  @override
  State<PlayerAvatarButton> createState() => _PlayerAvatarButtonState();
}

class _PlayerAvatarButtonState extends State<PlayerAvatarButton> {
  late final String? _userId = widget.service.currentUserId;
  Uint8List? _avatar;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final userId = _userId;
    if (_busy || userId == null) return;
    setState(() => _busy = true);
    try {
      final avatar = await widget.service.loadAvatar(userId);
      if (mounted && widget.service.currentUserId == userId) {
        setState(() => _avatar = avatar);
      }
    } catch (_) {
      _showMessage(
        'No se pudo cargar el avatar.',
        action: SnackBarAction(label: 'Reintentar', onPressed: _loadAvatar),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _changeAvatar() async {
    final userId = _userId;
    if (_busy || userId == null) return;
    setState(() => _busy = true);
    try {
      final Uint8List? selected;
      try {
        selected = await widget.service.pickAvatar();
      } on FormatException catch (error) {
        _showMessage(error.message);
        return;
      } catch (_) {
        _showMessage('No se pudo seleccionar la imagen.');
        return;
      }

      if (selected == null || !mounted) return;
      await widget.service.saveAvatar(userId, selected);
      if (!mounted || widget.service.currentUserId != userId) return;
      setState(() => _avatar = selected);
      _showMessage('Avatar guardado.');
    } on FormatException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('No se pudo guardar el avatar. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showMessage(String message, {SnackBarAction? action}) {
    if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message), action: action));
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null || widget.service.currentUserId != _userId) {
      return const SizedBox.shrink();
    }
    const placeholder = Icon(Icons.person_outline);
    final avatar = _avatar;
    return IconButton(
      tooltip: 'Cambiar avatar',
      onPressed: _busy ? null : _changeAvatar,
      icon: SizedBox.square(
        dimension: 32,
        child: _busy
            ? const Padding(
                padding: EdgeInsets.all(6),
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : CircleAvatar(
                child: avatar == null
                    ? placeholder
                    : ClipOval(
                        child: Image.memory(
                          avatar,
                          width: 32,
                          height: 32,
                          cacheWidth: 96,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Tooltip(
                                message: 'No se pudo mostrar el avatar.',
                                child: placeholder,
                              ),
                        ),
                      ),
              ),
      ),
    );
  }
}
