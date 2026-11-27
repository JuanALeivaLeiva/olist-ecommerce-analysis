-- 1. Pedidos entregados sin fecha de entrega (validación de calidad)
SELECT COUNT(*) AS delivered_sin_fecha
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NULL;

-- 2. Puntualidad de la entrega y calificación del cliente
WITH entregas AS (
    SELECT order_id,
           julianday(order_delivered_customer_date) - julianday(order_purchase_timestamp) AS dias_entrega,
           julianday(order_delivered_customer_date) - julianday(order_estimated_delivery_date) AS dias_retraso
    FROM orders
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
      AND order_purchase_timestamp >= '2017-01-01'
      AND order_purchase_timestamp <  '2018-09-01'
),
resenas AS (
    SELECT order_id, AVG(review_score) AS puntaje
    FROM order_reviews
    GROUP BY order_id
)
SELECT CASE
           WHEN e.dias_retraso <= 0 THEN '1. A tiempo o antes'
           WHEN e.dias_retraso <= 7 THEN '2. Retraso de 1 a 7 días'
           ELSE '3. Retraso de más de 7 días'
       END AS puntualidad,
       COUNT(*) AS pedidos,
       ROUND(AVG(e.dias_entrega), 1) AS dias_entrega_prom,
       ROUND(AVG(r.puntaje), 2) AS puntaje_prom
FROM entregas e
JOIN resenas r ON e.order_id = r.order_id
GROUP BY puntualidad
ORDER BY puntualidad;