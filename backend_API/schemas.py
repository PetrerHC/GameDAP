# Importa la funcion datetime para obtener la fecha y hora
from datetime import datetime
#la neta no se xd
from pydantic import BaseModel, ConfigDict, Field

# En general se crean clases que tienen unica funcion, y a estas no 
# se les pone todos los datos si no los datos a insertar, modificar,
# ademas aqui se declaran limitantes de los mismos
class UsuarioCrear(BaseModel):
    nom_usr: str = Field(min_length=2, max_length=100)
    mail: str = Field(min_length=5, max_length=150)
    password: str = Field(min_length=8, max_length=128)
    dir_usr: str | None = None
    tip_usu: int = 1


class UsuarioActualizar(BaseModel):
    nom_usr: str = Field(min_length=2, max_length=100)
    mail: str = Field(min_length=5, max_length=150)
    dir_usr: str | None = None
    tip_usr: int = 1


class UsuarioRespuesta(BaseModel):
    id_usr: int
    nom_usr: str
    mail: str
    dir_usr: str | None
    tip_usu: int

    model_config = ConfigDict(from_attributes=True)


class BlogRespuesta(BaseModel):
    id_blog: int
    titulo: str
    descripcion: str | None = None
    img: str | None = None
    tags: str | None = None
    cant_likes: int
    cant_comentarios: int

    model_config = ConfigDict(from_attributes=True)


class ComentarioCrear(BaseModel):
    id_usuario: int 
    id_blog: int
    nombre_usuario: str
    texto : str = Field(min_length=1, max_length=255)
    fecha: datetime
    cant_likes: int
    id_stiker: str = Field(min_length= 1, max_length=255)


class ComentarioRespuesta(BaseModel):
    id_comentario: int
    id_usuario: int 
    id_blog: int
    nombre_usuario: str
    texto : str = Field(min_length=1, max_length=255)
    fecha: datetime
    cant_likes: int
    id_stiker: str = Field(min_length= 1, max_length=255)

    model_config = ConfigDict(from_attributes=True)

class LoginRequest(BaseModel):
    mail: str = Field(min_length=5, max_length=150)
    password: str = Field(min_length=1, max_length=128)

class BlogCrear(BaseModel):
    titulo: str = Field(min_length=2, max_length=150)
    descripcion: str = Field(min_length=1)
    img: str | None = Field(default=None, max_length=500)
    tags: str | None = Field(default=None, max_length=255)
    
class LikeBlogRespuesta(BaseModel):
    id_suario: int 
    id_blog: int
    like: bool
    
class LikeBlogCrear(BaseModel):
    id_suario: int 
    id_blog: int
    like: bool
    
class LikeComenRespuesta(BaseModel):
    id_suario: int 
    id_comentario: int
    like: bool
    
class LikeComenCrear(BaseModel):
    id_suario: int 
    id_comentario: int
    like: bool
    