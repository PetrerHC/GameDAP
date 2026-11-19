from datetime import datetime
# Limita los tipos de usuario a los valores permitidos.
from typing import Literal

# Define los campos, sus límites y las revisiones antes de guardar.
from pydantic import AliasChoices, BaseModel, ConfigDict, Field, field_validator


# Reúne los datos que usan tanto el registro como la edición.
class DatosUsuario(BaseModel):
    nom_usr: str = Field(min_length=2, max_length=100)
    mail: str = Field(min_length=5, max_length=150)
    dir_usr: str | None = Field(default=None, max_length=200)

    @field_validator("nom_usr", "mail", mode="before")
    @classmethod
    def limpiar_texto(cls, valor):
        if isinstance(valor, str):
            return valor.strip()
        return valor

    @field_validator("mail")
    @classmethod
    def validar_correo(cls, valor):
        if "@" not in valor or " " in valor:
            raise ValueError("Ingresa un correo válido")
        return valor.lower()


class RegistroCrear(DatosUsuario):
    # Se acepta también "password" para las llamadas anteriores.
    password: str = Field(
        min_length=8, max_length=128,
        validation_alias=AliasChoices("pass", "password"),
    )


# El panel crea administradores por defecto; el registro público usa tipo 2.
class UsuarioCrear(RegistroCrear):
    tip_usu: Literal["1", "2"] = "1"


class UsuarioActualizar(DatosUsuario):
    # Si no se envía el tipo, se conserva el que ya tiene la cuenta.
    tip_usu: Literal["1", "2"] | None = None


# Estos son los datos que se devuelven; no se incluye la contraseña.
class UsuarioRespuesta(BaseModel):
    id_usr: int
    nom_usr: str
    mail: str
    dir_usr: str | None
    tip_usu: str

    # Permite leer los campos del usuario obtenido de la base de datos.
    model_config = ConfigDict(from_attributes=True)


class LoginRequest(BaseModel):
    mail: str = Field(min_length=5, max_length=150)
    password: str = Field(
        min_length=1, max_length=128,
        validation_alias=AliasChoices("pass", "password"),
    )


# El correo identifica la cuenta cuya contraseña se va a cambiar.
class RecuperarPassword(BaseModel):
    mail: str = Field(min_length=5, max_length=150)
    password: str = Field(min_length=8, max_length=128)
    confirmar_password: str = Field(min_length=8, max_length=128)


class BlogRespuesta(BaseModel):
    id_blog: int
    titulo: str
    # En la respuesta, la descripción lleva el nombre desc.
    descripcion: str | None = Field(default=None, serialization_alias="desc")
    img: str | None = None
    tags: str | None = None
    cant_likes: int = 0
    cant_comentarios: int = 0
    me_gusta: bool = False

    model_config = ConfigDict(from_attributes=True)

    # Si un registro antiguo no tiene contador, se muestra cero.
    @field_validator("cant_likes", "cant_comentarios", mode="before")
    @classmethod
    def contador_en_cero(cls, valor):
        return valor or 0


class ComentarioCrear(BaseModel):
    id_usuario: int
    id_blog: int
    texto: str = Field(min_length=1, max_length=255)
    # Se deja vacío cuando el comentario no tiene sticker.
    id_stiker: str = Field(default="", max_length=255)


class ComentarioRespuesta(BaseModel):
    id_comentario: int
    id_usuario: int
    id_blog: int
    nombre_usuario: str | None = None
    texto: str
    fecha: datetime
    cant_likes: int = 0
    id_stiker: str = ""

    model_config = ConfigDict(from_attributes=True)


class LikeBlogCrear(BaseModel):
    id_usuario: int
    id_blog: int
    like: Literal[True] = True


class LikeBlogRespuesta(LikeBlogCrear):
    model_config = ConfigDict(from_attributes=True)


class LikeComenCrear(BaseModel):
    id_usuario: int
    id_comentario: int
    like: Literal[True] = True


class LikeComenRespuesta(LikeComenCrear):
    model_config = ConfigDict(from_attributes=True)
