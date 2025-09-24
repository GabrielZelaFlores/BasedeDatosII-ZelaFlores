--PARTE 3

-- Tabla principal con particionamiento por rango de fechas
CREATE TABLE ventas_particionada (
    id SERIAL,
    fecha_venta DATE NOT NULL,
    cliente_id INTEGER NOT NULL,
    producto_id INTEGER NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    total DECIMAL(12,2) NOT NULL,
    sucursal_id INTEGER NOT NULL,
    vendedor_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
) PARTITION BY RANGE (fecha_venta);

-- Crear particiones por año
CREATE TABLE ventas_2020 PARTITION OF ventas_particionada FOR VALUES FROM ('2020-01-01') TO ('2021-01-01');
CREATE TABLE ventas_2021 PARTITION OF ventas_particionada FOR VALUES FROM ('2021-01-01') TO ('2022-01-01');
CREATE TABLE ventas_2022 PARTITION OF ventas_particionada FOR VALUES FROM ('2022-01-01') TO ('2023-01-01');
CREATE TABLE ventas_2023 PARTITION OF ventas_particionada FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');
CREATE TABLE ventas_2024 PARTITION OF ventas_particionada FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');
-- Agrego para 2025 (ya que la fecha actual es 2025)
CREATE TABLE ventas_2025 PARTITION OF ventas_particionada FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

-- Índices automáticos en todas las particiones
CREATE INDEX idx_ventas_part_cliente ON ventas_particionada(cliente_id);
CREATE INDEX idx_ventas_part_producto ON ventas_particionada(producto_id);
CREATE INDEX idx_ventas_part_sucursal ON ventas_particionada(sucursal_id);

-- Verificar que los índices se crearon en cada partición
SELECT
    schemaname,
    tablename,
    indexname
FROM pg_indexes
WHERE tablename LIKE 'ventas_%'
ORDER BY tablename, indexname;


-- Insertar datos desde tabla sin particiones
INSERT INTO ventas_particionada (
    fecha_venta, cliente_id, producto_id,
    precio_unitario, total, sucursal_id, vendedor_id, created_at
)
SELECT fecha_venta, cliente_id, producto_id,
       precio_unitario, total, sucursal_id, vendedor_id, created_at
FROM ventas_sin_particion;

ANALYZE ventas_particionada;

-- Verificar distribución de datos por partición
SELECT
    tableoid::regclass AS particion,
    COUNT(*) AS registros
FROM ventas_particionada
GROUP BY particion
ORDER BY particion;

