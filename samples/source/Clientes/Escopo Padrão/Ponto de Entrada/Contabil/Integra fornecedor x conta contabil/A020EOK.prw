#include "rwmake.ch"
#include "topconn.ch
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A020EOK   ºAutor  ³                    º Data ³  24/02/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada na alteração do fornecedor para compati-   º±±
±±º          ³bilizar o Item Contábil                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function A020EOK()
Local aAreaSA2 := SA2->(GetArea())
Local aAreaCT1 := CT1->(GetArea())
Local cQryFOR
Local cCGC

//Valida se é pessoa fisica (11 digitos no CGC), juridica (8 digitos no CGC) ou Outro finaliza ponto de entrada
DbSelectArea("SA2")
IF SA2->A2_TIPO='J'
cCGC := (LEFT(SA2->A2_CGC,8))
ELSEIF SA2->A2_TIPO='F'
cCGC := (LEFT(SA2->A2_CGC,11))
ELSE
	Return(.T.)
	ENDIF 
// faz select no banco para verificar se existe fornecedor com o mesmo CGC

cQryFOR := " SELECT "
cQryFOR += " 	TOP(1) A2_COD, LEFT(A2_CGC,8) CNPJ, A2_CONTA , "
cQryFOR += " (SELECT COUNT (A2_COD) FROM "+RetSQLName('SA2')+" S2 WHERE "
cQryFOR += " CASE S2.A2_TIPO WHEN 'J' THEN LEFT(S2.A2_CGC,8) 
cQryFOR += " WHEN 'F' THEN LEFT(S2.A2_CGC,11) END= "
cQryFOR += " CASE SA2.A2_TIPO WHEN 'J' THEN LEFT(SA2.A2_CGC,8) 
cQryFOR += " WHEN 'F' THEN LEFT(SA2.A2_CGC,11) END AND S2.D_E_L_E_T_=' ') CONTA "
cQryFOR += " FROM "
cQryFOR += " 	"+RetSQLName('SA2')+" SA2 " 
cQryFOR += " WHERE  CASE A2_TIPO WHEN 'J' THEN LEFT(A2_CGC,8) "
cQryFOR += " WHEN 'F' THEN LEFT(A2_CGC,11) END ='"+cCGC+"'"
cQryFOR += " 	AND D_E_L_E_T_ = ' ' ORDER BY A2_COD "
TCQuery cQryFOR New Alias "QRY_FOR"
// se tiver fornecedor traz a conta contabil e finaliza o ponto de entrada
ALERT(QRY_FOR->CONTA)
IF QRY_FOR->CONTA != 1 
	QRY_FOR->(DbCloseArea())
	Return(.T.)	

EndIf


ALERT(QRY_FOR->CONTA)
DbSelectArea("CT1")
CT1->(DbSetOrder(1))
If CT1->(DbSeek(xFilial("CT1")+SA2->A2_CONTA))
	RecLock("CT1",.F.)	
	CT1->(DbDelete())	
	CT1->(MsUnLock())	
EndIf
RestArea(aAreaSA2)
RestArea(aAreaCT1)
Return(.T.)
