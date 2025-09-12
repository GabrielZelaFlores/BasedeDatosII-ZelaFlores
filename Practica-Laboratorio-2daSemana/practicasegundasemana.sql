--Zela Flores Gabriel Frank
--Base de Dtos II

-- Paso 1: Conexión a la Base de Datos
CREATE DATABASE laboratorio_indices;
\c laboratorio_indices;

-- Paso 2: Creación de Tablas Base
CREATE TABLE empleados (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    departamento VARCHAR(50),
    salario DECIMAL(10, 2),
    fecha_ingreso DATE,
    activo BOOLEAN DEFAULT true
);

CREATE TABLE ventas (
    id SERIAL PRIMARY KEY,
    empleado_id INTEGER REFERENCES empleados(id),
    fecha_venta TIMESTAMP,
    producto VARCHAR(100),
    categoria VARCHAR(50),
    precio DECIMAL(10, 2),
    cantidad INTEGER,
    total DECIMAL(12, 2)
);

-- Ejercicio 1: Análisis Sin Índices
-- Insertar datos de empleados (1000 registros)
INSERT INTO empleados (nombre, email, departamento, salario, fecha_ingreso)
SELECT 
    'emple' || i || ' ' || 'apellido' || i,
    'emp' || i || '@empresa.com',
    CASE (i % 5)
        WHEN 0 THEN 'Ventas'
        WHEN 1 THEN 'Marketing'
        WHEN 2 THEN 'TI'
        WHEN 3 THEN 'RRHH'
        ELSE 'Finanzas'
    END,
    3000 + (RANDOM() * 5000)::INTEGER,
    '2020-01-01'::DATE + (RANDOM() * 1400)::INTEGER
FROM generate_series(1, 1000) AS i;

-- Insertar datos de ventas (100,000 registros)
INSERT INTO ventas (empleado_id, fecha_venta, producto, categoria, precio, cantidad, total)
SELECT 
    (SELECT id FROM empleados ORDER BY RANDOM() LIMIT 1),  -- Selecciona un ID existente aleatoriamente
    '2023-01-01'::TIMESTAMP + (RANDOM() * 365 || ' days')::INTERVAL,
    'Producto ' || i,
    CASE (i % 4)
        WHEN 0 THEN 'Electrónicos'
        WHEN 1 THEN 'Ropa'
        WHEN 2 THEN 'Hogar'
        ELSE 'Deportes'
    END,
    (RANDOM() * 1000 + 10)::DECIMAL(10, 2),
    (RANDOM() * 10)::INTEGER,
    0
FROM generate_series(1, 100000) AS i;

-- Actualizar el total en ventas
UPDATE ventas SET total = precio * cantidad;

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


SELECT COUNT(*) FROM empleados;
SELECT MAX(id) FROM empleados;
