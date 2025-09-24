--Zela Flores Gabriel Frank Krisna 
--Base de Datos II
--Laboratorio 4

CREATE DATABASE lab_particionamiento;

CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

ALTER SYSTEM SET log_min_duration_statement = 1000; -- 1 segundo
ALTER SYSTEM SET log_statement = 'all';
SELECT pg_reload_conf();


-- Tabla de ventas sin particiones
CREATE TABLE ventas_sin_particion (
    id SERIAL PRIMARY KEY,
    fecha_venta DATE NOT NULL,
    cliente_id INTEGER NOT NULL,
    producto_id INTEGER NOT NULL,
    cantidad INTEGER NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    total DECIMAL(12,2) NOT NULL,
    sucursal_id INTEGER NOT NULL,
    vendedor_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Índices básicos
CREATE INDEX idx_ventas_fecha ON ventas_sin_particion(fecha_venta);
CREATE INDEX idx_ventas_cliente ON ventas_sin_particion(cliente_id);


-- Función para generar datos aleatorios
CREATE OR REPLACE FUNCTION generar_ventas_masivas(num_registros INTEGER)
RETURNS VOID AS $$
DECLARE
    i INTEGER;
    fecha_aleatoria DATE;
    precio DECIMAL(10,2);
BEGIN
    FOR i IN 1..num_registros LOOP
        -- Fecha entre 2020 y 2024
        fecha_aleatoria := '2020-01-01'::DATE + (RANDOM() * ('2024-12-31'::DATE - '2020-01-01'::DATE))::INTEGER;
        precio := ROUND((RANDOM() * 1000 + 10)::NUMERIC, 2);
        INSERT INTO ventas_sin_particion (
            fecha_venta, cliente_id, producto_id, cantidad,
            precio_unitario, total, sucursal_id, vendedor_id
        ) VALUES (
            fecha_aleatoria,
            (RANDOM() * 10000 + 1)::INTEGER,
            (RANDOM() * 5000 + 1)::INTEGER,
            (RANDOM() * 10 + 1)::INTEGER,
            precio,
            precio * (RANDOM() * 10 + 1),
            (RANDOM() * 50 + 1)::INTEGER,
            (RANDOM() * 200 + 1)::INTEGER
        );
        -- Mostrar progreso cada 100,000 registros
        IF i % 100000 = 0 THEN
            RAISE NOTICE 'Insertados % registros', i;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Ejecutar inserción de 2 millones de registros
SELECT generar_ventas_masivas(2000000);

-- Estadísticas de la tabla
SELECT
    schemaname,
    relname AS tablename,
    n_tup_ins AS inserciones,
    n_tup_del AS eliminaciones,
    n_tup_upd AS actualizaciones,
    seq_scan AS escaneos_secuencial,
    seq_tup_read AS tuplas_leidas_secuencial,
    idx_scan AS escaneos_index,
    idx_tup_fetch AS tuplas_fetch_index
FROM pg_stat_user_tables
WHERE relname = 'ventas_sin_particion';


-- Tamaño de la tabla
SELECT
    pg_size_pretty(pg_total_relation_size('ventas_sin_particion')) AS tamano_total,
    pg_size_pretty(pg_relation_size('ventas_sin_particion')) AS tamano_tabla,
    pg_size_pretty(pg_total_relation_size('ventas_sin_particion') - pg_relation_size('ventas_sin_particion')) AS tamano_indices;



	