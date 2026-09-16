-- ============================================================
-- PROYECTO: Sistema Web Inmobiliaria
-- Script DML - Datos de prueba (PostgreSQL / Supabase)
-- Ejecutar DESPUÉS de ddl_inmobiliaria.sql
-- ============================================================

-- ============================================================
-- 1. ROL (catálogo fijo)
-- ============================================================
INSERT INTO rol (nombre_rol) VALUES
('ADMINISTRADOR'),
('INMOBILIARIA'),
('CLIENTE');

-- ============================================================
-- 2. USUARIO (10 registros)
-- NOTA: todos los password_hash corresponden a la contraseña real "123456"
-- generados con BCrypt (10 rounds), compatibles con jBCrypt en Java.
-- Úsala solo para pruebas/sustentación, nunca en un entorno real.
-- ============================================================
INSERT INTO usuario (correo, password_hash, estado) VALUES
('admin@inmoapp.com',        '$2a$10$Lu6qQ6J4I5SGDGLKZfpaNuINpnlo2tN9eit8fwGmuJDgbGGE9AK1G', 'ACTIVO'),
('agente.duran@inmoapp.com', '$2a$10$hK.6jGAgPq7dNzm/BNHj7eIOlzaIpkz/U2gy5bhgAeGEMRbIuRwzO', 'ACTIVO'),
('agente.rios@inmoapp.com',  '$2a$10$.eMm1SGEhjrR2EuO/dgfF.Lkm.9Lf/GdQ476r4Md89mmVAX.V7k5m', 'ACTIVO'),
('juan.perez@gmail.com',     '$2a$10$Shz8cpLEBzDHzgImMhLQ0OLe9IxI6U/zRG2Dimb.hAKFBDaaBskiC', 'ACTIVO'),
('maria.gomez@gmail.com',    '$2a$10$9CF9y.j.W/MCposhJ7j5zOzanhEXosp0tIMLh9gang5TNrsy3dRzS', 'ACTIVO'),
('carlos.diaz@gmail.com',    '$2a$10$OwQPNihNjhDpOO/1iIzneOkVMRJwhkArfBp7oxK.hFth8muVEhCo6', 'ACTIVO'),
('laura.ruiz@gmail.com',     '$2a$10$UUWaGooU5nxay3rKLUzeb.eN3VTSk12glK5xScRQ9KVFzwZaFXwCG', 'ACTIVO'),
('pedro.suarez@gmail.com',   '$2a$10$cmk/7PgIpXcd6/c7BftZwOeC.c1mIk6XhImbkkzaNb87XP.dM84RG', 'INACTIVO'),
('ana.torres@gmail.com',     '$2a$10$WlU3/dtBBENW73l8J7HBsOKis5VZUyW1GTjTnZMC0yF7/r2vFhKwC', 'ACTIVO'),
('felipe.mora@gmail.com',    '$2a$10$Edu.BeFStYKQT4dtMDwACekMT/PaTsleOtMT4M9r/mXEn3jUPNA5a', 'ACTIVO');

-- ============================================================
-- 3. USUARIO_ROL (asignación de roles)
-- id_usuario 1=admin, 2-3=inmobiliaria, 4-10=cliente
-- ============================================================
INSERT INTO usuario_rol (id_usuario, id_rol) VALUES
(1, 1), -- admin -> ADMINISTRADOR
(2, 2), -- agente.duran -> INMOBILIARIA
(3, 2), -- agente.rios -> INMOBILIARIA
(4, 3),
(5, 3),
(6, 3),
(7, 3),
(8, 3),
(9, 3),
(10, 3),
(9, 2); -- ejemplo de usuario con doble rol (N:M real): ana.torres también es agente

-- ============================================================
-- 4. PERFIL (1:1 con usuario, 10 registros)
-- ============================================================
INSERT INTO perfil (id_usuario, nombres, apellidos, documento, telefono, direccion) VALUES
(1,  'Laura',   'Martínez', '1091234561', '3001112233', 'Cra 10 #20-30, Bucaramanga'),
(2,  'Andrés',  'Durán',    '1091234562', '3002223344', 'Cll 45 #12-10, Floridablanca'),
(3,  'Camila',  'Ríos',     '1091234563', '3003334455', 'Cra 27 #33-21, Bucaramanga'),
(4,  'Juan',    'Pérez',    '1091234564', '3004445566', 'Cll 56 #8-19, Bucaramanga'),
(5,  'María',   'Gómez',    '1091234565', '3005556677', 'Cra 15 #40-12, Floridablanca'),
(6,  'Carlos',  'Díaz',     '1091234566', '3006667788', 'Cll 32 #22-45, Girón'),
(7,  'Laura',   'Ruiz',     '1091234567', '3007778899', 'Cra 9 #14-56, Bucaramanga'),
(8,  'Pedro',   'Suárez',   '1091234568', '3008889900', 'Cll 60 #18-30, Floridablanca'),
(9,  'Ana',     'Torres',   '1091234569', '3009990011', 'Cra 33 #45-10, Bucaramanga'),
(10, 'Felipe',  'Mora',     '1091234570', '3001231212', 'Cll 20 #10-05, Girón');

-- ============================================================
-- 5. INMOBILIARIA (1:1 con usuario, agentes)
-- ============================================================
INSERT INTO inmobiliaria (id_usuario, nombre_agencia, nit) VALUES
(2, 'Durán Bienes Raíces',     '900123456-1'),
(3, 'Ríos Propiedades',        '900123457-2'),
(9, 'Torres Inmobiliaria Plus','900123458-3');

-- ============================================================
-- 6. CIUDAD (catálogo, 10 registros)
-- ============================================================
INSERT INTO ciudad (nombre_ciudad) VALUES
('Bucaramanga'),
('Floridablanca'),
('Girón'),
('Piedecuesta'),
('Bogotá'),
('Medellín'),
('Cali'),
('Cartagena'),
('Barranquilla'),
('Santa Marta');

-- ============================================================
-- 7. TIPO_PROPIEDAD (catálogo)
-- ============================================================
INSERT INTO tipo_propiedad (nombre_tipo) VALUES
('Casa'),
('Apartamento'),
('Local'),
('Oficina'),
('Terreno');

-- ============================================================
-- 8. PROPIEDAD (10 registros)
-- id_inmobiliaria: 1=Durán, 2=Ríos, 3=Torres
-- ============================================================
INSERT INTO propiedad (id_inmobiliaria, id_ciudad, id_tipo, matricula_inmobiliaria, titulo, descripcion, precio, estado) VALUES
(1, 1, 2, 'MI-000001', 'Apartamento moderno en el centro',      'Apartamento de 3 alcobas, remodelado, cerca a parque.', 320000000, 'DISPONIBLE'),
(1, 2, 1, 'MI-000002', 'Casa campestre en Floridablanca',       'Casa de 2 pisos con jardín y garaje doble.',            580000000, 'DISPONIBLE'),
(2, 1, 3, 'MI-000003', 'Local comercial cerca a Cabecera',      'Local de 60m2, apto para restaurante o tienda.',        250000000, 'DISPONIBLE'),
(2, 3, 2, 'MI-000004', 'Apartamento vista panorámica en Girón', 'Apartamento nuevo, torre con ascensor.',                210000000, 'DISPONIBLE'),
(3, 1, 4, 'MI-000005', 'Oficina en edificio corporativo',       'Oficina de 45m2 con recepción compartida.',             180000000, 'ARRENDADA'),
(1, 4, 1, 'MI-000006', 'Casa familiar en Piedecuesta',          'Casa de 4 alcobas, patio amplio.',                      450000000, 'DISPONIBLE'),
(2, 2, 5, 'MI-000007', 'Lote urbanizable en Floridablanca',     'Terreno de 500m2, uso residencial.',                    300000000, 'DISPONIBLE'),
(3, 1, 2, 'MI-000008', 'Apartaestudio para inversión',          'Ideal para renta universitaria, amoblado.',              95000000, 'VENDIDA'),
(1, 3, 1, 'MI-000009', 'Casa esquinera en Girón',                'Casa de 3 alcobas, cerca al parque principal.',         380000000, 'DISPONIBLE'),
(2, 1, 3, 'MI-000010', 'Local en zona rosa de Bucaramanga',     'Local de 80m2, alto tráfico peatonal.',                 410000000, 'INACTIVA');

-- ============================================================
-- 9. IMAGEN_PROPIEDAD (varias por propiedad, 10+ registros)
-- ============================================================
INSERT INTO imagen_propiedad (id_propiedad, url_imagen) VALUES
(1, 'https://picsum.photos/seed/prop1a/800/600'),
(1, 'https://picsum.photos/seed/prop1b/800/600'),
(2, 'https://picsum.photos/seed/prop2a/800/600'),
(3, 'https://picsum.photos/seed/prop3a/800/600'),
(4, 'https://picsum.photos/seed/prop4a/800/600'),
(5, 'https://picsum.photos/seed/prop5a/800/600'),
(6, 'https://picsum.photos/seed/prop6a/800/600'),
(7, 'https://picsum.photos/seed/prop7a/800/600'),
(8, 'https://picsum.photos/seed/prop8a/800/600'),
(9, 'https://picsum.photos/seed/prop9a/800/600'),
(10, 'https://picsum.photos/seed/prop10a/800/600');

-- ============================================================
-- 10. CARACTERISTICA (catálogo, 10 registros)
-- ============================================================
INSERT INTO caracteristica (nombre) VALUES
('Piscina'),
('Parqueadero'),
('Ascensor'),
('Gimnasio'),
('Zona BBQ'),
('Seguridad 24h'),
('Terraza'),
('Amoblado'),
('Aire acondicionado'),
('Jardín');

-- ============================================================
-- 11. PROPIEDAD_CARACTERISTICA (N:M, varias combinaciones)
-- ============================================================
INSERT INTO propiedad_caracteristica (id_propiedad, id_caracteristica, cantidad) VALUES
(1, 2, 1), (1, 3, 1), (1, 6, 1),
(2, 2, 2), (2, 10, 1), (2, 5, 1),
(3, 6, 1),
(4, 1, 1), (4, 2, 1), (4, 3, 1), (4, 4, 1),
(5, 3, 1), (5, 6, 1),
(6, 2, 2), (6, 10, 1),
(7, 2, 1),
(8, 8, 1), (8, 9, 1),
(9, 2, 1), (9, 10, 1),
(10, 6, 1);

-- ============================================================
-- 12. CITA (10 registros)
-- ============================================================
INSERT INTO cita (id_propiedad, id_usuario, fecha_hora, estado) VALUES
(1, 4,  '2026-09-10 10:00', 'PENDIENTE'),
(1, 5,  '2026-09-11 15:00', 'CONFIRMADA'),
(2, 6,  '2026-09-12 09:00', 'PENDIENTE'),
(3, 7,  '2026-09-12 11:00', 'CANCELADA'),
(4, 4,  '2026-09-13 14:00', 'CONFIRMADA'),
(6, 8,  '2026-09-14 16:00', 'PENDIENTE'),
(7, 9,  '2026-09-15 10:00', 'REALIZADA'),
(9, 10, '2026-09-16 09:30', 'PENDIENTE'),
(2, 7,  '2026-09-17 11:00', 'PENDIENTE'),
(4, 6,  '2026-09-18 15:30', 'CONFIRMADA');

-- ============================================================
-- 13. SOLICITUD (10 registros)
-- ============================================================
INSERT INTO solicitud (id_propiedad, id_usuario, tipo, estado) VALUES
(1, 4,  'ARRIENDO', 'EN_REVISION'),
(2, 5,  'COMPRA',   'APROBADA'),
(3, 6,  'ARRIENDO', 'EN_REVISION'),
(4, 4,  'COMPRA',   'RECHAZADA'),
(6, 8,  'COMPRA',   'EN_REVISION'),
(7, 9,  'ARRIENDO', 'APROBADA'),
(9, 10, 'COMPRA',   'EN_REVISION'),
(2, 7,  'ARRIENDO', 'EN_REVISION'),
(4, 6,  'COMPRA',   'APROBADA'),
(1, 9,  'ARRIENDO', 'RECHAZADA');

-- ============================================================
-- 14. DOCUMENTO_SOLICITUD (al menos uno por algunas solicitudes)
-- ============================================================
INSERT INTO documento_solicitud (id_solicitud, url_documento) VALUES
(1, 'https://storage.inmoapp.com/docs/sol1_cedula.pdf'),
(1, 'https://storage.inmoapp.com/docs/sol1_carta_laboral.pdf'),
(2, 'https://storage.inmoapp.com/docs/sol2_cedula.pdf'),
(3, 'https://storage.inmoapp.com/docs/sol3_cedula.pdf'),
(5, 'https://storage.inmoapp.com/docs/sol5_cedula.pdf'),
(6, 'https://storage.inmoapp.com/docs/sol6_cedula.pdf'),
(6, 'https://storage.inmoapp.com/docs/sol6_certificado_ingresos.pdf'),
(8, 'https://storage.inmoapp.com/docs/sol8_cedula.pdf'),
(9, 'https://storage.inmoapp.com/docs/sol9_cedula.pdf'),
(10, 'https://storage.inmoapp.com/docs/sol10_cedula.pdf');

-- ============================================================
-- 15. FAVORITO (N:M, 10 registros)
-- ============================================================
INSERT INTO favorito (id_usuario, id_propiedad) VALUES
(4, 1), (4, 6), (4, 9),
(5, 2), (5, 4),
(6, 3), (6, 7),
(7, 1), (7, 2),
(10, 9);

-- ============================================================
-- 16. AUDITORIA (10 registros)
-- ============================================================
INSERT INTO auditoria (id_usuario, accion) VALUES
(1, 'Inicio de sesión exitoso'),
(2, 'Publicó propiedad MI-000001'),
(3, 'Publicó propiedad MI-000003'),
(4, 'Registró nueva cuenta'),
(1, 'Activó cuenta de usuario id 9'),
(2, 'Editó propiedad MI-000002'),
(9, 'Aprobó solicitud id 2'),
(3, 'Rechazó solicitud id 4'),
(1, 'Consultó reporte de propiedades por ciudad'),
(6, 'Actualizó datos de perfil');
