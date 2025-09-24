#include "rwmake.ch"
#include "topconn.ch"
// ANTES DE ATIVAR O PONTO DE ENTRADA ATIVAR O PARAMETRO MV_MVCSA1 =.T.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M030INC   �Autor  �                    � Data �  02/01/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada na inclus�o/altera��o/exclus�o do cliente  ���
���          �bpara compatiilizar a classe valor                          ���
�������������������������������������������������������������������������͹��
���Uso       �AP                                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
       	//CTH->CTH_YCLIFO := "C"            //- PARA TRATAR CONSULTA PADR�O NO CT2 (CLASSE D�BITO)		
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
     	//CTH->CTH_YCLIFO := "C"          //- PARA TRATAR CONSULTA PADR�O NO CT2 (CLASSE D�BITO)	
		CTH->(MsUnLock())	     	
	EndIF
	elseif !INCLUI .And. !ALTERA // Exclus�o de cliente
	
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
	//CTH->CTH_YCLIFO := "C"            //- PARA TRATAR CONSULTA PADR�O NO CT2 (CLASSE D�BITO)
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
	//CTH->CTH_YCLIFO := "C"          //- PARA TRATAR CONSULTA PADR�O NO CT2 (CLASSE D�BITO)
	CTH->(MsUnLock())	
EndIF
	




	RestArea(aArea)

	Return(.T.)
EndIf


Return(.T.)	
