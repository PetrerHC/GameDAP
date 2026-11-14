
# Importa herramientas para administrar el inicio y cierre de la aplicación.
from contextlib import asynccontextmanager


# Permite configurar CORS para aceptar solicitudes desde otras aplicaciones.
from fastapi.middleware.cors import CORSMiddleware
# Importa el tipo de sesión que se utiliza para consultar la base de datos.
from sqlalchemy.orm import Session
# Permite construir consultas SQL de selección con SQLAlchemy.
from sqlalchemy import select
# Permite identificar errores de integridad, como registros duplicados o relaciones inválidas.
from sqlalchemy.exc import IntegrityError
# Proporciona funciones para generar y verificar hashes de contraseñas.
from pwdlib import PasswordHash

# Facilita trabajar con rutas y archivos del sistema.
from pathlib import Path
# Se utiliza para copiar el contenido de las imágenes recibidas.
import shutil
# Genera identificadores únicos para evitar nombres repetidos en las imágenes.
import uuid

# Importa las herramientas principales de FastAPI para crear rutas, validar datos y recibir archivos.
from fastapi import (
    FastAPI,
    Depends,
    HTTPException,
    Response,
    Request,
    UploadFile,
    File,
    Form,
)
# Permite publicar archivos estáticos, como las imágenes subidas.
from fastapi.staticfiles import StaticFiles

# Importa la configuración de la base de datos y la función que proporciona una sesión.
from database import Base, engine, obtener_sesion
# Importa los modelos que representan las tablas de la base de datos.
from models import Usuario, Blog, Comentario, LikeBlog, LikeComentario
# Importa los esquemas que validan los datos de entrada y salida de la API.
from schemas import (
    UsuarioCrear,
    UsuarioActualizar,
    UsuarioRespuesta,
    BlogRespuesta,
    ComentarioCrear,
    ComentarioRespuesta,
    LoginRequest,
    LikeBlogCrear,
    LikeBlogRespuesta,
    LikeComenCrear,
    LikeComenRespuesta,
)

# Crea el administrador de hashes que se usará para proteger y comprobar contraseñas.
password_hash = PasswordHash.recommended()


# Define el ciclo de vida de la aplicación: acciones de inicio y cierre.
@asynccontextmanager
# Función ejecutada durante el ciclo de vida de FastAPI.
async def lifespan(app: FastAPI):
    # Mantiene la aplicación activa; al finalizar, FastAPI continúa con el cierre.
    yield


# Crea la aplicación principal y establece el título que aparece en la documentación.
app = FastAPI(
    title="API de aplicación móvil",
    lifespan=lifespan,
)
# Construye la ruta absoluta de la carpeta donde se guardarán las imágenes.
UPLOAD_DIR = Path(__file__).resolve().parent / "uploads"
# Crea la carpeta de imágenes si todavía no existe.
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)

# Registra una ruta pública para poder consultar los archivos guardados.
app.mount(
    "/uploads",
    StaticFiles(directory=str(UPLOAD_DIR)),
    name="uploads",
)

# Agrega el middleware que controla las solicitudes CORS.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get(
    "/",
    tags=["General"],
    summary="Comprobar el estado de la API",
    description="Devuelve un mensaje para confirmar que el servicio está funcionando.",
)
def inicio():
    return {"mensaje": "API funcionando correctamente"}

@app.post(
    "/login",
    response_model=UsuarioRespuesta,
    tags=["Autenticación"],
    summary="Iniciar sesión",
    description="Valida el correo y la contraseña. Si son correctos, devuelve los datos públicos del usuario.",
)
def iniciar_sesion(
    datos: LoginRequest,
    db: Session = Depends(obtener_sesion),
):
    # Limpia espacios y convierte el correo a minúsculas para buscarlo de forma consistente.
    correo = datos.mail.strip().lower()

    # Busca un único usuario cuyo correo coincida con el recibido.
    usuario = db.scalar(
        select(Usuario).where(Usuario.mail == correo)
    )

    # Usa el mismo mensaje de error para no indicar si el correo existe o no.
    # Se utiliza el mismo mensaje para no revelar
    # si el correo está registrado.
    # Rechaza el acceso si el usuario no existe o la contraseña no coincide con su hash.
    if usuario is None or not password_hash.verify(
        datos.password,
        usuario.pass_hash,
    ):
        raise HTTPException(
            status_code=401,
            detail="Correo o contraseña incorrectos",
        )

    # Devuelve el usuario; el esquema de respuesta determina qué campos se exponen.
    # Devuelve únicamente los datos públicos del usuario.
    return usuario

# ============================================================
# USUARIOS: operaciones para consultar, registrar, modificar y eliminar cuentas.
# ============================================================# USUARIOS

@app.get(
    "/usuarios",
    response_model=list[UsuarioRespuesta],
    tags=["Usuarios"],
    summary="Consultar todos los usuarios",
    description="Devuelve la lista de usuarios registrados.",
)
def listar_usuarios(db: Session = Depends(obtener_sesion)):
    return db.scalars(
        select(Usuario).order_by(Usuario.id_usr)
    ).all()


@app.post(
    "/usuarios",
    response_model=UsuarioRespuesta,
    status_code=201,
    tags=["Usuarios"],
    summary="Registrar un usuario",
    description="Crea una cuenta nueva. La contraseña se guarda mediante un hash seguro.",
)
def crear_usuario(
    datos: UsuarioCrear,
    db: Session = Depends(obtener_sesion),
):
    # Construye el objeto Usuario con los datos recibidos.
    usuario = Usuario(
        nom_usr=datos.nom_usr.strip(),
        mail=datos.mail.strip().lower(),
        # Nunca guarda la contraseña original: almacena su hash.
        pass_hash=password_hash.hash(datos.password),
        dir_usr=datos.dir_usr,
        tip_usu=datos.tip_usu,
    )

    # Agrega el nuevo usuario a la sesión para prepararlo para guardar.
    db.add(usuario)

    # Intenta guardar los cambios en la base de datos.
    try:
        # Confirma la transacción y guarda los cambios.
        db.commit()
        # Actualiza el objeto con los valores definitivos asignados por la base de datos.
        db.refresh(usuario)
    # Si ocurre un conflicto de integridad, deshace los cambios.
    except IntegrityError:
        # Revierte la transacción para dejar la sesión en un estado consistente.
        db.rollback()
        raise HTTPException(
            status_code=409,
            detail="El correo ya está registrado",
        )

    return usuario


@app.put(
    "/usuarios/{usuario_id}",
    response_model=UsuarioRespuesta,
    tags=["Usuarios"],
    summary="Actualizar un usuario",
    description="Modifica los datos del usuario indicado por su identificador.",
)
def actualizar_usuario(
    usuario_id: int,
    datos: UsuarioActualizar,
    db: Session = Depends(obtener_sesion),
):
    # Busca el usuario por su clave primaria.
    usuario = db.get(Usuario, usuario_id)

    # Comprueba que el usuario exista antes de modificarlo.
    if usuario is None:
        raise HTTPException(
            status_code=404,
            detail="Usuario no encontrado",
        )

    usuario.nom_usr = datos.nom_usr.strip()
    usuario.mail = datos.mail.strip().lower()
    usuario.dir_usr = datos.dir_usr
    usuario.tip_usu = datos.tip_usr

    # Intenta guardar los cambios en la base de datos.
    try:
        # Confirma la transacción y guarda los cambios.
        db.commit()
        # Actualiza el objeto con los valores definitivos asignados por la base de datos.
        db.refresh(usuario)
    # Si ocurre un conflicto de integridad, deshace los cambios.
    except IntegrityError:
        # Revierte la transacción para dejar la sesión en un estado consistente.
        db.rollback()
        raise HTTPException(
            status_code=409,
            detail="El correo ya está registrado",
        )

    return usuario


@app.delete(
    "/usuarios/{usuario_id}",
    status_code=204,
    tags=["Usuarios"],
    summary="Eliminar un usuario",
    description="Elimina la cuenta indicada. No devuelve contenido si la operación se completa.",
)
def eliminar_usuario(
    usuario_id: int,
    db: Session = Depends(obtener_sesion),
):
    # Busca el usuario por su clave primaria.
    usuario = db.get(Usuario, usuario_id)

    # Comprueba que el usuario exista antes de modificarlo.
    if usuario is None:
        raise HTTPException(
            status_code=404,
            detail="Usuario no encontrado",
        )

    # Marca el usuario para eliminarlo al confirmar la transacción.
    db.delete(usuario)

    # Intenta guardar los cambios en la base de datos.
    try:
        # Confirma la transacción y guarda los cambios.
        db.commit()
    # Si ocurre un conflicto de integridad, deshace los cambios.
    except IntegrityError:
        # Revierte la transacción para dejar la sesión en un estado consistente.
        db.rollback()
        raise HTTPException(
            status_code=409,
            detail="No se pudo eliminar el usuario porque tiene datos relacionados",
        )

    return Response(status_code=204)


# ============================================================
# PUBLICACIONES: consulta, creación y detalle de publicaciones.
# ============================================================# BLOG

@app.get(
    "/blog",
    response_model=list[BlogRespuesta],
    tags=["Publicaciones"],
    summary="Consultar publicaciones",
    description="Devuelve todas las publicaciones registradas en el blog.",
)
def listar_blog(db: Session = Depends(obtener_sesion)):
    return db.scalars(
        select(Blog).order_by(Blog.cant_likes.desc())
    ).all()


@app.post(
    "/blog",
    response_model=BlogRespuesta,
    status_code=201,
    tags=["Publicaciones"],
    summary="Crear una publicación",
    description="Registra una publicación con título, descripción, imagen y etiquetas. La imagen debe ser JPG, JPEG, PNG o WEBP.",
)
def crear_blog(
    request: Request,
    titulo: str = Form(...),
    descripcion: str = Form(...),
    imagen: UploadFile = File(...),
    tags: str | None = Form(default=None),
    cant_likes: int = Form(...),
    cant_comentarios: int = Form(...),
    db: Session = Depends(obtener_sesion),
):
    # Verifica que el título y la descripción no estén vacíos.
    if not titulo.strip() or not descripcion.strip():
        raise HTTPException(
            status_code=422,
            detail="El título y la descripción son obligatorios",
        )

    # Obtiene la extensión del archivo y la convierte a minúsculas.
    extension = Path(imagen.filename or "").suffix.lower()
    # Solo permite los formatos de imagen indicados.
    if extension not in {".jpg", ".jpeg", ".png", ".webp"}:
        raise HTTPException(
            status_code=400,
            detail="Formato de imagen no permitido. Usa JPG, JPEG, PNG o WEBP.",
        )

    # Genera un nombre único para evitar sobrescribir otra imagen.
    nombre_archivo = f"{uuid.uuid4().hex}{extension}"
    # Une la carpeta de destino con el nombre del archivo.
    ruta_archivo = UPLOAD_DIR / nombre_archivo

    # Abre el archivo en modo escritura binaria para guardar la imagen.
    with ruta_archivo.open("wb") as destino:
        # Copia los datos recibidos al archivo del servidor.
        shutil.copyfileobj(imagen.file, destino)

    # Construye la dirección pública con la que se podrá consultar la imagen.
    url_imagen = (
        f"{str(request.base_url).rstrip('/')}/uploads/{nombre_archivo}"
    )

    # Crea el objeto de la publicación con los datos del formulario.
    publicacion = Blog(
        titulo=titulo.strip(),
        descripcion=descripcion.strip(),
        img=url_imagen,
        tags=tags.strip() if tags and tags.strip() else None,
        # Inicializa el contador de likes en cero.
        cant_likes = 0,
        # Inicializa el contador de comentarios en cero.
        cant_comentarios = 0,
    )

    # Intenta guardar los cambios en la base de datos.
    try:
        db.add(publicacion)
        # Confirma la transacción y guarda los cambios.
        db.commit()
        db.refresh(publicacion)
    except Exception as error:
        # Revierte la transacción para dejar la sesión en un estado consistente.
        db.rollback()
        # Si falla el guardado en la base de datos, elimina la imagen para no dejar archivos huérfanos.
        ruta_archivo.unlink(missing_ok=True)
        raise HTTPException(
            status_code=500,
            detail="No se pudo guardar la publicación en la base de datos.",
        ) from error

    return publicacion


@app.get(
    "/blog/{blog_id}",
    response_model=BlogRespuesta,
    tags=["Publicaciones"],
    summary="Consultar una publicación",
    description="Devuelve los datos de una publicación mediante su identificador.",
)
def obtener_blog(
    blog_id: int,
    db: Session = Depends(obtener_sesion),
):
    # Busca la publicación mediante su identificador.
    publicacion = db.get(Blog, blog_id)

    if publicacion is None:
        raise HTTPException(
            status_code=404,
            detail="Publicación no encontrada",
        )

    return publicacion


# ============================================================
# COMENTARIOS: operaciones para consultar, crear y eliminar comentarios.
# ============================================================# COMENTARIOS

@app.get(
    "/comentarios",
    response_model=list[ComentarioRespuesta],
    tags=["Comentarios"],
    summary="Consultar comentarios",
    description="Devuelve la lista de comentarios registrados.",
)
def listar_comentarios(db: Session = Depends(obtener_sesion)):
    return db.scalars(
        select(Comentario).order_by(Comentario.cant_likes.desc())
    ).all()


@app.post(
    "/comentarios",
    response_model=ComentarioRespuesta,
    status_code=201,
    tags=["Comentarios"],
    summary="Crear un comentario",
    description="Registra un comentario asociado a un usuario y a una publicación.",
)
def crear_comentario(
    datos: ComentarioCrear,
    db: Session = Depends(obtener_sesion),
):
    # Evita registrar comentarios que solo contienen espacios o están vacíos.
    if not datos.texto.strip():
        raise HTTPException(
            status_code=422,
            detail="El comentario no puede estar vacío",
        )

    # Comprueba que el usuario que comenta exista.
    if db.get(Usuario, datos.id_usuario) is None:
        raise HTTPException(
            status_code=404,
            detail="Usuario no encontrado",
        )

    # Comprueba que la publicación a la que pertenece el comentario exista.
    if db.get(Blog, datos.id_blog) is None:
        raise HTTPException(
            status_code=404,
            detail="Publicación no encontrada",
        )

    # Construye el comentario con los datos enviados por el cliente.
    nuevo = Comentario(
        id_usuario=datos.id_usuario,
        id_blog=datos.id_blog,
        nombre_usuario = datos.nombre_usuario,
        texto=datos.texto.strip(),
        cant_likes=datos.cant_likes,
        id_stiker = datos.id_stiker,
    )

    db.add(nuevo)
    
    # Recupera la publicación para actualizar su contador de comentarios.
    blog = db.get(Blog, datos.id_blog)
    if blog is None:
        raise HTTPException(
            status_code=404,
            detail="Publicación no encontrada",
        )
    if blog.cant_comentarios is None:
        blog.cant_comentarios = 0
    # Aumenta en uno la cantidad de comentarios de la publicación.
    blog.cant_comentarios += 1
    
    db.commit()
    db.refresh(nuevo)

    return nuevo

@app.get(
    "/likeblog",
    response_model=list[LikeBlogRespuesta],
    tags=["Likes de publicaciones"],
    summary="Consultar likes de publicaciones",
    description="Devuelve los registros de reacciones realizados en las publicaciones.",
)
def listar_Likes_Blog(db: Session = Depends(obtener_sesion)):
    return db.scalars(
        select(LikeBlog).order_by(LikeBlog.id_suario)
    ).all()
    
    
@app.post(
    "/likeblog",
    response_model=LikeBlogRespuesta,
    status_code=201,
    tags=["Likes de publicaciones"],
    summary="Dar like a una publicación",
    description="Registra la reacción de un usuario y actualiza el contador de likes de la publicación. No permite duplicar la reacción del mismo usuario.",
)
def crear_Like_Blog(
    datos: LikeBlogCrear,
    db: Session = Depends(obtener_sesion),
):

    if db.get(Usuario, datos.id_suario) is None:
        raise HTTPException(
            status_code=404,
            detail="Usuario no encontrado",
        )

    # Recupera la publicación para validar su existencia y actualizar su contador.
    # 1. Obtenemos el blog completo en una variable en lugar de solo validar si existe
    # Recupera la publicación para actualizar su contador de comentarios.
    blog = db.get(Blog, datos.id_blog)
    if blog is None:
        raise HTTPException(
            status_code=404,
            detail="Publicación no encontrada",
        )

    # Comprueba que el usuario todavía no haya reaccionado a esta publicación.
    # 2. Opcional pero recomendado: Validar si ya existe el registro para evitar errores de llave duplicada
    # Busca una reacción del mismo usuario para la misma publicación.
    like_existente = db.query(LikeBlog).filter(
        LikeBlog.id_suario == datos.id_suario,
        LikeBlog.id_blog == datos.id_blog
    ).first()

    if like_existente:
        raise HTTPException(
            status_code=400,
            detail="El usuario ya le ha dado like a este blog",
        )

    # Crea el registro que representa la reacción.
    # 3. Creamos el registro del like
    # Construye el objeto LikeBlog con el usuario, publicación y valor del like.
    nuevo = LikeBlog(
        id_suario=datos.id_suario,
        id_blog=datos.id_blog,
        like=datos.like,
    )

    db.add(nuevo)

    # Actualiza el contador de likes almacenado en la publicación.
    # 4. Actualizamos la cantidad de likes en la tabla blog
    if blog.cant_likes is None:
        blog.cant_likes = 0
    # Suma uno al total de likes de la publicación.
    blog.cant_likes += 1

    # Guarda el like y el nuevo contador dentro de la misma transacción.
    # 5. Guardamos todo en la base de datos de forma sincronizada
    db.commit()
    db.refresh(nuevo)

    return nuevo

@app.delete(
    "/likeblog/{id_like_blog}",
    status_code=204,
    tags=["Likes de publicaciones"],
    summary="Quitar like de una publicación",
    description="Elimina la reacción de un usuario a una publicación.",
)
def eliminar_like_blog(
    id_suario: int,
    id_blog: int,
    db: Session = Depends(obtener_sesion),
):

    blog = db.get(Blog, id_blog)
    if Usuario is None:
        raise HTTPException(
            status_code=404,
            detail="Usuario no encontrado",
        )
        
    # Busca una reacción del mismo usuario para la misma publicación.
    like_existente = db.query(LikeBlog).filter(
        LikeBlog.id_suario == id_suario,
        LikeBlog.id_blog == id_blog
    ).first()

    if not like_existente:
        raise HTTPException(
            status_code=404,
            detail="El like no existe o el usuario no le ha dado like a este blog",
        )
        
    if blog:
        if blog.cant_likes and blog.cant_likes > 0:
            blog.cant_likes -= 1

    db.delete(like_existente)

    # Intenta guardar los cambios en la base de datos.
    try:
        # Confirma la transacción y guarda los cambios.
        db.commit()
    # Si ocurre un conflicto de integridad, deshace los cambios.
    except IntegrityError:
        # Revierte la transacción para dejar la sesión en un estado consistente.
        db.rollback()
        raise HTTPException(
            status_code=409,
            detail="No se pudo eliminar el comentario porque tiene datos relacionados",
        )

    return Response(status_code=204)


# ============================================================
# LIKES DE COMENTARIOS: consulta, registro y eliminación de reacciones.
# ============================================================#Crear, obtener y eliminar el apartado de likes con comentarios

@app.get(
    "/likecomen",
    response_model=list[LikeComenRespuesta],
    tags=["Likes de comentarios"],
    summary="Consultar likes de comentarios",
    description="Devuelve los registros de reacciones realizados en los comentarios.",
)
def listar_Likes_Comen(db: Session = Depends(obtener_sesion)):
    return db.scalars(
        select(LikeComentario).order_by(LikeComentario.id_suario)
    ).all()
    
    
@app.post(
    "/likecomen",
    response_model=LikeComenRespuesta,
    status_code=201,
    tags=["Likes de comentarios"],
    summary="Dar like a un comentario",
    description="Registra la reacción de un usuario y actualiza el contador de likes del comentario. No permite duplicar la reacción del mismo usuario.",
)
def crear_Like_Comen(
    datos: LikeComenCrear,
    db: Session = Depends(obtener_sesion),
):

    if db.get(Usuario, datos.id_suario) is None:
        raise HTTPException(
            status_code=404,
            detail="Usuario no encontrado",
        )

    # Busca el comentario que recibirá la reacción.
    # 1. Obtenemos el comentario
    comen = db.get(Comentario, datos.id_comentario)
    if comen is None:
        raise HTTPException(
            status_code=404,
            detail="Comentario no encontrado",
        )

    # Evita que un mismo usuario registre dos likes para el mismo comentario.
    # 2. Validar si ya existe el registro para evitar errores de llave duplicada
    like_existente = db.query(LikeComentario).filter(
        LikeComentario.id_suario == datos.id_suario,
        LikeComentario.id_comentario == datos.id_comentario
    ).first()

    if like_existente:
        raise HTTPException(
            status_code=400,
            detail="El usuario ya le ha dado like a este comentario", # <-- Corregido el mensaje
        )

    # Crea el registro que representa la reacción.
    # 3. Creamos el registro del like
    # Crea el registro de la reacción del comentario.
    nuevo = LikeComentario(
        id_suario=datos.id_suario,
        id_comentario=datos.id_comentario,
        like=datos.like,
    )

    db.add(nuevo)

    # Actualiza el contador de likes del comentario.
    # 4. Actualizamos la cantidad de likes en la tabla Comentarios
    if comen.cant_likes is None:
        comen.cant_likes = 0
    # Incrementa el contador de reacciones.
    comen.cant_likes += 1

    # Guarda el like y el nuevo contador dentro de la misma transacción.
    # 5. Guardamos todo en la base de datos de forma sincronizada
    db.commit()
    db.refresh(nuevo)

    return nuevo

@app.delete(
    "/likecomen/{id_like_comen}",
    status_code=204,
    tags=["Likes de comentarios"],
    summary="Quitar like de un comentario",
    description="Elimina la reacción de un usuario a un comentario.",
)
def eliminar_like_Comen(
    id_suario: int,
    id_comen: int,
    db: Session = Depends(obtener_sesion),
):

    comen = db.get(Comentario, id_comen)
    if Usuario is None:
        raise HTTPException(
            status_code=404,
            detail="Comentario no encontrado",
        )
        
    like_existente = db.query(LikeComentario).filter(
        LikeComentario.id_suario == id_suario,
        LikeComentario.id_comentario == id_comen,
    ).first()

    if not like_existente:
        raise HTTPException(
            status_code=404,
            detail="El like no existe o el usuario no le ha dado like a este comentario",
        )
        
    if comen:
        if comen.cant_likes and comen.cant_likes > 0:
            comen.cant_likes -= 1

    db.delete(like_existente)

    # Intenta guardar los cambios en la base de datos.
    try:
        # Confirma la transacción y guarda los cambios.
        db.commit()
    # Si ocurre un conflicto de integridad, deshace los cambios.
    except IntegrityError:
        # Revierte la transacción para dejar la sesión en un estado consistente.
        db.rollback()
        raise HTTPException(
            status_code=409,
            detail="No se pudo eliminar el comentario porque tiene datos relacionados",
        )

    return Response(status_code=204)

@app.delete(
    "/comentarios/{id_comentario}",
    status_code=204,
    tags=["Comentarios"],
    summary="Eliminar un comentario",
    description="Elimina el comentario indicado y actualiza el contador de comentarios de la publicación.",
)
def eliminar_comentario(
    id_comentario: int,
    id_blog: int,
    db: Session = Depends(obtener_sesion),
):
    blog = db.get(Blog, id_blog)
    if Usuario is None:
        raise HTTPException(
            status_code=404,
            detail="Comentario no encontrado",
        )
    
    # Busca el comentario que se desea eliminar.
    coment = db.get(Comentario, id_comentario)

    if coment is None:
        raise HTTPException(
            status_code=404,
            detail="Comentario no encontrado",
        )
        
    if blog:
        if blog.cant_comentarios and blog.cant_comentarios > 0:
            # Resta uno al contador de comentarios de la publicación.
            blog.cant_comentarios -= 1

    # Marca el comentario para eliminarlo al confirmar la transacción.
    db.delete(coment)

    # Intenta guardar los cambios en la base de datos.
    try:
        # Confirma la transacción y guarda los cambios.
        db.commit()
    # Si ocurre un conflicto de integridad, deshace los cambios.
    except IntegrityError:
        # Revierte la transacción para dejar la sesión en un estado consistente.
        db.rollback()
        raise HTTPException(
            status_code=409,
            detail="No se pudo eliminar el comentario porque tiene datos relacionados",
        )

    return Response(status_code=204)