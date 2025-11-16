SELECT 
    dtRef,
    descLifeCycle,
    cluster,
    COUNT(*) as qtdeCliente
FROM life_cycle
WHERE descLifeCycle <> 'O5-ZUMBI'
GROUP BY dtRef, descLifeCycle, cluster
ORDER BY dtRef, descLifeCycle, cluster