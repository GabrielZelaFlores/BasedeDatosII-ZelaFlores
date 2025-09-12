-- Ejercicio 2: Creación de Índices Básicos
-- Crear índices apropiados (B-tree por defecto)
CREATE INDEX idx_empleados_departamento
ON empleados(departamento);

CREATE INDEX idx_empleados_salario
ON empleados(salario);

CREATE INDEX idx_ventas_empleado_id
ON ventas(empleado_id);

CREATE INDEX idx_ventas_fecha
ON ventas(fecha_venta);

CREATE INDEX idx_ventas_categoria
ON ventas(categoria);

CREATE INDEX idx_ventas_empleado_fecha
ON ventas(empleado_id, fecha_venta);

-- Verificar índices creados
-- Ver todos los índices de una tabla
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'empleados';

-- Ver tamaño de índices
SELECT 
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_total_relation_size(indexrelid)) AS index_size
FROM pg_stat_user_indexes
ORDER BY pg_total_relation_size(indexrelid) DESC;

-- Re-ejecutar Consultas (Con Índices)
\timing on

-- Consulta 1: Búsqueda por ID de empleado
EXPLAIN ANALYZE
SELECT * FROM empleados WHERE id = 500;

-- Consulta 2: Búsqueda por departamento
EXPLAIN ANALYZE
SELECT * FROM empleados WHERE departamento = 'Ventas';

-- Consulta 3: Búsqueda por rango de salarios
EXPLAIN ANALYZE
SELECT * FROM empleados
WHERE salario BETWEEN 4000 AND 5000;

-- Consulta 4: JOIN con agregación
EXPLAIN ANALYZE
SELECT e.nombre, COUNT(*) as total_ventas
FROM empleados e
JOIN ventas v ON e.id = v.empleado_id
WHERE v.fecha_venta >= '2023-06-01'::DATE
GROUP BY e.id, e.nombre
ORDER BY total_ventas DESC
LIMIT 10;

