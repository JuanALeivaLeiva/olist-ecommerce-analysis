WITH ventas_mensuales AS (
    SELECT strftime('%Y-%m', o.order_purchase_timestamp) AS mes,
           COUNT(DISTINCT o.order_id) AS pedidos,
           ROUND(SUM(oi.price), 2) AS ventas
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp >= '2017-01-01'
      AND o.order_purchase_timestamp <  '2018-09-01'
    GROUP BY mes
)
SELECT mes,
       pedidos,
       ventas,
       LAG(ventas) OVER (ORDER BY mes) AS ventas_mes_anterior,
       ROUND((ventas - LAG(ventas) OVER (ORDER BY mes)) * 100.0
             / LAG(ventas) OVER (ORDER BY mes), 1) AS variacion_pct
FROM ventas_mensuales
ORDER BY mes;