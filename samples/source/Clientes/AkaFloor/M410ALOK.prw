#Include "PROTHEUS.CH"
 
User Function M410ALOK()
 
Local lRet      := .T.
Local cQuery    := ""
 
    If !Empty(SC5->C5_NOTA)
        If ALTERA   //Altera��o
            MsgAlert("ALTERA��O - Pedido j� faturado.","ATEN��O")
        ElseIf !INCLUI .And. !ALTERA    //Exclus�o
            MsgAlert("EXCLUS�O - Pedido j� faturado.","ATEN��O")
        ElseIf INCLUI .And. IsInCallStack("A410COPIA")  //C�pia
            MsgAlert("C�PIA - Pedido j� faturado.","ATEN��O")
        EndIf
       
    EndIf

    //Monta a consulta
    cQuery := " SELECT C6_OP, "+ CRLF
    cQuery += "(SELECT SUM(SC2.C2_QUJE) FROM " + RetSqlName('SC2') + " SC2  "+ CRLF
    cQuery += "WHERE SC6.C6_NUM=SC2.C2_NUM AND SC6.C6_FILIAL=SC2.C2_FILIAL) C2_QUJE "+ CRLF
    cQuery += "FROM " + RetSqlName('SC6') + " SC6" + CRLF
    cQuery += " WHERE  C6_NUM = '" + SC5->C5_NUM + "' AND C6_OP = '01' AND SC6.D_E_L_E_T_ = ''" + CRLF
    PLSQuery(cQuery, 'QRYDADTMP')

    //Enquanto houver registros, adiciona na tempor�ria
    While !QRYDADTMP->(EoF())
        If !Empty(QRYDADTMP->C6_OP) .AND. (QRYDADTMP->C2_QUJE)=0
            If ALTERA   //Altera��o
            MsgAlert("Altera��o n�o permitida - Pedido possui Ordem de Produ��o: ","ATEN��O")
            ElseIf !INCLUI .And. !ALTERA    //Exclus�o
            MsgAlert("Exclus�o n�o permitida - Pedido possui Ordem de Produ��o:  ","ATEN��O")
            EndIf
            lRet := .F.
        EndIf   
  
        QRYDADTMP->(DbSkip())
    EndDo

    QRYDADTMP->(DbCloseArea())

Return lRet
