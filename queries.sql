-- =====================================================
-- QUERIES COMPLEXAS - OFICINA MECÂNICA
-- Desafio DIO - Construa um Projeto Lógico de BD do Zero
-- =====================================================

-- =====================================================
-- 1. RECUPERAÇÕES SIMPLES COM SELECT
-- =====================================================

-- Listar todos os clientes
SELECT * FROM Cliente;

-- Listar veículos com informações do cliente
SELECT v.placa, v.marca, v.modelo, v.ano, c.nomeCliente, c.telefone
FROM Veiculo v
INNER JOIN Cliente c ON v.idCliente = c.idCliente;

-- Listar todas as ordens de serviço
SELECT idOrdemServico, numeroOS, statusOS, dataPedido FROM OrdemServico;

-- =====================================================
-- 2. FILTROS COM WHERE
-- =====================================================

-- Ordens de serviço concluídas
SELECT numeroOS, statusOS, dataAbertura, dataConclusao, valorFinal
FROM OrdemServico
WHERE statusOS = 'Concluída';

-- Serviços de uma categoria específica
SELECT nomeServico, precoBase, categoria
FROM Servico
WHERE categoria = 'Manutenção Preventiva'
AND ativo = TRUE;

-- Peças com estoque baixo
SELECT nomePeca, estoque, estoqueMinimo
FROM Peca
WHERE estoque < estoqueMinimo;

-- Clientes do tipo PJ
SELECT nomeCliente, cpfCnpj, email, endereco
FROM Cliente
WHERE tipoCliente = 'PJ'
AND ativo = TRUE;

-- =====================================================
-- 3. EXPRESSÕES COM ATRIBUTOS DERIVADOS
-- =====================================================

-- Margem de lucro das peças
SELECT nomePeca, precoCusto, precoVenda,
       (precoVenda - precoCusto) AS lucroUnitario,
       ROUND((((precoVenda - precoCusto) / precoCusto) * 100), 2) AS percentualLucro
FROM Peca
WHERE ativo = TRUE;

-- Receita total e desconto das ordens de serviço
SELECT numeroOS, valorTotal, desconto,
       (valorTotal - desconto) AS valorLiquido,
       ROUND((desconto / valorTotal * 100), 2) AS percentualDesc
FROM OrdemServico
WHERE statusOS = 'Concluída';

-- =====================================================
-- 4. ORDENAÇÃO COM ORDER BY
-- =====================================================

-- Ordens de serviço mais recentes
SELECT numeroOS, dataAbertura, statusOS, valorFinal
FROM OrdemServico
ORDER BY dataAbertura DESC LIMIT 10;

-- Serviços ordenados por preço (maior para menor)
SELECT nomeServico, categoria, precoBase, tempoEstimado
FROM Servico
ORDER BY precoBase DESC;

-- Mecânicos ordenados por especialidade e nome
SELECT nomeMecanico, especialidade, salario, dataAdmissao
FROM Mecanico
WHERE ativo = TRUE
ORDER BY especialidade ASC, nomeMecanico ASC;

-- =====================================================
-- 5. FILTROS COM GROUP BY E HAVING
-- =====================================================

-- Total de ordens de serviço por status
SELECT statusOS, COUNT(*) AS totalOrdens, SUM(valorFinal) AS valorTotal
FROM OrdemServico
GROUP BY statusOS
ORDER BY totalOrdens DESC;

-- Mecânicos com mais de 5 ordens de serviço
SELECT m.nomeMecanico, m.especialidade, COUNT(o.idOrdemServico) AS totalOS
FROM Mecanico m
LEFT JOIN OrdemServico o ON m.idMecanico = o.idMecanico
GROUP BY m.idMecanico
HAVING COUNT(o.idOrdemServico) > 0
ORDER BY totalOS DESC;

-- Clientes com maior gasto em serviços
SELECT c.nomeCliente, COUNT(o.idOrdemServico) AS totalOrdens,
       SUM(o.valorFinal) AS totalGasto,
       ROUND(AVG(o.valorFinal), 2) AS mediaGasto
FROM Cliente c
LEFT JOIN Veiculo v ON c.idCliente = v.idCliente
LEFT JOIN OrdemServico o ON v.idVeiculo = o.idVeiculo
GROUP BY c.idCliente
HAVING COUNT(o.idOrdemServico) > 0
ORDER BY totalGasto DESC;

-- Serviços mais utilizados
SELECT s.nomeServico, s.categoria, COUNT(os.idServico) AS vezesUtilizado,
       SUM(os.precoUnitario * os.quantidade) AS receita
FROM Servico s
LEFT JOIN OrdemServico_Servico os ON s.idServico = os.idServico
GROUP BY s.idServico
HAVING COUNT(os.idServico) > 0
ORDER BY vezesUtilizado DESC;

-- =====================================================
-- 6. JUNÇÕES ENTRE TABELAS
-- =====================================================

-- Detalhes completos da ordem de serviço
SELECT o.numeroOS, o.statusOS, c.nomeCliente, v.placa, v.marca, v.modelo,
       m.nomeMecanico, m.especialidade, o.dataAbertura, o.valorFinal
FROM OrdemServico o
INNER JOIN Veiculo v ON o.idVeiculo = v.idVeiculo
INNER JOIN Cliente c ON v.idCliente = c.idCliente
LEFT JOIN Mecanico m ON o.idMecanico = m.idMecanico;

-- Serviços incluídos em cada ordem de serviço
SELECT o.numeroOS, s.nomeServico, s.categoria, os.quantidade, os.precoUnitario,
       os.subtotal, os.observacoes
FROM OrdemServico o
INNER JOIN OrdemServico_Servico os ON o.idOrdemServico = os.idOrdemServico
INNER JOIN Servico s ON os.idServico = s.idServico
ORDER BY o.numeroOS;

-- Peças utilizadas em cada ordem de serviço
SELECT o.numeroOS, p.nomePeca, op.quantidade, op.precoUnitario, op.subtotal,
       f.nomeFornecedor
FROM OrdemServico o
INNER JOIN OrdemServico_Peca op ON o.idOrdemServico = op.idOrdemServico
INNER JOIN Peca p ON op.idPeca = p.idPeca
LEFT JOIN Fornecedor f ON p.idFornecedor = f.idFornecedor
ORDER BY o.numeroOS;

-- Pagamentos realizados com detalhes
SELECT o.numeroOS, p.formaPagamento, p.valorPagamento, p.parcelas,
       p.statusPagamento, p.dataPagamento, c.nomeCliente
FROM Pagamento p
INNER JOIN OrdemServico o ON p.idOrdemServico = o.idOrdemServico
INNER JOIN Veiculo v ON o.idVeiculo = v.idVeiculo
INNER JOIN Cliente c ON v.idCliente = c.idCliente;

-- =====================================================
-- 7. QUERIES COMPLEXAS DE NEGÓCIO
-- =====================================================

-- Análise de receita por categoria de serviço
SELECT s.categoria, COUNT(DISTINCT os.idOrdemServico) AS totalOrdens,
       COUNT(os.idServico) AS totalServiços, SUM(os.quantidade) AS quantidadeTotal,
       SUM(os.subtotal) AS receitaTotal,
       ROUND(AVG(os.precoUnitario), 2) AS preçoMedio
FROM Servico s
LEFT JOIN OrdemServico_Servico os ON s.idServico = os.idServico
GROUP BY s.categoria
ORDER BY receitaTotal DESC;

-- Eficiência de mecânicos (tempo médio de conclusão)
SELECT m.nomeMecanico, m.especialidade, COUNT(o.idOrdemServico) AS totalOrdens,
       ROUND(SUM(s.tempoEstimado) / 60, 2) AS horasTrabalhadas,
       SUM(o.valorFinal) AS totalGerado,
       ROUND(SUM(o.valorFinal) / COUNT(o.idOrdemServico), 2) AS mediaValor
FROM Mecanico m
LEFT JOIN OrdemServico o ON m.idMecanico = o.idMecanico
LEFT JOIN OrdemServico_Servico os ON o.idOrdemServico = os.idOrdemServico
LEFT JOIN Servico s ON os.idServico = s.idServico
WHERE o.statusOS = 'Concluída'
GROUP BY m.idMecanico
ORDER BY totalGerado DESC;

-- Estoque e previsão de reposição
SELECT nomePeca, categoria, estoque, estoqueMinimo,
       CASE WHEN estoque <= estoqueMinimo THEN 'REPOSICAO URGENTE'
            WHEN estoque <= (estoqueMinimo * 1.5) THEN 'REPOSICAO PROXIMA'
            ELSE 'EM DIA'
       END AS statusEstoque,
       precoCusto, (estoqueMinimo - estoque) AS quantidadeRecomendada,
       ROUND((estoqueMinimo - estoque) * precoCusto, 2) AS investimentoRecomendado
FROM Peca
WHERE ativo = TRUE;

-- =====================================================
-- 8. QUERIES COM SUBQUERIES
-- =====================================================

-- Ordens de serviço acima da média de valor
SELECT numeroOS, valorFinal, dataConclusao
FROM OrdemServico
WHERE valorFinal > (SELECT AVG(valorFinal) FROM OrdemServico WHERE statusOS = 'Concluída')
AND statusOS = 'Concluída'
ORDER BY valorFinal DESC;

-- Mecânicos que nunca realizaram serviços
SELECT nomeMecanico, especialidade, dataAdmissao
FROM Mecanico
WHERE idMecanico NOT IN (SELECT DISTINCT idMecanico FROM OrdemServico WHERE idMecanico IS NOT NULL);

-- Clientes inativos ou sem ordens de serviço
SELECT nomeCliente, tipoCliente, email
FROM Cliente
WHERE idCliente NOT IN (SELECT DISTINCT c.idCliente FROM Cliente c
INNER JOIN Veiculo v ON c.idCliente = v.idCliente
INNER JOIN OrdemServico o ON v.idVeiculo = o.idVeiculo);

-- =====================================================
-- FIM DAS QUERIES
-- =====================================================
