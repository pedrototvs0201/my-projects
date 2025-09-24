#include "rwmake.ch"
#include "topconn.ch"
// ANTES DE ATIVAR O PONTO DE ENTRADA ATIVAR O PARAMETRO MV_MVCSA1 =.T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M030INC   ºAutor  ³                    º Data ³  02/01/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada na inclusão/alteração/exclusão do cliente  º±±
±±º          ³bpara compatiilizar O Item Contabil                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function CRMA980          

Local aArea := GetArea()

DbSelectArea("CTD")                                	
CTD->(DbSetOrder(1))
If INCLUI
	If !(CTD->(DbSeek(xFilial("CTD")+"C"+ALLTRIM(SA1->A1_COD)+ALLTRIM(SA1->A1_LOJA))))	                     
		RecLock("CTD",.T.)
		CTD->CTD_FILIAL	:= xFilial("CTD")
		CTD->CTD_ITEM	:= "C"+ALLTRIM(SA1->A1_COD)+ALLTRIM(SA1->A1_LOJA)
		//CTD->CTD_CLASSE	:= "2"
		CTD->CTD_DESC01	:= SA1->A1_NOME
		CTD->CTD_BLOQ	:= SA1->A1_MSBLQL
		//CTD->CTD_NORMAL := "2"
		CTD->CTD_DTEXIS := CTOD("01/01/80")
		CTD->CTD_ITLP := "1"+ALLTRIM(SA1->A1_COD)+ALLTRIM(SA1->A1_LOJA)
   		//CTD->CTD_YCGC   := SA1->A1_CGC    //- CASO O CLIENTE QUEIRA COLOCAR UM FILTRO NA CLASSE DE VALOR POR CNPJ
       	//CTD->CTD_YCLIFO := "C"            //- PARA TRATAR CONSULTA PADRÃO NO CT2 (CLASSE DÉBITO)		
		CTD->(MsUnLock())	     
	Else
		RecLock("CTD",.F.)
		CTD->CTD_FILIAL	:= xFilial("CTD")
		CTD->CTD_ITEM	:= "C"+ALLTRIM(SA1->A1_COD)+ALLTRIM(SA1->A1_LOJA)
		//CTD->CTD_CLASSE	:= "2"
		CTD->CTD_DESC01	:= SA1->A1_NOME
		CTD->CTD_BLOQ	:= SA1->A1_MSBLQL
		//CTD->CTD_NORMAL := "2"
		CTD->CTD_DTEXIS := CTOD("01/01/80")
		CTD->CTD_ITLP :="1"+ALLTRIM(SA1->A1_COD)+ALLTRIM(SA1->A1_LOJA) 
       	//CTD->CTD_YCGC   := SA1->A1_CGC  //- CASO O CLIENTE QUEIRA COLOCAR UM FILTRO NA CLASSE DE VALOR POR CNPJ
     	//CTD->CTD_YCLIFO := "C"          //- PARA TRATAR CONSULTA PADRÃO NO CT2 (CLASSE DÉBITO)	
		CTD->(MsUnLock())	     	
	EndIF
	elseif !INCLUI .And. !ALTERA // Exclusão de cliente
	
	If CTD->(DbSeek(xFilial("CTD")+"C"+ALLTRIM(SA1->A1_COD)+ALLTRIM(SA1->A1_LOJA)))
	RecLock("CTD",.F.)
	CTD->(DbDelete())
	CTD->(MsUnLock())

EndIf
		
	
		elseif ALTERA
		If !(CTD->(DbSeek(xFilial("CTD")+"C"+ALLTRIM(SA1->A1_COD)+ALLTRIM(SA1->A1_LOJA))))
	RecLock("CTD",.T.)
	CTD->CTD_FILIAL	:= xFilial("CTD")
	CTD->CTD_ITEM := "C"+ALLTRIM(SA1->A1_COD)+ALLTRIM(SA1->A1_LOJA)
	//CTD->CTD_CLASSE	:= "2"
	CTD->CTD_DESC01	:= SA1->A1_NOME
	//CTD->CTD_BLOQ	:= SA1->A1_MSBLQL 
	//CTD->CTD_NORMAL := "2"
	CTD->CTD_DTEXIS := CTOD("01/01/80")
	CTD->CTD_ITLP := "1"+ALLTRIM(SA1->A1_COD)+ALLTRIM(SA1->A1_LOJA)
	//CTD->CTD_YCGC   := SA1->A1_CGC    //- CASO O CLIENTE QUEIRA COLOCAR UM FILTRO NA CLASSE DE VALOR POR CNPJ	
	//CTD->CTD_YCLIFO := "C"            //- PARA TRATAR CONSULTA PADRÃO NO CT2 (CLASSE DÉBITO)
	CTD->(MsUnLock())	     
Else
	RecLock("CTD",.F.)   
	CTD->CTD_FILIAL	:= xFilial("CTD")
	CTD->CTD_ITEM	:= "C"+ALLTRIM(SA1->A1_COD)+ALLTRIM(SA1->A1_LOJA)
	//CTD->CTD_CLASSE	:= "2"
	CTD->CTD_DESC01	:= SA1->A1_NOME
	CTD->CTD_BLOQ	:= SA1->A1_MSBLQL 
	//CTD->CTD_NORMAL := "2"
	CTD->CTD_DTEXIS := CTOD("01/01/80")
	CTD->CTD_ITLP := "1"+ALLTRIM(SA1->A1_COD)+ALLTRIM(SA1->A1_LOJA)
	//CTD->CTD_YCGC   := SA1->A1_CGC  //- CASO O CLIENTE QUEIRA COLOCAR UM FILTRO NA CLASSE DE VALOR POR CNPJ 
	//CTD->CTD_YCLIFO := "C"          //- PARA TRATAR CONSULTA PADRÃO NO CT2 (CLASSE DÉBITO)
	CTD->(MsUnLock())	
EndIF
	




	RestArea(aArea)

	Return(.T.)
EndIf


Return(.T.)	
