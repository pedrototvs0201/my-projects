#include "rwmake.ch"
#include "topconn.ch
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A020EOK   �Autor  �                    � Data �  24/02/2017 ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada na altera��o do fornecedor para compati-   ���
���          �bilizar o Item Cont�bil                                     ���
�������������������������������������������������������������������������͹��
���Uso       �AP                                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function A020EOK()
Local aAreaSA2 := SA2->(GetArea())
Local aAreaCTD := CTD->(GetArea())
DbSelectArea("CTD")
CTD->(DbSetOrder(1))
If CTD->(DbSeek(xFilial("CTD")+"F"+ALLTRIM(SA2->A2_COD)+ALLTRIM(SA2->A2_LOJA)))
	RecLock("CTD",.F.)	
	CTD->(DbDelete())	
	CTD->(MsUnLock())	
EndIf
RestArea(aAreaSA2)
RestArea(aAreaCTD)
Return(.T.)
