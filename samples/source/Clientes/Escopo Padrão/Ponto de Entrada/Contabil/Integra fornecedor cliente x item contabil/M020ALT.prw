#include "rwmake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M020ALT   �Autor  �                    � Data �  26/05/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada na altera��o do fornecedor para compati-   ���
���          �bilizar o Item Cont�bil                                     ���
�������������������������������������������������������������������������͹��
���Uso       �AP                                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function M020ALT

Local aArea := GetArea()

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
	//CTD->CTD_YCGC   := SA2->A2_CGC   //- CASO O CLIENTE QUEIRA COLOCAR UM FILTRO NA CLASSE DE VALOR POR CNPJ		
	//CTD->CTD_YCLIFO := "F"           //-      PARA TRATAR CONSULTA PADR�O NO CT2 (CLASSE D�BITO)
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
	//CTD->CTD_YCLIFO := "F"    	//- PARA TRATAR CONSULTA PADR�O NO CT2 (CLASSE D�BITO)		
	CTD->(MsUnLock())          	
EndIF
	
RestArea(aArea)

Return(.T.)                  
