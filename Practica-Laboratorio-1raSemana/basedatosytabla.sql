-- Zela Flores Gabriel Frank
-- Base de Datos II

-- EJERCICIO 1
-- PARTE A: CREAR BASE DE DATOS Y TABLA

CREATE DATABASE practica_almacenamiento;


-- 1.1 Crear la tabla "estudiantes"

CREATE TABLE estudiantes (
    id_estudiante INTEGER PRIMARY KEY,
    nombres VARCHAR(58) NOT NULL,
    apellidos VARCHAR(50) NOT NULL,
    carrera VARCHAR(38),
    semestre INTEGER,
    promedio DECIMAL(4,2)
);

-- 1.2 INSERTAR DATOS DE PRUEBA

INSERT INTO estudiantes VALUES
(1001, 'Ana', 'Garcia López', 'Ingenieria de Software', 6, 16.5),
(1815, 'Carlos', 'Mendoza Silva', 'Ingeniería de Software', 5, 15.8),
(1828, 'Maria', 'Torres Vega', 'Ingenieria de Sistemas', 7, 17.2),
(1035, 'José', 'Ramirez Cruz', 'Ingeniería de Software', 4, 14.9),
(1042, 'Lucía', 'Herrera Diaz', 'Ingeniería Industrial', 8, 18.1),
(1856, 'Diego', 'Castillo Ruiz', 'Ingeniería de Software', 6, 16.8),
(1063, 'Patricia', 'Morales Soto', 'Ingeniería de Sistemas', 3, 15.4),
(1977, 'Roberto', 'Jiménez Paz', 'Ingeniería de Software', 5, 17.8),
(1884, 'Carmen', 'Vargas Leon', 'Ingenieria Industrial', 7, 16.3),
(1098, 'Miguel', 'Santos Ríos', 'Ingeniería de Sistemas', 4, 15.1);


-- PARTE B: ESTRUCTURA HEAP (MONTÓN)

-- 1.3 CREAR TABLA HEAP (SIN ÍNDICES)

CREATE TABLE estudiantes_heap AS
SELECT * FROM estudiantes;

-- Verificar que NO tiene índices
SELECT * FROM pg_indexes WHERE tablename = 'estudiantes_heap';

-- 1.4 MEDIR RENDIMIENTO DE BÚSQUEDA SECUENCIAL

-- Paso 1: Activamos la medición de tiempo para ver cuánto tarda la consulta.
\timing on

-- Paso 2: Realizamos una búsqueda en la tabla heap.
SELECT * FROM estudiantes_heap WHERE id_estudiante = 1077;

-- Paso 3: Ver cuántos registros se examinaron.
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM estudiantes_heap WHERE id_estudiante = 1077;


-- PARTE C: ESTRUCTURA ORDENADA

-- 1.5 CREAR TABLA ORDENADA POR ID
CREATE TABLE estudiantes_ordenados AS
SELECT * FROM estudiantes ORDER BY id_estudiante;

-- Crear índice en el campo id_estudiante
CREATE INDEX idx_estudiantes_ordenados_id
ON estudiantes_ordenados (id_estudiante);

-- 1.6 COMPARAR RENDIMIENTO

-- BÚSQUEDA EXACTA
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM estudiantes_ordenados WHERE id_estudiante = 1077;

-- BÚSQUEDA POR RANGO
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM estudiantes_ordenados WHERE id_estudiante BETWEEN 1030 AND 1080;


