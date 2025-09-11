-- 3.1 FUNCIÓN PARA INSERTAR DATOS MASIVOS

CREATE OR REPLACE FUNCTION insertar_estudiantes_masivo()
RETURNS VOID AS $$
DECLARE
    i INTEGER;
    carreras TEXT[] := ARRAY['Ingeniería de Software', 'Ingeniería de Sistemas', 'Ingeniería Industrial'];
    nombres  TEXT[] := ARRAY['Juan', 'María', 'Carlos', 'Ana', 'Luis', 'Carmen', 'José', 'Patricia'];
    apellidos TEXT[] := ARRAY['García', 'López', 'Martínez', 'González', 'Rodríguez', 'Pérez', 'Sánchez'];
BEGIN
    -- Bucle que genera datos desde id = 2000 hasta id = 3000
    FOR i IN 2000..3000 LOOP
        -- Insertar en tabla HEAP
        INSERT INTO estudiantes_heap VALUES (
            i,
            nombres[(i % 8) + 1],
            apellidos[(i % 7) + 1],
            carreras[(i % 3) + 1],
            (i % 8) + 1,
            14.0 + (i % 5)
        );

        -- Insertar en tabla ORDENADA
        INSERT INTO estudiantes_ordenados VALUES (
            i,
            nombres[(i % 8) + 1],
            apellidos[(i % 7) + 1],
            carreras[(i % 3) + 1],
            (i % 8) + 1,
            14.0 + (i % 5)
        );

        -- Insertar en tabla HASH (particionada)
        INSERT INTO estudiantes_hash VALUES (
            i,
            nombres[(i % 8) + 1],
            apellidos[(i % 7) + 1],
            carreras[(i % 3) + 1],
            (i % 8) + 1,
            14.0 + (i % 5)
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- EJECUTAR LA FUNCIÓN
SELECT insertar_estudiantes_masivo();

-- Contar registros en cada tabla
SELECT COUNT(*) FROM estudiantes_heap;
SELECT COUNT(*) FROM estudiantes_ordenados;
SELECT COUNT(*) FROM estudiantes_hash;


-- 3.2 COMPARAR RENDIMIENTO DE BÚSQUEDAS
-- HEAP
EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*) FROM estudiantes_heap WHERE id_estudiante = 2500;

-- ORDENADO
EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*) FROM estudiantes_ordenados WHERE id_estudiante = 2500;

-- HASH
EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*) FROM estudiantes_hash WHERE id_estudiante = 2500;

-- 3.3 COMPARAR ESPACIO UTILIZADO

SELECT
    schemaname,
    relname AS tablename,
    pg_size_pretty(pg_total_relation_size(schemaname || '.' || relname)) AS tamaño
FROM pg_stat_user_tables
WHERE relname LIKE 'estudiantes_%'
ORDER BY pg_total_relation_size(schemaname || '.' || relname) DESC;
