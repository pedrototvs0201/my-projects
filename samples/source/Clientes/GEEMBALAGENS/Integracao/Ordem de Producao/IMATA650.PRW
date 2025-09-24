#Include "Protheus.ch"
#include "rwmake.ch"
#include "TbiConn.ch"

//-------------------------------------------------------------------
//https://tdn.totvs.com.br/display/tec/ProtheusDOC
/*{Protheus.doc} IMATA650
description Ponto de Entrada para inclus�o da OP
@author  author
@since   07/01/2025
@version version
*/
//-------------------------------------------------------------------

User Function Imata650()
	Local aMATA650   := {} //-Array com os campos
	Local cErro as character
	Local lRet       := .t.
	Local dtIniP	 as date
	Local cOPP       as character

	dtIniP := DaySum(Date(), 2) //Data de Inicio da Produ��o
	//DbSelectArea("SC2")
	//DbSetOrder(1) //Ordenando por C2_NUM
	cOPP :=  NextNumero("SC2", 1, "C2_NUM", .T.)//GetSxeNum("SC2","C2_NUM")//Numero da Ordem de Producao
	
	DbSelectArea("SB1")
	DbsetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 3 - Inclusao ³
//³ 4 - Alteracao ³
//³ 5 - Exclusao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Local nOpc := 3
	Private lMsErroAuto := .F.

	cErro := ""
	//PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01"

	aMATA650 := { {'C2_NUM' ,cOPP ,NIL},;
		{'C2_ITEM'   ,"01"    ,NIL},;
		{'C2_SEQUEN' ,"001"   ,NIL},;
		{'C2_PRODUTO',alltrim(cProduto),NIL},;
		{'C2_LOCAL'  ,'01'    ,NIL},;
		{'C2_QUANT'  ,nQuant  ,NIL},;
		{'C2_DATPRI' ,dtIniP  ,NIL},;
		{'C2_DATPRF' ,DtEntr  ,NIL},;
		{'C2_PEDIDO' ,cPedido ,NIL},;
		{'C2_ITEMPV' ,cItPed  ,NIL},;
		{'C2_XNUMTRI',cOp     ,NIL},;
		{'AUTEXPLODE',"S"     ,NIL}}


	ConOut("Inicio : "+Time())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se alteracao ou exclusao, deve-se posicionar no registro ³
//³ da SC2 antes de executar a rotina automatica ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbSelectArea("SC2")
	DbSetOrder(13) //FILIAL + NUM + ITEM + SEQUEN + ITEMGRD
	If DbSeek(xFilial("SC2")+cOp+alltrim(cProduto),.T.)
		nOpc := 4
	else
		nOpc := 3
	EndIf

	msExecAuto({|x,Y| Mata650(x,Y)},aMata650,nOpc)
	If !lMsErroAuto
		aIns(aLinha,25,cOPP) //Adicionando o numero da OP no array aLinha1
		ConOut("Sucesso! ")
	Else
		cErro := "Erro na Inclus�o OP"//ConOut("Erro!")
		MostraErro()
		lRet := .f.
	EndIf

	ConOut("Fim : "+Time())

	//RESET ENVIRONMENT

Return(cErro)
