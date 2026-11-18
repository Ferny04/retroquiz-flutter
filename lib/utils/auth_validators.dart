String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Ingresa tu correo electrónico.';
  if (!RegExp(r'^[^\s@]+@[^\s@.]+(?:\.[^\s@.]+)+$').hasMatch(email)) {
    return 'Ingresa un correo electrónico válido.';
  }
  return null;
}

String? validateLoginPassword(String? value) {
  if (value == null || value.isEmpty) return 'Ingresa tu contraseña.';
  return null;
}

String? validateRegistrationPassword(String? value) {
  if (value == null || value.isEmpty) return 'Ingresa tu contraseña.';
  if (value.length < 8 ||
      !RegExp(r'[A-Z]').hasMatch(value) ||
      !RegExp(r'[a-z]').hasMatch(value) ||
      !RegExp(r'[0-9]').hasMatch(value) ||
      !RegExp(r'[^A-Za-z0-9\s]').hasMatch(value)) {
    return 'Usa al menos 8 caracteres con mayúscula, minúscula, número y símbolo.';
  }
  return null;
}

String? validatePasswordConfirmation(String? value, String password) {
  if (value == null || value.isEmpty) return 'Confirma tu contraseña.';
  if (value != password) return 'Las contraseñas no coinciden.';
  return null;
}
