/* ==========================================================
   M4 - CONSULTAS SQL DE NEGOCIO - Ventas_Tech_DB
   AUTOR: Fidel Fernández - Data Analytics, Coderhouse
   ========================================================== */

-- ==========================================================
-- CONSULTA 1: RESUMEN EJECUTIVO MENSUAL
-- Total facturado, cantidad de pedidos y ticket promedio por mes
-- ==========================================================
SELECT
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;

-- ==========================================================
-- CONSULTA 2: TOP 5 PRODUCTOS POR FACTURACIÓN
-- ==========================================================
SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;

-- ==========================================================
-- CONSULTA 3: CLIENTES RECURRENTES (más de un pedido)
-- ==========================================================
SELECT
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;

-- ==========================================================
-- CONSULTA 4: MESES POR ENCIMA / POR DEBAJO DEL PROMEDIO
-- ==========================================================
SELECT
    mes,
    total_mensual,
    CASE
        WHEN total_mensual > (SELECT AVG(total_mensual) FROM (
                SELECT MONTH(fecha_venta) AS mes,
                       SUM(cantidad * precio_unitario) AS total_mensual
                FROM ventas
                GROUP BY MONTH(fecha_venta)
             ) AS sub)
        THEN 'Por encima'
        ELSE 'Por debajo'
    END AS comparacion_promedio
FROM (
    SELECT MONTH(fecha_venta) AS mes,
           SUM(cantidad * precio_unitario) AS total_mensual
    FROM ventas
    GROUP BY MONTH(fecha_venta)
) AS totales
ORDER BY mes;

-- ==========================================================
-- HALLAZGOS DE NEGOCIO
-- ==========================================================
-- 1. El producto 1 (Laptop Pro 15) concentra el 56% de la facturación
--    total del período ($3.600 de $6.444), pese a venderse en pocas
--    unidades. Es el producto crítico del negocio: cualquier quiebre
--    de stock impacta de lleno en los ingresos.
--
-- 2. El 100% de los clientes registrados realizó más de una compra
--    (5 de 5 clientes con 2 pedidos cada uno). La base es enteramente
--    recurrente, lo que sugiere buena retención pero también una fuerte
--    dependencia de una cartera chica de clientes.
--
-- 3. El ticket promedio es de $644, pero está muy influido por la venta
--    de laptops. Los productos de bajo valor (mouse, teclado) se venden
--    en mayor volumen unitario pero aportan poco a la facturación:
--    hay una oportunidad de mejorar el ticket con venta cruzada.