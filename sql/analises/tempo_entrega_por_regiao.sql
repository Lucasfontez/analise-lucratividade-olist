/*
Nessa consulta, busquei medir o tempo total de espera do cliente (da compra até a entrega) 
por região, cruzado com a nota média de avaliação.

Objetivo: testar se Norte/Nordeste têm notas baixas por lentidão absoluta, e não
por atraso, já que entregam antes do prazo prometido.

Resultado: confirma a relação. Quanto maior o tempo de espera, pior a nota — Norte
(22,5 dias / 4,03) e Nordeste (19,9 / 3,97) contra Sudeste (10,7 / 4,18). O prazo
prometido folgado mascarava a lentidão real, o que derruba a nota é o tempo absoluto.
*/

WITH Tempo_Entrega AS (
SELECT
	o.order_id AS id_pedido,
	rg.regiao AS regiao,
	r.review_score AS avaliacao_pedido,
	(o.order_delivered_customer_date::DATE -
    order_purchase_timestamp::DATE) AS dias_entrega
FROM orders o
JOIN order_reviews r ON r.order_id = o.order_id
JOIN customers c ON c.customer_id = o.customer_id
JOIN regioes rg ON rg.uf = c.customer_state
WHERE
	o.order_status = 'delivered' AND o.order_delivered_customer_date IS NOT NULL
	AND o.order_purchase_timestamp IS NOT NULL
)
SELECT
	regiao,
	COUNT(*) AS qtd_pedidos,
	ROUND(AVG(dias_entrega), 1) AS tempo_medio_dias,
	ROUND(AVG(avaliacao_pedido), 2) AS nota_media
FROM Tempo_Entrega
GROUP BY regiao
ORDER BY tempo_medio_dias DESC;
