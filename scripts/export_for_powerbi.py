import sqlite3
from pathlib import Path
import pandas as pd

DB_PATH = Path("olist.db")
OUT_DIR = Path("dashboard/data")
OUT_DIR.mkdir(parents=True, exist_ok=True)

FILTRO = """
    o.order_status = 'delivered'
    AND o.order_purchase_timestamp >= '2017-01-01'
    AND o.order_purchase_timestamp <  '2018-09-01'
"""

QUERIES = {
    # Una fila por producto vendido
    "ventas": f"""
        SELECT oi.order_id,
               oi.order_item_id,
               DATE(o.order_purchase_timestamp) AS fecha_compra,
               c.customer_unique_id,
               c.customer_state AS estado_cliente,
               COALESCE(t.product_category_name_english,
                        p.product_category_name,
                        'sin_categoria') AS categoria,
               oi.price AS precio,
               oi.freight_value AS flete
        FROM orders o
        JOIN order_items oi ON o.order_id = oi.order_id
        JOIN customers c ON o.customer_id = c.customer_id
        LEFT JOIN products p ON oi.product_id = p.product_id
        LEFT JOIN product_category_name_translation t
               ON p.product_category_name = t.product_category_name
        WHERE {FILTRO}
    """,
    # Una fila por pedido, con datos de entrega y calificación
    "pedidos": f"""
        WITH resenas AS (
            SELECT order_id, AVG(review_score) AS puntaje
            FROM order_reviews
            GROUP BY order_id
        )
        SELECT o.order_id,
               DATE(o.order_purchase_timestamp) AS fecha_compra,
               c.customer_unique_id,
               ROUND(julianday(o.order_delivered_customer_date)
                     - julianday(o.order_purchase_timestamp), 1) AS dias_entrega,
               ROUND(julianday(o.order_delivered_customer_date)
                     - julianday(o.order_estimated_delivery_date), 1) AS dias_retraso,
               CASE
                   WHEN o.order_delivered_customer_date IS NULL
                       THEN 'Sin fecha de entrega'
                   WHEN julianday(o.order_delivered_customer_date)
                        - julianday(o.order_estimated_delivery_date) <= 0
                       THEN '1. A tiempo o antes'
                   WHEN julianday(o.order_delivered_customer_date)
                        - julianday(o.order_estimated_delivery_date) <= 7
                       THEN '2. Retraso de 1 a 7 días'
                   ELSE '3. Retraso de más de 7 días'
               END AS puntualidad,
               r.puntaje
        FROM orders o
        JOIN customers c ON o.customer_id = c.customer_id
        LEFT JOIN resenas r ON o.order_id = r.order_id
        WHERE {FILTRO}
    """,
    # Una fila por cliente real, con su segmento RFM
    "clientes": f"""
        WITH base AS (
            SELECT c.customer_unique_id,
                   MAX(o.order_purchase_timestamp) AS ultima_compra,
                   COUNT(DISTINCT o.order_id) AS frecuencia,
                   SUM(oi.price) AS monetario
            FROM orders o
            JOIN customers c ON o.customer_id = c.customer_id
            JOIN order_items oi ON o.order_id = oi.order_id
            WHERE {FILTRO}
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
        )
        SELECT customer_unique_id,
               recencia_dias,
               frecuencia,
               ROUND(monetario, 2) AS monetario,
               CASE
                   WHEN r_score >= 4 AND m_score >= 4 THEN 'Campeones'
                   WHEN frecuencia >= 2 THEN 'Recurrentes'
                   WHEN m_score >= 4 THEN 'Alto valor, una compra'
                   WHEN r_score >= 4 THEN 'Nuevos recientes'
                   WHEN r_score <= 2 AND m_score <= 2 THEN 'Inactivos de bajo valor'
                   ELSE 'Ocasionales'
               END AS segmento
        FROM puntajes
    """,
}


def main():
    conn = sqlite3.connect(DB_PATH)
    for nombre, query in QUERIES.items():
        df = pd.read_sql_query(query, conn)
        ruta = OUT_DIR / f"{nombre}.csv"
        df.to_csv(ruta, index=False, encoding="utf-8-sig")
        print(f"{nombre}: {len(df):,} filas -> {ruta}")
    conn.close()


if __name__ == "__main__":
    main()