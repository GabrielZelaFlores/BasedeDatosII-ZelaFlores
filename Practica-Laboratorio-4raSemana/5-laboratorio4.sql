--PARTE 6

DROP TABLE IF EXISTS ventas_particionada CASCADE;

CREATE TABLE ventas_particionada (
    id SERIAL,
    fecha_venta DATE NOT NULL,
    cliente_id INTEGER NOT NULL,
    producto_id INTEGER NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    total DECIMAL(12,2) NOT NULL,
    sucursal_id INTEGER NOT NULL,
    vendedor_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) PARTITION BY RANGE (fecha_venta);

CREATE OR REPLACE FUNCTION crear_particion_anual(
    tabla_principal TEXT,
    ano INTEGER
) RETURNS TEXT AS $$
DECLARE
    fecha_inicio DATE := make_date(ano, 1, 1);
    fecha_fin DATE := make_date(ano + 1, 1, 1);
    nombre_particion TEXT := tabla_principal || '_' || ano;
    comando_sql TEXT;
BEGIN
    comando_sql := format(
        'CREATE TABLE IF NOT EXISTS %I PARTITION OF %I FOR VALUES FROM (%L) TO (%L) PARTITION BY RANGE (fecha_venta);',
        nombre_particion, tabla_principal, fecha_inicio, fecha_fin
    );
    EXECUTE comando_sql;
    RETURN 'Partición anual creada: ' || nombre_particion;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION crear_particion_mensual(
    tabla_principal TEXT,
    ano INTEGER,
    mes INTEGER
) RETURNS TEXT AS $$
DECLARE
    fecha_inicio DATE;
    fecha_fin DATE;
    nombre_anual TEXT;
    nombre_mensual TEXT;
    comando_sql TEXT;
BEGIN
    -- Primero aseguramos que exista la partición anual
    PERFORM crear_particion_anual(tabla_principal, ano);

    fecha_inicio := make_date(ano, mes, 1);
    fecha_fin := fecha_inicio + INTERVAL '1 month';
    nombre_anual := tabla_principal || '_' || ano;
    nombre_mensual := nombre_anual || '_' || LPAD(mes::TEXT, 2, '0');

    comando_sql := format(
        'CREATE TABLE IF NOT EXISTS %I PARTITION OF %I FOR VALUES FROM (%L) TO (%L);',
        nombre_mensual, nombre_anual, fecha_inicio, fecha_fin
    );

    EXECUTE comando_sql;
    RETURN 'Partición mensual creada: ' || nombre_mensual;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION limpiar_particiones_antiguas(
    tabla_principal TEXT,
    meses_retener INTEGER DEFAULT 24
) RETURNS TEXT AS $$
DECLARE
    rec RECORD;
    fecha_limite DATE;
    fecha_particion DATE;
    resultado TEXT := '';
BEGIN
    fecha_limite := date_trunc('month', CURRENT_DATE) - (meses_retener || ' months')::INTERVAL;

    FOR rec IN
        SELECT tablename
        FROM pg_tables
        WHERE tablename LIKE tabla_principal || '_%%%%_%%' -- detecta formato YYYY_MM
          AND schemaname = 'public'
    LOOP
        BEGIN
            fecha_particion := to_date(
                substring(rec.tablename from '([0-9]{4}_[0-9]{2})'),
                'YYYY_MM'
            );

            IF fecha_particion < fecha_limite THEN
                EXECUTE format('DROP TABLE IF EXISTS %I CASCADE;', rec.tablename);
                resultado := resultado || 'Eliminada: ' || rec.tablename || E'\n';
            END IF;
        EXCEPTION
            WHEN others THEN
                CONTINUE;
        END;
    END LOOP;

    RETURN COALESCE(NULLIF(resultado, ''), 'No se eliminaron particiones');
END;
$$ LANGUAGE plpgsql;

-- Crear particiones de prueba
SELECT crear_particion_mensual('ventas_particionada', 2025, 1);
SELECT crear_particion_mensual('ventas_particionada', 2025, 2);
SELECT crear_particion_mensual('ventas_particionada', 2024, 12);

-- Limpiar particiones con más de 12 meses de antigüedad
SELECT limpiar_particiones_antiguas('ventas_particionada', 12);
