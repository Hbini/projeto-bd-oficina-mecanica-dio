# projeto-bd-oficina-mecanica-dio
Projeto Lógico de Banco de Dados para Oficina Mecânica - Desafio DIO. Inclui: Schema SQL completo com 10 tabelas, 30+ queries complexas, e documentação detalhada.

## 📋 Descrição

Este projeto implementa um **Banco de Dados Lógico** completo para uma **Oficina Mecânica**, desenvolvido como desafio da plataforma DIO (Digital Innovation One). O projeto demonstra competências essenciais em modelagem relacional, design de schema SQL e análise de dados com queries complexas.

### Objetivo
Criar uma solução de banco de dados robusta que gerencie todos os processos operacionais de uma oficina mecânica, incluindo clientes, veículos, mecânicos, serviços, peças e pagamentos.

---

## 🗂️ Estrutura do Projeto

### Arquivos Inclusos
- **schema.sql** - Script de criação completo do banco de dados com 10 tabelas principais
- **queries.sql** - Conjunto abrangente de 30+ queries complexas para análise de dados
- **README.md** - Documentação detalhada do projeto

---

## 📊 Diagrama Lógico

### Entidades Principais
1. **Cliente** - Informações dos clientes (Pessoa Física e Jurídica)
2. **Veículo** - Dados dos veículos dos clientes
3. **Mecanico** - Informações dos mecânicos da oficina
4. **OrdemServico** - Registro das ordens de serviço
5. **Servico** - Catálogo de serviços disponíveis
6. **Peca** - Estoque de peças
7. **Fornecedor** - Dados dos fornecedores de peças
8. **Pagamento** - Registros de pagamentos
9. **OrdemServico_Servico** - Relacionamento muitos-para-muitos (Ordem x Serviço)
10. **OrdemServico_Peca** - Relacionamento muitos-para-muitos (Ordem x Peça)

### Relacionamentos
- Um cliente pode ter múltiplos veículos (1:N)
- Um veículo pode ter múltiplas ordens de serviço (1:N)
- Uma ordem de serviço pode incluir múltiplos serviços (M:N)
- Uma ordem de serviço pode utilizar múltiplas peças (M:N)
- Um mecânico pode realizar múltiplas ordens de serviço (1:N)
- Um fornecedor pode fornecer múltiplas peças (1:N)

---

## 📋 Tabelas e Colunas

### Cliente
```sql
idCliente (PK)
nomeCliente (VARCHAR 100)
tipoCliente (ENUM: 'PF', 'PJ')
cpfCnpj (VARCHAR 18, UNIQUE)
email (VARCHAR 100)
telefone (VARCHAR 20)
endereco (VARCHAR 200)
ativo (BOOLEAN, DEFAULT TRUE)
dataCadastro (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP)
```

### Veículo
```sql
idVeiculo (PK)
idCliente (FK)
placa (VARCHAR 10, UNIQUE)
marca (VARCHAR 50)
modelo (VARCHAR 50)
ano (INT)
cor (VARCHAR 30)
quilometragem (INT)
observacoes (TEXT)
```

### Mecanico
```sql
idMecanico (PK)
nomeMecanico (VARCHAR 100)
especialidade (VARCHAR 100)
salario (DECIMAL 10,2)
dataAdmissao (DATE)
ativo (BOOLEAN, DEFAULT TRUE)
```

### OrdemServico
```sql
idOrdemServico (PK)
idVeiculo (FK)
idMecanico (FK, NULLABLE)
numeroOS (VARCHAR 20, UNIQUE)
statusOS (ENUM: 'Aberta', 'Em Progresso', 'Concluída', 'Cancelada')
dataAbertura (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP)
dataConclusao (DATETIME, NULLABLE)
valorTotal (DECIMAL 10,2)
desconto (DECIMAL 10,2, DEFAULT 0)
descricao (TEXT, NULLABLE)
observacoes (TEXT, NULLABLE)
```

### Servico
```sql
idServico (PK)
nomeServico (VARCHAR 100)
categoria (VARCHAR 50)
descricao (TEXT)
precoBase (DECIMAL 10,2)
tempoEstimado (INT - em minutos)
ativo (BOOLEAN, DEFAULT TRUE)
```

### Peca
```sql
idPeca (PK)
idFornecedor (FK, NULLABLE)
nomePeca (VARCHAR 100)
categoria (VARCHAR 50)
precoCusto (DECIMAL 10,2)
precoVenda (DECIMAL 10,2)
estoque (INT)
estoqueMinimo (INT)
observacoes (TEXT)
ativo (BOOLEAN, DEFAULT TRUE)
```

### Fornecedor
```sql
idFornecedor (PK)
nomeFornecedor (VARCHAR 100)
contato (VARCHAR 100)
email (VARCHAR 100)
telefone (VARCHAR 20)
endereco (VARCHAR 200)
```

### Pagamento
```sql
idPagamento (PK)
idOrdemServico (FK)
formaPagamento (ENUM: 'Dinheiro', 'Cartão Débito', 'Cartão Crédito', 'PIX', 'Transferência', 'Boleto')
valorPagamento (DECIMAL 10,2)
parcelas (INT, DEFAULT 1)
statuspagamento (ENUM: 'Pendente', 'Confirmado', 'Cancelado')
dataPagamento (DATE, NULLABLE)
observacoes (TEXT)
```

### OrdemServico_Servico (Tabela Associativa)
```sql
idOrdemServicoServico (PK)
idOrdemServico (FK)
idServico (FK)
quantidade (INT, DEFAULT 1)
precoUnitario (DECIMAL 10,2)
subtotal (DECIMAL 10,2)
observacoes (TEXT)
```

### OrdemServico_Peca (Tabela Associativa)
```sql
idOrdemServicoPeca (PK)
idOrdemServico (FK)
idPeca (FK)
quantidade (INT)
precoUnitario (DECIMAL 10,2)
subtotal (DECIMAL 10,2)
data_uso (DATETIME, NULLABLE)
```

---

## 🔍 Queries Disponíveis

O arquivo `queries.sql` contém 30+ queries organizadas em 8 categorias:

### 1. Recuperações Simples (SELECT)
- Listar todos os clientes
- Listar veículos com informações do cliente
- Listar todas as ordens de serviço

### 2. Filtros (WHERE)
- Ordens de serviço concluídas
- Serviços de uma categoria específica
- Peças com estoque baixo
- Clientes do tipo PJ

### 3. Expressões com Atributos Derivados
- Margem de lucro das peças
- Receita total e desconto das ordens

### 4. Ordenação (ORDER BY)
- Ordens mais recentes
- Serviços ordenados por preço
- Mecânicos ordenados por especialidade

### 5. Agregações (GROUP BY, HAVING)
- Total de ordens por status
- Mecânicos com mais ordens
- Clientes com maior gasto
- Serviços mais utilizados

### 6. Junções Entre Tabelas
- Detalhes completos da ordem
- Serviços incluídos em cada ordem
- Peças utilizadas em cada ordem
- Pagamentos realizados

### 7. Queries Complexas de Negócio
- Análise de receita por categoria
- Eficiência de mecânicos
- Previsão de reposição de estoque

### 8. Subqueries
- Ordens acima da média
- Mecânicos sem ordens
- Clientes inativos

---

## 🚀 Como Usar

### 1. Criar o Banco de Dados
```bash
mysql -u seu_usuario -p < schema.sql
```

### 2. Executar as Queries
```bash
mysql -u seu_usuario -p nome_banco < queries.sql
```

### 3. Verificar a Estrutura
```sql
USE OficinaMecanica;
DESCRIBE Cliente;
SHOW TABLES;
```

---

## 🎓 Conceitos Demonstrados

✅ Modelagem Relacional  
✅ Normalização de Dados (até 3ª Forma Normal)  
✅ Chaves Primárias e Estrangeiras  
✅ Índices (INDEX)  
✅ Restrições de Integridade (UNIQUE, NOT NULL, CHECK)  
✅ Relacionamentos 1:1, 1:N e M:N  
✅ SELECT com múltiplas cláusulas  
✅ INNER JOIN e LEFT JOIN  
✅ GROUP BY e HAVING  
✅ Agregações (COUNT, SUM, AVG, ROUND)  
✅ Subqueries (IN, NOT IN)  
✅ CASE WHEN (Expressões Condicionais)  
✅ ORDER BY DESC/ASC  
✅ LIMIT  
✅ Alias de Tabelas e Colunas  

---

## 👨‍💼 Autor
**Hbini** - Desafio DIO (Digital Innovation One)  
Data: 2026

---

## 📄 Licença
Projeto de código aberto para fins educacionais.
