WITH tb_daily AS (
  SELECT
    DISTINCT
    idCliente,
    SUBSTR(DtCriacao, 0, 11) AS dtDia
  FROM transacoes
  WHERE
    DtCriacao < '{date_analytical}'
), tb_idade AS (
  SELECT
    idCliente,
    CAST(MAX(JULIANDAY('{date_analytical}') - JULIANDAY(dtDia)) AS INT) AS qtDiasPrimTransacao,
    CAST(MIN(JULIANDAY('{date_analytical}') - JULIANDAY(dtDia)) AS INT) AS qtDiasUltTransacao
  FROM tb_daily
  GROUP BY 
    idCliente
), tb_rn AS (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY idCliente ORDER BY dtDia DESC) AS rnDia
  FROM tb_daily
), tb_penultima_ativacao AS (
  SELECT
    *,
    CAST(JULIANDAY('{date_analytical}') - JULIANDAY(dtDia) AS INT) AS qtDiasPenultimaTransacao
  FROM tb_rn
  WHERE rnDia = 2
), tb_life_cycle AS (
  SELECT
    t1.*,
    t2.qtDiasPenultimaTransacao,
    CASE
      WHEN t1.qtDiasPrimTransacao <= 7 THEN '01-CURIOSO'
      WHEN t1.qtDiasUltTransacao <= 7 AND t2.qtDiasPenultimaTransacao - t1.qtDiasUltTransacao <= 14 THEN '02-FIEL'
      WHEN t1.qtDiasUltTransacao BETWEEN 8 AND 14 THEN '03-TURISTA'
      WHEN t1.qtDiasUltTransacao BETWEEN 15 AND 28 THEN '04-DESENCANTADA'
      WHEN t1.qtDiasUltTransacao > 28 THEN '05-ZUMBI'
      WHEN t1.qtDiasUltTransacao <= 7 AND t2.qtDiasPenultimaTransacao - t1.qtDiasUltTransacao BETWEEN 15 AND 27 THEN '02-RECONQUISTADO'
      WHEN t1.qtDiasUltTransacao <= 7 AND t2.qtDiasPenultimaTransacao - t1.qtDiasUltTransacao > 28 THEN '02-REBORN'
    END AS descLifeCycle
  FROM tb_idade AS t1
  LEFT JOIN tb_penultima_ativacao AS t2
  USING(idCliente)
), tb_freq_valor AS (
  SELECT
    idCliente,
    COUNT(DISTINCT SUBSTR(dtCriacao, 0, 11)) AS qtdeFrequencia,
    SUM(CASE WHEN QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS qtdePontosPos
  FROM transacoes
  WHERE DtCriacao < '{date_analytical}'
  AND DtCriacao >= DATE('{date_analytical}', '-28 day')
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
SELECT 
  date('{date_analytical}', '-1 day') AS dtRef,
  t1.*,
  t2.qtdeFrequencia,
  t2.qtdePontosPos,
  t2.cluster
FROM tb_life_cycle AS t1
LEFT JOIN tb_cluster AS t2
USING(idCliente)