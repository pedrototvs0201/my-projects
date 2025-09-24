#INCLUDE "TOTVS.CH"
#include 'RPTDEF.CH'
#include 'protheus.ch'
#INCLUDE "TBICONN.CH"

//|-----------------------------------------------------------------------------|
//| Programa  | intsa1      | Autor(s)| Denilson Almeida    | Data | 30/04/2020 |
//|-----------------------------------------------------------------------------|
//| Descri��o | Gera��o de arquivo .csv com a lista dos funcion�rios com redu��o|
//|-----------------------------------------------------------------------------|
//|                             �ltimas Altera��es                              |
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
	
	
	//Importa��o cadastro de cliente
	U_INTSA1()
	//Importa��o Cadastro de Produto
	U_INTSB1()
	//Importa��o Pedido de Venda
	U_INTSC5()

	//Importa��o Ordem de Produ��o
	U_INTSC2()

	RESET ENVIRONMENT

return
