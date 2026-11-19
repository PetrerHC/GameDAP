CREATE DATABASE IF NOT EXISTS bd_aplicacion_movil
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE bd_aplicacion_movil;

CREATE TABLE usuario (
    id_usr INT AUTO_INCREMENT PRIMARY KEY,
    nom_usr VARCHAR(100) NOT NULL,
    mail VARCHAR(150) NOT NULL UNIQUE,
    pass VARCHAR(255) NOT NULL,
    dir_usr VARCHAR(200),
    tip_usu VARCHAR(50) NOT NULL DEFAULT '1'
);

CREATE TABLE blog (
    id_blog INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    `desc` TEXT,
    img VARCHAR(500),
    tags VARCHAR(255),
    cant_likes INT NOT NULL DEFAULT 0,
    cant_comentarios INT NOT NULL DEFAULT 0
);

CREATE TABLE comentarios (
    id_comentario INT AUTO_INCREMENT PRIMARY KEY,
    texto TEXT NOT NULL,
    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    nombre_usuario VARCHAR(100),
    cant_likes INT NOT NULL DEFAULT 0,
    id_stiker VARCHAR(255) NOT NULL DEFAULT '',
    id_usuario INT NOT NULL,
    id_blog INT NOT NULL,

    CONSTRAINT fk_comentario_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usr),

    CONSTRAINT fk_comentario_blog
        FOREIGN KEY (id_blog)
        REFERENCES blog(id_blog)
);
-- Cada usuario puede guardar un solo like por publicación.
CREATE TABLE likes_blog (
    id_usuario INT NOT NULL,
    id_blog INT NOT NULL,
    `like` BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (id_usuario, id_blog),
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usr),
    FOREIGN KEY (id_blog) REFERENCES blog(id_blog)
);

-- Guarda los likes que recibe cada comentario.
CREATE TABLE likes_comentario (
    id_usuario INT NOT NULL,
    id_comentario INT NOT NULL,
    `like` BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (id_usuario, id_comentario),
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usr),
    FOREIGN KEY (id_comentario) REFERENCES comentarios(id_comentario)
);

-- Estas cuentas de ejemplo reciben su contraseña desde "Recuperar contraseña".
INSERT INTO usuario
    (nom_usr, mail, pass, dir_usr, tip_usu)
VALUES
    ('Adriana Contreras', 'adriana@ejemplo.com',
     'HASH_DE_PRUEBA', 'Querétaro', '1'),
    ('Carlos Pérez', 'carlos@ejemplo.com',
     'HASH_DE_PRUEBA', 'Querétaro', '2');

INSERT INTO blog (titulo, `desc`, img, tags)
VALUES
    (
      'Construyendo aplicaciones con Flutter',
      'Una introducción al desarrollo móvil con Dart.',
      'https://picsum.photos/800/400?random=1',
      'Flutter,Dart'
    ),
    (
      'Introducción a la inteligencia artificial',
      'Conceptos fundamentales de inteligencia artificial.',
      'https://picsum.photos/800/400?random=2',
      'IA,tecnología'
    );

INSERT INTO comentarios
    (texto, nombre_usuario, id_usuario, id_blog)
VALUES
    ('Muy útil la explicación de Flutter.', 'Adriana Contreras', 1, 1),
    ('Me gustaría ver más ejemplos.', 'Carlos Pérez', 2, 1),
    ('Buen artículo de introducción.', 'Adriana Contreras', 1, 2);

UPDATE blog b SET cant_comentarios =
    (SELECT COUNT(*) FROM comentarios c WHERE c.id_blog = b.id_blog);
