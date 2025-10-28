
CREATE DATABASE IF NOT EXISTS erp_rest;
USE erp_rest;

-- Tabela 1: guestChecks (Pedidos/Contas)
-- Armazena os dados de cabeçalho (agregação) do pedido.

CREATE TABLE guestChecks (
    guestCheckId BIGINT PRIMARY KEY,  -- ID Único do Pedido

    -- Metadados de Ambiente e Consulta
    locRef VARCHAR(50) NOT NULL,       -- Referência da Loja
    curUTC TIMESTAMP NOT NULL,        -- Data/hora UTC da consulta 

    -- Identificação do Pedido
    chkNum INTEGER NOT NULL,          -- Número da conta 
    rvcNum INTEGER,                   -- Número do Recibo 
    otNum INTEGER,                    -- Número da Ordem 
    tblNum INTEGER,                   -- Número da Mesa 
    tblName VARCHAR(50),              -- Nome da Mesa 
    empNum INTEGER,                   -- Número do Atendente 
    gstCnt INTEGER,                   -- Contagem de Convidados 

    -- Datas e Horários
    opnBusDt DATE NOT NULL,           -- Data de operação
    opnUTC TIMESTAMP,                 -- Data/hora UTC de abertura 
    clsdBusDt DATE,                   -- Data de operação
    clsdUTC TIMESTAMP,                -- Data/hora UTC de fechamento 
    clsdFlag BOOLEAN,                 -- Flag de Fechado 

    -- Totais Monetários
    subTtl DECIMAL(10, 2),            -- Subtotal
    chkTtl DECIMAL(10, 2) NOT NULL,   -- Total final da conta 
    dscTtl DECIMAL(10, 2),            -- Total de descontos 
    payTtl DECIMAL(10, 2),            -- Total pago 
    balDueTtl DECIMAL(10, 2),         -- Saldo devedor 
    nonTxblSlsTtl DECIMAL(10, 2)      -- Total de Vendas não tributávei
);

-- Tabela 2: taxes (Impostos do Pedido)
-- Armazena os detalhes dos impostos aplicados a um pedido específico.

CREATE TABLE taxes (
    guestCheckId BIGINT NOT NULL,     

    taxNum INTEGER NOT NULL,          -- ID do imposto

    -- Detalhes Monetários e Taxas
    txblSlsTtl DECIMAL(10, 2),        -- Total de vendas sujeitas a imposto
    taxCollTtl DECIMAL(10, 2) NOT NULL,-- Total de imposto coletado
    taxRate DECIMAL(5, 2) NOT NULL,   -- Taxa de imposto
    type INTEGER,                     -- Tipo de imposto

    PRIMARY KEY (guestCheckId, taxNum),
    FOREIGN KEY (guestCheckId)
        REFERENCES guestChecks(guestCheckId)
);

-- Tabela 3: detailLines 
-- Armazena todos os itens do pedido (menu, desconto, taxas, etc.).

CREATE TABLE detailLines (
    guestCheckLineItemId BIGINT PRIMARY KEY,

    guestCheckId BIGINT NOT NULL,         

    -- Classificação e Identificação da Linha
    lineNum INTEGER NOT NULL,               -- Número da Linha no pedido
    dtlId INTEGER,                          -- ID de detalhe
    
    -- Serve para diferenciar menuItem, discount, serviceCharge, etc. 
    detailType VARCHAR(20) NOT NULL,        -- Tipo de linha: menuItem, discount, serviceCharge, tenderMedia, errorCode.

    -- Metadados de Tempo
    busDt DATE NOT NULL,                    -- Data de operação da linha
    detailUTC TIMESTAMP,                    -- Data/hora UTC de inclusão da linha
    lastUpdateUTC TIMESTAMP,                -- Última atualização UTC

    -- Totais e Quantidades
    dspQty INTEGER NOT NULL,                -- Quantidade de exibição
    dspTtl DECIMAL(10, 2) NOT NULL,         -- Total de exibição
    aggQty INTEGER,                         -- Quantidade agregada
    aggTtl DECIMAL(10, 2),                  -- Total agregado

    -- Informações do Serviço
    wsNum INTEGER,                          -- Número da Estação de Trabalho
    svcRndNum INTEGER,                      -- Número da Rodada de Serviço 
    seatNum INTEGER,                        -- Número do Assento
    chkEmpNum INTEGER,                      -- Número do Atendente que adicionou o item 

    FOREIGN KEY (guestCheckId)
        REFERENCES guestChecks(guestCheckId)
);

-- Tabela 4: menuItem (Detalhes do Item de Menu)
-- Armazena atributos específicos do item de menu associado a uma linha de detalhe.

CREATE TABLE menuItem (
    guestCheckLineItemId BIGINT PRIMARY KEY,

    -- Atributos do Item de Menu
    miNum INTEGER NOT NULL,                 -- Número/ID do Item de Menu
    prcLvl INTEGER,                         -- Nível de preço aplicado 
    modFlag BOOLEAN,                        -- Flag de Modificação 
    inclTax DECIMAL(10, 4),                 -- Valor do imposto incluído 
    activeTaxes VARCHAR(50),                -- Lista de impostos ativos

    FOREIGN KEY (guestCheckLineItemId)
        REFERENCES detailLines(guestCheckLineItemId)
);