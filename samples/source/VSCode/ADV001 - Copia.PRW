//Bibliotecas
#Include "Protheus.ch"
#Include "RWMake.ch"
#INCLUDE "TOPCONN.CH"

User Function A010TOK()
	
	Local lRet := .T.

	Local stop := .T.
	//Local cAlias := GetNextAlias()
	Local cQuery := ""

	cQuery += "SELECT BM_XLOCPAD ARMAZEM FROM SBM990 WHERE BM_GRUPO = '" + M->B1_GRUPO + "'"
	TcQuery cQuery NEW ALIAS "QRY"

	IF QRY->ARMAZEM == 0
		MsgBox(OemToAnsi("Armazem nÃ£o cadastrado no Grupo!"), "Mensagem", "ALERT")
		
		ENDIF
	IF M->B1_LOCPAD != QRY->ARMAZEM .and. QRY->ARMAZEM!=0

	lRet := MsgYesNo("O Armazem do grupo de produto :"+ M->B1_GRUPO + "é diferente do Armazem informado no cadastro"+M->B1_COD+", deseja alterar o produto?</b>","Alerta?!")


	if lRet == .T.


		M->B1_GRUPO := QRY->ARMAZEM
MsgBox(OemToAnsi("Armazem alterado!"), "Mensagem", "ALERT")
		EndIf

MsgBox(OemToAnsi("teste!"), "Mensagem", "ALERT")

Return 
