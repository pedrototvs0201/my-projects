#include "rwmake.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M020INC   ºAutor  ³		             º Data ³  02/01/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada na inclusão do fornecedor para compati-    º±±
±±º          ³bilizar a classe valor                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function M020INC

Local aArea := GetArea()

If INCLUI
	DbSelectArea("CTH")
	CTH->(DbSetOrder(1))
	
	If !(CTH->(DbSeek(xFilial("CTH")+"F"+ALLTRIM(SA2->A2_COD))))
		RecLock("CTH",.T.)
		CTH->CTH_FILIAL	:= xFilial("CTH")
		CTH->CTH_CLVL	:= "F"+ALLTRIM(SA2->A2_COD)
		CTH->CTH_CLASSE	:= "2"
		CTH->CTH_DESC01	:= SA2->A2_NOME
		CTH->CTH_BLOQ	:= SA2->A2_MSBLQL
		CTH->CTH_NORMAL := "1"
		CTH->CTH_DTEXIS := CTOD("01/01/80")
		CTH->CTH_CLVLLP := "F"+ALLTRIM(SA2->A2_COD)
		//CTH->CTH_YCGC   := SA2->A2_CGC   // - CASO O CLIENTE QUEIRA COLOCAR UM FILTRO NA CLASSE DE VALOR POR CNPJ
		//CTH->CTH_YCLIFO := "F"           // - PARA TRATAR CONSULTA PADRÃO NO CT2 (CLASSE DÉBITO)
		CTH->(MsUnLock())
	Else
		RecLock("CTH",.F.)
		CTH->CTH_FILIAL	:= xFilial("CTH")
		CTH->CTH_CLVL	:= "F"+ALLTRIM(SA2->A2_COD)
		CTH->CTH_CLASSE	:= "2"
		CTH->CTH_DESC01	:= SA2->A2_NOME
		CTH->CTH_BLOQ	:= SA2->A2_MSBLQL
		CTH->CTH_NORMAL := "1"
		CTH->CTH_DTEXIS := CTOD("01/01/80")
		CTH->CTH_CLVLLP := "F"+ALLTRIM(SA2->A2_COD)
		//CTH->CTH_YCGC   := SA2->A2_CGC   //- CASO O CLIENTE QUEIRA COLOCAR UM FILTRO NA CLASSE DE VALOR POR CNPJ
		//CTH->CTH_YCLIFO := "F"          //- PARA TRATAR CONSULTA PADRÃO NO CT2 (CLASSE DÉBITO)
		CTH->(MsUnLock())
	EndIF
EndIf
RestArea(aArea)

Return(.T.)   
