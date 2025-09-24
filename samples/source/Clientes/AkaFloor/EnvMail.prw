//Bibliotecas
#Include "Protheus.ch"
//+-----------------------------------------------------------------------+//
//+ Desenvolvido por: Givanildo de Rezende          Em: 08/10/2021        +//
//+-----------------------------------------------------------------------+//
// Rotina para enviar e-mail com anexos                                    //
//                                                                         //
//+-----------------------------------------------------------------------+//
// Revisoes                     | Givanildo  	           | 08/10/2021    //
//-------------------------------------------------------------------------//
//  CAMPOS PERSONALIZADOS       |  PARAMETROS              | GATILHO       //
//  ============================|==========================|===============//
//                            	|   			           |               //
//                              |                          |               //
//-------------------------------------------------------------------------//
//-
//----------------------------------------------- quebra da rotina ------------------------------------------------------//
/*/{Protheus.doc} EnvMail
https://terminaldeinformacao.com/2017/10/17/funcao-dispara-e-mail-varios-anexos-em-advpl/
Funcao para disparo do e-mail utilizando TMailMessage e tMailManager com opcao de multiplos anexos
@author Atilio
@since 26/05/2017
@version 1.0
@type function
@param cPara, characters, Destinatario que ira receber o e-Mail
@param cAssunto, characters, Assunto do e-Mail
@param cCorpo, characters, Corpo do e-Mail (com suporte ao  html)
@param aAnexos, array, Anexos que estaraoo no e-mail (devem estar na mesma pasta da protheus data)
@param lMostraLog, logical, Define se sera mostrado mensagem de log ao usuario (uma tela de aviso)
@param lUsaTLS, logical, Define se ira utilizar o protocolo criptografico TLS
@return lRet, Retorna se houve falha ou nÃ£o no disparo do e-Mail
@example Exemplos:
-----
1 - Mensagem Simples de envio
u_EnvMail("teste@servidor.com.br", "Teste", "Teste TMailMessage - Protheus", , .T.)
-----
2 - Mensagem com anexos (devem estar dentro da Protheus Data)
aAnexos := {}
aAdd(aAnexos, "\pasta\arquivo1.pdf")
aAdd(aAnexos, "\pasta\arquivo2.pdf")
aAdd(aAnexos, "\pasta\arquivo3.pdf")
u_EnvMail("teste@servidor.com.br", "Teste", "Teste TMailMessage com anexos - Protheus", aAnexos)
u_EnvMail("informatica@patral.com.br", "Teste", "Teste TMailMessage", , .T.)
@obs Deve-se configurar os parÃ¢metros:
* MV_RELACNT - Conta de login do e-Mail    - Ex.: email@servidor.com.br
* MV_RELPSW  - Senha de login do e-Mail    - Ex.: senha
* MV_RELSERV - Servidor SMTP do e-Mail     - Ex.: smtp.servidor.com.br:587
* MV_RELTIME - TimeOut do e-Mail           - Ex.: 120
/*/
User Function EnvMail(cPara, cAssunto, cCorpo, aAnexos, lMostraLog, lUsaTLS, lNovo)
    Local aArea        := GetArea()
    Local nAtual       := 0
    Local lRet         := .T.
    Local oMsg         := TMailManager():New()
    Local oSrv         := TMailManager():New()
    Local nRet         := 0
    Local cFrom        := Alltrim(SuperGetMv("MV_RELACNT",.F.,"noreply@akafloor.com.br"))
    Local cUser        := "noreply@akafloor.com.br"//SubStr(cFrom, 1, At('@', cFrom)-1) // "nfevortice@gmail.com"
    Local cPass        := Alltrim(SuperGetMv("MV_RELPSW",.F.,"Pisopronto10@"))
    Local cSrvFull     := Alltrim(SuperGetMv("MV_RELSERV",.F.,"smtp-mail.outlook.com:587"))
    Local cServer      := ""
    Local nPort        := 0
    Local nTimeOut     := SuperGetMv("MV_RELTIME",.T.,120)
    Local cContaAuth   := ""
    Local cPassAuth    := ""
    Local ctoken       := "access_token"
    Local cProcessos   := ""
    Default cPara      := ""
    Default cAssunto   := ""
    Default cCorpo     := ""
    Default aAnexos    := {}
    Default lMostraLog := .T.
    Default lUsaTLS    := .T.
    Default lNovo      := .F.

    cLog               := ""

    oSrv:SetUseSSL( .T. )
    oSrv:SetUseTLS( .T. )
    

    //Se tiver em branco o destinatario, o assunto ou o corpo do email
    If Empty(cPara) .Or. Empty(cAssunto) .Or. Empty(cCorpo)
        cLog += "001 - Destinatario, Assunto ou Corpo do e-Mail vazio(s)!" + CRLF
        lRet := .F.
    EndIf
    If lRet
        If lNovo
            cContaAuth := Alltrim(SuperGetMv("MV_X_NCNT"))
            cPassAuth  := Alltrim(SuperGetMv("MV_X_NPSW"))
            cSrvFull   := Alltrim(SuperGetMv("MV_X_NSRV"))
        Else
            cContaAuth := cFrom
            cPassAuth  := cPass
        EndIf
        cServer      := Iif(':' $ cSrvFull, SubStr(cSrvFull, 1, At(':', cSrvFull)-1), cSrvFull)
        nPort        := Iif(':' $ cSrvFull, Val(SubStr(cSrvFull, At(':', cSrvFull)+1, Len(cSrvFull))), 587)
        //Cria a nova mensagem
        oMsg := TMailMessage():New()
        oMsg:Clear()
        //Define os atributos da mensagem
        //oMsg:cDate    := cValToChar(Date())
        oMsg:cFrom    := cFrom
        oMsg:cTo      := cPara
        oMsg:cSubject := cAssunto
        oMsg:cBody    := cCorpo   
        //Percorre os anexos
        For nAtual := 1 To Len(aAnexos)
            //Se o arquivo existir
            If File(aAnexos[nAtual])
                //Anexa o arquivo na mensagem de e-Mail
                nRet := oMsg:AttachFile(aAnexos[nAtual])
                If nRet < 0
                    cLog += "002 - Nao foi possivel anexar o arquivo '"+aAnexos[nAtual]+"'!" + CRLF
                EndIf
                //Senao, acrescenta no log
            Else
                cLog += "003 - Arquivo '"+aAnexos[nAtual]+"' nao encontrado!" + CRLF
            EndIf
        Next
        //Cria servidor para disparo do e-Mail
        oSrv  := TMailManager():New()
        //Define se irão utilizar o TLS
        If lUsaTLS
            oSrv:SetUseTLS(.T.)
        EndIf
        //Inicializa conexão
        nRet := oSrv:Init("", cServer, cUser, cPass, 0, nPort)
        If nRet != 0
            cLog += "004 - Nao foi possivel inicializar o servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
            lRet := .F.
        EndIf
        If lRet

        oSrv:SetOAuthToken( ctoken )
   
        nRet := oSrv:SMTPConnect()
        if nRet <> 0
            conout( "005 - Erro SMTPConnect oAUTH2: " + oSrv:GetErrorString( nRet ) )
             lRet := .F.
        endif


            //Define o time out
            nRet := oSrv:SetSMTPTimeout(nTimeOut)
            If nRet != 0
                cLog += "006 - Nao foi possivel definir o TimeOut '"+cValToChar(nTimeOut)+"'" + CRLF
               lRet := .F.
            EndIf
          
            If lRet
                //Realiza a autenticação do usuário e senha
                nRet := oSrv:SmtpAuth(cContaAuth, cPassAuth)
                If nRet <> 0
                    cLog += " 007 - Nao foi possivel autenticar no servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
                    lRet := .F.
                EndIf
                If lRet
                    //Envia a mensagem
                    nRet := oMsg:Send(oSrv)
                    If nRet <> 0
                        cLog += "008 - Nao foi possivel enviar a mensagem: " + oSrv:GetErrorString(nRet) + CRLF
                        lRet := .F.
                    EndIf
                EndIf
                //Disconecta do servidor
                nRet := oSrv:SMTPDisconnect()
                If nRet <> 0
                    cLog += "009 - Nao foi possivel disconectar do servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
                EndIf
            EndIf
        EndIf
    EndIf
    //Se tiver log de avisos/erros
    If !Empty(cLog)
        //Busca todas as funções
        nAtu := 0
        cProcessos := ""
        /*
        While ! (ProcName(nAtu) == '')
            cProcessos += ProcName(nAtu) + "; "
            nAtu++
        EndDo
        */
        cLog := "+======================= EnvMail =======================+" + CRLF + ;
            "EnvMail  - "+dToC(Date())+ " " + Time() + CRLF + ;
            "Funcao    - " + FunName() + CRLF + ;
            "Processos - " + cProcessos + CRLF + ;
            "Para      - " + cPara + CRLF + ;
            "Assunto   - " + cAssunto + CRLF + ;
            "Corpo     - " + cCorpo + CRLF + ;
            "Existem mensagens de aviso: "+ CRLF +;
            cLog + CRLF +;
            "+======================= EnvMail =======================+"
        //ConOut(cLog)
        //Se for para mostrar o log visualmente e for processo com interface com o usuÃ¡rio, mostra uma mensagem na tela
        If lMostraLog .And. ! IsBlind()
            Aviso("Log", cLog, {"Ok"}, 2)
        EndIf
    EndIf
    RestArea(aArea)
Return lRet

