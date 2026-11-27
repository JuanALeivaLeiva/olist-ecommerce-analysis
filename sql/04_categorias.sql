SELECT COALESCE(t.product_category_name_english,
                p.product_category_name,
                'sin_categoria') AS categoria,
       COUNT(DISTINCT o.order_id) AS pedidos,
       COUNT(*) AS unidades,
       ROUND(SUM(oi.price), 2) AS ventas,
       ROUND(SUM(oi.price) * 100.0 / SUM(SUM(oi.price)) OVER (), 1) AS pct_ventas
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation t
       ON p.product_category_name = t.product_category_name
WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp >= '2017-01-01'
  AND o.order_purchase_timestamp <  '2018-09-01'
GROUP BY categoria
ORDER BY ventas DESC
LIMIT 15;