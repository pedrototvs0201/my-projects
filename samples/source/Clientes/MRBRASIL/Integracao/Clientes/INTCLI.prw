#INCLUDE "TOTVS.CH"
#include 'RPTDEF.CH'
#include 'protheus.ch'
#INCLUDE "TBICONN.CH"

//|-----------------------------------------------------------------------------|
//| Programa  | intsa1      | Autor(s)| Denilson Almeida    | Data | 30/04/2020 |
//|-----------------------------------------------------------------------------|
//| Descrição | Geração de arquivo .csv com a lista dos funcionários com redução|
//|-----------------------------------------------------------------------------|
//|                             Últimas Alterações                              |
//|-----------------------------------------------------------------------------|
//| DATA       | ANALISTA          | DETALHAMENTO                               |
//|------------|-------------------|--------------------------------------------|
//|            |                   |                                            |
//|-----------------------------------------------------------------------------|


User Function INTCLI()

	Local cDirSrv as character
	Local aDirAux as array


	If Select("SX6") == 0
		PREPARE ENVIRONMENT EMPRESA '01' FILIAL '0101'
	Endif
	
	
	//Importação cadastro de cliente
	U_INTSA1()
	//Importação Cadastro de Produto
	U_INTSB1()
	//Importação Pedido de Venda
	U_INTSC5()

	//Importação Ordem de Produção
	U_INTSC2()

	RESET ENVIRONMENT

return
