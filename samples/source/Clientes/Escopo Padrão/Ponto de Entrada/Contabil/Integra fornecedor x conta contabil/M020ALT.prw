#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M020ALT   ºAutor  ³                    º Data ³  26/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada na alteração do fornecedor para compati-   º±±
±±º          ³bilizar a classe valor                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function M020ALT

Local aArea := GetArea()

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
Else
		RecLock("CT1",.F.)
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
	
RestArea(aArea)
DbSelectArea("SA2")
SA2->A2_CONTA :="2.1.1.01."+RIGHT(ALLTRIM(SA2->A2_COD),4)
RestArea(aArea)


Return()                  
