//Bibliotecas
#Include "Protheus.ch"
#Include "RWMake.ch"
#Include "TOPCONN.CH"
#Include "PRTOPDEF.CH"

User Function A010TOK()
	
	Local lRet 
	Local stop := .T.
	Local cQuery := ""
	Local cUpdateQuery :=""

	cQuery += "SELECT BM_XLOCPAD ARMAZEM FROM "+ RetSqlName("SBM")+" WHERE BM_GRUPO = '" + M->B1_GRUPO + "'"
	TcQuery cQuery NEW ALIAS "QRY"

	IF QRY->ARMAZEM == '0' .or. ALLTRIM(QRY->ARMAZEM)==''
		MsgBox(OemToAnsi("Armazem não cadastrado no Grupo!"), "Mensagem", "ALERT")
		QRY->(dbCloseArea())
		Return stop
		ENDIF


	IF M->B1_LOCPAD != QRY->ARMAZEM 

	 lRet:=MsgYesNo("O Armazem do grupo de produto "+ M->B1_GRUPO + " é diferente do Armazem informado.  Deseja alterar para o "+QRY->ARMAZEM+"?</b>","Alerta?!")


	if lRet == .T.
	M->B1_LOCPAD := QRY->ARMAZEM
		cUpdateQuery += "UPDATE "+ RetSqlName("SB1")+" SET B1_LOCPAD = '"+QRY->ARMAZEM+"' WHERE B1_COD = '"+ALLTRIM(M->B1_COD)+"'"
	
 TcSqlExec(cUpdateQuery)
		
MsgBox(OemToAnsi("Armazem alterado!"), "Mensagem", "ALERT")
elseif lRet==.F.
MsgBox(OemToAnsi("Armazém não alterado!"), "Mensagem", "ALERT")



		EndIf
endif

QRY->(dbCloseArea())
Return 
