-- 1. Distribución de pedidos por estado
SELECT order_status, COUNT(*) AS total_pedidos
FROM orders
GROUP BY order_status
ORDER BY total_pedidos DESC;

-- 2. Rango de fechas del dataset
SELECT MIN(order_purchase_timestamp) AS primera_compra,
       MAX(order_purchase_timestamp) AS ultima_compra
FROM orders;

-- 3. Pedidos por mes (para detectar meses incompletos)
SELECT strftime('%Y-%m', order_purchase_timestamp) AS mes,
       COUNT(*) AS pedidos
FROM orders
GROUP BY mes
ORDER BY mes;

-- 4. Valores nulos en fechas clave
SELECT COUNT(*) AS total,
       SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END) AS sin_aprobacion,
       SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS sin_entrega
FROM orders;

-- 5. Clientes: identificador de pedido vs. cliente real
SELECT COUNT(DISTINCT customer_id) AS ids_de_cliente,
       COUNT(DISTINCT customer_unique_id) AS clientes_reales
FROM customers;

-- 6. Pedidos que no tienen productos asociados
SELECT o.order_status, COUNT(*) AS pedidos_sin_items
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL
GROUP BY o.order_status;