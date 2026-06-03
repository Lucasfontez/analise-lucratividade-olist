/*
Agrupa a análise de atraso x satisfação por região do Brasil (JOIN na dimensão regioes).

- Motivo: resolver a amostra instável da análise por estado e limpar a visualização.

Resultado: Norte e Nordeste têm as piores notas (4,03 e 3,97) mesmo entregando
muito antes do prazo — sinal de que algo além da pontualidade afeta a satisfação.
*/

WITH Atraso_por_Regiao AS (
SELECT
	o.order_id AS id_pedido,
	rg.regiao AS regiao,
	r.review_score AS avaliacao_pedido,
	(o.order_delivered_customer_date::DATE -
    o.order_estimated_delivery_date::DATE) AS dias_atraso
FROM orders o
JOIN order_reviews r ON r.order_id = o.order_id
JOIN customers c ON c.customer_id = o.customer_id
JOIN regioes rg ON rg.uf = c.customer_state
WHERE
	o.order_status = 'delivered'
	AND o.order_delivered_customer_date IS NOT NULL
	AND o.order_estimated_delivery_date IS NOT NULL
)
SELECT
	regiao,
	COUNT(*) AS qtd_pedidos,
	ROUND(AVG(avaliacao_pedido), 2) AS nota_media,
	ROUND(AVG(dias_atraso), 1) AS atraso_medio_dias
FROM Atraso_por_Regiao
GROUP BY regiao
ORDER BY nota_media ASC;
