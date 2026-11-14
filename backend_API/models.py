from sqlalchemy import (
    Column, Integer, String, Text,
    DateTime, ForeignKey,Boolean, func
)
from database import Base

# Las clases practicamente es cmo poner toda la base de datos con todos sus campos, 
# pues de aqui se extraen para insertarlos en la base de datos
class Usuario(Base):
    __tablename__ = "usuario"

    id_usr = Column(Integer, primary_key=True, index=True)
    nom_usr = Column(String(100), nullable=False)
    mail = Column(String(150), unique=True, nullable=False)
    pass_hash = Column("pass", String(255), nullable=False)
    dir_usr = Column(String(200), nullable=True)
    tip_usu = Column(Integer, nullable=False, default=1)
class Blog(Base):
    __tablename__ = "blog"
    id_blog = Column(Integer, primary_key=True, index=True)
    titulo = Column(String(150), nullable=False)
    descripcion = Column("desc", Text, nullable=True)
    img = Column(String(500), nullable=True)
    tags = Column(String(255), nullable=True)
    cant_likes = Column(Integer, nullable=True)
    cant_comentarios = Column(Integer, nullable=True)
class Comentario(Base):
    __tablename__ = "comentarios"
    id_comentario = Column(Integer, primary_key=True, index=True)
    id_usuario = Column(Integer, ForeignKey("usuario.id_usr"), nullable=False)
    id_blog = Column(Integer, ForeignKey("blog.id_blog"), nullable=False)
    nombre_usuario = Column(String(50))
    texto = Column(Text, nullable=False)
    fecha = Column(
        DateTime,
        nullable=False,
        server_default=func.current_timestamp(),
    )
    cant_likes = Column(Integer, default=0)
    id_stiker = Column(String(255), nullable= False)
    
    
class LikeBlog(Base):
    __tablename__ = "likes_blog"
    id_suario = Column(Integer, ForeignKey("usuario.id_usr"),primary_key=True, nullable=False)
    id_blog = Column(Integer, ForeignKey("blog.id_blog"),primary_key=True, nullable=False)
    like = Column(Boolean, default=True)
    
class LikeComentario(Base):
    __tablename__ = "likes_comentario"
    id_suario = Column(Integer, ForeignKey("usuario.id_usr"),primary_key=True, nullable=False)
    id_comentario = Column(Integer, ForeignKey("comentarios.id_comentario"),primary_key=True, nullable=False)
    like = Column(Boolean, default=True)
    