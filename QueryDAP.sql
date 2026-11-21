-- Crear la base de datos
CREATE DATABASE IF NOT EXISTS bd_aplicacion_movil;
USE bd_aplicacion_movil;

-- 1. Tabla USUARIO
CREATE TABLE usuario (
    id_usr INT AUTO_INCREMENT PRIMARY KEY,
    nom_usr VARCHAR(50) NOT NULL,
    mail VARCHAR(100) NOT NULL UNIQUE,
    pass VARCHAR(255) NOT NULL,
    dir_usr VARCHAR(255),
    tip_usu VARCHAR(50)
);

-- 2. Tabla BLOG
CREATE TABLE blog (
    id_blog INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    `desc` TEXT,
    img VARCHAR(255),
    tags VARCHAR(255),
    cant_likes INT NOT NULL DEFAULT 0,
    cant_comentarios INT NOT NULL DEFAULT 0
);

-- 3. Tabla COMENTARIOS
CREATE TABLE comentarios (
    id_comentario INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_blog INT NOT NULL,
    nombre_usuario VARCHAR(50),
    texto TEXT NOT NULL,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    cant_likes INT NOT NULL DEFAULT 0,
    id_stiker VARCHAR(50),
    CONSTRAINT fk_comentario_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usr),
    CONSTRAINT fk_comentario_blog FOREIGN KEY (id_blog) REFERENCES blog(id_blog)
);

-- 4. Tabla LIKES_BLOG
CREATE TABLE likes_blog (
    id_usuario INT NOT NULL,
    id_blog INT NOT NULL,
    `like` BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (id_usuario, id_blog),
    CONSTRAINT fk_likesblog_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usr),
    CONSTRAINT fk_likesblog_blog FOREIGN KEY (id_blog) REFERENCES blog(id_blog)
);

-- 5. Tabla LIKES_COMENTARIO
CREATE TABLE likes_comentario (
    id_usuario INT NOT NULL,
    id_comentario INT NOT NULL,
    `like` BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (id_usuario, id_comentario),
    CONSTRAINT fk_likescom_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usr),
    CONSTRAINT fk_likescom_comentario FOREIGN KEY (id_comentario) REFERENCES comentarios(id_comentario)
);