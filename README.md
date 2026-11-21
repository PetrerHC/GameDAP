# GameDAP

Guía para instalar y abrir GameDAP desde cero en Windows usando Google Chrome, al terminar podrás entrar a la aplicación, crear una cuenta y guardar publicaciones, comentarios y likes.

La aplicación trabaja con tres partes, Flutter muestra las pantallas, Python recibe lo que haces en ellas y MariaDB guarda la información para que siga disponible cuando vuelvas a entrar.

## Antes de empezar

Necesitas una computadora con Windows 10 u 11 de 64 bits, conexión a internet para las descargas y permiso para instalar programas, esta guía usa todos los componentes en la misma computadora.

| Herramienta | Para qué se necesita | 
| ----- | ----- | 
| Google Chrome | Abrir y usar la aplicación | 
| Git | Descargar el proyecto y permitir que Flutter funcione | 
| Visual Studio Code | Abrir la carpeta del proyecto y editar su configuración | 
| Flutter y Dart | Preparar las pantallas y ejecutarlas en Chrome | 
| Python 3.13 | Ejecutar la parte que recibe y guarda los datos | 
| MariaDB | Guardar usuarios, publicaciones, comentarios y likes | 
| HeidiSQL | Abrir la base de datos con botones y cargar el archivo del proyecto | 

MariaDB y MySQL son programas distintos que sirven para guardar datos, en esta guía instalaremos MariaDB y con eso basta para seguir los pasos.

Cuando se mencione PowerShell, abre Inicio en Windows, escribe `PowerShell` y abre el programa, es la ventana donde pegarás los comandos que aparecen dentro de los recuadros.

Copia cada línea y presiona Enter, espera a que termine antes de continuar con la siguiente, si aparece un error revisa la sección **Si algo no funciona** antes de avanzar.

## Paso 1 — Instalar Google Chrome

1. Abre el navegador que ya tenga tu computadora, puede ser Microsoft Edge

2. Entra a [descargar Google Chrome](https://www.google.com/chrome/)

3. Presiona **Descargar Chrome** y abre el archivo descargado

4. Acepta el permiso de Windows si aparece y espera a que termine la instalación

5. Abre Chrome y comprueba que puedes visitar una página

Si Chrome ya está instalado y abre correctamente, puedes continuar con el siguiente paso.

## Paso 2 — Instalar Git

1. Entra a [descargar Git para Windows](https://git-scm.com/install/windows)

2. Descarga el instalador para Windows de 64 bits y ábrelo

3. Avanza con **Next**, puedes conservar las opciones que vienen seleccionadas

4. Si aparece una pantalla sobre el uso de Git desde otros programas, conserva **Git from the command line and also from 3rd-party software**

5. Presiona **Install** y al terminar cierra el instalador

6. Abre una nueva ventana de PowerShell y ejecuta lo siguiente

```
git --version

```

Debe aparecer el nombre de Git acompañado de un número de versión.

## Paso 3 — Instalar Visual Studio Code

1. Entra a [descargar Visual Studio Code](https://code.visualstudio.com/download)

2. Elige la descarga para Windows y abre el instalador

3. Acepta las condiciones y conserva las opciones normales de instalación

4. Deja marcada la opción **Agregar a PATH** si aparece y termina la instalación

5. Abre Visual Studio Code y presiona `Ctrl + Shift + X`

6. Busca **Flutter** e instala la extensión publicada por **Dart Code**

7. Revisa que también aparezca instalada la extensión **Dart**, normalmente se agrega junto con la de Flutter

Las extensiones ayudan a trabajar con los archivos, el siguiente paso instala Flutter para que también puedas ejecutar la aplicación.

## Paso 4 — Instalar Flutter y dejar listo Dart

### Descargar Flutter

1. Abre la [página de descarga de Flutter](https://docs.flutter.dev/install/manual)

2. Selecciona Windows y descarga el archivo ZIP de la versión estable, identificada como **stable**

3. Abre el Explorador de archivos y busca el ZIP descargado

4. Haz clic derecho y selecciona **Extraer todo**

5. Coloca la carpeta llamada `flutter` directamente en `C:\`, de forma que exista `C:\flutter\bin`

Si ya tienes Flutter en otra carpeta puedes conservarlo y usar su ubicación en los pasos siguientes, evita colocarlo dentro de `Archivos de programa` o en una ruta con espacios.

### Hacer que Windows encuentre Flutter

1. Abre Inicio y busca **Editar las variables de entorno de esta cuenta**

2. En las variables de tu usuario selecciona **Path** y presiona **Editar**

3. Presiona **Nuevo** y agrega esta ruta sin borrar las que ya existan

```
C:\flutter\bin

```

4. Acepta las ventanas para guardar los cambios

5. Cierra y vuelve a abrir PowerShell y Visual Studio Code

6. Ejecuta estos comandos en PowerShell

```
flutter --version
dart --version

```

Dart es el lenguaje con el que están hechas las pantallas y ya viene incluido al instalar Flutter, no necesitas descargarlo por separado.

Las dependencias guardadas en `flutter_application_3/pubspec.lock` requieren Flutter **3.47.0 o posterior** y Dart **3.13.0 o posterior, dentro de la versión 3**, revisa que los números que aparecen cumplan con eso.

Si el archivo `pubspec.lock` de tu copia marca otros números mínimos, puedes confirmarlos abriendo `flutter_application_3/pubspec.lock` y revisando las últimas líneas en la sección `sdks:`.

### Revisar que Flutter encuentre Chrome

```
flutter doctor
flutter devices

```

En la revisión deben aparecer Flutter y Chrome disponibles, en la lista de dispositivos busca **Chrome (web)**.

Para abrir esta aplicación en Chrome no necesitas instalar Android Studio, un emulador, Java ni Visual Studio, los avisos relacionados solamente con Android o con aplicaciones de escritorio no impiden seguir esta guía.

Si Visual Studio Code te pide la ubicación de Flutter, elige `C:\flutter` o la carpeta donde lo hayas instalado.

## Paso 5 — Instalar Python

1. Entra a [descargar Python para Windows](https://www.python.org/downloads/windows/)

2. Busca una versión de **Python 3.13** y selecciona **Windows installer (64-bit)**

3. Abre el instalador y marca **Add python.exe to PATH**

4. Presiona **Install Now** y espera a que termine

5. Cierra y vuelve a abrir PowerShell

6. Comprueba la instalación con estos comandos

```
py -3.13 --version
py -3.13 -m pip --version

```

El primer comando debe mostrar Python 3.13 y el segundo debe mostrar una versión de `pip`, que es la herramienta con la que Python descarga los complementos que necesita el proyecto.

En la página de Python, algunas versiones de mantenimiento más recientes de la rama 3.13 solo publican el código fuente y no incluyen instalador para Windows; si no ves el archivo en la primera que entres, baja un poco en la lista y elige una versión 3.13 que sí tenga el enlace **Windows installer (64-bit)**. También puedes instalarlo directamente desde PowerShell ejecutando `winget install Python.Python.3.13`.

Si ya tienes Python 3.13 y ambos comandos funcionan, no necesitas instalarlo otra vez.

## Paso 6 — Instalar MariaDB

### Descargar e instalar

1. Entra a [descargar MariaDB](https://mariadb.com/downloads/)

2. Elige **Community Server**, una versión estable y **MS Windows de 64 bits**

3. Descarga el instalador con terminación `.msi` y ábrelo

4. Acepta las condiciones y conserva los componentes habituales, incluyendo **Database instance** y **HeidiSQL**

5. Escribe una contraseña para el usuario `root` y guárdala porque la usarás más adelante

6. Conserva desactivado el acceso remoto de `root` y la creación de usuarios anónimos

7. Deja marcada **Install as service** con el nombre **MariaDB**, esto permite que siga funcionando en segundo plano

8. Deja marcada **Enable networking** y conserva el puerto **3306**

9. Presiona **Install** y después **Finish**

El puerto es el número que usa la aplicación para encontrar la base de datos, normalmente es `3306` y debe coincidir en todas las configuraciones.

Al elegir la contraseña de `root`, procura usar solo letras y números y evita comillas (`'` o `"`), espacios o símbolos como `#` y `$`, así evitarás problemas cuando Python lea el archivo de configuración en el paso 9.

### Si ya tienes MySQL, MariaDB o XAMPP

Puedes usar una instalación existente de MySQL o MariaDB si conoces su usuario, contraseña y puerto, no hace falta instalar otra copia para este proyecto.

Si eliges instalar otra copia y el puerto `3306` ya está ocupado, usa uno libre como `3307` y anótalo, después tendrás que escribir ese mismo número en HeidiSQL y en el archivo de conexión.

Si vas a usar MariaDB desde XAMPP, inicia su botón **MySQL** antes de continuar, Apache y phpMyAdmin no son necesarios para abrir GameDAP en Chrome.

### Comprobar que MariaDB está encendido

1. Presiona `Windows + R`, escribe `services.msc` y presiona Enter

2. Busca el servicio **MariaDB** o el nombre que elegiste al instalarlo

3. Revisa que su estado diga **En ejecución**

4. Si está detenido, haz clic derecho sobre él y selecciona **Iniciar**

Si usas MySQL instalado por separado, revisa su servicio en la misma ventana, puede tener un nombre como `MySQL80`.

## Paso 7 — Descargar y abrir el proyecto

Los ejemplos siguientes usan la carpeta `GameDAP` dentro de tu carpeta de usuario de Windows, `$env:USERPROFILE` representa esa ubicación y no tienes que cambiarlo por tu nombre.

Abre PowerShell y ejecuta cada línea por separado.

```
Set-Location $env:USERPROFILE
git clone https://github.com/PetrerHC/GameDAP
Set-Location GameDAP

```

Si GitHub solicita iniciar sesión, usa una cuenta con acceso al proyecto, si ya tienes la carpeta descargada puedes usarla directamente sin repetir la descarga.

En Visual Studio Code entra a **Archivo > Abrir carpeta** y selecciona `GameDAP`, debes ver estos elementos en el lado izquierdo.

| Elemento | Qué contiene | 
| ----- | ----- | 
| `backend_API` | La parte que trabaja con los datos | 
| `backend_API/bd.sql` | La base de datos preparada para cargarla | 
| `flutter_application_3` | Las pantallas de la aplicación | 
| `requirements.txt` | La lista de complementos de Python | 
| `README.md` | Esta guía | 

Si guardaste el proyecto en otro lugar, usa esa ubicación en los comandos que contienen `GameDAP`, debe ser la carpeta donde se encuentran `backend_API` y `flutter_application_3`.

Si descargaste el proyecto desde GitHub como archivo ZIP en lugar de usar `git clone`, Windows lo extraerá con el nombre `GameDAP-main`; cámbiale el nombre a `GameDAP` para que coincidan las rutas de los pasos siguientes.

Revisa también que dentro de `backend_API` exista la carpeta `uploads`; si no aparece porque Git no descarga carpetas vacías, créala con clic derecho > **Nueva carpeta** y nómbrala `uploads` para que puedas guardar fotos en tus publicaciones.

## Paso 8 — Cargar la base de datos

Este paso se hace una sola vez en una base nueva, el archivo incluye las tablas y algunos datos de ejemplo.

### Abrir la conexión en HeidiSQL

1. Abre HeidiSQL desde Inicio, si no se instaló junto con MariaDB descarga su instalador desde [HeidiSQL](https://www.heidisql.com/download.php) y completa la instalación con las opciones habituales

2. Presiona **Nueva** o **New** y escribe `GameDAP` como nombre de la conexión

3. Completa los campos con estos datos

| Campo | Valor | 
| ----- | ----- | 
| Tipo de red | MariaDB o MySQL mediante TCP/IP | 
| Nombre del host o IP | `127.0.0.1` | 
| Usuario | `root` | 
| Contraseña | La que elegiste al instalar MariaDB | 
| Puerto | `3306` o el que hayas elegido | 

4. Presiona **Abrir** u **Open**

`127.0.0.1` significa que la base de datos está en esta misma computadora, el usuario `root` pertenece a MariaDB y es diferente de las cuentas con las que después entrarás a GameDAP.

### Cargar el archivo del proyecto

1. Revisa el panel izquierdo, si ya existe `bd_aplicacion_movil` con tablas y datos no vuelvas a cargar el archivo encima

2. Para una instalación nueva entra a **Archivo > Ejecutar archivo SQL** o **File > Run SQL file**

3. Selecciona `bd.sql` dentro de la carpeta `GameDAP\backend_API`

4. Si aparece la opción de codificación, selecciona **UTF-8** para conservar los acentos

5. Confirma la ejecución y espera a que termine sin errores

6. Actualiza el panel izquierdo y abre la base llamada `bd_aplicacion_movil`

El archivo crea la base automáticamente, dentro deben aparecer estas cinco tablas.

* `usuario`

* `blog`

* `comentarios`

* `likes_blog`

* `likes_comentario`

Si ya tienes datos de otra versión, guarda una copia antes de realizar cambios y revisa la sección de errores de tablas, cargar `bd.sql` otra vez no actualiza una base antigua.

## Paso 9 — Escribir los datos de conexión

1. Regresa a Visual Studio Code y abre la carpeta `backend_API` del panel izquierdo

2. Haz clic derecho en esa carpeta y selecciona **Nuevo archivo**

3. Escribe `.env` como nombre completo, debe empezar con un punto y no terminar en `.txt`

4. Si el archivo ya existe, ábrelo para revisar sus datos en lugar de crear otro

5. Escribe lo siguiente y cambia el texto de la contraseña por la que elegiste al instalar MariaDB

```
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=root
DB_PASSWORD='ESCRIBE_AQUI_TU_CONTRASENA'
DB_NAME=bd_aplicacion_movil

```

Conserva las comillas alrededor de la contraseña y escribe dentro tu valor real, si elegiste otro usuario o puerto también debes cambiarlo aquí.

Si ya tenías una contraseña en MariaDB o MySQL y contiene comillas simples (`'`), cámbiala por una con solo letras y números para evitar que corte la lectura del archivo `.env`.

| Dato | Qué debes poner | 
| ----- | ----- | 
| `DB_HOST` | `127.0.0.1` para trabajar en esta computadora | 
| `DB_PORT` | El mismo puerto que usaste en HeidiSQL | 
| `DB_USER` | El usuario de MariaDB con el que abriste la conexión | 
| `DB_PASSWORD` | La contraseña de ese usuario de MariaDB | 
| `DB_NAME` | `bd_aplicacion_movil` | 

Presiona `Ctrl + S` para guardar, el archivo debe quedar dentro de `backend_API` junto a `main.py` y `database.py`.

Este archivo contiene tu contraseña de la base de datos y se crea en cada computadora, el proyecto ya está configurado para excluirlo de las subidas normales a GitHub.

## Paso 10 — Instalar los complementos de Python

Abre PowerShell y entra a la carpeta `backend_API`.

```
Set-Location "$env:USERPROFILE\GameDAP\backend_API"

```

Crea la carpeta donde se guardarán los complementos de Python para este proyecto, este comando se necesita la primera vez.

```
py -3.13 -m venv venv

```

Cuando termine, instala los complementos de la lista del proyecto.

```
.\venv\Scripts\python.exe -m pip install --upgrade pip
.\venv\Scripts\python.exe -m pip install -r ..\requirements.txt
.\venv\Scripts\python.exe -m pip check

```

`..\requirements.txt` indica que la lista está una carpeta arriba, en la carpeta principal de GameDAP, no dentro de `backend_API`.

El último comando debe mostrar `No broken requirements found`, eso indica que los complementos instalados no presentan conflictos entre sí.

| Complemento | Para qué lo usa la aplicación | 
| ----- | ----- | 
| FastAPI y Uvicorn | Recibir las acciones que realizas desde Chrome | 
| SQLAlchemy y PyMySQL | Consultar y guardar información en MariaDB | 
| python-dotenv | Leer el archivo `.env` | 
| python-multipart | Recibir las imágenes de las publicaciones | 
| pwdlib y argon2-cffi | Guardar las contraseñas de las cuentas de forma protegida | 
| Pydantic | Revisar que los datos recibidos tengan el formato esperado | 

La lista también instala los complementos que necesitan estas herramientas, no hace falta buscarlos uno por uno.

Los comandos llaman directamente al Python de la carpeta `venv`, por eso no necesitas ejecutar `Activate.ps1` ni cambiar los permisos de PowerShell.

## Paso 11 — Instalar los complementos de Flutter

En PowerShell entra a la carpeta de las pantallas y descarga lo que necesita el proyecto.

```
Set-Location "$env:USERPROFILE\GameDAP\flutter_application_3"
flutter pub get

```

Espera a que termine sin errores, normalmente verás el mensaje `Got dependencies!`.

| Complemento | Para qué sirve | 
| ----- | ----- | 
| `http` | Enviar y recibir los datos de la aplicación | 
| `image_picker` | Elegir una foto para una publicación | 
| `giphy_get` | Buscar y elegir GIFs para agregarlos en la aplicación | 
| `cupertino_icons` | Mostrar algunos iconos | 
| `flutter_map` y `latlong2` | Mostrar el mapa y sus ubicaciones | 
| `google_maps_flutter` | Complemento de mapas que también está declarado en el proyecto | 
| `flutter_test` y `flutter_lints` | Ayudar a revisar el código | 

Estos complementos ya están escritos en `pubspec.yaml`, el comando los instala y usa las versiones guardadas en `pubspec.lock`, no necesitas editar esos archivos para seguir la guía.

La pantalla de mapa conectada en el proyecto usa OpenStreetMap y necesita internet para cargar el mapa, esa pantalla no requiere una clave de Google Maps.

El buscador de GIFs (`giphy_get`) también necesita conexión a internet para mostrar y cargar los resultados, y se instala automáticamente con `flutter pub get` sin pasos adicionales.

## Paso 12 — Encender la parte que guarda los datos

Ahora vas a usar dos ventanas de PowerShell, deja esta primera ventana abierta mientras uses GameDAP.

Comprueba que MariaDB esté encendido y ejecuta lo siguiente en la primera ventana.

```
Set-Location "$env:USERPROFILE\GameDAP\backend_API"
.\venv\Scripts\python.exe -m uvicorn main:app --host 127.0.0.1 --port 8000

```

Debe aparecer un mensaje parecido a `Uvicorn running on http://127.0.0.1:8000`, esta parte del programa también se llama API y se encarga de recibir lo que envían las pantallas.

Si aparece una ventana del Firewall de Windows Defender pidiendo permiso de red la primera vez que inicias Python, presiona **Permitir acceso** para que Chrome pueda comunicarse con la API.

### Comprobar que responde y puede leer la base

1. Abre [la comprobación de la API](http://127.0.0.1:8000/) en Chrome

2. Debe aparecer el mensaje que se muestra abajo

```
{"mensaje":"API funcionando correctamente"}

```

3. Abre [la lista de publicaciones](http://127.0.0.1:8000/blogs)

4. Si cargaste `bd.sql`, deben aparecer los datos de las dos publicaciones de ejemplo como texto

La primera dirección comprueba que Python está respondiendo, la segunda también comprueba que puede leer las tablas de la base de datos.

En [la página de pruebas](http://127.0.0.1:8000/docs) puedes ver las acciones disponibles, para continuar con la instalación basta con que las dos comprobaciones anteriores funcionen.

## Paso 13 — Abrir GameDAP en Chrome

Abre una segunda ventana de PowerShell y ejecuta lo siguiente sin cerrar la primera.

```
Set-Location "$env:USERPROFILE\GameDAP\flutter_application_3"
flutter run -d chrome

```

La primera ejecución puede tardar varios minutos mientras Flutter prepara la aplicación, cuando termine se abrirá una ventana de Chrome con la pantalla de inicio de sesión de GameDAP.

Si Windows Defender vuelve a mostrar un aviso de firewall al abrir Flutter o Chrome, presiona **Permitir acceso**.

Flutter ya está configurado para comunicarse con `http://127.0.0.1:8000` cuando se ejecuta en Chrome, no necesitas cambiar archivos de Dart para esta instalación.

La dirección de la ventana de GameDAP puede tener un número diferente al `8000`, es normal porque una dirección muestra las pantallas y la otra recibe sus datos.

Para que todo siga funcionando deben permanecer encendidos MariaDB, la primera ventana con Python y la segunda ventana con Flutter.

## Paso 14 — Entrar por primera vez

### Crear tu propia cuenta

1. En el inicio de sesión presiona **Crear una cuenta**

2. Escribe tu nombre y correo, puedes dejar la dirección vacía

3. Elige una contraseña de entre 8 y 128 caracteres y repítela en la confirmación

4. Presiona **Registrar usuario**

5. Cuando aparezca la confirmación, entra con ese correo y esa contraseña

Las cuentas creadas desde esta pantalla son de usuario general, desde ellas puedes consultar publicaciones, publicar, comentar y dar like.

### Entrar con las cuentas de ejemplo

El archivo de la base incluye estas cuentas.

| Correo | Tipo de cuenta | 
| ----- | ----- | 
| `adriana@ejemplo.com` | Administradora | 
| `carlos@ejemplo.com` | Usuario general | 

Estas cuentas todavía no tienen una contraseña que sirva para iniciar sesión, el texto `HASH_DE_PRUEBA` que aparece en la base no es una contraseña para escribir en la aplicación.

Para asignarle una contraseña a una cuenta de ejemplo sigue estos pasos.

1. En el inicio de sesión escribe su correo en **Correo electrónico**

2. Presiona **¿Olvidaste tu contraseña?**

3. Escribe una contraseña nueva de entre 8 y 128 caracteres y repítela

4. Presiona **Guardar contraseña**

5. Regresa al inicio de sesión y entra con ese correo y la contraseña que acabas de guardar

La cuenta administradora abre la gestión de usuarios, desde el menú lateral puedes entrar a **Inicio (Blog)**, **Registrar usuario**, **Agregar blog** y **Mi perfil**.

Esta copia está pensada para prácticas en tu computadora, la recuperación cambia la contraseña con solo conocer el correo y las acciones del servidor todavía no comprueban los permisos de cada cuenta, por eso esta guía mantiene la ejecución dentro de tu computadora.

## Paso 15 — Cerrar y volver a abrir otro día

Para detener la aplicación presiona `q` en la ventana de Flutter y `Ctrl + C` en la ventana de Python, cerrar esas ventanas no borra lo que guardaste en la base de datos.

La siguiente vez solo necesitas comprobar que MariaDB esté encendido y abrir las dos ventanas de PowerShell.

**Primera ventana**

```
Set-Location "$env:USERPROFILE\GameDAP\backend_API"
.\venv\Scripts\python.exe -m uvicorn main:app --host 127.0.0.1 --port 8000

```

**Segunda ventana**

```
Set-Location "$env:USERPROFILE\GameDAP\flutter_application_3"
flutter run -d chrome

```

Las instalaciones y la carga de `bd.sql` no se repiten cada vez que abres la aplicación, solo vuelve a instalar los complementos si cambia la lista que usa el proyecto.

## Si algo no funciona

### Windows no reconoce flutter, dart o git

Cierra y vuelve a abrir PowerShell y Visual Studio Code, si sigue igual revisa el paso de instalación de esa herramienta, para Flutter la entrada de **Path** debe terminar en `flutter\bin` y dentro de esa carpeta debe existir `flutter.bat`.

### Python no aparece o Windows abre Microsoft Store

Usa `py -3.13 --version` como indica la guía, si tampoco funciona vuelve a abrir el instalador de Python 3.13 y comprueba que estén instalados Python, pip y el lanzador de Python, después abre otra ventana de PowerShell.

### Flutter indica que la versión de Dart es demasiado antigua

Actualiza Flutter y comprueba otra vez sus versiones.

```
flutter channel stable
flutter upgrade
flutter --version
dart --version

```

Después vuelve a ejecutar `flutter pub get` dentro de `flutter_application_3`, Dart se actualiza junto con Flutter y no necesitas instalar otra copia por separado.

### Flutter pide activar el Modo para desarrolladores (symlinks)

Si al ejecutar `flutter pub get` o `flutter run` aparece un mensaje indicando que el soporte para enlaces simbólicos (*symlinks*) requiere activar el modo de desarrollador, abre la configuración desde PowerShell.

```
start ms-settings:developers

```

Activa el interruptor de **Modo para desarrolladores**, acepta el aviso de Windows y vuelve a ejecutar el comando de Flutter.

### Chrome no aparece en flutter devices

Abre Chrome una vez y vuelve a abrir PowerShell, después ejecuta lo siguiente.

```
flutter config --enable-web
flutter devices

```

Si aún no aparece, confirma que Chrome esté instalado para tu usuario de Windows y vuelve a completar su instalación del paso 1.

### PowerShell bloquea pip.exe o Activate.ps1

Usa los comandos con `.\venv\Scripts\python.exe -m pip` del paso 10, no necesitas activar la carpeta `venv` para utilizarlos.

Si Windows también bloquea `python.exe`, la persona que administra el equipo tendrá que autorizar esa instalación antes de continuar.

### No se encuentra requirements.txt o pubspec.yaml

Revisa la carpeta que aparece en PowerShell, los comandos de Python se ejecutan desde `backend_API` y usan `..\requirements.txt`, los de Flutter se ejecutan desde `flutter_application_3`.

### Fallan las descargas de complementos

Comprueba tu conexión a internet y repite el comando que falló, si Python dice `No matching distribution found` revisa que estés usando Python 3.13 de 64 bits y conserva las versiones escritas en `requirements.txt` para poder identificar cuál no se pudo descargar.

### Aparece Access denied o el error 1045

El usuario o la contraseña de MariaDB no coinciden, prueba los mismos datos en HeidiSQL y corrige `DB_USER` y `DB_PASSWORD` en `.env`, después detén Python con `Ctrl + C` y vuelve a ejecutar el comando del paso 12.

### Aparece el error 2003, 10061 o no se puede conectar a MySQL

Revisa que MariaDB esté en ejecución y que `DB_PORT` coincida con el puerto de HeidiSQL, si utilizaste `3307` también debe aparecer `3307` en `.env`.

### Aparece Unknown database o el error 1049

La base todavía no existe en la conexión que está usando Python o su nombre no coincide, revisa que HeidiSQL use el mismo host y puerto que `.env` y que ahí exista `bd_aplicacion_movil`, si es una instalación nueva carga el archivo del paso 8.

### Aparece Table already exists o Duplicate entry al cargar bd.sql

La base ya tiene tablas o datos y no debes volver a ejecutar todo el archivo encima, revisa lo que existe en HeidiSQL antes de continuar para evitar repetir o mezclar información.

### Aparece Unknown column o Table doesn't exist al usar la app

La base no tiene la estructura que espera esta versión del proyecto, una instalación nueva debe usar el archivo `backend_API/bd.sql` de esta misma copia de GameDAP.

Si necesitas conservar una base antigua, guarda una copia desde HeidiSQL haciendo clic derecho en la base y eligiendo **Exportar base de datos como SQL**, conserva las tablas y los datos en el archivo de respaldo antes de pedir que se adapte su estructura, este proyecto no incluye un programa de migración automática.

### MySQL solicita cryptography o menciona caching_sha2_password

Esto puede aparecer al usar una instalación existente de MySQL, desde `backend_API` instala el complemento adicional indicado por [PyMySQL](https://pymysql.readthedocs.io/en/latest/user/installation.html) y vuelve a iniciar Python.

```
.\venv\Scripts\python.exe -m pip install "PyMySQL[rsa]"

```

### El puerto 8000 está ocupado

Revisa si ya tienes abierta otra ventana ejecutando GameDAP, puedes usar esa ventana o detenerla con `Ctrl + C` antes de iniciar otra copia.

Si necesitas usar el puerto `8001`, cambia el comando de la primera ventana por este.

```
.\venv\Scripts\python.exe -m uvicorn main:app --host 127.0.0.1 --port 8001

```

En la segunda ventana ejecuta Flutter con la misma dirección nueva.

```
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8001

```

En este caso las comprobaciones de Python también se abren con `8001`, si Flutter ya estaba abierto primero detenlo con `q` y luego ejecuta el nuevo comando.

### La aplicación abre pero no muestra publicaciones o no permite entrar

Abre la dirección de publicaciones del paso 12, si falla revisa la primera ventana de PowerShell y la conexión de MariaDB, si muestra los datos comprueba que Flutter esté usando la misma dirección y puerto.

Para las cuentas de ejemplo primero asigna una contraseña siguiendo el paso 14, si la lista aparece vacía como `[]` y no cargaste los datos de ejemplo todavía no hay publicaciones guardadas.

### Aparece ClientException: XMLHttpRequest error en la pantalla

Este mensaje indica que la pantalla en Chrome no logra comunicarse con Python. Comprueba que la primera ventana de PowerShell con Uvicorn siga abierta sin errores, que MariaDB esté en ejecución y que ambos estén trabajando en `http://127.0.0.1:8000`.

### El botón Tomar foto abre una ventana para elegir un archivo

En Chrome de escritorio puede abrirse el selector de archivos en lugar de una cámara, elige una imagen JPG, JPEG, PNG o WEBP de hasta 8 MB para continuar con la publicación.

### Falla al subir una foto en una publicación nueva

Comprueba que exista la carpeta `uploads` dentro de `backend_API` (`GameDAP\backend_API\uploads`), que la ventana de Python siga abierta y que el archivo elegido sea JPG, JPEG, PNG o WEBP de hasta 8 MB.

### Una imagen de ejemplo o el mapa no carga

Las fotos de ejemplo y el mapa se descargan de internet, comprueba tu conexión, las fotos que agregas tú se guardan en `backend_API/uploads` y también necesitan que la ventana de Python siga abierta.

### Los GIFs no cargan o no aparecen resultados

El buscador de GIFs necesita conexión a internet para consultar y descargar las animaciones; comprueba tu conexión e inténtalo de nuevo.

## Paso 16 — Comprobar que la aplicación ya funciona

Realiza esta prueba con la cuenta que creaste o con una cuenta de ejemplo que ya tenga contraseña, así compruebas que las pantallas y la base de datos trabajan juntas.

 1. Inicia sesión y entra a **Inicio (Blog)** si estás usando la cuenta administradora

 2. Comprueba que se muestren las publicaciones de ejemplo

 3. Presiona el botón **+** para crear una publicación o entra a **Agregar blog** desde el menú de administrador

 4. Escribe un título y una descripción, las etiquetas son opcionales

 5. Presiona **Tomar foto** y elige una imagen JPG, JPEG, PNG o WEBP de hasta 8 MB

 6. Presiona **Guardar publicación** y comprueba que aparezca en el inicio, si hace falta usa el botón de actualizar publicaciones

 7. Abre esa publicación, agrega un comentario y da like

 8. Vuelve al inicio, actualiza las publicaciones y entra de nuevo para comprobar que el comentario y el like siguen guardados

 9. Cierra sesión desde el menú y vuelve a entrar con la misma cuenta

10. Revisa que la publicación y el comentario sigan disponibles después de volver a entrar

Si puedes completar esta prueba, GameDAP ya está funcionando en Chrome con la información guardada en MariaDB.
