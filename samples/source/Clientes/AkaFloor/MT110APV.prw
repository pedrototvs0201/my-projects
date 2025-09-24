#Include "TopConn.ch"

User Function MT110APV()
    Local nRecno := ParamIxb[2]
    Local lRet1   := .F.
    Local lRet2   := .F.
    Local dBase  := Date() // Data atual
    Local cQRYusr 


    cQRYusr := " SELECT USR_ID,"
    cQRYusr += " 	(SELECT COUNT(USR_ID) CONTA FROM SYS_USR_GROUPS G WHERE USR_GRUPO in('000000') AND G.USR_ID=SY.USR_ID AND G.D_E_L_E_T_<>'*') CONTA1 , "
    cQRYusr += " 	(SELECT COUNT(USR_ID) CONTA FROM SYS_USR_GROUPS G WHERE USR_GRUPO in('000001') AND G.USR_ID=SY.USR_ID AND G.D_E_L_E_T_<>'*') CONTA2 , "
    cQRYusr += " FROM  SYS_USRSYS_USR SY "
    cQRYusr += " WHERE SY.USR_ID='"+RetCodUsr()+"'	AND D_E_L_E_T_ = ' ' "
    TCQuery cQRYusr New Alias "QRY_USR"


    If nRecno == 0
        Return .F.
    EndIf

    dbSelectArea("SC1")
    SC1->(dbSetOrder(1))
    SC1->(DbGoTo(nRecno))

  
    // Nível 1: Aprovação inicial

    IF QRY_USR->CONTA1 == 0
MsgAlert("Usuário não tem permissão para aprovar solicitações de compra.", "Aprovação")

else 
    If Empty(SC1->C1_DATAAPR)
        lRet1 := FWAlertYesNo("Confirma aprovação da solicitação de compra?", "Aprovação Nível 1")
        If lRet1 .AND. SC1->(RecLock("SC1", .F.))
            SC1->C1_DATAAPR := dBase
            SC1->(MsUnlock())
        EndIf
    EndIf
EndIf

IF QRY_USR->CONTA2 == 0
MsgAlert("Usuário não tem permissão para aprovar solicitações de compra.", "Aprovação")

else 
    If !Empty(SC1->C1_DATAAPR) .AND. Empty(SC1->C1_DATAPR2)
        lRet2 := FWAlertYesNo("Confirma segunda aprovação?", "Aprovação Nível 2")
        If lRet2 .AND. SC1->(RecLock("SC1", .F.))
            SC1->C1_DATAPR2 := dBase
            SC1->C1_APROV := "L" // Libera a SC
            SC1->(MsUnlock())
           
        EndIf
    EndIf
    EndIf
   QRY_USR->(DbCloseArea())
Return lRet1 .OR. lRet2


User Function MT110COR()
    Local aCores := {}

    aAdd(aCores, { "Empty(C1_DATAAPR) .AND. Empty(C1_DATAPR2) .AND. C1_APROV == ' '", "BR_VIOLETA" })
    aAdd(aCores, { "!Empty(C1_DATAAPR) .AND. Empty(C1_DATAPR2)", "BR_AZUL_CLARO" })


Return aCores


User Function MT110LEG()
    Local aLegNew := PARAMIXB[1]  // Array com as legendas

    aAdd(aLegNew, { "BR_VIOLETA", "Aguardando Aprovação" })
    aAdd(aLegNew, { "BR_AZUL_CLARO", "Aprovado Nível 1" })

Return aLegNew
