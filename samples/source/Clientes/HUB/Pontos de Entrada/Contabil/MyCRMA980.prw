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
±±º          ³bpara compatiilizar a classe valor                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function CRMA980          

Local aArea := GetArea()

DbSelectArea("CTH")                                	
CTH->(DbSetOrder(1))
If INCLUI
	If !(CTH->(DbSeek(xFilial("CTH")+"C"+ALLTRIM(SA1->A1_COD))))	                     
		RecLock("CTH",.T.)
		CTH->CTH_FILIAL	:= xFilial("CTH")
		CTH->CTH_CLVL	:= "C"+ALLTRIM(SA1->A1_COD)
		CTH->CTH_CLASSE	:= "2"
		CTH->CTH_DESC01	:= SA1->A1_NOME
		CTH->CTH_BLOQ	:= SA1->A1_MSBLQL
		CTH->CTH_NORMAL := "2"
		CTH->CTH_DTEXIS := CTOD("01/01/80")
		CTH->CTH_CLVLLP := "C"+ALLTRIM(SA1->A1_COD)
   		//CTH->CTH_YCGC   := SA1->A1_CGC    //- CASO O CLIENTE QUEIRA COLOCAR UM FILTRO NA CLASSE DE VALOR POR CNPJ
       	//CTH->CTH_YCLIFO := "C"            //- PARA TRATAR CONSULTA PADRÃO NO CT2 (CLASSE DÉBITO)		
		CTH->(MsUnLock())	     
	Else
		RecLock("CTH",.F.)
		CTH->CTH_FILIAL	:= xFilial("CTH")
		CTH->CTH_CLVL	:= "C"+ALLTRIM(SA1->A1_COD)
		CTH->CTH_CLASSE	:= "2"
		CTH->CTH_DESC01	:= SA1->A1_NOME
		CTH->CTH_BLOQ	:= SA1->A1_MSBLQL
		CTH->CTH_NORMAL := "2"
		CTH->CTH_DTEXIS := CTOD("01/01/80")
		CTH->CTH_CLVLLP := "C"+ALLTRIM(SA1->A1_COD)
       	//CTH->CTH_YCGC   := SA1->A1_CGC  //- CASO O CLIENTE QUEIRA COLOCAR UM FILTRO NA CLASSE DE VALOR POR CNPJ
     	//CTH->CTH_YCLIFO := "C"          //- PARA TRATAR CONSULTA PADRÃO NO CT2 (CLASSE DÉBITO)	
		CTH->(MsUnLock())	     	
	EndIF
	elseif !INCLUI .And. !ALTERA // Exclusão de cliente
	
	If CTH->(DbSeek(xFilial("CTH")+"C"+ALLTRIM(SA1->A1_COD)))
	RecLock("CTH",.F.)
	CTH->(DbDelete())
	CTH->(MsUnLock())

EndIf
		
	
		elseif ALTERA
		If !(CTH->(DbSeek(xFilial("CTH")+"C"+ALLTRIM(SA1->A1_COD))))
	RecLock("CTH",.T.)
	CTH->CTH_FILIAL	:= xFilial("CTH")
	CTH->CTH_CLVL	:= "C"+ALLTRIM(SA1->A1_COD)
	CTH->CTH_CLASSE	:= "2"
	CTH->CTH_DESC01	:= SA1->A1_NOME
	CTH->CTH_BLOQ	:= SA1->A1_MSBLQL 
	CTH->CTH_NORMAL := "2"
	CTH->CTH_DTEXIS := CTOD("01/01/80")
	CTH->CTH_CLVLLP := "C"+ALLTRIM(SA1->A1_COD)
	//CTH->CTH_YCGC   := SA1->A1_CGC    //- CASO O CLIENTE QUEIRA COLOCAR UM FILTRO NA CLASSE DE VALOR POR CNPJ	
	//CTH->CTH_YCLIFO := "C"            //- PARA TRATAR CONSULTA PADRÃO NO CT2 (CLASSE DÉBITO)
	CTH->(MsUnLock())	     
Else
	RecLock("CTH",.F.)   
	CTH->CTH_FILIAL	:= xFilial("CTH")
	CTH->CTH_CLVL	:= "C"+ALLTRIM(SA1->A1_COD)
	CTH->CTH_CLASSE	:= "2"
	CTH->CTH_DESC01	:= SA1->A1_NOME
	CTH->CTH_BLOQ	:= SA1->A1_MSBLQL 
	CTH->CTH_NORMAL := "2"
	CTH->CTH_DTEXIS := CTOD("01/01/80")
	CTH->CTH_CLVLLP := "C"+ALLTRIM(SA1->A1_COD)
	//CTH->CTH_YCGC   := SA1->A1_CGC  //- CASO O CLIENTE QUEIRA COLOCAR UM FILTRO NA CLASSE DE VALOR POR CNPJ 
	//CTH->CTH_YCLIFO := "C"          //- PARA TRATAR CONSULTA PADRÃO NO CT2 (CLASSE DÉBITO)
	CTH->(MsUnLock())	
EndIF
	




	RestArea(aArea)

	Return(.T.)
EndIf


Return(.T.)	
