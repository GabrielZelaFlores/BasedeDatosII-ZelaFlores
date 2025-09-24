--PARTE 4
-- Tabla con particionamiento por fecha y subparticionamiento por hash
CREATE TABLE ventas_hibrida (
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

-- Partición principal 2024 con subparticiones por hash en cliente_id
CREATE TABLE ventas_2024_base PARTITION OF ventas_hibrida
FOR VALUES FROM ('2024-01-01') TO ('2025-01-01')
PARTITION BY HASH (cliente_id);

-- Crear 4 subparticiones hash para 2024
CREATE TABLE ventas_2024_h0 PARTITION OF ventas_2024_base FOR VALUES WITH (MODULUS 4, REMAINDER 0);
CREATE TABLE ventas_2024_h1 PARTITION OF ventas_2024_base FOR VALUES WITH (MODULUS 4, REMAINDER 1);
CREATE TABLE ventas_2024_h2 PARTITION OF ventas_2024_base FOR VALUES WITH (MODULUS 4, REMAINDER 2);
CREATE TABLE ventas_2024_h3 PARTITION OF ventas_2024_base FOR VALUES WITH (MODULUS 4, REMAINDER 3);

-- Agrego para 2025 (opcional)
CREATE TABLE ventas_2025_base PARTITION OF ventas_hibrida
FOR VALUES FROM ('2025-01-01') TO ('2026-01-01')
PARTITION BY HASH (cliente_id);
CREATE TABLE ventas_2025_h0 PARTITION OF ventas_2025_base FOR VALUES WITH (MODULUS 4, REMAINDER 0);

-- Insertar datos específicos para 2024
INSERT INTO ventas_hibrida (
    fecha_venta,
    cliente_id,
    producto_id,
    precio_unitario,
    total,
    sucursal_id,
    vendedor_id
)
SELECT 
    fecha_venta,
    cliente_id,
    producto_id,
    precio_unitario,
    total,
    sucursal_id,
    vendedor_id
FROM ventas_sin_particion
WHERE fecha_venta >= '2024-01-01' AND fecha_venta < '2025-01-01';


-- Verificar distribución en subparticiones (corregido para contar registros reales)
SELECT
    t.tablename,
    pg_size_pretty(pg_total_relation_size(t.tablename::regclass)) AS tamano,
    c.reltuples::bigint AS registros_estimados
FROM (VALUES 
    ('ventas_2024_h0'),
    ('ventas_2024_h1'),
    ('ventas_2024_h2'),
    ('ventas_2024_h3')
) t(tablename)
JOIN pg_class c ON c.oid = t.tablename::regclass;


