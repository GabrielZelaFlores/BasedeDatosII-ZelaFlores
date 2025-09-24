--PARTE2

EXPLAIN ANALYZE
SELECT c.nombre, COUNT(p.pedido_id) as total_pedidos
FROM clientes c
LEFT JOIN pedidos p ON c.cliente_id = p.cliente_id
WHERE c.ciudad = 'Lima'
GROUP BY c.cliente_id, c.nombre
ORDER BY total_pedidos DESC;

--SIN EJECUTAR
EXPLAIN (FORMAT JSON)
SELECT c.nombre, COUNT(p.pedido_id) as total_pedidos
FROM clientes c
LEFT JOIN pedidos p ON c.cliente_id = p.cliente_id
WHERE c.ciudad 'Lima'
GROUP BY c.cliente_id, c.nombre
ORDER BY total_pedidos DESC;


--Parte 3
CREATE INDEX idx_clientes_ciudad ON clientes(ciudad);
CREATE INDEX idx_pedidos_fecha ON pedidos(fecha_pedido);
CREATE INDEX idx_pedidos_cliente_fecha ON pedidos(cliente_id, fecha_pedido);
-- Índice compuesto
CREATE INDEX idx_pedidos_cliente_fecha ON pedidos(cliente_id, fecha_pedido);

--Comparando rendimiento
EXPLAIN ANALYZE
SELECT c.nombre, COUNT(p.pedido_id) as total_pedidos
FROM clientes c
LEFT JOIN pedidos p ON c.cliente_id = p.cliente_id
WHERE c.ciudad = 'Lima'
GROUP BY c.cliente_id, c.nombre
ORDER BY total_pedidos DESC;

--Índices Parciales
CREATE INDEX idx_parcial_clientes_lima_activos ON clientes(cliente_id)
WHERE ciudad = 'Lima' AND activo = true;

EXPLAIN ANALYZE
SELECT c.nombre, c.email
FROM clientes c
WHERE c.ciudad = 'Lima' AND c.activo = true
AND c.fecha_registro > '2024-01-01';

--Algoritmos de Join
SET enable_hashjoin = off;
SET enable_mergejoin = off;
SET enable_nestloop = off;

EXPLAIN ANALYZE
SELECT c.nombre, p.total, pr.nombre_producto
FROM clientes c
JOIN pedidos p ON c.cliente_id = p.cliente_id
JOIN detalle_pedidos dp ON p.pedido_id = dp.pedido_id
JOIN productos pr ON dp.producto_id = pr.producto_id
WHERE c.ciudad = 'Lima'
AND p.fecha_pedido > '2025-01-01';

RESET ALL

