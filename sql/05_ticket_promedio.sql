SELECT strftime('%Y-%m', o.order_purchase_timestamp) AS mes,
       COUNT(DISTINCT o.order_id) AS pedidos,
       ROUND(SUM(oi.price), 2) AS ventas,
       ROUND(SUM(oi.price) / COUNT(DISTINCT o.order_id), 2) AS ticket_promedio,
       ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT o.order_id), 2) AS items_por_pedido
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp >= '2017-01-01'
  AND o.order_purchase_timestamp <  '2018-09-01'
GROUP BY mes
ORDER BY mes;

-- Ticket promedio global del periodo analizado
SELECT ROUND(SUM(oi.price) / COUNT(DISTINCT o.order_id), 2) AS ticket_promedio_global,
       ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT o.order_id), 2) AS items_por_pedido_global
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp >= '2017-01-01'
  AND o.order_purchase_timestamp <  '2018-09-01';