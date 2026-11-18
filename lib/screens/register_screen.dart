import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/auth_validators.dart';
import 'email_confirmation_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    this.authService = const UnavailableAuthService(),
  });

  final AuthService authService;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _loading = false;
  bool _hidePassword = true;
  bool _hideConfirmation = true;
  String? _message;

  Future<void> _register() async {
    if (_loading || !_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    if (widget.authService.configurationMessage != null) return;
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final authenticated = await widget.authService.signUp(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      _password.clear();
      _confirmation.clear();
      if (authenticated) {
        // El login recibe el resultado y abre el mapa solo con sesión real.
        Navigator.pop(context, true);
      } else {
        // Reemplaza el registro: tanto el botón como Atrás vuelven al login.
        await Navigator.pushReplacement<void, bool>(
          context,
          MaterialPageRoute<void>(
            builder: (context) => const EmailConfirmationScreen(),
          ),
        );
      }
    } catch (error) {
      if (mounted) setState(() => _message = authErrorMessage(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disabled = _loading;
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.person_add_outlined, size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      'Únete a la aventura',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (widget.authService.configurationMessage != null) ...[
                      Text(widget.authService.configurationMessage!),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _email,
                      enabled: !disabled,
                      validator: validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      enabled: !disabled,
                      validator: validateRegistrationPassword,
                      obscureText: _hidePassword,
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        border: const OutlineInputBorder(),
                        errorMaxLines: 3,
                        suffixIcon: IconButton(
                          tooltip: _hidePassword
                              ? 'Mostrar contraseña'
                              : 'Ocultar contraseña',
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: disabled
                              ? null
                              : () {
                                  setState(
                                    () => _hidePassword = !_hidePassword,
                                  );
                                },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Al menos 8 caracteres: mayúscula, minúscula, número y símbolo.',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmation,
                      enabled: !disabled,
                      validator: (value) =>
                          validatePasswordConfirmation(value, _password.text),
                      obscureText: _hideConfirmation,
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _register(),
                      decoration: InputDecoration(
                        labelText: 'Confirmar contraseña',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          tooltip: _hideConfirmation
                              ? 'Mostrar confirmación de contraseña'
                              : 'Ocultar confirmación de contraseña',
                          icon: Icon(
                            _hideConfirmation
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: disabled
                              ? null
                              : () {
                                  setState(
                                    () =>
                                        _hideConfirmation = !_hideConfirmation,
                                  );
                                },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_message != null) ...[
                      Semantics(liveRegion: true, child: Text(_message!)),
                      const SizedBox(height: 16),
                    ],
                    FilledButton(
                      onPressed:
                          disabled ||
                              widget.authService.configurationMessage != null
                          ? null
                          : _register,
                      child: _loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                semanticsLabel: 'Creando cuenta',
                              ),
                            )
                          : const Text('Crear cuenta'),
                    ),
                    TextButton(
                      onPressed: _loading ? null : () => Navigator.pop(context),
                      child: const Text('Volver al inicio de sesión'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
