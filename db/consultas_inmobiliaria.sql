-- ============================================================
-- PROYECTO: Sistema Web Inmobiliaria
-- Consultas SQL obligatorias (mínimo 5, según enunciado)
-- ============================================================

-- ------------------------------------------------------------
-- CONSULTA 1 (INNER JOIN, 3+ tablas)
-- Propiedades con su ciudad, su tipo y su inmobiliaria.
-- ------------------------------------------------------------
SELECT
    p.id_propiedad,
    p.titulo,
    p.precio,
    p.estado,
    c.nombre_ciudad,
    tp.nombre_tipo,
    i.nombre_agencia
FROM propiedad p
INNER JOIN ciudad c          ON p.id_ciudad = c.id_ciudad
INNER JOIN tipo_propiedad tp ON p.id_tipo = tp.id_tipo
INNER JOIN inmobiliaria i    ON p.id_inmobiliaria = i.id_inmobiliaria
ORDER BY p.id_propiedad;


-- ------------------------------------------------------------
-- CONSULTA 2 (INNER JOIN, 3+ tablas)
-- Citas agendadas con el nombre del cliente, la propiedad y la ciudad.
-- ------------------------------------------------------------
SELECT
    ci.id_cita,
    ci.fecha_hora,
    ci.estado,
    pf.nombres || ' ' || pf.apellidos AS cliente,
    p.titulo AS propiedad,
    c.nombre_ciudad
FROM cita ci
INNER JOIN usuario u   ON ci.id_usuario = u.id_usuario
INNER JOIN perfil pf   ON u.id_usuario = pf.id_usuario
INNER JOIN propiedad p ON ci.id_propiedad = p.id_propiedad
INNER JOIN ciudad c    ON p.id_ciudad = c.id_ciudad
ORDER BY ci.fecha_hora;


-- ------------------------------------------------------------
-- CONSULTA 3 (resuelve relación N:M)
-- Características de cada propiedad (tabla intermedia propiedad_caracteristica).
-- ------------------------------------------------------------
SELECT
    p.id_propiedad,
    p.titulo,
    car.nombre AS caracteristica,
    pc.cantidad
FROM propiedad p
INNER JOIN propiedad_caracteristica pc ON p.id_propiedad = pc.id_propiedad
INNER JOIN caracteristica car          ON pc.id_caracteristica = car.id_caracteristica
ORDER BY p.id_propiedad, car.nombre;


-- ------------------------------------------------------------
-- CONSULTA 4 (LEFT JOIN)
-- Propiedades que aún NO tienen citas agendadas.
-- ------------------------------------------------------------
SELECT
    p.id_propiedad,
    p.titulo,
    p.estado,
    ci.id_cita
FROM propiedad p
LEFT JOIN cita ci ON p.id_propiedad = ci.id_propiedad
WHERE ci.id_cita IS NULL;


-- ------------------------------------------------------------
-- CONSULTA 5 (agregación con GROUP BY + HAVING)
-- Ciudades con más de 1 propiedad disponible, para el reporte de propiedades por ciudad.
-- ------------------------------------------------------------
SELECT
    c.nombre_ciudad,
    COUNT(p.id_propiedad) AS total_disponibles
FROM propiedad p
INNER JOIN ciudad c ON p.id_ciudad = c.id_ciudad
WHERE p.estado = 'DISPONIBLE'
GROUP BY c.nombre_ciudad
HAVING COUNT(p.id_propiedad) > 1
ORDER BY total_disponibles DESC;


-- ------------------------------------------------------------
-- EXTRA (opcional, útil para el reporte "citas por estado")
-- Cantidad de citas agrupadas por estado.
-- ------------------------------------------------------------
SELECT
    estado,
    COUNT(*) AS total_citas
FROM cita
GROUP BY estado
ORDER BY total_citas DESC;
