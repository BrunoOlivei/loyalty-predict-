-- Rescência
-- Frequência
-- Valor

WITH tb_freq_valor AS (
  SELECT
    idCliente,
    COUNT(DISTINCT SUBSTR(dtCriacao, 0, 11)) AS qtdeFrequencia,
    SUM(CASE WHEN QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS qtdePontosPos
  FROM transacoes
  WHERE DtCriacao < '2025-09-01'
  AND DtCriacao >= DATE('2025-09-01', '-28 day')
  GROUP BY idCliente
  ORDER BY qtdeFrequencia DESC
), tb_cluster AS (
  SELECT 
    *,
    CASE
      WHEN qtdeFrequencia <= 10 AND qtdePontosPos > 1500 THEN '12-HYPERS'
      WHEN qtdeFrequencia > 10 AND qtdePontosPos >= 1500 THEN '22-EFICIENTES'
      WHEN qtdeFrequencia <= 10 AND qtdePontosPos >= 750 THEN '11-INDECISOS'
      WHEN qtdeFrequencia > 10 AND qtdePontosPos >= 750 THEN '21-ESFORCADO'
      WHEN qtdeFrequencia < 5 THEN '00-LURKERS'
      WHEN qtdeFrequencia <= 10 THEN '01-PREGUICOSOS'
      WHEN qtdeFrequencia > 10 THEN '20-POTENCIAL'
    END AS cluster
  FROM tb_freq_valor
)
SELECT *
FROM tb_cluster