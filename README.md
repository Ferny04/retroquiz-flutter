# RetroQuiz: Aventura Multiverso

El quinto avance agrega un avatar por cuenta en Supabase Storage. El mapa
muestra la imagen al iniciar sesión y permite cambiarla desde el icono de perfil.

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
  y no modifica esa sesión. La demo tampoco consulta ni permite cambiar avatares.
- Avatar privado para cuentas autenticadas. Acepta JPG y PNG de hasta 2 MB.
- Planeta Volcánico: 10 preguntas por partida desde el banco local de 24 preguntas
  de seis categorías, preguntas y respuestas aleatorias, puntuación y resultados.
- Al terminar las 10 preguntas con sesión, guarda el mundo como completado y
  conserva la mejor puntuación. Completar significa terminar, incluso con 0 aciertos.
- Reino Arcoíris se desbloquea al recuperar ese progreso. Al tocarlo muestra un
  aviso de próximas preguntas; los mundos del tres al seis siguen bloqueados.

No hay ranking, vidas, modo ultradifícil ni nuevos planetas jugables.

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
   sesión manualmente.
5. Si estás preparando un proyecto vacío, aplica una sola vez la
   [migración de progreso](supabase/migrations/004_world_progress.sql).
6. Para el quinto avance, revisa la
   [migración de avatares](supabase/migrations/005_player_avatars.sql) y ejecútala
   completa una vez en **SQL Editor > New query**. Si el proyecto ya tiene
   `world_progress`, ejecuta únicamente la migración de avatares.
7. En **Storage**, comprueba que `player-avatars` sea privado, que tenga un límite
   de 2 MB por archivo y que permita `image/jpeg` y `image/png`.

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

Requiere Flutter 3.47.0 o superior con Dart `^3.13.2`, un dispositivo/emulador o
destino de escritorio/web configurado, y conexión a Internet para autenticar.

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
git diff --check
```

Se comprueban validaciones, errores, carga, solicitudes duplicadas, navegación
con y sin sesión, confirmación de correo, demostración y respuestas tardías al
abandonar el login. Las pruebas de interfaz usan un servicio simulado; el envío
de correo y la autenticación contra Supabase se comprueban manualmente.
Se conservan las pruebas del banco local, las respuestas aleatorias y las
partidas con 0, 6 y 10 aciertos, resultados y reinicio.
También se comprueban los ojos independientes, el registro con error y el
desplazamiento del mapa en pantallas pequeñas con plataformas Android/iOS.
Las pruebas de avatar verifican la ruta por cuenta, la descarga autenticada, el
reemplazo del objeto, la validación local, los avisos de error y la demo con una
sesión previa. Usan dobles de prueba y respuestas HTTP simuladas.

El mapa conserva un único `ListView`: respecto al commit `cc5b4fa`, el tercer
avance solo agregó el aviso de demo y un espacio de 16 píxeles. No se modifican
sus físicas de desplazamiento sin un defecto reproducible. Al probarlo en el
emulador, revisa ambos extremos de la lista y el comportamiento al soltar el dedo.

Referencias oficiales: [inicialización de Flutter](https://supabase.com/docs/reference/dart/initializing),
[inicio de sesión](https://supabase.com/docs/reference/dart/auth-signinwithpassword) y
[registro y confirmación de correo](https://supabase.com/docs/reference/dart/auth-signup).

## Cuarto avance: cómo funciona el progreso

La tabla nueva `world_progress` contiene `user_id`, `world_id` (`volcanic`),
`best_score` (0–1000, múltiplos de 100) y `completed`. La clave primaria combina
usuario y mundo: repetir una partida no crea otra fila. No requiere tablas de
mundos, perfiles ni preguntas remotas.

La función SQL `complete_volcanic_world(p_score)` obtiene el usuario con
`auth.uid()`, inserta su progreso y, si ya existe, usa `greatest` para conservar
el máximo. Todo ocurre en una operación, incluso si llegan dos guardados a la vez.
La política RLS permite a cada cuenta leer solamente sus filas; los visitantes
no tienen permisos. `authenticated` solo tiene `SELECT` en la tabla: no puede
insertar, actualizar ni borrar directamente. El guardado pasa por la RPC, que usa
`security definer`, `search_path = ''` y nombres de tabla con esquema explícito.
Ejecuta la migración como `postgres` en SQL Editor, que será el propietario.
La función comprueba que `auth.uid()` no sea nulo y que los puntos no sean nulos,
estén entre 0 y 1000 y sean múltiplos de 100. Solo `authenticated` recibe `EXECUTE`.
El cliente envía únicamente `p_score`; el usuario se obtiene de la sesión del
servidor y no se acepta como parámetro. La RPC devuelve solo la fila que acaba
de guardar para ese usuario, aunque su propietario pueda saltarse RLS.

Las preguntas y el cálculo de puntos siguen siendo locales. El servidor no
comprueba las respuestas ni que se hayan completado las 10 preguntas: una cuenta
autenticada puede enviar cualquier puntuación válida, incluido 1000. Estas
validaciones protegen el acceso y el formato de los datos; no evitan trampas.

Funciones nuevas y cambios que puedes explicar en clase:

| Función o propiedad | Explicación |
| --- | --- |
| `WorldProgress.fromJson` | Convierte la fila recibida en un objeto con cuatro datos. |
| `currentUserId` | Obtiene el identificador de la cuenta que tiene sesión. |
| `loadVolcanicProgress` | Consulta solo el Volcánico del usuario actual; devuelve `null` si todavía no hay partida. |
| `saveVolcanicProgress` | Comprueba la cuenta y los puntos, llama a la función SQL y devuelve la fila guardada. |
| Métodos de `UnavailableProgressService` | Devuelven un error controlado cuando Supabase no está configurado. |
| `_loadProgress` | Muestra carga, consulta el servicio y actualiza el mapa con `setState`; permite reintentar si falla. |
| `_secondWorldUnlocked` | Comprueba que sea una partida real y que el Volcánico esté completado. |
| `_openVolcanicWorld` | Abre la partida con `Navigator` y recarga el progreso al regresar de los resultados. |
| `_showSecondWorld` | Muestra que Reino Arcoíris ya está desbloqueado y tendrá preguntas después. |
| `_saveProgress` | Guarda al abrir resultados, evita solicitudes duplicadas y muestra éxito o un botón para reintentar. |
| `complete_volcanic_world` (SQL) | Inserta o actualiza una sola fila, manteniendo la mejor puntuación. |

`initState` inicia la consulta del mapa o el guardado de resultados una vez.
En la partida captura la cuenta inicial; si cambia o desaparece la sesión, el
servicio rechaza el guardado. `_nextQuestion` ahora espera a que cierres resultados
antes de cerrar también la partida: así vuelves al mapa y consultas el dato guardado.
`main`, bienvenida y login pasan el mismo servicio con parámetros normales de
constructores, sin gestores de estado adicionales ni dependencias nuevas de producción.

La demo omite tanto consultas como guardados, incluso si Supabase conserva una
sesión anterior. Si falla el guardado, los resultados permanecen visibles y puedes
reintentar antes de salir. No hay cola local de partidas pendientes; si sales, ese
resultado no se conserva para reintentar después. Si se perdió la respuesta pero el
servidor sí guardó, repetir la petición mantiene una única fila y el máximo.
Las peticiones de progreso tienen un límite de espera de 15 segundos.

## Comprobar el cuarto avance en Android Studio

1. Verifica en **Table Editor** que exista `world_progress` y que tenga RLS activado.
2. Usa la configuración Flutter de Android Studio descrita arriba, con tu
   Publishable key local. Ejecuta en un emulador o teléfono con Internet.
3. Inicia sesión con una cuenta sin progreso. Reino Arcoíris debe estar bloqueado.
   Abandona una partida antes de la décima pregunta: no debe aparecer una fila.
4. Termina las 10 preguntas. En resultados debe aparecer **Progreso guardado**.
   Comprueba en Supabase una fila con el UUID de esa cuenta, `world_id = volcanic`,
   los puntos obtenidos y `completed = true`.
5. Pulsa **Volver al mapa**. Debe mostrar **Completado**, la mejor puntuación y
   Reino Arcoíris desbloqueado. Al tocar el segundo mundo aparece el aviso; todavía
   no abre otro cuestionario.
6. Repite con menos aciertos: debe quedar una sola fila y conservar el récord.
   Repite con más aciertos y comprueba que aumente.
7. Detén y vuelve a ejecutar la app; entra nuevamente por login. El mapa debe
   recuperar el récord y el desbloqueo. El SDK conserva la sesión, pero la entrada
   sigue siendo explícita por login, como en el tercer avance.
8. Regresa a bienvenida e inicia sesión con otra cuenta: debe ver su propio mapa,
   sin el progreso de la anterior. Revisa las políticas RLS en Supabase;
   **Table Editor** con permisos de administrador puede mostrar ambas cuentas.
9. Abre **Vista previa de mundos**, termina una partida y vuelve al mapa: muestra
   el aviso de demo, no desbloquea el segundo mundo ni modifica filas, aunque haya
   una sesión anterior.
10. Entra al mapa con conexión y después desconecta Internet antes de terminar.
    Espera el error, recupera Internet y pulsa **Reintentar guardado**. Debe guardar
    sin duplicar filas. También entra sin red al mapa, cuando sea posible, y usa
    **Reintentar carga** después de reconectar.

Las nuevas pruebas de interfaz recorren partidas completas, abandono, demo con
sesión previa, errores/reintento, recuperación y desbloqueo. Las pruebas del
servicio usan el cliente Supabase real con respuestas HTTP simuladas (`http` se
añadió solo a `dev_dependencies`). Verifican llamadas, filtros, datos y errores.
El comportamiento SQL del máximo se simula en estas pruebas: ejecutar la migración,
comprobar la concurrencia y verificar RLS contra Supabase real siguen siendo pasos
manuales; las pruebas no usan credenciales ni cambian el backend.

Referencias del guardado: [llamadas RPC desde Flutter](https://supabase.com/docs/reference/dart/rpc)
y [políticas RLS](https://supabase.com/docs/guides/database/postgres/row-level-security).

## Quinto avance de avatar privado

El icono de perfil de **Mapa de mundos** abre el selector de imágenes. Flutter
comprueba el tamaño, identifica el formato por los bytes y verifica que la imagen
se pueda abrir. El bucket privado aplica también el límite de bytes y la lista de
tipos MIME admitidos.

El servicio usa el ID de la sesión para leer y guardar `<uid>/avatar`. El archivo
se reemplaza en la misma ruta aunque cambie de JPG a PNG. Al abrir el mapa,
consulta si hay avatar y descarga sus bytes con el token de la sesión. Una cuenta
sin imagen ve el icono de perfil. Las políticas de Storage permiten leer,
insertar y reemplazar únicamente el objeto cuyo nombre coincide con
`auth.uid() || '/avatar'`. Una política restrictiva aplica ese aislamiento aunque
ya existan permisos generales de Storage. La demo omite toda interacción con el
servicio.
[Control de acceso de Supabase Storage](https://supabase.com/docs/guides/storage/security/access-control).

### Probar el avatar en Android Studio

1. Aplica la migración de avatares y usa la configuración Flutter descrita arriba.
   Detén por completo la app y pulsa **Run** para cargar el plugin nuevo.
2. Guarda un JPG y un PNG pequeños en el dispositivo. En el emulador puedes
   arrastrarlos a su ventana para copiarlos a **Descargas**.
3. Inicia sesión con la cuenta A. Toca el icono de perfil arriba a la derecha,
   identificado como **Cambiar avatar**, y elige una imagen. Debe aparecer
   **Avatar guardado** y verse la imagen en el mapa. En Storage debe haber un
   objeto en la carpeta del UUID de A.
4. Cambia al otro formato. Comprueba que se actualice la imagen y se conserve un
   solo objeto. Detén la app, vuelve a ejecutarla e inicia sesión con A para
   comprobar que recupera el avatar.
5. Vuelve a la bienvenida e inicia sesión con B. Comprueba que vea su propio
   avatar o el icono de perfil. Guarda una imagen con B y revisa que la de A
   siga igual. Abre **Vista previa de mundos** con una sesión previa y verifica
   que no aparezca el control de avatar.
6. Cancela el selector y comprueba que se conserve el avatar. Prueba una imagen
   de más de 2 MB y un formato no admitido, como WebP si el selector lo muestra.
   Desactiva la red después de abrir el mapa para probar el aviso de subida.
   Para probar la recuperación, entra al mapa y corta la red antes de que
   termine la consulta. Reconecta y pulsa **Reintentar** si aparece el aviso.
7. Completa el Volcánico y comprueba que se guarde el progreso, se muestre el
   récord y se desbloquee Reino Arcoíris.

Si Android cierra RetroQuiz mientras está abierto el selector, vuelve a iniciar
sesión y selecciona la imagen de nuevo.

Para verificar las políticas en Supabase real, usa un cliente HTTP con la
Publishable key en `apikey` y el token de acceso de B en `Authorization: Bearer`.
Prueba GET contra `/storage/v1/object/authenticated/player-avatars/<uid-de-A>/avatar`
y POST con una imagen válida y `x-upsert: true` contra
`/storage/v1/object/player-avatars/<uid-de-A>/avatar`. Ninguna operación debe
tener éxito. Repite con el UUID propio para verificar el acceso autorizado y
prueba abrir la URL pública del objeto sin sesión. El panel de Storage tiene
permisos de administrador y sirve para inspeccionar los objetos. Las pruebas
automáticas no ejecutan estas comprobaciones contra el proyecto remoto.
