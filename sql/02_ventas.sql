-- Ventas mensuales (solo pedidos entregados)
SELECT strftime('%Y-%m', o.order_purchase_timestamp) AS mes,
       COUNT(DISTINCT o.order_id) AS pedidos,
       ROUND(SUM(oi.price), 2) AS ventas
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY mes
ORDER BY mes;