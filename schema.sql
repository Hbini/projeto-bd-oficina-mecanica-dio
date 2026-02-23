-- =====================================================
-- PROJETO LÓGICO DE BANCO DE DADOS - OFICINA MECÂNICA
-- Desafio DIO - Construa um Projeto Lógico de BD do Zero
-- Autor: Hbini
-- Data: 2026
-- =====================================================

-- Criar banco de dados
CREATE DATABASE IF NOT EXISTS OficinaMecanica;
USE OficinaMecanica;

-- =====================================================
-- TABELA: Cliente
-- Armazena informações dos clientes (PF e PJ)
-- =====================================================
CREATE TABLE Cliente (
    idCliente INT AUTO_INCREMENT PRIMARY KEY,
    nomeCliente VARCHAR(100) NOT NULL,
    tipoCliente ENUM('PF', 'PJ') NOT NULL,
    cpfCnpj VARCHAR(18) UNIQUE NOT NULL,
    telefone VARCHAR(20),
    email VARCHAR(100),
    endereco VARCHAR(200),
    cidade VARCHAR(50),
    estado CHAR(2),
    cep VARCHAR(10),
    dataCadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ativo BOOLEAN DEFAULT TRUE,
    INDEX idx_cpfCnpj (cpfCnpj),
    INDEX idx_nomeCliente (nomeCliente)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- TABELA: Veiculo
-- Armazena informações dos veículos dos clientes
-- =====================================================
CREATE TABLE Veiculo (
    idVeiculo INT AUTO_INCREMENT PRIMARY KEY,
    idCliente INT NOT NULL,
    placa VARCHAR(10) UNIQUE NOT NULL,
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    ano INT NOT NULL,
    cor VARCHAR(30),
    quilometragem INT,
    dataUltimaRevisao DATE,
    observacoes TEXT,
    FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente) ON DELETE RESTRICT,
    INDEX idx_placa (placa),
    INDEX idx_cliente (idCliente)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- TABELA: Mecanico
-- Armazena informações dos mecânicos da oficina
-- =====================================================
CREATE TABLE Mecanico (
    idMecanico INT AUTO_INCREMENT PRIMARY KEY,
    nomeMecanico VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    especialidade VARCHAR(50),
    telefone VARCHAR(20),
    email VARCHAR(100),
    salario DECIMAL(10,2),
    dataAdmissao DATE NOT NULL,
    ativo BOOLEAN DEFAULT TRUE,
    INDEX idx_especialidade (especialidade)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- TABELA: Servico
-- Catálogo de serviços oferecidos pela oficina
-- =====================================================
CREATE TABLE Servico (
    idServico INT AUTO_INCREMENT PRIMARY KEY,
    nomeServico VARCHAR(100) NOT NULL,
    descricao TEXT,
    precoBase DECIMAL(10,2) NOT NULL,
    tempoEstimado INT COMMENT 'Tempo em minutos',
    categoria ENUM('Manutenção Preventiva', 'Manutenção Corretiva', 'Elétrica', 'Mecânica', 'Funilaria', 'Pintura', 'Outros') DEFAULT 'Outros',
    ativo BOOLEAN DEFAULT TRUE,
    INDEX idx_categoria (categoria)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- TABELA: Fornecedor
-- Fornecedores de peças e materiais
-- =====================================================
CREATE TABLE Fornecedor (
    idFornecedor INT AUTO_INCREMENT PRIMARY KEY,
    nomeFornecedor VARCHAR(100) NOT NULL,
    cnpj VARCHAR(18) UNIQUE NOT NULL,
    telefone VARCHAR(20),
    email VARCHAR(100),
    endereco VARCHAR(200),
    cidade VARCHAR(50),
    estado CHAR(2),
    INDEX idx_nomeFornecedor (nomeFornecedor)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- TABELA: Peca
-- Catálogo de peças disponíveis
-- =====================================================
CREATE TABLE Peca (
    idPeca INT AUTO_INCREMENT PRIMARY KEY,
    nomePeca VARCHAR(100) NOT NULL,
    descricao TEXT,
    codigoFabricante VARCHAR(50),
    precoCusto DECIMAL(10,2) NOT NULL,
    precoVenda DECIMAL(10,2) NOT NULL,
    estoque INT DEFAULT 0,
    estoqueMinimo INT DEFAULT 5,
    idFornecedor INT,
    ativo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (idFornecedor) REFERENCES Fornecedor(idFornecedor) ON DELETE SET NULL,
    INDEX idx_nomePeca (nomePeca),
    INDEX idx_codigoFabricante (codigoFabricante)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- TABELA: OrdemServico
-- Ordens de serviço abertas para os veículos
-- =====================================================
CREATE TABLE OrdemServico (
    idOrdemServico INT AUTO_INCREMENT PRIMARY KEY,
    numeroOS VARCHAR(20) UNIQUE NOT NULL,
    idVeiculo INT NOT NULL,
    idMecanico INT,
    dataAbertura TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    dataPrevisao DATE,
    dataConclusao DATETIME,
    statusOS ENUM('Aberta', 'Em Andamento', 'Aguardando Peças', 'Concluída', 'Cancelada') DEFAULT 'Aberta',
    quilometragemEntrada INT,
    problemaRelatado TEXT,
    diagnostico TEXT,
    observacoes TEXT,
    valorTotal DECIMAL(10,2) DEFAULT 0.00,
    desconto DECIMAL(10,2) DEFAULT 0.00,
    valorFinal DECIMAL(10,2) DEFAULT 0.00,
    FOREIGN KEY (idVeiculo) REFERENCES Veiculo(idVeiculo) ON DELETE RESTRICT,
    FOREIGN KEY (idMecanico) REFERENCES Mecanico(idMecanico) ON DELETE SET NULL,
    INDEX idx_numeroOS (numeroOS),
    INDEX idx_statusOS (statusOS),
    INDEX idx_dataAbertura (dataAbertura)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- TABELA: OrdemServico_Servico
-- Relação N:M entre Ordem de Serviço e Serviços
-- =====================================================
CREATE TABLE OrdemServico_Servico (
    idOrdemServico INT NOT NULL,
    idServico INT NOT NULL,
    quantidade INT DEFAULT 1,
    precoUnitario DECIMAL(10,2) NOT NULL,
    desconto DECIMAL(10,2) DEFAULT 0.00,
    subtotal DECIMAL(10,2) GENERATED ALWAYS AS ((quantidade * precoUnitario) - desconto) STORED,
    observacoes TEXT,
    PRIMARY KEY (idOrdemServico, idServico),
    FOREIGN KEY (idOrdemServico) REFERENCES OrdemServico(idOrdemServico) ON DELETE CASCADE,
    FOREIGN KEY (idServico) REFERENCES Servico(idServico) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- TABELA: OrdemServico_Peca
-- Relação N:M entre Ordem de Serviço e Peças
-- =====================================================
CREATE TABLE OrdemServico_Peca (
    idOrdemServico INT NOT NULL,
    idPeca INT NOT NULL,
    quantidade INT NOT NULL,
    precoUnitario DECIMAL(10,2) NOT NULL,
    desconto DECIMAL(10,2) DEFAULT 0.00,
    subtotal DECIMAL(10,2) GENERATED ALWAYS AS ((quantidade * precoUnitario) - desconto) STORED,
    PRIMARY KEY (idOrdemServico, idPeca),
    FOREIGN KEY (idOrdemServico) REFERENCES OrdemServico(idOrdemServico) ON DELETE CASCADE,
    FOREIGN KEY (idPeca) REFERENCES Peca(idPeca) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- TABELA: Pagamento
-- Registra os pagamentos das ordens de serviço
-- =====================================================
CREATE TABLE Pagamento (
    idPagamento INT AUTO_INCREMENT PRIMARY KEY,
    idOrdemServico INT NOT NULL,
    dataPagamento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    formaPagamento ENUM('Dinheiro', 'Cartão Débito', 'Cartão Crédito', 'PIX', 'Transferência', 'Boleto') NOT NULL,
    valorPagamento DECIMAL(10,2) NOT NULL,
    parcelas INT DEFAULT 1,
    statusPagamento ENUM('Pendente', 'Confirmado', 'Cancelado') DEFAULT 'Pendente',
    observacoes TEXT,
    FOREIGN KEY (idOrdemServico) REFERENCES OrdemServico(idOrdemServico) ON DELETE RESTRICT,
    INDEX idx_statusPagamento (statusPagamento)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- TABELA: Avaliacao
-- Avaliações dos clientes sobre os serviços
-- =====================================================
CREATE TABLE Avaliacao (
    idAvaliacao INT AUTO_INCREMENT PRIMARY KEY,
    idOrdemServico INT NOT NULL,
    dataAvaliacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notaAtendimento INT CHECK (notaAtendimento BETWEEN 1 AND 5),
    notaQualidade INT CHECK (notaQualidade BETWEEN 1 AND 5),
    notaPrazo INT CHECK (notaPrazo BETWEEN 1 AND 5),
    comentario TEXT,
    FOREIGN KEY (idOrdemServico) REFERENCES OrdemServico(idOrdemServico) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- FIM DO SCHEMA
-- =====================================================
