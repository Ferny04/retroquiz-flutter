import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' as rive;

import '../services/auth_service.dart';
import '../utils/auth_validators.dart';
import 'register_screen.dart';
import 'world_map_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.authService = const UnavailableAuthService(),
  });

  final AuthService authService;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _message;
  final FocusNode _passwordFocus = FocusNode();
  bool _ocultarPassword = true;
  bool _errorRobot = false;
  rive.Artboard? _robot;
  rive.StateMachineController? _robotController;
  rive.SMIBool? _manosArriba;

  @override
  void initState() {
    super.initState();
    _passwordFocus.addListener(_actualizarManos);
    _cargarRobot();
  }

  Future<void> _cargarRobot() async {
    try {
      // La importación directa permite capturar fallos del runtime nativo.
      final datos = await rootBundle
          .load('assets/animations/robot-login.riv')
          .timeout(const Duration(seconds: 5));
      if (!mounted) return;

      final archivo = rive.RiveFile.import(datos);
      final robot = archivo.mainArtboard;
      final controller = rive.StateMachineController.fromArtboard(
        robot,
        'robot_login_machine',
      );
      if (controller != null) {
        robot.addController(controller);
        final entrada = controller.findInput<bool>('is_hands_up');
        if (entrada is rive.SMIBool) {
          _manosArriba = entrada;
        }
      }
      _robotController = controller;
      _actualizarManos();
      setState(() {
        _robot = robot;
      });
    } catch (_) {
      // Si Rive falla, el formulario continúa disponible.
      if (!mounted) return;
      setState(() {
        _errorRobot = true;
      });
    }
  }

  void _actualizarManos() {
    // El robot se cubre los ojos al enfocar la contraseña.
    _manosArriba?.value = _passwordFocus.hasFocus;
  }

  Future<void> _signIn() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    if (widget.authService.configurationMessage != null) return;
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final authenticated = await widget.authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      if (authenticated) {
        _passwordController.clear();
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (context) => const WorldMapScreen(isDemo: false),
          ),
        );
      } else {
        setState(() {
          _message = 'No se recibió una sesión válida. Intenta iniciar sesión de nuevo.';
        });
      }
    } catch (error) {
      if (mounted) setState(() => _message = authErrorMessage(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.removeListener(_actualizarManos);
    _passwordFocus.dispose();
    _robotController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
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
                    SizedBox(
                      // Al cargar, la altura se adapta a la proporción del robot.
                      height: _robot == null ? 210 : null,
                      child: _errorRobot
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.smart_toy_outlined, size: 80),
                                Text('La animación no está disponible.'),
                              ],
                            )
                          : _robot == null
                          ? const Center(child: CircularProgressIndicator())
                          : AspectRatio(
                              aspectRatio: _robot!.width / _robot!.height,
                              child: rive.Rive(
                                artboard: _robot!,
                                fit: BoxFit.contain,
                              ),
                            ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Prepara tu aventura',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (widget.authService.configurationMessage != null) ...[
                      Text(
                        widget.authService.configurationMessage!,
                        style: const TextStyle(color: Colors.amberAccent),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _emailController,
                      validator: validateEmail,
                      enabled: !_loading,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      validator: validateLoginPassword,
                      enabled: !_loading,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _signIn(),
                      focusNode: _passwordFocus,
                      obscureText: _ocultarPassword,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          tooltip: _ocultarPassword
                              ? 'Mostrar contraseña'
                              : 'Ocultar contraseña',
                          icon: Icon(
                            _ocultarPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: _loading
                              ? null
                              : () {
                                  setState(() {
                                    _ocultarPassword = !_ocultarPassword;
                                  });
                                },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_message != null) ...[
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          _message!,
                          style: const TextStyle(color: Colors.amberAccent),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    FilledButton(
                      onPressed:
                          _loading ||
                              widget.authService.configurationMessage != null
                          ? null
                          : _signIn,
                      child: _loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                semanticsLabel: 'Iniciando sesión',
                              ),
                            )
                          : const Text('Iniciar sesión'),
                    ),
                    TextButton(
                      onPressed: _loading
                          ? null
                          : () async {
                              FocusScope.of(context).unfocus();
                              final authenticated = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute<bool>(
                                  builder: (context) => RegisterScreen(
                                    authService: widget.authService,
                                  ),
                                ),
                              );
                              if (!context.mounted || authenticated != true) {
                                return;
                              }
                              _passwordController.clear();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (context) =>
                                      const WorldMapScreen(isDemo: false),
                                ),
                              );
                            },
                      child: const Text('Crear una cuenta'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.public),
                      label: const Text('Vista previa de mundos'),
                      onPressed: _loading
                          ? null
                          : () {
                              FocusScope.of(context).unfocus();
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (context) =>
                                      const WorldMapScreen(isDemo: true),
                                ),
                              );
                            },
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
