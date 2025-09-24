--Zela Flores Gabriel Frank
--Base de Dtos II
--PARTE 1
CREATE DATABASE laboratorio_optimizacion;

--Creando tabla clientes
CREATE TABLE clientes (
  cliente_id SERIAL PRIMARY KEY,
  nombre VARCHAR(100),
  email VARCHAR(100),
  ciudad VARCHAR(50),
  fecha_registro DATE,
  activo BOOLEAN DEFAULT TRUE
);

--Creando tabla productos
CREATE TABLE productos (
  producto_id SERIAL PRIMARY KEY,
  nombre_producto VARCHAR(100),
  categoria VARCHAR(50),
  precio DECIMAL(10,2),
  stock INTEGER
);

--Creando tabla pedidos
CREATE TABLE pedidos (
  pedido_id SERIAL PRIMARY KEY,
  cliente_id INTEGER REFERENCES clientes(cliente_id),
  fecha_pedido DATE,
  total DECIMAL(10,2),
  estado VARCHAR(20)
);

--Creando tabla detalle_pedidos
CREATE TABLE detalle_pedidos (
  detalle_id SERIAL PRIMARY KEY,
  pedido_id INTEGER REFERENCES pedidos(pedido_id),
  producto_id INTEGER REFERENCES productos(producto_id),
  cantidad INTEGER,
  precio_unitario DECIMAL(10,2)
);

--INSERTAMOS DATOS DE PRUEBA
--Clientes
INSERT INTO clientes (nombre, email, ciudad, fecha_registro, activo)
SELECT 
  'Cliente ' || generate_series,
  'cliente' || generate_series || '@email.com',
  CASE 
    WHEN generate_series % 5 = 0 THEN 'Lima'
    WHEN generate_series % 5 = 1 THEN 'Arequipa'
    WHEN generate_series % 5 = 2 THEN 'Trujillo'
    WHEN generate_series % 5 = 3 THEN 'Cusco'
    ELSE 'Piura'
  END,
  CURRENT_DATE - (generate_series % 365),
  generate_series % 10 != 0
FROM generate_series(1, 10000);

--Productos
INSERT INTO productos (nombre_producto, categoria, precio, stock)
SELECT 
  'Producto ' || generate_series,
  CASE 
    WHEN generate_series % 4 = 0 THEN 'Electrónicos'
    WHEN generate_series % 4 = 1 THEN 'Ropa'
    WHEN generate_series % 4 = 2 THEN 'Hogar'
    ELSE 'Deportes'
  END,
  (generate_series % 500) + 10.99,
  generate_series % 100 + 1
FROM generate_series(1, 1000);

--Pedidos
INSERT INTO pedidos (cliente_id, fecha_pedido, total, estado)
SELECT 
  (generate_series % 10000) + 1,
  CURRENT_DATE - (generate_series % 180),
  ((generate_series % 500) + 50) * 1.19,
  CASE 
    WHEN generate_series % 4 = 0 THEN 'Completado'
    WHEN generate_series % 4 = 1 THEN 'Pendiente'
    WHEN generate_series % 4 = 2 THEN 'Enviado'
    ELSE 'Cancelado'
  END
FROM generate_series(1, 50000);

--Detalle_pedidos
INSERT INTO detalle_pedidos (pedido_id, producto_id, cantidad, precio_unitario)
SELECT 
  (generate_series % 50000) + 1,
  (generate_series % 1000) + 1,
  (generate_series % 5) + 1,
  ((generate_series % 200) + 10) * 0.99
FROM generate_series(1, 150000);

