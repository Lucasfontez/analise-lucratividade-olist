/*
Busquei medir o peso do frete por região, com valor médio absoluto e frete como % do preço
(média das proporções item a item, com NULLIF para evitar divisão por zero).

Objetivo: testar se as regiões mais lentas/insatisfeitas pagam frete mais caro.

Resultado: O padrão alinhado com tempo e satisfação. O Norte paga 49,7% do preço em
frete (vs. 20,7% no Sudeste), O que acaba sendo mais que o dobro! As regiões que mais esperam 
são as que mais pagam frete e as menos satisfeitas. Indício de problema estrutural de
distância (vendedores concentrados no Sudeste), não de atraso pontual.

Em resumo claro, a correlação forte e consistente entre tempo, frete e nota, onde
não se pode afirmar uma causa isolada do frete.
*/

WITH Frete_Regiao AS (
SELECT
	rg.regiao AS regiao,
	oi.price AS preco,
	oi.freight_value AS frete
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN customers c ON o.customer_id = c.customer_id
JOIN regioes rg ON rg.uf = c.customer_state
)
SELECT
	regiao,
	COUNT(*) AS qtd_itens,
	ROUND(AVG(frete), 2) AS frete_medio,
    ROUND(AVG(preco), 2) AS preco_medio,
    ROUND(AVG(frete / NULLIF(preco, 0)) * 100, 1) AS frete_pct_preco
FROM Frete_Regiao
GROUP BY regiao
ORDER BY frete_pct_preco DESC;
