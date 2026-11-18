# RetroQuiz: Aventura Multiverso

El tercer avance conecta el registro y el inicio de sesión por correo y contraseña
con Supabase Authentication.

## Alcance actual

- Bienvenida y login con robot Rive (`robot_login_machine`, entrada `is_hands_up`
  al enfocar la contraseña), opción de mostrar/ocultar contraseña y formulario
  disponible incluso si falla la animación.
- Registro con validación de correo, contraseña segura y confirmación.
- Login real: el mapa se abre cuando Supabase devuelve una sesión.
- Registro con ojos independientes para ambas contraseñas. Sin sesión, abre una
  pantalla de confirmación que reemplaza el registro y permite volver al login.
- Vista previa identificada como **demostración**. No crea una sesión ni guarda
  progreso. Si el SDK conserva una sesión anterior, este botón solo abre la demo
  y no modifica esa sesión.
- Planeta Volcánico: 10 preguntas por partida desde el banco local de 24 preguntas
  de seis categorías, preguntas y respuestas aleatorias, puntuación y resultados.
- Los otros cinco mundos del mapa siguen bloqueados.

No hay guardado de progreso en Supabase, ranking, vidas, modo ultradifícil,
almacenamiento de imágenes ni nuevos planetas jugables.

## Configurar Supabase

1. Usa el proyecto `https://gnpsqairefmqaudvkovv.supabase.co`.
2. Verifica que el proveedor de correo permita registro y contraseña. Mantén la
   política: mínimo ocho caracteres, una mayúscula, una minúscula, un número y un
   símbolo. La aplicación también la valida.
3. Obtén la **Publishable key** en la configuración de claves API del proyecto.
   Debe comenzar con `sb_publishable_`. Pásala al ejecutar o compilar.
4. Con **Confirm email** activado, revisa la configuración del envío de correo y
   la **Site URL** usada por el enlace de confirmación. Este avance no agrega
   enlaces profundos: confirma en el navegador y regresa a la app para iniciar
   sesión manualmente. No necesitas tablas ni políticas de progreso.

No pongas claves reales en código, README, pruebas o archivos versionados. Nunca
uses una clave secreta `sb_secret_`, una clave `service_role` ni la contraseña de
PostgreSQL en Flutter. La app rechaza valores sin prefijo de Publishable key.
Las claves públicas de una app cliente no sustituyen las políticas del backend.

Sin clave aparece un aviso de configuración en bienvenida y login. Los botones
de autenticación quedan deshabilitados y la demo sigue disponible. Si falla la
inicialización se muestra un mensaje sin detalles ni claves.

### Confirmación que termina en localhost

`SupabaseAuthService.signUp` no establece `emailRedirectTo`; Supabase usa la
**Site URL**. Revisa manualmente **Authentication > URL Configuration**:

- Si **Site URL** apunta a localhost, cámbiala por una página HTTPS propia ya
  desplegada que indique regresar a la app. En un iPhone, localhost es el teléfono.
- Revisa **Redirect URLs**, la lista de destinos permitidos. Agregar una dirección
  aquí no cambia por sí solo el destino predeterminado.
- Como alternativa futura, configura primero un deep link en Android/iOS y en
  Supabase; después podrá pasarse como `emailRedirectTo`. Este avance no lo añade.
- Para una demo privada puedes desactivar temporalmente **Confirm email**; las
  cuentas nuevas podrán entrar sin verificar el correo. No prueba la confirmación.

No se cambia configuración remota ni se inventa un destino. Tras corregirla,
prueba con un correo nuevo y revisa la confirmación en **Authentication > Users**.
Si personalizaste la plantilla del correo, comprueba también su enlace.
Consulta la [documentación de redirecciones](https://supabase.com/docs/guides/auth/redirect-urls).

## Ejecutar desde PowerShell

Requiere Flutter compatible con Dart `^3.13.2`, un dispositivo/emulador o destino
de escritorio/web configurado, y conexión a Internet para autenticar.

```powershell
Set-Location 'C:\Flutter_Proyectos\retroquiz'
flutter pub get
flutter devices
# Pega la Publishable key al solicitarla; no la escribas en archivos del repo.
$retroquizPublishableKey = Read-Host 'Publishable key de Supabase'
flutter run --dart-define="SUPABASE_PUBLISHABLE_KEY=$retroquizPublishableKey"
```

Con varios dispositivos, agrega `-d ID_DEL_DISPOSITIVO`. También puedes usar
`-d chrome` con Chrome instalado. Para compilar un APK:

```powershell
flutter build apk --dart-define="SUPABASE_PUBLISHABLE_KEY=$retroquizPublishableKey"
Remove-Variable retroquizPublishableKey
```

`--dart-define` es un valor de compilación: si cambias la clave, detén y ejecuta
la app de nuevo; un hot reload no lo actualiza. Android incluye permiso de
Internet y macOS permiso de conexiones salientes.

## Ejecutar desde Android Studio

1. Abre esta carpeta como proyecto Flutter y descarga las dependencias.
2. Selecciona un emulador o dispositivo.
3. En **Run > Edit Configurations**, abre la configuración Flutter para
   `lib/main.dart`. En **Additional run args** agrega
   `--dart-define=SUPABASE_PUBLISHABLE_KEY=TU_PUBLISHABLE_KEY`, reemplazando el
   marcador por tu Publishable key.
4. Mantén esa configuración local, sin compartirla como archivo del proyecto ni
   versionarla. Ejecuta la app. También puedes usar la terminal integrada con los
   comandos de PowerShell anteriores.

## Comprobación manual

1. Entra a **Comenzar aventura > Crear una cuenta**. Prueba correo inválido,
   contraseña que incumpla cada regla y confirmación diferente: no deben enviarse.
   Comprueba que los dos ojos muestran y ocultan cada campo por separado.
2. Registra un correo accesible con una contraseña válida. Durante la espera
   aparece un indicador y se evitan solicitudes repetidas.
3. Con confirmación activada, debes ver **¡Revisa tu correo!** en una pantalla
   independiente. Pulsa **Ir a iniciar sesión** o Atrás: ambos vuelven al login,
   sin dejar el registro debajo. Confirma el enlace del correo antes de entrar.
   Revisa el usuario y su confirmación en **Authentication > Users** de Supabase.
   Supabase puede dar una respuesta ambigua si el correo ya existe.
4. Intenta entrar antes de confirmar: se muestra el aviso correspondiente.
   Prueba una contraseña incorrecta: no debe abrir el mapa.
5. Con los datos correctos debe abrir **Mapa de mundos** sin el aviso de demo.
   Si desactivaste Confirm email, el registro puede devolver una sesión y abrir
   el mapa directamente.
6. Reinicia y abre **Vista previa de mundos**: debe verse el aviso de demo.
   Juega el Volcánico, revisa resultados y vuelve al mapa. No se guarda progreso
   ni se llama al servicio de autenticación desde la demo.
7. Sin conexión, el formulario debe mostrar un mensaje y permitir reintentar.

El SDK administra la persistencia y renovación de la sesión real. Este avance
mantiene la bienvenida inicial y la entrada explícita por login; no añade
redirección automática por sesión guardada, cierre de sesión ni recuperación
de contraseña.

## Pruebas

No requieren Publishable key, credenciales reales ni acceso al proyecto Supabase:

```powershell
flutter analyze
flutter test
```

Se comprueban validaciones, errores, carga, solicitudes duplicadas, navegación
con y sin sesión, confirmación de correo, demostración y respuestas tardías al
abandonar el login. Las pruebas de interfaz usan un servicio simulado; el envío
de correo y la autenticación contra Supabase se comprueban manualmente.
Se conservan las pruebas del banco local, las respuestas aleatorias y las
partidas con 0, 6 y 10 aciertos, resultados y reinicio.
También se comprueban los ojos independientes, el registro con error y el
desplazamiento del mapa en pantallas pequeñas con plataformas Android/iOS.

El mapa conserva un único `ListView`: respecto al commit `cc5b4fa`, el tercer
avance solo agregó el aviso de demo y un espacio de 16 píxeles. No se modifican
sus físicas de desplazamiento sin un defecto reproducible. Al probarlo en el
emulador, revisa ambos extremos de la lista y el comportamiento al soltar el dedo.

Referencias oficiales: [inicialización de Flutter](https://supabase.com/docs/reference/dart/initializing),
[inicio de sesión](https://supabase.com/docs/reference/dart/auth-signinwithpassword) y
[registro y confirmación de correo](https://supabase.com/docs/reference/dart/auth-signup).
