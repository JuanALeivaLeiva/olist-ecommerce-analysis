WITH base AS (
    SELECT c.customer_unique_id,
           MAX(o.order_purchase_timestamp) AS ultima_compra,
           COUNT(DISTINCT o.order_id) AS frecuencia,
           SUM(oi.price) AS monetario
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp >= '2017-01-01'
      AND o.order_purchase_timestamp <  '2018-09-01'
    GROUP BY c.customer_unique_id
),
puntajes AS (
    SELECT customer_unique_id,
           CAST(julianday('2018-09-01') - julianday(ultima_compra) AS INTEGER) AS recencia_dias,
           frecuencia,
           monetario,
           NTILE(5) OVER (ORDER BY ultima_compra ASC) AS r_score,
           NTILE(5) OVER (ORDER BY monetario ASC) AS m_score
    FROM base
),
segmentos AS (
    SELECT customer_unique_id, recencia_dias, frecuencia, monetario,
           CASE
               WHEN r_score >= 4 AND m_score >= 4 THEN 'Campeones'
               WHEN frecuencia >= 2 THEN 'Recurrentes'
               WHEN m_score >= 4 THEN 'Alto valor, una compra'
               WHEN r_score >= 4 THEN 'Nuevos recientes'
               WHEN r_score <= 2 AND m_score <= 2 THEN 'Inactivos de bajo valor'
               ELSE 'Ocasionales'
           END AS segmento
    FROM puntajes
)
SELECT segmento,
       COUNT(*) AS clientes,
       ROUND(SUM(monetario), 2) AS ventas,
       ROUND(SUM(monetario) * 100.0 / SUM(SUM(monetario)) OVER (), 1) AS pct_ventas,
       ROUND(AVG(monetario), 2) AS gasto_promedio,
       ROUND(AVG(recencia_dias), 0) AS recencia_promedio_dias
FROM segmentos
GROUP BY segmento
ORDER BY ventas DESC;