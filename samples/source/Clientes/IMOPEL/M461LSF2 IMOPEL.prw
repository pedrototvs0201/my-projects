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

User Function MT410INC

Local aArea := GetArea()
DbSelectArea("SC6")
SC6->(DbSetOrder(1))



RecLock("SC6",.F.)
if  !empty(SC6->C6_XLOTCLI) .and. !empty(SC6->C6_PEDCLI)
                 
	
	SC6->C6_DESCRI := ALLTRIM(SC6->C6_DESCRI)+" \ LOTE: "+ALLTRIM(SC6->C6_XLOTCLI)+" \ OC: "+ALLTRIM(SC6->C6_PEDCLI)
	
elseif  !empty(SC6->C6_XLOTCLI) .and. empty(SC6->C6_PEDCLI)
                 
	SC6->C6_DESCRI := ALLTRIM(SC6->C6_DESCRI)+" \ LOTE: "+ALLTRIM(SC6->C6_XLOTCLI)
	
elseif  empty(SC6->C6_XLOTCLI) .and. !empty(SC6->C6_PEDCLI)
                 
	
	SC6->C6_DESCRI := ALLTRIM(SC6->C6_DESCRI)+" \ OC: "+ALLTRIM(SC6->C6_PEDCLI)


    elseif SC6->C6_DESCRI := ALLTRIM(SC6->C6_DESCRI)
    EndIF
	

	          

	

	SC6->(MsUnLock())  
RestArea(aArea)
Return(.T.)                  
         
