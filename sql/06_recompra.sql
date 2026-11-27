WITH pedidos_cliente AS (
    SELECT c.customer_unique_id,
           COUNT(DISTINCT o.order_id) AS num_pedidos
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp >= '2017-01-01'
      AND o.order_purchase_timestamp <  '2018-09-01'
    GROUP BY c.customer_unique_id
)
SELECT COUNT(*) AS clientes,
       SUM(CASE WHEN num_pedidos > 1 THEN 1 ELSE 0 END) AS clientes_recurrentes,
       ROUND(SUM(CASE WHEN num_pedidos > 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS tasa_recompra_pct
FROM pedidos_cliente;