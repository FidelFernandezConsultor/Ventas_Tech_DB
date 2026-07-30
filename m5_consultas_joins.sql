/* ==========================================================
   M5 - CONSULTAS CON JOINS - RetailPro_DB
   AUTOR: Fidel Fernández - Data Analytics, Coderhouse
   ========================================================== */

-- ==========================================================
-- CONSULTA 1: VISTA BASE DEL PROYECTO (INNER JOIN)
-- Cruza ventas, clientes, productos, categorias y territorios
-- ==========================================================
SELECT
    v.fecha_venta,
    c.nombre AS cliente,
    c.segmento,
    t.region,
    p.nombre_producto AS producto,
    cat.categoria,
    v.cantidad,
    v.precio_unitario,
    v.total_venta,
    v.canal
FROM ventas v
INNER JOIN clientes c    ON v.id_cliente = c.id_cliente
INNER JOIN productos p   ON v.id_producto = p.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
INNER JOIN territorios t  ON c.id_territorio = t.id_territorio
ORDER BY v.fecha_venta;


-- ==========================================================
-- CONSULTA 2: CLIENTES SIN VENTAS (LEFT JOIN)
-- Clientes registrados que nunca compraron
-- ==========================================================
SELECT
    c.nombre AS cliente,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;

-- ==========================================================
-- CONSULTA 3: PRODUCTOS SIN VENTAS (LEFT JOIN)
-- Productos del catálogo que nunca se vendieron
-- ==========================================================
SELECT
    p.nombre_producto AS producto,
    cat.categoria,
    p.precio_lista
FROM productos p
LEFT JOIN ventas v ON p.id_producto = v.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
WHERE v.id_venta IS NULL;

-- ==========================================================
-- CONSULTA 4: CONSOLIDADO POR CANAL (UNION ALL)
-- Apila ventas Online y Presencial, luego totaliza por canal
-- ==========================================================
SELECT
    canal,
    COUNT(*) AS cantidad_ventas,
    SUM(total_venta) AS total_facturado
FROM (
    -- Parte 1: ventas del canal Online
    SELECT canal, total_venta
    FROM ventas
    WHERE canal = 'Online'

    UNION ALL

    -- Parte 2: ventas del canal Presencial
    SELECT canal, total_venta
    FROM ventas
    WHERE canal = 'Presencial'
) AS consolidado
GROUP BY canal;