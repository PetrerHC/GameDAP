# GameDAP

Aplicación Flutter con una API en FastAPI. Incluye registro, login, recuperación
directa de contraseña, usuarios, publicaciones, filtros, likes y comentarios.

## Ejecutar la API

Desde la carpeta principal:

```powershell
python -m pip install -r requirements.txt
python -m uvicorn main:app --app-dir backend_API --host 0.0.0.0 --port 8000
```

Configura MySQL en `backend_API/.env`:

```dotenv
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=tu_usuario
DB_PASSWORD=tu_contrasena
DB_NAME=bd_aplicacion_movil
```

- Para una base nueva, importa `backend_API/bd.sql` en MySQL.
- Si ya tienes tablas, respalda la base y ejecuta
  `python backend_API/migrate_schema.py` antes de iniciar la API. El script adapta
  los nombres antiguos, agrega las columnas que faltan y recalcula contadores;
  conserva los registros. Está preparado para MySQL y se puede volver a ejecutar.
- El SQL incluye las cuentas de ejemplo `adriana@ejemplo.com` (administradora) y
  `carlos@ejemplo.com` (usuario). Sus contraseñas se asignan mediante la pantalla
  de recuperación; `HASH_DE_PRUEBA` no es una contraseña.

La documentación de los servicios está en [Swagger](http://127.0.0.1:8000/docs).

## Ejecutar Flutter

```powershell
cd flutter_application_3
flutter pub get
flutter run
```

La app usa `127.0.0.1:8000` en web y `10.0.2.2:8000` en el emulador Android.
Para un teléfono físico, indica la IP de tu computadora en la misma red:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000
```

## Funcionamiento

- **Registro público:** crea usuarios de tipo `2`. En Flutter, solo un administrador ve
  el panel para crear cuentas; ahí el tipo inicial es `1`.
- **Recuperación:** escribe el correo en el login y pulsa “¿Olvidaste tu contraseña?”.
  La siguiente pantalla pide únicamente la contraseña nueva y su confirmación.
  Deben coincidir y tener entre 8 y 128 caracteres. No se envían correos ni códigos.
- **Visitante:** puede leer publicaciones, usar filtros y consultar comentarios.
  En Flutter, para publicar, comentar o dar like necesita iniciar sesión.
- **Likes y comentarios:** se guardan en la API. Los contadores se actualizan
  después de cada acción y al regresar del detalle.
- **Imágenes:** Flutter envía `multipart/form-data` con `titulo`, `desc`, `tags`
  e `imagen`. FastAPI guarda el archivo en `backend_API/uploads/` y devuelve su
  ruta en `img`. Se aceptan JPG, JPEG, PNG y WEBP de hasta 8 MB.
- **Errores:** la API devuelve un mensaje en `detail`; Flutter lo muestra en rojo.
  Las operaciones correctas muestran una confirmación en verde.

La recuperación directa se implementó para esta práctica: quien conozca un correo
registrado puede cambiar su contraseña. Este flujo no verifica la identidad de la
persona y no debe usarse así en una aplicación pública.

La API no exige tokens ni permisos por rol. Puedes probar todos los servicios
directamente en `/docs`, sin usar Authorize. Flutter conserva el usuario localmente
para mostrar sus pantallas y enviar su ID al comentar o dar like.
La configuración HTTP de Android es para el servidor local de desarrollo.

## Servicios usados por Flutter

| Método y ruta | Uso | Acceso |
| --- | --- | --- |
| `POST /login` | Usuario completo, sin contraseña | Público |
| `POST /register` | Registro con tipo `2` | Público |
| `POST /recuperar-password` | `mail`, `password`, `confirmar_password` | Público |
| `POST /logout` | Confirmación de cierre; Flutter limpia el usuario local | Público |
| `GET /usuarios` | Lista de usuarios | Público |
| `POST /usuarios` | Crear un usuario; tipo inicial `1` | Público |
| `PUT /usuarios/{id}` | Cambiar nombre, correo y dirección | Público |
| `DELETE /usuarios/{id}` | Eliminar usuario sin comentarios ni likes | Público |
| `GET /blogs?tag=Minecraft` | Lista, filtro y contadores | Público |
| `POST /blogs` | Crear publicación con foto | Público |
| `GET /blogs/{id}` | Detalle, contadores y `me_gusta` | Público |
| `GET /blogs/{id}/comentarios` | Comentarios de una publicación | Público |
| `POST /comentarios` | `id_usuario`, `id_blog`, `texto`, `id_stiker` | Público |
| `POST /likeblog` | `id_usuario`, `id_blog`; dar like | Público |
| `DELETE /blogs/{id}/likes` | Quitar el like; indicar `?id_usuario=1` | Público |

Las llamadas no necesitan el encabezado `Authorization`. En `GET /blogs` y
`GET /blogs/{id}`, puedes enviar `?id_usuario=1` para consultar `me_gusta`.
Para quitar un like de blog o comentario, el parámetro `id_usuario` es obligatorio.
El ID identifica el registro a consultar o modificar; no es un permiso.
El registro y login aceptan `pass` o `password`. La descripción del blog sale
como `desc`; se mantienen las rutas antiguas `/blog` como alternativa.
Sin sticker, envía `id_stiker: ""`; el servidor asigna nombre, fecha y contadores.

Las consultas, cambios y eliminaciones devuelven **200**; las creaciones, **201**.
Datos inválidos o duplicados devuelven **400**; login incorrecto, **401**;
registros inexistentes, **404**. Un login incorrecto responde:
`{"detail": "Credenciales incorrectas"}`.
