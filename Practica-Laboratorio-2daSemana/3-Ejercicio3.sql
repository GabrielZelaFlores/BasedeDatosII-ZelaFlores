-- Ejercicio 3: Índices Hash
-- Crear índices Hash para comparar
CREATE INDEX idx_empleados_dept_hash
ON empleados USING HASH(departamento);

CREATE INDEX idx_ventas_categoria_hash
ON ventas USING HASH(categoria);

-- Consultas de Comparación
SET enable_seqscan = OFF;

-- Con índice B-tree
DROP INDEX IF EXISTS idx_empleados_dept_hash;
EXPLAIN ANALYZE
SELECT * FROM empleados WHERE departamento = 'Ventas';

-- Con índice Hash
DROP INDEX IF EXISTS idx_empleados_dept_hash;
CREATE INDEX idx_empleados_dept_hash ON empleados USING HASH(departamento);
EXPLAIN ANALYZE
SELECT * FROM empleados WHERE departamento = 'Ventas';

-- Probar búsqueda por rango (Hash NO funciona eficientemente)
SET enable_seqscan = ON;
EXPLAIN ANALYZE
SELECT * FROM empleados WHERE departamento = 'Marketing';

-- Registro de Resultados - Comparativa
