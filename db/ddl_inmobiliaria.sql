CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================
-- PROYECTO: Sistema Web Inmobiliaria
-- Script DDL - PostgreSQL (Supabase)
-- ============================================================

-- Limpieza previa (útil mientras ajustas el modelo en desarrollo)
DROP TABLE IF EXISTS auditoria CASCADE;
DROP TABLE IF EXISTS favorito CASCADE;
DROP TABLE IF EXISTS documento_solicitud CASCADE;
DROP TABLE IF EXISTS solicitud CASCADE;
DROP TABLE IF EXISTS cita CASCADE;
DROP TABLE IF EXISTS propiedad_caracteristica CASCADE;
DROP TABLE IF EXISTS caracteristica CASCADE;
DROP TABLE IF EXISTS imagen_propiedad CASCADE;
DROP TABLE IF EXISTS propiedad CASCADE;
DROP TABLE IF EXISTS tipo_propiedad CASCADE;
DROP TABLE IF EXISTS ciudad CASCADE;
DROP TABLE IF EXISTS inmobiliaria CASCADE;
DROP TABLE IF EXISTS perfil CASCADE;
DROP TABLE IF EXISTS usuario_rol CASCADE;
DROP TABLE IF EXISTS rol CASCADE;
DROP TABLE IF EXISTS usuario CASCADE;

-- ============================================================
-- 1. USUARIO  (credenciales y estado de la cuenta)
-- ============================================================
CREATE TABLE usuario (
    id_usuario      SERIAL PRIMARY KEY,
    correo          VARCHAR(150) NOT NULL UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,
    estado          VARCHAR(20) NOT NULL DEFAULT 'ACTIVO', -- ACTIVO / INACTIVO / BLOQUEADO
    fecha_registro  TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================
-- 2. ROL
-- ============================================================
CREATE TABLE rol (
    id_rol      SERIAL PRIMARY KEY,
    nombre_rol  VARCHAR(30) NOT NULL UNIQUE -- ADMINISTRADOR / INMOBILIARIA / CLIENTE
);

-- ============================================================
-- 3. USUARIO_ROL  (N:M entre usuario y rol)
-- ============================================================
CREATE TABLE usuario_rol (
    id_usuario  INT NOT NULL,
    id_rol      INT NOT NULL,
    PRIMARY KEY (id_usuario, id_rol),
    CONSTRAINT fk_usuariorol_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_usuariorol_rol FOREIGN KEY (id_rol)
        REFERENCES rol(id_rol) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ============================================================
-- 4. PERFIL  (1:1 con usuario -> datos personales)
-- ============================================================
CREATE TABLE perfil (
    id_perfil   SERIAL PRIMARY KEY,
    id_usuario  INT NOT NULL UNIQUE, -- UNIQUE garantiza la relación 1:1
    nombres     VARCHAR(100) NOT NULL,
    apellidos   VARCHAR(100) NOT NULL,
    documento   VARCHAR(30) NOT NULL,
    telefono    VARCHAR(20),
    direccion   VARCHAR(200),
    foto_url    VARCHAR(255),
    CONSTRAINT fk_perfil_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================================
-- 5. INMOBILIARIA  (agente -> 1 usuario puede operar 1 agencia)
-- ============================================================
CREATE TABLE inmobiliaria (
    id_inmobiliaria SERIAL PRIMARY KEY,
    id_usuario      INT NOT NULL UNIQUE,
    nombre_agencia  VARCHAR(150) NOT NULL,
    nit             VARCHAR(30) NOT NULL UNIQUE,
    CONSTRAINT fk_inmobiliaria_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================================
-- 6. CIUDAD  (catálogo)
-- ============================================================
CREATE TABLE ciudad (
    id_ciudad     SERIAL PRIMARY KEY,
    nombre_ciudad VARCHAR(100) NOT NULL UNIQUE
);

-- ============================================================
-- 7. TIPO_PROPIEDAD  (catálogo)
-- ============================================================
CREATE TABLE tipo_propiedad (
    id_tipo     SERIAL PRIMARY KEY,
    nombre_tipo VARCHAR(50) NOT NULL UNIQUE -- casa, apartamento, local, oficina, terreno
);

-- ============================================================
-- 8. PROPIEDAD  (1:N desde inmobiliaria, ciudad, tipo_propiedad)
-- ============================================================
CREATE TABLE propiedad (
    id_propiedad            SERIAL PRIMARY KEY,
    id_inmobiliaria         INT NOT NULL,
    id_ciudad               INT NOT NULL,
    id_tipo                 INT NOT NULL,
    matricula_inmobiliaria  VARCHAR(50) NOT NULL UNIQUE,
    titulo                  VARCHAR(150) NOT NULL,
    descripcion             TEXT,
    precio                  DECIMAL(14,2) NOT NULL CHECK (precio >= 0),
    estado                  VARCHAR(20) NOT NULL DEFAULT 'DISPONIBLE', -- DISPONIBLE / VENDIDA / ARRENDADA / INACTIVA
    fecha_publicacion       TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_propiedad_inmobiliaria FOREIGN KEY (id_inmobiliaria)
        REFERENCES inmobiliaria(id_inmobiliaria) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_propiedad_ciudad FOREIGN KEY (id_ciudad)
        REFERENCES ciudad(id_ciudad) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_propiedad_tipo FOREIGN KEY (id_tipo)
        REFERENCES tipo_propiedad(id_tipo) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ============================================================
-- 9. IMAGEN_PROPIEDAD  (1:N desde propiedad)
-- ============================================================
CREATE TABLE imagen_propiedad (
    id_imagen    SERIAL PRIMARY KEY,
    id_propiedad INT NOT NULL,
    url_imagen   VARCHAR(255) NOT NULL,
    es_principal BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_imagen_propiedad FOREIGN KEY (id_propiedad)
        REFERENCES propiedad(id_propiedad) ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================================
-- 10. CARACTERISTICA  (catálogo)
-- ============================================================
CREATE TABLE caracteristica (
    id_caracteristica SERIAL PRIMARY KEY,
    nombre            VARCHAR(60) NOT NULL UNIQUE -- piscina, parqueadero, ascensor, gimnasio...
);

-- ============================================================
-- 11. PROPIEDAD_CARACTERISTICA  (N:M entre propiedad y caracteristica)
-- ============================================================
CREATE TABLE propiedad_caracteristica (
    id_propiedad      INT NOT NULL,
    id_caracteristica INT NOT NULL,
    cantidad          INT DEFAULT 1,
    PRIMARY KEY (id_propiedad, id_caracteristica),
    CONSTRAINT fk_propcarac_propiedad FOREIGN KEY (id_propiedad)
        REFERENCES propiedad(id_propiedad) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_propcarac_caracteristica FOREIGN KEY (id_caracteristica)
        REFERENCES caracteristica(id_caracteristica) ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================================
-- 12. CITA  (1:N desde propiedad y desde usuario/cliente)
-- ============================================================
CREATE TABLE cita (
    id_cita      SERIAL PRIMARY KEY,
    id_propiedad INT NOT NULL,
    id_usuario   INT NOT NULL, -- cliente que agenda
    fecha_hora   TIMESTAMP NOT NULL,
    estado       VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE', -- PENDIENTE / CONFIRMADA / CANCELADA / REALIZADA
    CONSTRAINT fk_cita_propiedad FOREIGN KEY (id_propiedad)
        REFERENCES propiedad(id_propiedad) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_cita_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT uk_cita_propiedad_fecha UNIQUE (id_propiedad, fecha_hora)
);

-- ============================================================
-- 13. SOLICITUD  (1:N desde propiedad y desde usuario/cliente)
-- ============================================================
CREATE TABLE solicitud (
    id_solicitud SERIAL PRIMARY KEY,
    id_propiedad INT NOT NULL,
    id_usuario   INT NOT NULL, -- cliente
    tipo         VARCHAR(20) NOT NULL, -- COMPRA / ARRIENDO
    estado       VARCHAR(20) NOT NULL DEFAULT 'EN_REVISION', -- BORRADOR / EN_REVISION / APROBADA / RECHAZADA
    fecha_solicitud TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_solicitud_propiedad FOREIGN KEY (id_propiedad)
        REFERENCES propiedad(id_propiedad) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_solicitud_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================================
-- 14. DOCUMENTO_SOLICITUD  (1:N desde solicitud)
-- ============================================================
CREATE TABLE documento_solicitud (
    id_documento   SERIAL PRIMARY KEY,
    id_solicitud   INT NOT NULL,
    url_documento  VARCHAR(255) NOT NULL,
    nombre_documento VARCHAR(255),
    tipo_documento VARCHAR(80),
    fecha_carga    TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_documento_solicitud FOREIGN KEY (id_solicitud)
        REFERENCES solicitud(id_solicitud) ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================================
-- 15. FAVORITO  (N:M entre usuario y propiedad)
-- ============================================================
CREATE TABLE favorito (
    id_usuario   INT NOT NULL,
    id_propiedad INT NOT NULL,
    fecha_marcado TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id_usuario, id_propiedad),
    CONSTRAINT fk_favorito_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_favorito_propiedad FOREIGN KEY (id_propiedad)
        REFERENCES propiedad(id_propiedad) ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================================
-- 16. AUDITORIA  (1:N desde usuario)
-- ============================================================
CREATE TABLE auditoria (
    id_auditoria SERIAL PRIMARY KEY,
    id_usuario   INT,
    accion       VARCHAR(150) NOT NULL,
    fecha        TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_auditoria_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario) ON DELETE SET NULL ON UPDATE CASCADE
);
