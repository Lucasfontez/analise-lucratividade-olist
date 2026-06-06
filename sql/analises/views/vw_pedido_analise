/*
vw_pedido_analise, fonte do Power BI (página 1: atraso × satisfação)

GRÃO: 1 linha por pedido.

Por que pedido, e não item? Porque tudo está aqui como: nota, atraso, tempo de
entrega, o que acaba sendo informação do PEDIDO. Cada pedido tem uma nota só (um review).
Se eu trouxesse no grão de item, um pedido com 3 itens repetiria a mesma
nota 3x e a média da nota sairia enviesada (pedido com mais itens
pesaria mais, sem nenhum motivo). Frete e preço, que vivem no item, ficam
de fora desta view de propósito, eles moram na vw_item_frete.

O QUE ESTA VIEW PROVA??(validado de forma independente no Excel):

A nota média por faixa de atraso -> No prazo 4,29...+7 dias 1,7
A queda contínua, é a tese principal do projeto: Pontualidade é piso!
não diferencial.
*/

CREATE OR REPLACE VIEW vw_pedido_analise AS
SELECT
    o.order_id,
    r.review_score                                          AS nota,
    (o.order_delivered_customer_date::date
       - o.order_purchase_timestamp::date)                  AS dias_entrega,
    (o.order_delivered_customer_date::date
       - o.order_estimated_delivery_date::date)             AS dias_atraso,
    CASE
        WHEN (o.order_delivered_customer_date::date - o.order_estimated_delivery_date::date) <= 0 THEN 'No prazo'
        WHEN (o.order_delivered_customer_date::date - o.order_estimated_delivery_date::date) <= 3 THEN '1–3 dias'
        WHEN (o.order_delivered_customer_date::date - o.order_estimated_delivery_date::date) <= 7 THEN '4–7 dias'
        ELSE                                                                                           '+7 dias'
    END                                                     AS faixa_atraso,
    c.customer_state                                        AS uf,
    reg.regiao                                              AS regiao
FROM orders o
LEFT JOIN order_reviews r ON r.order_id    = o.order_id
JOIN customers c          ON c.customer_id = o.customer_id
LEFT JOIN regioes reg     ON reg.uf        = c.customer_state
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date  IS NOT NULL
  AND o.order_estimated_delivery_date  IS NOT NULL;

SELECT * FROM vw_pedido_analise LIMIT 100;

/*
VALIDAÇÃO: tem que reproduzir o Excel (No prazo 4,29 -> +7 dias 1,7)
O COUNT(*) ainda mostra o tamanho de cada faixa: ~90 mil no prazo contra
~2,9 mil em atraso grave, o que torna a queda de quem atrasa mais marcante.
-----------------------------------------------------------------------------
SELECT
	faixa_atraso,
	ROUND(AVG(nota), 2) AS nota_media,
	COUNT(*) AS pedidos
FROM vw_pedido_analise
GROUP BY faixa_atraso
ORDER BY nota_media DESC;

OBSERVAÇÃO DE AVISO PRO POWER BI: faixa_atraso é texto, então o Power BI ordena em ordem
alfabética ("+7 dias" vem antes de "No prazo") e bagunça o eixo do gráfico.

Solução: criar uma coluna numérica de ordenação (1=No prazo, 2=1–3, 3=4–7,
4=+7) e aplicar "Sort by column" sobre a faixa.
*/
