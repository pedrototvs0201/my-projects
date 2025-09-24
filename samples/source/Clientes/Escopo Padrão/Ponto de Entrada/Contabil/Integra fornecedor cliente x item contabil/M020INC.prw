#include "rwmake.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M020INC   ºAutor  ³		             º Data ³  02/01/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada na inclusão do fornecedor para compati-    º±±
±±º          ³bilizar a Item Contábil                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function M020INC

Local aArea := GetArea()

If INCLUI
	DbSelectArea("CTD")
	CTD->(DbSetOrder(1))
	
	If !(CTD->(DbSeek(xFilial("CTD")+"F"+ALLTRIM(SA2->A2_COD)+ALLTRIM(SA2->A2_LOJA))))
		RecLock("CTD",.T.)
		CTD->CTD_FILIAL	:= xFilial("CTD")
		CTD->CTD_ITEM	:= "F"+ALLTRIM(SA2->A2_COD)+ALLTRIM(SA2->A2_LOJA)
		CTD->CTD_CLASSE	:= "2"
		CTD->CTD_DESC01	:= SA2->A2_NOME
		CTD->CTD_BLOQ	:= SA2->A2_MSBLQL
		//CTD->CTD_NORMAL := "1"
		CTD->CTD_DTEXIS := CTOD("01/01/80")
		CTD->CTD_ITLP := "2"+ALLTRIM(SA2->A2_COD)+ALLTRIM(SA2->A2_LOJA)
		//CTD->CTD_YCGC   := SA2->A2_CGC   // - CASO O CLIENTE QUEIRA COLOCAR UM FILTRO NA CLASSE DE VALOR POR CNPJ
		//CTD->CTD_YCLIFO := "F"           // - PARA TRATAR CONSULTA PADRÃO NO CT2 (CLASSE DÉBITO)
		CTD->(MsUnLock())
	Else
		RecLock("CTD",.F.)
		CTD->CTD_FILIAL	:= xFilial("CTD")
		CTD->CTD_ITEM	:= "F"+ALLTRIM(SA2->A2_COD)+ALLTRIM(SA2->A2_LOJA)
		CTD->CTD_CLASSE	:= "2"
		CTD->CTD_DESC01	:= SA2->A2_NOME
		CTD->CTD_BLOQ	:= SA2->A2_MSBLQL
		//CTD->CTD_NORMAL := "1"
		CTD->CTD_DTEXIS := CTOD("01/01/80")
		CTD->CTD_ITLP := "2"+ALLTRIM(SA2->A2_COD)+ALLTRIM(SA2->A2_LOJA)
		//CTD->CTD_YCGC   := SA2->A2_CGC   //- CASO O CLIENTE QUEIRA COLOCAR UM FILTRO NA CLASSE DE VALOR POR CNPJ
		//CTD->CTD_YCLIFO := "F"          //- PARA TRATAR CONSULTA PADRÃO NO CT2 (CLASSE DÉBITO)
		CTD->(MsUnLock())
	EndIF
EndIf
RestArea(aArea)

Return(.T.)   
