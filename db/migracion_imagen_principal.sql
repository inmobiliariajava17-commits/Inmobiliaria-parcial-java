-- ============================================================
-- MIGRACIÓN: imagen principal de cada propiedad
-- Ejecutar en una base de datos que ya tenga creada imagen_propiedad
-- ============================================================

ALTER TABLE imagen_propiedad
    ADD COLUMN IF NOT EXISTS es_principal BOOLEAN NOT NULL DEFAULT FALSE;

-- Dejar como principal la primera imagen de cada propiedad que todavía
-- no tenga una marcada como principal.
UPDATE imagen_propiedad ip
SET es_principal = TRUE
WHERE ip.id_imagen IN (
    SELECT MIN(ip2.id_imagen)
    FROM imagen_propiedad ip2
    GROUP BY ip2.id_propiedad
    HAVING COUNT(*) > 0
)
AND NOT EXISTS (
    SELECT 1
    FROM imagen_propiedad ip3
    WHERE ip3.id_propiedad = ip.id_propiedad
      AND ip3.es_principal = TRUE
);
