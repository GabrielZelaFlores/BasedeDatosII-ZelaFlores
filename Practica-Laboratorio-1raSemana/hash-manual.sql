
-- EJERCICIO 2: HASH MANUAL

-- 2.1 CREAR FUNCIÓN HASH PERSONALIZADA
CREATE OR REPLACE FUNCTION hash_estudiante (id INTEGER)
RETURNS INTEGER AS $$
BEGIN
    RETURN id % 7;  
    -- Tabla hash con 7 posiciones (de 0 a 6).
END;
$$ LANGUAGE plpgsql;

-- 2.2 APLICAR HASH A LOS DATOS
SELECT id_estudiante,nombres,apellidos, hash_estudiante(id_estudiante) AS posicion_hash
FROM estudiantes
ORDER BY hash_estudiante(id_estudiante), id_estudiante;

-- 2.3 ANALIZAR COLISIONES
SELECT
    hash_estudiante(id_estudiante) AS posicion_hash, COUNT(*) AS cantidad_registros,
    ARRAY_AGG(id_estudiante ORDER BY id_estudiante) AS ids_en_posicion
FROM estudiantes
GROUP BY hash_estudiante(id_estudiante) ORDER BY posicion_hash;


-- ==========================================
-- PARTICIONAMIENTO HASH
-- 2.4 CREAR TABLA PRINCIPAL PARTICIONADA POR HASH
CREATE TABLE estudiantes_hash (
    id_estudiante INTEGER,
    nombres VARCHAR(50),
    apellidos VARCHAR(50),
    carrera VARCHAR(30),
    semestre INTEGER,
    promedio DECIMAL(4,2)
) PARTITION BY HASH (id_estudiante);

-- CreE 4 particiones.
-- PostgreSQL calculará: id_estudiante % 4 = {0,1,2,3}
CREATE TABLE estudiantes_hash_p0
PARTITION OF estudiantes_hash
FOR VALUES WITH (MODULUS 4, REMAINDER 0);

CREATE TABLE estudiantes_hash_p1
PARTITION OF estudiantes_hash
FOR VALUES WITH (MODULUS 4, REMAINDER 1);

CREATE TABLE estudiantes_hash_p2
PARTITION OF estudiantes_hash
FOR VALUES WITH (MODULUS 4, REMAINDER 2);

CREATE TABLE estudiantes_hash_p3
PARTITION OF estudiantes_hash
FOR VALUES WITH (MODULUS 4, REMAINDER 3);

-- 2.5 INSERTAR DATOS Y VERIFICAR DISTRIBUCIÓN

INSERT INTO estudiantes_hash
SELECT * FROM estudiantes;

-- Ver distribución por partición
SELECT
    schemaname,
    relname AS tablename,
    n_tup_ins AS registros_insertados
FROM pg_stat_user_tables
WHERE relname LIKE 'estudiantes_hash%'
ORDER BY relname;
