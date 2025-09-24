#include "rwmake.ch"
#include "topconn.ch"


/*

	M020INC.prw - Cria a conta contábil do cliente no plano de contas

	Autor:  Pedro Eustaquio
	Data:   27/05/2025
	Versão: 1.0

	Descrição:
	Este ponto de entrada é responsável por criar a conta contábil do cliente no plano de contas,
	caso ela ainda não exista. Ele verifica se a conta já está presente e, se não estiver, cria uma nova
	entrada com os dados necessários.

	Observações:
	- Certifique-se de que as tabelas SA2 e CT1 estejam corretamente definidas.
*/

User Function M020INC

Local aArea := GetArea()
Local cQryFOR
Local cCGC

//Valida se é pessoa fisica (11 digitos no CGC), juridica (8 digitos no CGC) ou Outro finaliza ponto de entrada
DbSelectArea("SA2")
IF SA2->A2_TIPO='J'
cCGC := (LEFT(SA2->A2_CGC,8))
ELSEIF SA2->A2_TIPO='F'
cCGC := (LEFT(SA2->A2_CGC,11))
ELSE
	Return(.F.) 
	ENDIF 
// faz select no banco para verificar se existe fornecedor com o mesmo CGC

cQryFOR := " SELECT "
cQryFOR += " A2_COD, CASE A2_TIPO WHEN 'J' THEN SUBSTR(A2_CGC, 1, 8)  WHEN 'F' THEN SUBSTR(A2_CGC, 1, 11) END CNPJ, A2_CONTA  , "
cQryFOR += " (SELECT COUNT (A2_COD) FROM "+RetSQLName('SA2')+" S2 WHERE "
cQryFOR += " CASE S2.A2_TIPO WHEN 'J' THEN SUBSTR(S2.A2_CGC, 1, 8) 
cQryFOR += " WHEN 'F' THEN SUBSTR(S2.A2_CGC, 1, 11) END= "
cQryFOR += " CASE SA2.A2_TIPO WHEN 'J' THEN SUBSTR(SA2.A2_CGC, 1, 8) 
cQryFOR += " WHEN 'F' THEN SUBSTR(SA2.A2_CGC, 1, 11) END AND S2.D_E_L_E_T_=' ') CONTA "
cQryFOR += " FROM "
cQryFOR += " 	"+RetSQLName('SA2')+" SA2 " 
cQryFOR += " WHERE  CASE A2_TIPO WHEN 'J' THEN SUBSTR(SA2.A2_CGC, 1, 8) "
cQryFOR += " WHEN 'F' THEN SUBSTR(SA2.A2_CGC, 1, 11) END ='"+cCGC+"'"
cQryFOR += " 	AND D_E_L_E_T_ = ' ' ORDER BY A2_COD "
TCQuery cQryFOR New Alias "QRY_FOR"
// se tiver fornecedor traz a conta contabil e finaliza o ponto de entrada

IF QRY_FOR->CONTA != 1 
	
	SA2->A2_CONTA :=QRY_FOR->A2_CONTA
	RestArea(aArea)
	QRY_FOR->(DbCloseArea())
	Return(.F.)	

EndIf
//Cria plano de contas para o fornecedor
If INCLUI

	DbSelectArea("CT1")
	CT1->(DbSetOrder(1))

	If !(CT1->(DbSeek(xFilial("CT1")+"2.1.1.01."+RIGHT(ALLTRIM(SA2->A2_COD),4))))
		RecLock("CT1",.T.)
		CT1->CT1_FILIAL	:= xFilial("CT1")
		CT1->CT1_CONTA	:= "2.1.1.01."+RIGHT(ALLTRIM(SA2->A2_COD),4)
		CT1->CT1_CLASSE	:= "2"
		CT1->CT1_DESC01	:= SA2->A2_NOME
		CT1->CT1_CLASSE := "2"
		CT1->CT1_NORMAL	:= "2"
		CT1->CT1_CTASUP := "2.1.1.01"
		CT1->CT1_RES 	:= GETSXENUM("CT1","CT1_RES")                                                                                                                                      
		//CTD->CTD_NORMAL := "2"
		CT1->CT1_NATCTA := "02"
		CT1->CT1_NTSPED := "02"
		CT1->CT1_BLOQ   := "2"
		CT1->CT1_CVD02  := "1"
		CT1->CT1_CVD03  := "1"
		CT1->CT1_CVD04  := "1"
		CT1->CT1_CVD05  := "1"
   		CT1->CT1_CVC02  := "1"
   		CT1->CT1_CVC03  := "1"
   		CT1->CT1_CVC04  := "1"	
		CT1->CT1_ACITEM := "1"		
		CT1->CT1_ACCUST := "1"		
		CT1->CT1_ACCLVL := "1"	
		CT1->CT1_DTEXIS := CTOD("01/01/80")  
		CT1->CT1_AGLSLD := "2"
		CT1->CT1_CCOBRG := "2"
		CT1->CT1_ITOBRG := "2"
		CT1->CT1_CLOBRG := "2"
		CT1->CT1_LALHIR := "2"
		CT1->CT1_LALUR  := "0"
		CT1->CT1_ACATIV := "2"
		CT1->CT1_ATOBRG := "2"
		CT1->CT1_ACET05 := "2"
		CT1->CT1_05OBRG := "2"
		CT1->CT1_INTP   := "1"
		CT1->CT1_PVARC  := "1"
		
   		//CTD->CTD_YCGC   := SA1->A1_CGC    //- CASO O CLIENTE QUEIRA COLOCAR UM FILTRO NA CLASSE DE VALOR POR CNPJ
       	//CTD->CTD_YCLIFO := "C"            //- PARA TRATAR CONSULTA PADRÃO NO CT2 (CLASSE DÉBITO)		
		CT1->(MsUnLock())	   
	Else
		RecLock("CT1",.T.)
		CT1->CT1_FILIAL	:= xFilial("CT1")
		CT1->CT1_CONTA	:= "2.1.1.01."+RIGHT(ALLTRIM(SA2->A2_COD),4)
		CT1->CT1_CLASSE	:= "2"
		CT1->CT1_DESC01	:= SA2->A2_NOME
		CT1->CT1_CLASSE := "2"
		CT1->CT1_NORMAL	:= "2"
		CT1->CT1_CTASUP := "2.1.1.01"
		//CTD->CTD_NORMAL := "2"
		CT1->CT1_NATCTA := "02"
		CT1->CT1_NTSPED := "02"
		CT1->CT1_RES 	:= GETSXENUM("CT1","CT1_RES")  
		CT1->CT1_BLOQ   := "2"
		CT1->CT1_CVD02  := "1"
		CT1->CT1_CVD03  := "1"
		CT1->CT1_CVD04  := "1"
		CT1->CT1_CVD05  := "1"
   		CT1->CT1_CVC02  := "1"
   		CT1->CT1_CVC03  := "1"
   		CT1->CT1_CVC04  := "1"	
   		CT1->CT1_ACITEM := "1"		
		CT1->CT1_ACCUST := "1"		
		CT1->CT1_ACCLVL := "1"	
		CT1->CT1_DTEXIS := CTOD("01/01/80")  
		CT1->CT1_AGLSLD := "2"
		CT1->CT1_CCOBRG := "2"
		CT1->CT1_ITOBRG := "2"
		CT1->CT1_CLOBRG := "2"
		CT1->CT1_LALHIR := "2"
		CT1->CT1_LALUR  := "0"
		CT1->CT1_ACATIV := "2"
		CT1->CT1_ATOBRG := "2"
		CT1->CT1_ACET05 := "2"
		CT1->CT1_05OBRG := "2"
		CT1->CT1_INTP   := "1"
		CT1->CT1_PVARC  := "1"
		CT1->(MsUnLock())	
	EndIF
EndIf
RestArea(aArea)
DbSelectArea("SA2")
SA2->A2_CONTA :="2.1.1.01."+RIGHT(ALLTRIM(SA2->A2_COD),4)
RestArea(aArea)

QRY_FOR->(DbCloseArea())

Return(.T.)   
