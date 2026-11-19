from pathlib import Path
import uuid

from fastapi import Depends, FastAPI, File, Form, HTTPException, UploadFile
# Detecta campos faltantes o datos que no tienen el formato esperado.
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
# Devuelve los mensajes de error en JSON.
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
from pwdlib import PasswordHash
# Detecta contraseñas guardadas con un formato que no se puede leer.
from pwdlib.exceptions import UnknownHashError
# Permite consultar, borrar y filtrar los registros de la base de datos.
from sqlalchemy import delete, func, select
# Permite controlar errores al guardar datos o repetir un registro.
from sqlalchemy.exc import IntegrityError, SQLAlchemyError
from sqlalchemy.orm import Session

from database import obtener_sesion
from models import Blog, Comentario, LikeBlog, LikeComentario, Usuario
from schemas import (
    BlogRespuesta, ComentarioCrear, ComentarioRespuesta, LikeBlogCrear,
    LikeBlogRespuesta, LikeComenCrear, LikeComenRespuesta, LoginRequest,
    RecuperarPassword, RegistroCrear, UsuarioActualizar,
    UsuarioCrear, UsuarioRespuesta,
)


app = FastAPI(title="API de GameDAP")
password_hash = PasswordHash.recommended()
UPLOAD_DIR = Path(__file__).resolve().parent / "uploads"
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=str(UPLOAD_DIR)), name="uploads")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.exception_handler(RequestValidationError)
async def datos_invalidos(request, error):
    # Flutter recibe siempre un mensaje corto en "detail".
    detalle = error.errors()[0]
    campo = str(detalle["loc"][-1])
    mensajes = {
        "missing": f"Falta el campo {campo}",
        "string_too_short": f"Revisa la longitud del campo {campo}",
        "string_too_long": f"El campo {campo} es demasiado largo",
        "literal_error": f"El valor de {campo} no es válido",
    }
    mensaje = mensajes.get(detalle["type"], f"Revisa el campo {campo}")
    if detalle["type"] == "value_error":
        mensaje = detalle["msg"].removeprefix("Value error, ")
    return JSONResponse(status_code=400, content={"detail": mensaje})


# Guarda los cambios; si hay un conflicto, los deshace.
def guardar(db: Session, mensaje: str):
    try:
        db.commit()
    except IntegrityError as error:
        db.rollback()
        raise HTTPException(400, mensaje) from error


def buscar_usuario(db: Session, id_usuario: int):
    # Busca al usuario que se indicó en el comentario o like.
    usuario = db.get(Usuario, id_usuario)
    if usuario is None:
        raise HTTPException(404, "Usuario no encontrado")
    return usuario


def buscar_blog(db: Session, blog_id: int, bloquear: bool = False):
    consulta = select(Blog).where(Blog.id_blog == blog_id)
    # Al cambiar un contador, esperamos a que termine cualquier cambio anterior.
    if bloquear:
        consulta = consulta.with_for_update()
    blog = db.scalar(consulta)
    if blog is None:
        raise HTTPException(404, "Publicación no encontrada")
    return blog


# Prepara los datos que se muestran en las tarjetas y en el detalle.
def respuesta_blog(blog: Blog, me_gusta: bool = False):
    respuesta = BlogRespuesta.model_validate(blog)
    respuesta.me_gusta = me_gusta
    return respuesta


# Crea la cuenta y guarda la contraseña protegida.
def registrar_cuenta(datos: RegistroCrear, tipo: str, db: Session):
    usuario = Usuario(
        nom_usr=datos.nom_usr,
        mail=datos.mail,
        pass_hash=password_hash.hash(datos.password),
        dir_usr=datos.dir_usr,
        tip_usu=tipo,
    )
    db.add(usuario)
    guardar(db, "El correo ya está registrado")
    db.refresh(usuario)
    return usuario


@app.get("/")
def inicio():
    return {"mensaje": "API funcionando correctamente"}


@app.post("/login", response_model=UsuarioRespuesta, tags=["Autenticación"])
def iniciar_sesion(datos: LoginRequest, db: Session = Depends(obtener_sesion)):
    usuario = db.scalar(select(Usuario).where(Usuario.mail == datos.mail.strip().lower()))
    # Compara la contraseña escrita con la que está guardada.
    correcta = False
    if usuario is not None:
        try:
            correcta = password_hash.verify(datos.password, usuario.pass_hash)
        except UnknownHashError:
            # Los hashes de ejemplo del SQL no son contraseñas reales.
            correcta = False
    if not correcta:
        raise HTTPException(401, "Credenciales incorrectas")
    return usuario


@app.post("/register", response_model=UsuarioRespuesta, status_code=201, tags=["Autenticación"])
def registrar(datos: RegistroCrear, db: Session = Depends(obtener_sesion)):
    # El registro público siempre crea un usuario general.
    return registrar_cuenta(datos, "2", db)


@app.post("/recuperar-password", tags=["Autenticación"])
def recuperar_password(datos: RecuperarPassword, db: Session = Depends(obtener_sesion)):
    if datos.password != datos.confirmar_password:
        raise HTTPException(400, "Las contraseñas no coinciden")
    usuario = db.scalar(select(Usuario).where(Usuario.mail == datos.mail.strip().lower()))
    if usuario is None:
        raise HTTPException(404, "Usuario no encontrado")
    # Flujo directo solicitado para la práctica, sin envío ni verificación de correo.
    usuario.pass_hash = password_hash.hash(datos.password)
    guardar(db, "No se pudo actualizar la contraseña")
    return {"mensaje": "Contraseña actualizada correctamente"}


@app.post("/logout", tags=["Autenticación"])
def cerrar_sesion():
    # La app conserva y limpia el usuario de forma local.
    return {"mensaje": "Sesión cerrada"}


@app.get("/usuarios", response_model=list[UsuarioRespuesta], tags=["Usuarios"])
def listar_usuarios(db: Session = Depends(obtener_sesion)):
    return db.scalars(select(Usuario).order_by(Usuario.id_usr)).all()


@app.post("/usuarios", response_model=UsuarioRespuesta, status_code=201, tags=["Usuarios"])
def crear_usuario(
    datos: UsuarioCrear, db: Session = Depends(obtener_sesion),
):
    return registrar_cuenta(datos, datos.tip_usu, db)


@app.put("/usuarios/{usuario_id}", response_model=UsuarioRespuesta, tags=["Usuarios"])
def actualizar_usuario(
    usuario_id: int, datos: UsuarioActualizar,
    db: Session = Depends(obtener_sesion),
):
    usuario = db.get(Usuario, usuario_id)
    if usuario is None:
        raise HTTPException(404, "Usuario no encontrado")
    usuario.nom_usr = datos.nom_usr
    usuario.mail = datos.mail
    usuario.dir_usr = datos.dir_usr
    if datos.tip_usu is not None:
        usuario.tip_usu = datos.tip_usu
    guardar(db, "El correo ya está registrado")
    db.refresh(usuario)
    return usuario


@app.delete("/usuarios/{usuario_id}", tags=["Usuarios"])
def eliminar_usuario(
    usuario_id: int, db: Session = Depends(obtener_sesion),
):
    usuario = db.get(Usuario, usuario_id)
    if usuario is None:
        raise HTTPException(404, "Usuario no encontrado")
    db.delete(usuario)
    guardar(db, "No se puede eliminar un usuario con comentarios o likes")
    return {"mensaje": "Usuario eliminado"}


@app.get("/blog", response_model=list[BlogRespuesta], include_in_schema=False)
@app.get("/blogs", response_model=list[BlogRespuesta], tags=["Publicaciones"])
def listar_blogs(
    tag: str | None = None, db: Session = Depends(obtener_sesion),
    id_usuario: int | None = None,
):
    consulta = select(Blog).order_by(Blog.id_blog.desc())
    if tag and tag.strip():
        consulta = consulta.where(func.lower(Blog.tags).contains(tag.strip().lower(), autoescape=True))
    blogs = db.scalars(consulta).all()
    # Guarda los IDs de las publicaciones que tienen like de este usuario.
    favoritos = set()
    if id_usuario is not None:
        favoritos = set(db.scalars(select(LikeBlog.id_blog).where(
            LikeBlog.id_usuario == id_usuario, LikeBlog.like.is_(True),
        )).all())
    publicaciones = []
    for blog in blogs:
        publicaciones.append(respuesta_blog(blog, blog.id_blog in favoritos))
    return publicaciones


@app.post("/blog", response_model=BlogRespuesta, status_code=201, include_in_schema=False)
@app.post("/blogs", response_model=BlogRespuesta, status_code=201, tags=["Publicaciones"])
def crear_blog(
    titulo: str = Form(...), imagen: UploadFile = File(...),
    desc: str = Form(...),
    tags: str | None = Form(default=None),
    db: Session = Depends(obtener_sesion),
):
    texto = desc.strip()
    if not 2 <= len(titulo.strip()) <= 150 or not texto:
        raise HTTPException(400, "Escribe un título de 2 a 150 caracteres y una descripción")
    if tags and len(tags) > 255:
        raise HTTPException(400, "Las etiquetas no deben superar 255 caracteres")
    extension = Path(imagen.filename or "").suffix.lower()
    if extension not in {".jpg", ".jpeg", ".png", ".webp"}:
        raise HTTPException(400, "Formato de imagen no permitido. Usa JPG, JPEG, PNG o WEBP")
    # Lee hasta 8 MB y un byte extra para detectar si la foto pesa de más.
    contenido = imagen.file.read(8 * 1024 * 1024 + 1)
    if not contenido or len(contenido) > 8 * 1024 * 1024:
        raise HTTPException(400, "La imagen debe pesar entre 1 byte y 8 MB")
    # Revisa que el contenido del archivo corresponda a una imagen.
    firmas = {
        ".jpg": contenido.startswith(b"\xff\xd8\xff"),
        ".jpeg": contenido.startswith(b"\xff\xd8\xff"),
        ".png": contenido.startswith(b"\x89PNG\r\n\x1a\n"),
        ".webp": contenido[:4] == b"RIFF" and contenido[8:12] == b"WEBP",
    }
    if not firmas[extension]:
        raise HTTPException(400, "El archivo no corresponde al formato de imagen indicado")
    # Crea un nombre distinto para no reemplazar una foto anterior.
    nombre = f"{uuid.uuid4().hex}{extension}"
    ruta = UPLOAD_DIR / nombre
    blog = Blog(
        titulo=titulo.strip(), descripcion=texto, img=f"uploads/{nombre}",
        tags=tags.strip() if tags else None, cant_likes=0, cant_comentarios=0,
    )
    try:
        # La imagen queda en disco; la base de datos solo guarda su ruta.
        ruta.write_bytes(contenido)
        db.add(blog)
        db.commit()
        db.refresh(blog)
    except (SQLAlchemyError, OSError) as error:
        db.rollback()
        ruta.unlink(missing_ok=True)
        raise HTTPException(500, "No se pudo guardar la publicación") from error
    return respuesta_blog(blog)


@app.get("/blog/{blog_id}", response_model=BlogRespuesta, include_in_schema=False)
@app.get("/blogs/{blog_id}", response_model=BlogRespuesta, tags=["Publicaciones"])
def obtener_blog(
    blog_id: int, db: Session = Depends(obtener_sesion), id_usuario: int | None = None,
):
    blog = buscar_blog(db, blog_id)
    like = db.get(LikeBlog, (id_usuario, blog_id)) if id_usuario is not None else None
    return respuesta_blog(blog, bool(like and like.like))


@app.get("/blogs/{blog_id}/comentarios", response_model=list[ComentarioRespuesta], tags=["Comentarios"])
def comentarios_del_blog(blog_id: int, db: Session = Depends(obtener_sesion)):
    buscar_blog(db, blog_id)
    return db.scalars(select(Comentario).where(
        Comentario.id_blog == blog_id,
    ).order_by(Comentario.fecha, Comentario.id_comentario)).all()


@app.get("/comentarios", response_model=list[ComentarioRespuesta], tags=["Comentarios"])
def listar_comentarios(db: Session = Depends(obtener_sesion)):
    return db.scalars(select(Comentario).order_by(Comentario.id_comentario)).all()


@app.post("/comentarios", response_model=ComentarioRespuesta, status_code=201, tags=["Comentarios"])
def crear_comentario(
    datos: ComentarioCrear, db: Session = Depends(obtener_sesion),
):
    usuario = buscar_usuario(db, datos.id_usuario)
    if not datos.texto.strip():
        raise HTTPException(400, "El comentario no puede estar vacío")
    blog = buscar_blog(db, datos.id_blog, bloquear=True)
    nuevo = Comentario(
        id_usuario=usuario.id_usr, id_blog=blog.id_blog,
        nombre_usuario=usuario.nom_usr, texto=datos.texto.strip(),
        cant_likes=0, id_stiker=datos.id_stiker,
    )
    db.add(nuevo)
    # Guarda el comentario y aumenta el contador en la misma operación.
    blog.cant_comentarios = (blog.cant_comentarios or 0) + 1
    guardar(db, "No se pudo guardar el comentario")
    db.refresh(nuevo)
    return nuevo


@app.post("/likeblog", response_model=LikeBlogRespuesta, status_code=201, tags=["Likes"])
def crear_like_blog(
    datos: LikeBlogCrear, db: Session = Depends(obtener_sesion),
):
    usuario = buscar_usuario(db, datos.id_usuario)
    blog = buscar_blog(db, datos.id_blog, bloquear=True)
    # Evita que la misma persona sume más de un like al mismo blog.
    if db.get(LikeBlog, (usuario.id_usr, blog.id_blog)):
        raise HTTPException(400, "Ya le diste like a esta publicación")
    nuevo = LikeBlog(id_usuario=usuario.id_usr, id_blog=blog.id_blog, like=True)
    db.add(nuevo)
    blog.cant_likes = (blog.cant_likes or 0) + 1
    guardar(db, "Ya le diste like a esta publicación")
    return nuevo


@app.delete("/blogs/{blog_id}/likes", response_model=BlogRespuesta, tags=["Likes"])
def eliminar_like_blog(
    blog_id: int, id_usuario: int, db: Session = Depends(obtener_sesion),
):
    blog = buscar_blog(db, blog_id, bloquear=True)
    like = db.get(LikeBlog, (id_usuario, blog_id))
    if like is None:
        raise HTTPException(404, "No has dado like a esta publicación")
    db.delete(like)
    # Resta el like sin dejar el contador por debajo de cero.
    blog.cant_likes = max(0, (blog.cant_likes or 0) - 1)
    guardar(db, "No se pudo quitar el like")
    return respuesta_blog(blog)


@app.get("/likeblog", response_model=list[LikeBlogRespuesta], tags=["Likes"])
def listar_likes_blog(id_usuario: int | None = None, db: Session = Depends(obtener_sesion)):
    consulta = select(LikeBlog)
    if id_usuario is not None:
        consulta = consulta.where(LikeBlog.id_usuario == id_usuario)
    return db.scalars(consulta).all()


# Se conservan las operaciones de comentarios que ya tenía la API.
@app.get("/likecomen", response_model=list[LikeComenRespuesta], tags=["Likes"])
def listar_likes_comentario(id_usuario: int | None = None, db: Session = Depends(obtener_sesion)):
    consulta = select(LikeComentario)
    if id_usuario is not None:
        consulta = consulta.where(LikeComentario.id_usuario == id_usuario)
    return db.scalars(consulta).all()


@app.post("/likecomen", response_model=LikeComenRespuesta, status_code=201, tags=["Likes"])
def crear_like_comentario(
    datos: LikeComenCrear, db: Session = Depends(obtener_sesion),
):
    usuario = buscar_usuario(db, datos.id_usuario)
    comentario = db.scalar(select(Comentario).where(
        Comentario.id_comentario == datos.id_comentario,
    ).with_for_update())
    if comentario is None:
        raise HTTPException(404, "Comentario no encontrado")
    if db.get(LikeComentario, (usuario.id_usr, datos.id_comentario)):
        raise HTTPException(400, "Ya le diste like a este comentario")
    nuevo = LikeComentario(id_usuario=usuario.id_usr, id_comentario=datos.id_comentario, like=True)
    db.add(nuevo)
    comentario.cant_likes = (comentario.cant_likes or 0) + 1
    guardar(db, "No se pudo guardar el like")
    return nuevo


@app.delete("/likecomen/{id_comentario}", tags=["Likes"])
def eliminar_like_comentario(
    id_comentario: int, id_usuario: int, db: Session = Depends(obtener_sesion),
):
    comentario = db.scalar(select(Comentario).where(
        Comentario.id_comentario == id_comentario,
    ).with_for_update())
    like = db.get(LikeComentario, (id_usuario, id_comentario))
    if comentario is None or like is None:
        raise HTTPException(404, "Like no encontrado")
    db.delete(like)
    comentario.cant_likes = max(0, (comentario.cant_likes or 0) - 1)
    guardar(db, "No se pudo quitar el like")
    return {"mensaje": "Like eliminado"}


@app.delete("/comentarios/{id_comentario}", tags=["Comentarios"])
def eliminar_comentario(
    id_comentario: int, db: Session = Depends(obtener_sesion),
):
    comentario = db.get(Comentario, id_comentario)
    if comentario is None:
        raise HTTPException(404, "Comentario no encontrado")
    blog = buscar_blog(db, comentario.id_blog, bloquear=True)
    # Borra primero los likes que pertenecen al comentario.
    db.execute(delete(LikeComentario).where(LikeComentario.id_comentario == id_comentario))
    db.delete(comentario)
    blog.cant_comentarios = max(0, (blog.cant_comentarios or 0) - 1)
    guardar(db, "No se pudo eliminar el comentario")
    return {"mensaje": "Comentario eliminado"}
