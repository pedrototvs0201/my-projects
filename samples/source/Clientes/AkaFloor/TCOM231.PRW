//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "topconn.ch"
#include "fileio.ch"
 
//+----------------------------------------------------------------------+//
    //+ Desenvolvido por: Givanildo de Rezende          Em: 10/06/2022   +//
    //+------------------------------------------------------------------+//
    // Rotina para enviar e-mail aos clientes após o faturamento          //
    //                                                                    //
    //                                                                    //
    //+------------------------------------------------------------------+//
    // Revisoes                | Givanildo  	          | 10/06/2022    //
    //--------------------------------------------------------------------//
    //  CAMPOS PERSONALIZADOS  |  PARAMETROS              | GATILHO       //
    //=========================|==========================|===============//
    //  				       |   			              |               //
    //  				       |                          |               //
    //--------------------------------------------------------------------//
//-
User Function TCOM231(cRotina,cNum,cEvento,cEmail)
    Local aAnexos   := {}
    Local lFalha    := .F.
    Local lRet      := .F.
    Local _cHTML    := ""

    default cAcao := ''

    Private cLog      := ""
    //  Montar o corpo do e-mail (HTML)
    _cHTML := MyBody(cRotina,cNum,cEvento)
    // Percorrer o Array enviando os e-mails
    cAssunto    := "Notificação interna Akafloor "
    cCorpo      := _cHTML
    lMostraLog  := .F.
    lUsaTLS     := .T.
    lNovo       := .F.

    lRet := u_EnvMail(cEmail, cAssunto, cCorpo, aAnexos, lMostraLog, lUsaTLS, lNovo)
    If !lRet
        lFalha :=.T.
    EndIf

    If lFalha
        Alert("Ocorreu algum problema no envio do e-mail!"+chr(13)+;
              "Verifique o log do arquivo!"+chr(13)+;
              cLog)
    else
		If SUPERGETMV("MV_XCONFOK",.T.,.F.) // Confirma se foi enviado
        	cMsg :="Os anexos foram enviados para o e-mail: " + Alltrim(cEmail)+chr(13)+;
					"E-mail enviado com sucesso!!!"
			IncProc(cMsg)
		EndIf
    EndIf

Return(!lFalha)
//----------------------------------------------(quebra)------------------------------------------------------//

Static Function MyBody(cRotina,cNum,cEvento)
   
    Local cBody   := ""
    Local cNomCom := ""
    Local cEnviro := iif(Trim(GetEnvServer())== "cabo21_dev","Desenvolvimento","Produção")
    Local aFieldSM0 := { ;
        "M0_CODIGO",;    //Posição [1]
        "M0_CODFIL",;    //Posição [2]
        "M0_NOMECOM",;   //Posição [3]
        "M0_CGC",;       //Posição [4]
        "M0_INSCM",;     //Posição [5]
        "M0_CIDENT",;    //Posição [6]
        "M0_ESTENT",;    //Posição [7]
        "M0_ENDENT",;    //Posição [8]
        "M0_BAIRENT",;   //Posição [9]
        "M0_CEPENT",;    //Posição [10]
        "M0_COMPENT",;   //Posição [11]
        "M0_TEL";        //Posição [12]
    }
    Local aSM0Data2 := {}
    Local cTexto    := " "

    Default cAcao := ''

    aSM0Data2 := FWSM0Util():GetSM0Data(, cFilAnt, aFieldSM0)
    If Len(aSM0Data2) > 0
        cNomCom := aSM0Data2[3][2] //M0_NOMECOM
        //Alert(aSM0Data2[4][2]) //M0_CGC
        //Alert(aSM0Data2[6][2]) //M0_CIDENT
    EndIf    

    cBody += '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">'
    cBody += '<html>'
    cBody += '<head>'
    cBody += '  <meta content="text/html; charset=ISO-8859-1"'
    cBody += ' http-equiv="content-type">'
    cBody += '  <title></title>'
    cBody += '</head>'
    cBody += '<body>'

    If cRotina == "SC"
        If cEvento $ "I/A"
            cBody += 'A '
            cBody += 'solicita&ccedil;&atilde;o de compra n&ordm; <big'
            cBody += ' style="font-weight: bold;"> '+cNum+' </big> se encontra '
            cBody += 'pendente de aprova&ccedil;&atilde;o!<br>'
            cBody += 'Ambiente <big><span style="font-weight: bold;">' +cEnviro+' </span></big>'  
        Elseif cEvento $ "AP"
            cBody += 'A '
            cBody += 'solicita&ccedil;&atilde;o de compra n&ordm; <big'
            cBody += ' style="font-weight: bold;"> '+cNum+' </big>'
            cBody += 'foi aprovada por '+UsrRetName(__cUserId)+'<br>'
            cBody += 'Ambiente <big><span style="font-weight: bold;">' +cEnviro+' </span></big>'
        Elseif cEvento $ "RJ"
            cBody += 'A '
            cBody += 'solicita&ccedil;&atilde;o de compra n&ordm; <big'
            cBody += ' style="font-weight: bold;"> '+cNum+' </big>'
            cBody += 'foi rejeitada por '+UsrRetName(__cUserId)+'<br>'
            cBody += 'Ambiente <big><span style="font-weight: bold;">' +cEnviro+' </span></big>'
        Elseif cEvento == "BQ"
            cBody += 'A '
            cBody += 'solicita&ccedil;&atilde;o de compra n&ordm; <big'
            cBody += ' style="font-weight: bold;"> '+cNum+' </big>'
            cBody += 'foi bloqueada por '+UsrRetName(__cUserId)+'<br>'
            cBody += 'Ambiente <big><span style="font-weight: bold;">' +cEnviro+' </span></big>'
        Else
            cBody += 'A '
            cBody += 'solicita&ccedil;&atilde;o de compra n&ordm; <big'
            cBody += ' style="font-weight: bold;"> '+cNum+' </big> foi '
            cBody += 'foi excluída por '+UsrRetName(__cUserId)+'<br>'
            cBody += 'Ambiente <big><span style="font-weight: bold;">' +cEnviro+' </span></big>'
        EndIf
    EndIf
    //DMS
    if cRotina == 'MT094END'

        lSolicitacao := posicione("SC1",1,xFilial("SC1")+alltrim(cNum),"C1_NUM")
        lPedido      := posicione("SC7",1,xFilial("SC7")+alltrim(cNum),"C7_NUM")

        if !empty(lSolicitacao)
            cTexto := 'A Solicitação de compra '
        elseif !empty(lPedido)
            cTexto := 'O Pedido de compra '
        endif

        if  cEvento $ "A"
            cBody += cTexto+'n&ordm; <big style="font-weight: bold;"> '+cNum+' </big>'
            cBody += 'foi aprovado por'+UsrRetName(__cUserId)+'<br>'
            cBody += 'Ambiente <big><span style="font-weight: bold;">' +cEnviro+' </span></big>' 
        elseif cEvento $ "R"
            cBody += cTexto+' n&ordm; <big style="font-weight: bold;"> '+cNum+' </big>'
            cBody += 'foi reprovado por'+UsrRetName(__cUserId)+'<br>'
            cBody += 'Ambiente <big><span style="font-weight: bold;">' +cEnviro+' </span></big>' 
        endif
    endIf
    //
    If cRotina == "PC"
        If cEvento $ "I/A"
            cBody += 'O pedido de compra n&ordm; <big style="font-weight: bold;"> '+cNum+' </big>'
            cBody += 'se encontra pendente de aprova&ccedil;&atilde;o!<br>'
            cBody += 'Ambiente <big><span style="font-weight: bold;">' +cEnviro+' </span></big>'
        Else
            cBody += 'O pedido de compra n&ordm; <big style="font-weight: bold;"> '+cNum+' </big>'
            cBody += 'foi exclu&iacute;do!<br>'
            cBody += 'Ambiente <big><span style="font-weight: bold;">' +cEnviro+' </span></big>'
        EndIf
    EndIf

    If cRotina == "PV"
        If cEvento == "I"
            cBody += 'O pedido de venda n&ordm; <big style="font-weight: bold;"> '+cNum+' </big>'
            cBody += 'da empresa '+Trim(cNomCom)+' foi inclu&iacute;do no sistema!<br>'
            cBody += 'Ambiente <big><span style="font-weight: bold;">' +cEnviro+' </span></big>'
        Else
            cBody += 'O pedido de venda n&ordm; <big style="font-weight: bold;"> '+cNum+' </big>'
            cBody += 'da empresa '+Trim(cNomCom)+' foi exclu&iacute;do do sistema!<br>'
            cBody += 'Ambiente <big><span style="font-weight: bold;">' +cEnviro+' </span></big>'
        EndIf
    EndIf
    cBody += '<br>'
    cBody += '</body>'
    cBody += '</html>'

Return(cBody)
//----------------------------------------------(quebra)------------------------------------------------------//


//-----------------------------------------------------------------------------------------------------------------------------------------------
// O  ponto de entrada MT120GRV utilizado para continuar ou não a Inclusão, alteração ou exclusão do Pedido de Compra ou Autorização de Entrega.
//-----------------------------------------------------------------------------------------------------------------------------------------------
User Function MT120GRV() // Pedido de Compra
    Local aArea     := GetArea()
    Local cNum      := PARAMIXB[1]
    Local lInclui   := PARAMIXB[2]
    Local lAltera   := PARAMIXB[3]
    Local lExclui   := PARAMIXB[4]
    Local lRet      :=.T.
    //Local cEmail    := Alltrim(SuperGetMv("MV_MAILSC7",.F.,"givanildo.rezende@totvs.com.br"))
    Local cEmail    := Alltrim(SuperGetMv("MV_MAILSC7",.F.,"infra@akafloor.com.br"))
    Local cEvento   := ""
    Local cRotina   := "PC"
    Local nTotSC7   := 0

    //..customizacao do cliente
    dbSelectArea("SC7")
    SC7->(dbSetOrder(1)) // C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
    SC7->(dbGoTop())
    SC7->(dbSeek(XFILIAL("SC7")+cNum))
    While SC7->(!Eof()) .and. SC7->(C7_FILIAL+C7_NUM) == XFILIAL("SC7")+cNum
        nTotSC7 += SC7->C7_TOTAL

        SC7->(dbSkip())
    EndDo
    If nTotSC7 >= 50000
        cEmail += ";samia@akafloor.com.br"
        //cEmail += ";givanildo.rezende@totvs.com.br"
    EndIf

    If lInclui
        cEvento := "I"
    Else
        If lAltera
           cEvento := "A"
        Else
            If lExclui
                cEvento := "E"    
            EndIf
        EndIf
    EndIf
    If !Empty(Trim(cEvento))
        u_TCOM231(cRotina,cNum,cEvento,cEmail)
    EndIf
    RestArea(aArea) 
Return lRet
//----------------------------------------------(quebra)------------------------------------------------------//
//-----------------------------------------------------------------------------------------------------------------------------------------------
// O  ponto de entrada M110STTS utilizado para continuar ou não a inclusão, alteração, exclusão e cópia. Se retornar .T., deve executar 
// as operações de inclusão, alteração, exclusão e cópia ou .F. para interromper o processo.
//-----------------------------------------------------------------------------------------------------------------------------------------------
User Function M110STTS() // Solicitação de Compra
    //Validações do Cliente
    Local aArea     := GetArea() 
    Local cNum      := Paramixb[1]
    Local nEvento   := Paramixb[2] //1- Inclusão, 2- Alteração, 3- Exclusão.
    Local lRet      := NIL
    Local cEmail    := Alltrim(SuperGetMv("MV_MAILSC1",.F.,"infra@akafloor.com.br"))
    Local cEvento   := ""
    Local cRotina   := "SC"

    If nEvento == 1
        cEvento := "I"
    Else
        If nEvento == 2
           cEvento := "A"
        Else
            If nEvento == 3
                cEvento := "E"    
            EndIf
        EndIf
    EndIf
    If !Empty(Trim(cEvento))
        u_TCOM231(cRotina,cNum,cEvento,cEmail)
    EndIf
    RestArea(aArea)        
Return lRet
//----------------------------------------------(quebra)------------------------------------------------------//
//-----------------------------------------------------------------------------------------------------------------------------------------------
// O  ponto de entrada M410STTS utilizado para continuar ou não a inclusão, alteração, exclusão e cópia. Se retornar .T., deve executar 
// as operações de inclusão, alteração, exclusão e cópia ou .F. para interromper o processo.
//-----------------------------------------------------------------------------------------------------------------------------------------------
User Function M410AGRV() // Pedido de Venda
    Local aArea     := GetArea() 
    Local nEvento   := Paramixb[1] //1- Inclusão, 2- Alteração, 3- Exclusão.
    
    //Validações do Cliente
    Local lRet      := Nil
    Local cEmail    := Alltrim(SuperGetMv("MV_MAILSC5",.F.,"contasareceber@akafloorcom.br"))
    Local cEvento   := ""
    Local cRotina   := "PV"
    Local cNum      := M->C5_NUM
    //..customizacao do cliente
    If nEvento == 1
        cEvento := "I"
    Else
        If nEvento == 3
            cEvento := "E"    
        EndIf
    EndIf
    If !Empty(Trim(cEvento))
        u_TCOM231(cRotina,cNum,cEvento,cEmail)
    EndIf
    RestArea(aArea)    
Return lRet
//----------------------------------------------(quebra)------------------------------------------------------//

