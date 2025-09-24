#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÝÝÝÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝ»±±
±±ºPrograma  ³M461LSF2   ºAutor Pedro Eustáquioº       Data ³  01/08/25   º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºDesc.     ³Ponto de entrada para levar a marca do pedido para a NF -   º±±
±±º                                                                       º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºUso                                                                    º±±
±±ÈÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DescSC6()

Local aArea := GetArea()
DbSelectArea("SC6")
SC6->(DbSetOrder(1))



RecLock("SC6",.F.)
if  !empty(M->C6_XLOTCLI) .and. !empty(M->C6_PEDCLI)
                 
	
	M->C6_DESCRI := posicione('SB1',1,xFilial('SB1')+M->C6_PRODUTO,'B1_DESC')   +" \ LOTE: "+ALLTRIM(M->C6_XLOTCLI)+" \ OC: "+ALLTRIM(M->C6_PEDCLI)
	
elseif  !empty(M->C6_XLOTCLI) .and. empty(M->C6_PEDCLI)
                 
	M->C6_DESCRI := posicione('SB1',1,xFilial('SB1')+M->C6_PRODUTO,'B1_DESC') +" \ LOTE: "+ALLTRIM(M->C6_XLOTCLI)
	
elseif  empty(M->C6_XLOTCLI) .and. !empty(M->C6_PEDCLI)
                 
	
	M->C6_DESCRI := posicione('SB1',1,xFilial('SB1')+M->C6_PRODUTO,'B1_DESC') +" \ OC: "+ALLTRIM(M->C6_PEDCLI)


    elseif M->C6_DESCRI := posicione('SB1',1,xFilial('SB1')+M->C6_PRODUTO,'B1_DESC') 
    EndIF
	

	          

	

	SC6->(MsUnLock())  
RestArea(aArea)
Return(.T.)                  
         
