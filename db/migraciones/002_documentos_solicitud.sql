-- Agrega informacion para identificar los documentos cargados en una solicitud.
-- Ejecutar una sola vez sobre una base de datos que ya tenga la tabla documento_solicitud.

ALTER TABLE documento_solicitud
    ADD COLUMN IF NOT EXISTS nombre_documento VARCHAR(255),
    ADD COLUMN IF NOT EXISTS tipo_documento VARCHAR(80);

UPDATE documento_solicitud
SET nombre_documento = COALESCE(nombre_documento, 'Documento cargado'),
    tipo_documento = COALESCE(tipo_documento, 'DOCUMENTO ADICIONAL')
WHERE nombre_documento IS NULL OR tipo_documento IS NULL;
