--PARTE 5

-- Limpiar estadísticas
SELECT pg_stat_reset();

-- Consulta en tabla sin particionamiento
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT COUNT(*), AVG(total), MIN(fecha_venta), MAX(fecha_venta)
FROM ventas_sin_particion
WHERE fecha_venta BETWEEN '2023-06-01' AND '2023-08-31';

-- Misma consulta en tabla particionada
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT COUNT(*), AVG(total), MIN(fecha_venta), MAX(fecha_venta)
FROM ventas_particionada
WHERE fecha_venta BETWEEN '2023-06-01' AND '2023-08-31';

-- Consulta por cliente específico - tabla sin particiones
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT * FROM ventas_sin_particion
WHERE cliente_id = 5000
AND fecha_venta >= '2024-01-01'
ORDER BY fecha_venta DESC
LIMIT 100;

-- Misma consulta - tabla con subparticiones hash
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT * FROM ventas_hibrida
WHERE cliente_id = 5000
AND fecha_venta >= '2024-01-01'
ORDER BY fecha_venta DESC
LIMIT 100;

-- Verificar eliminación de particiones
SET enable_partition_pruning = on;
SET constraint_exclusion = partition;

EXPLAIN (ANALYZE, BUFFERS)
SELECT sucursal_id, SUM(total) AS ventas_totales
FROM ventas_particionada
WHERE fecha_venta = '2023-12-25'
GROUP BY sucursal_id
ORDER BY ventas_totales DESC;

-- Tabla para almacenar resultados de pruebas (corregida para incluir más campos)
CREATE TABLE metricas_rendimiento (
    id SERIAL PRIMARY KEY,
    tipo VARCHAR(50),  -- ej. 'sin_particion'
    tabla VARCHAR(50),
    tipo_consulta VARCHAR(100),  -- ej. 'rango_fechas'
    tiempo_ejecucion_ms DECIMAL(18,2),
    buffers_hit INTEGER,
    buffers_read INTEGER,
    fecha_prueba TIMESTAMP DEFAULT NOW()
);

-- Función para ejecutar y medir consultas (corregida: solo mide tiempo; buffers se agregan manualmente después de EXPLAIN)
CREATE OR REPLACE FUNCTION medir_consulta(
    nombre_prueba TEXT,
    consulta TEXT
) RETURNS VOID AS $$
DECLARE
    inicio TIMESTAMP;
    duracion DECIMAL(18,2);
BEGIN
    inicio := clock_timestamp();
    EXECUTE consulta;
    duracion := EXTRACT(MILLISECOND FROM (clock_timestamp() - inicio));
    RAISE NOTICE 'Prueba: %, Duración: % ms', nombre_prueba, duracion;
    INSERT INTO metricas_rendimiento (tipo, tiempo_ejecucion_ms)
    VALUES (nombre_prueba, duracion);
END;
$$ LANGUAGE plpgsql;

-- Ejemplo de uso (ajusta con tus consultas)
SELECT medir_consulta('rango_sin_particion', 'SELECT COUNT(*) FROM ventas_sin_particion WHERE fecha_venta BETWEEN ''2023-06-01'' AND ''2023-08-31'';');

-- Consulta 1: Rango de fechas - tabla sin partición
SELECT medir_consulta(
    'rango_sin_particion',
    'SELECT COUNT(*), AVG(total), MIN(fecha_venta), MAX(fecha_venta)
     FROM ventas_sin_particion
     WHERE fecha_venta BETWEEN ''2023-06-01'' AND ''2023-08-31'';'
);

-- Consulta 2: Rango de fechas - tabla particionada
SELECT medir_consulta(
    'rango_particionada',
    'SELECT COUNT(*), AVG(total), MIN(fecha_venta), MAX(fecha_venta)
     FROM ventas_particionada
     WHERE fecha_venta BETWEEN ''2023-06-01'' AND ''2023-08-31'';'
);

-- Consulta 3: Cliente específico - sin partición
SELECT medir_consulta(
    'cliente_sin_particion',
    'SELECT * FROM ventas_sin_particion
     WHERE cliente_id = 5000
     AND fecha_venta >= ''2024-01-01''
     ORDER BY fecha_venta DESC
     LIMIT 100;'
);

-- Consulta 4: Cliente específico - tabla híbrida (subparticiones)
SELECT medir_consulta(
    'cliente_particionada_hibrida',
    'SELECT * FROM ventas_hibrida
     WHERE cliente_id = 5000
     AND fecha_venta >= ''2024-01-01''
     ORDER BY fecha_venta DESC
     LIMIT 100;'
);

-- Consulta 5: Agregación por día y sucursal (verifica pruning)
SELECT medir_consulta(
    'agregacion_particionada',
    'SELECT sucursal_id, SUM(total) AS ventas_totales
     FROM ventas_particionada
     WHERE fecha_venta = ''2023-12-25''
     GROUP BY sucursal_id
     ORDER BY ventas_totales DESC;'
);

-- Ejecuta con EXPLAIN para ver buffers
EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*), AVG(total), MIN(fecha_venta), MAX(fecha_venta)
FROM ventas_sin_particion
WHERE fecha_venta BETWEEN '2023-06-01' AND '2023-08-31';

-- Supongamos que obtienes:
-- Buffers: shared hit=10240 read=120

-- Actualizas en metricas_rendimiento
UPDATE metricas_rendimiento
SET buffers_hit = 10240, buffers_read = 120
WHERE tipo = 'rango_sin_particion';

-- Ver todas las métricas
SELECT * FROM metricas_rendimiento ORDER BY fecha_prueba DESC;

-- Comparar tiempos promedio
SELECT tipo, AVG(tiempo_ejecucion_ms) AS tiempo_promedio
FROM metricas_rendimiento
GROUP BY tipo;

