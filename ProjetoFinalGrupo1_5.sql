SELECT * FROM `t1engenhariadados.1_5_projeto_final.reclamacoes_unificadas` LIMIT 1000

--- Volume total de reclamações
SELECT
    COUNT(*) AS volume_total_reclamacoes
FROM
    projeto-final-1-5.reclamacoes.reclamacoes_unificada;

-- 1. Volume de reclamações por região e UF
SELECT 
  regiao,
  uf,
  COUNT(*) AS total_reclamacoes
FROM projeto-final-1-5.reclamacoes.reclamacoes_unificada
GROUP BY regiao, uf
ORDER BY total_reclamacoes DESC
LIMIT 10;

--- 2. Principais tipos de problema reportados
SELECT 
  descricao_problema,
  COUNT(*) AS total
FROM projeto-final-1-5.reclamacoes.reclamacoes_unificada
GROUP BY descricao_problema
ORDER BY total DESC
LIMIT 10;

--- 3. Assuntos mais recorrentes por faixa etária

SELECT 
  faixa_etaria_consumidor,
  descricao_assunto,
  COUNT(*) AS total
FROM projeto-final-1-5.reclamacoes.reclamacoes_unificada
GROUP BY 1, 2 

--- 4. Taxa de atendimento das empresas (resolvidas vs não resolvidas)

SELECT 
  atendida,
  COUNT(*) AS total,
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percentual 
FROM projeto-final-1-5.reclamacoes.reclamacoes_unificada
GROUP BY 
  atendida;

--- 5. Tempo médio de resposta das empresas (abertura → arquivamento)

SELECT 
  TRUNC(AVG(DATE_DIFF(DATE(data_arquivamento), DATE(data_abertura), DAY))) AS media_dias_resposta_truncada
FROM 
  projeto-final-1-5.reclamacoes.reclamacoes_unificada
WHERE 
  data_arquivamento IS NOT NULL AND data_abertura IS NOT NULL;

--- 5.1  Qual assunto (problema) está contribuindo mais para a média de 213 dias de resposta?

SELECT
    descricao_problema,
    TRUNC(AVG(DATE_DIFF(DATE(data_arquivamento), DATE(data_abertura), DAY))) AS media_dias_resposta
FROM`projeto-final-1-5.reclamacoes.reclamacoes_unificada`
WHERE data_arquivamento IS NOT NULL
    AND data_abertura IS NOT NULL
GROUP BY
    descricao_problema
ORDER BY
    media_dias_resposta DESC
LIMIT 10;

--- 5.2
-- Filtra apenas os problemas mais lentos (identificados na Análise 5.1 com médias acima de 400 dias).
-- Esta é uma aplicação da Estatística Bivariada para correlacionar problemas complexos (variável categórica)
-- com o Setor CNAE (variável categórica) e a Média de Dias de Resposta (variável numérica).

SELECT
    descricao_cnae_principal,
    descricao_problema,
    TRUNC(AVG(DATE_DIFF(DATE(data_arquivamento), DATE(data_abertura), DAY))) AS media_dias_resposta
FROM
    projeto-final-1-5.reclamacoes.reclamacoes_unificada
WHERE
    data_arquivamento IS NOT NULL
    AND data_abertura IS NOT NULL
    AND descricao_problema IN (
        'Produto não possui registro, registro falso, numero de protocolo',
        'Duvidas sobre informação nutricional (avaliação nutricional: quantidade calórica)',
        'Prazo de validade (falta, ilegível, etc.)',
        'Presença de aditivos, produtos químicos, tóxicos, radiação (bromato)',
        'Preço (abusivo, remarcado, falta, etc.)',
        'Irregularidade na rotulagem (falta de dados, dados ilegíveis, outros)',
        'Fila em Banco',
        'Cobrança de honorários advocaticios, despesa de cobrança',
        'Produto não atende a finalidade especifica (cartilagem de tubarão, dietas, etc.)'
    )
GROUP BY
    descricao_cnae_principal, descricao_problema
ORDER BY
    media_dias_resposta DESC
LIMIT 10;

---5.3 Análise de Proporção: Foco na Insatisfação de Alto Volume
SELECT
    descricao_problema,
    atendida,
    COUNT(*) AS total_reclamacoes,
    -- Estatística Descritiva: Proporção. Calcula o percentual de 'Atendida' ou 'Não Atendida' dentro de cada tipo de problema.
    ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY descricao_problema), 2) AS percentual_por_problema
FROM
    projeto-final-1-5.reclamacoes.reclamacoes_unificada
WHERE
    descricao_problema IN (
        'Cobrança indevida/abusiva', 
        'Produto com vício',
        'Garantia (Abrangência, cobertura, etc.)'
    )
GROUP BY
    descricao_problema,
    atendida
ORDER BY
    descricao_problema,
    atendida DESC;

--- 6. Ranking de empresas com mais reclamações

SELECT 
  nome_empresa_corrigido,
  COUNT(*) AS total_reclamacoes
FROM projeto-final-1-5.reclamacoes.reclamacoes_unificada
GROUP BY nome_empresa_corrigido
ORDER BY total_reclamacoes DESC
LIMIT 10;

-- 6.1. Análise Focada: Os Principais Problemas da Empresa Líder (OI)

SELECT
    descricao_problema,
    COUNT(*) AS total
FROM projeto-final-1-5.reclamacoes.reclamacoes_unificada
WHERE
    nome_empresa_corrigido = 'OI' 
GROUP BY
    descricao_problema
ORDER BY
    total DESC
LIMIT 5;

--- 7. Problemas mais frequentes por setor (CNAE)
SELECT
    descricao_cnae_principal,
    descricao_assunto,
    COUNT(*) AS total_reclamacoes
FROM projeto-final-1-5.reclamacoes.reclamacoes_unificada
WHERE descricao_cnae_principal IS NOT NULL
GROUP BY
    descricao_cnae_principal,
    descricao_assunto
ORDER BY
    descricao_cnae_principal,
    total_reclamacoes DESC;


--- 8.Distribuição das reclamações por gênero e faixa etária
SELECT
    faixa_etaria_consumidor,
    sexo_consumidor,
    COUNT(*) AS total_reclamacoes,
    ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percentual
FROM projeto-final-1-5.reclamacoes.reclamacoes_unificada
WHERE faixa_etaria_consumidor IS NOT NULL AND sexo_consumidor IS NOT NULL
GROUP BY
    faixa_etaria_consumidor,
    sexo_consumidor
ORDER BY
    faixa_etaria_consumidor,
    total_reclamacoes DESC;

-- 8.1 Estatística Bivariada: As Maiores Dores do Consumidor Mais Vocal  

SELECT
    descricao_problema,
    COUNT(*) AS total
FROM`projeto-final-1-5.reclamacoes.reclamacoes_unificada`
WHERE
    sexo_consumidor = 'Feminino' AND faixa_etaria_consumidor = 'entre 31 a 40 anos' 
GROUP BY
    descricao_problema
ORDER BY
    total DESC;

--- 9. Evolução temporal das reclamações (por ano calendário)
SELECT
    EXTRACT(YEAR FROM DATE(data_abertura)) AS ano_calendario,
    COUNT(*) AS total_reclamacoes
FROM projeto-final-1-5.reclamacoes.reclamacoes_unificada
WHERE data_abertura IS NOT NULL
GROUP BY
    ano_calendario
ORDER BY
    ano_calendario ASC;

