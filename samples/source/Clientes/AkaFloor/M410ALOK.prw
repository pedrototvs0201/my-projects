#Include "PROTHEUS.CH"
 
User Function M410ALOK()
 
Local lRet      := .T.
Local cQuery    := ""
 
    If !Empty(SC5->C5_NOTA)
        If ALTERA   //Alteração
            MsgAlert("ALTERAÇÂO - Pedido já faturado.","ATENÇÃO")
        ElseIf !INCLUI .And. !ALTERA    //Exclusão
            MsgAlert("EXCLUSÃO - Pedido já faturado.","ATENÇÃO")
        ElseIf INCLUI .And. IsInCallStack("A410COPIA")  //Cópia
            MsgAlert("CÓPIA - Pedido já faturado.","ATENÇÃO")
        EndIf
       
    EndIf

    //Monta a consulta
    cQuery := " SELECT C6_OP, "+ CRLF
    cQuery += "(SELECT SUM(SC2.C2_QUJE) FROM " + RetSqlName('SC2') + " SC2  "+ CRLF
    cQuery += "WHERE SC6.C6_NUM=SC2.C2_NUM AND SC6.C6_FILIAL=SC2.C2_FILIAL) C2_QUJE "+ CRLF
    cQuery += "FROM " + RetSqlName('SC6') + " SC6" + CRLF
    cQuery += " WHERE  C6_NUM = '" + SC5->C5_NUM + "' AND C6_OP = '01' AND SC6.D_E_L_E_T_ = ''" + CRLF
    PLSQuery(cQuery, 'QRYDADTMP')

    //Enquanto houver registros, adiciona na temporária
    While !QRYDADTMP->(EoF())
        If !Empty(QRYDADTMP->C6_OP) .AND. (QRYDADTMP->C2_QUJE)=0
            If ALTERA   //Alteração
            MsgAlert("Alteração não permitida - Pedido possui Ordem de Produção: ","ATENÇÃO")
            ElseIf !INCLUI .And. !ALTERA    //Exclusão
            MsgAlert("Exclusão não permitida - Pedido possui Ordem de Produção:  ","ATENÇÃO")
            EndIf
            lRet := .F.
        EndIf   
  
        QRYDADTMP->(DbSkip())
    EndDo

    QRYDADTMP->(DbCloseArea())

Return lRet
