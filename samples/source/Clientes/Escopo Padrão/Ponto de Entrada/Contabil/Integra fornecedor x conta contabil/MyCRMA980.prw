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

DbSelectArea("CT1")                                	
CT1->(DbSetOrder(1))
If INCLUI
	If !(CT1->(DbSeek(xFilial("CT1")+"1.1.2.01."+RIGHT(ALLTRIM(SA1->A1_COD),3))))	                     
		RecLock("CT1",.T.)
		CT1->CT1_FILIAL	:= xFilial("CT1")
		CT1->CT1_CONTA	:= "1.1.2.01."+RIGHT(ALLTRIM(SA1->A1_COD),3)
		//CTD->CTD_CLASSE	:= "2"
		CT1->CT1_DESC01	:= SA1->A1_NOME
		CT1->CT1_CLASSE := "2"
		CT1->CT1_NORMAL	:= "2"
		CT1->CT1_CTASUP := "1.1.2.01"
		//CTD->CTD_NORMAL := "2"
		CT1->CT1_NATCTA := "01"
		CT1->CT1_NTSPED := "01"
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

   		//CTD->CTD_YCGC   := SA1->A1_CGC    //- CASO O CLIENTE QUEIRA COLOCAR UM FILTRO NA CLASSE DE VALOR POR CNPJ
       	//CTD->CTD_YCLIFO := "C"            //- PARA TRATAR CONSULTA PADRÃO NO CT2 (CLASSE DÉBITO)		
		CT1->(MsUnLock())	     
	Else
		RecLock("CT1",.F.)
		CT1->CT1_FILIAL	:= xFilial("CT1")
		CT1->CT1_CONTA	:= "1.1.2.01."+RIGHT(ALLTRIM(SA1->A1_COD),3)
		//CTD->CTD_CLASSE	:= "2"
		CT1->CT1_DESC01	:= SA1->A1_NOME
		CT1->CT1_CLASSE := "2"
		CT1->CT1_NORMAL	:= "2"
		CT1->CT1_CTASUP := "1.1.2.01"
		//CTD->CTD_NORMAL := "2"
		CT1->CT1_NATCTA := "01"
		CT1->CT1_NTSPED := "01"
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
	EndIF
	elseif !INCLUI .And. !ALTERA // Exclusão de cliente
	
	If (CT1->(DbSeek(xFilial("CT1")+"1.1.2.01."+RIGHT(ALLTRIM(SA1->A1_COD),3))))
	RecLock("CT1",.F.)
	CT1->(DbDelete())
	CT1->(MsUnLock())

EndIf
		
	
		elseif ALTERA
			If !(CT1->(DbSeek(xFilial("CT1")+"1.1.2.01."+RIGHT(ALLTRIM(SA1->A1_COD),3))))	                     
		RecLock("CT1",.T.)
		CT1->CT1_FILIAL	:= xFilial("CT1")
		CT1->CT1_CONTA	:= "1.1.2.01."+RIGHT(ALLTRIM(SA1->A1_COD),3)
		//CTD->CTD_CLASSE	:= "2"
		CT1->CT1_DESC01	:= SA1->A1_NOME
		CT1->CT1_CLASSE := "2"
		CT1->CT1_NORMAL	:= "2"
		CT1->CT1_CTASUP := "1.1.2.01"
		//CTD->CTD_NORMAL := "2"
		CT1->CT1_NATCTA := "01"
		CT1->CT1_NTSPED := "01"
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
	RecLock("CT1",.F.)
		CT1->CT1_FILIAL	:= xFilial("CT1")
		CT1->CT1_CONTA	:= "1.1.2.01."+RIGHT(ALLTRIM(SA1->A1_COD),3)
		//CTD->CTD_CLASSE	:= "2"
		CT1->CT1_DESC01	:= SA1->A1_NOME
		CT1->CT1_CLASSE := "2"
		CT1->CT1_NORMAL	:= "2"
		CT1->CT1_CTASUP := "1.1.2.01"
		//CTD->CTD_NORMAL := "2"
		CT1->CT1_NATCTA := "01"
		CT1->CT1_NTSPED := "01"
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
EndIF
	




	RestArea(aArea)

	Return(.T.)
EndIf

DbSelectArea("SA1")
SA1->A1_CONTA :="1.1.2.01."+RIGHT(ALLTRIM(SA1->A1_COD),3)
RestArea(aArea)

Return(.T.)	
