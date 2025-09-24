#INCLUDE "TBICONN.CH "
#include "protheus.ch"
#include "topconn.ch"

//
// FONTE PARA ENVIO DE E-MAIL VIA JOB'S
//



User Function JobLt()

	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '0101' TABLES 'SB1,SB8' MODULO 'EST'

	cLocal1 := GetMv("GB_LOCAL01")
	cLocal2 := GetMv("GB_LOCAL02")
	dValid  := DtoS (dDatabase + GetMv("GB_DIAS"))
	eMail1  := GetMv("GB_EMAIL1")
	eMail2  := GetMv("GB_EMAIL2")
	aTipo	:= {}

	AADD(aTipo,{'MP','MATERIA PRIMA'})
	AADD(aTipo,{'EM','EMBALAGEM'})
	AADD(aTipo,{'PA','PRODUTOS ACABADOS'})
	AADD(aTipo,{'PP','PRODUTOS EM PROCESSO'})
	AADD(aTipo,{'PI','PRODUTOS INTERMEDIARIOS'})
	AADD(aTipo,{'SP','SUB-PRODUTOS'})

	u_JobLtE(cLocal1,dValid,eMail1,1,aTipo)
	u_JobLtE(cLocal2,dValid,eMail2,2,aTipo)

	RESET ENVIRONMENT

Return

User Function JobLtE(cLocal,dValid,eMail,nTipo,aTipo)

	Local   _aArea	 := GetArea()
	Local   _aArray  := {}
	Local   nt       := 0
	Local 	N		 := 0

	// Envia E-mail por Tipo de Producao
	For N:=1 to Len(aTipo)


		_aArray  := {}

		xSQL  	:= GetNextAlias()
		xcQuery     := " SELECT B8_PRODUTO
		xcQuery     += " ,B1_DESC
		xcQuery     += " ,BM_DESC
		xcQuery     += " ,B8_LOCAL
		xcQuery     += " ,B8_SALDO
		xcQuery     += " ,B8_DTVALID
		xcQuery     += " ,B1_UM
		xcQuery     += " FROM "+RetSqlName("SB8")+" SB8
		xcQuery     += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON B8_PRODUTO = B1_COD AND SB1.D_E_L_E_T_ <> '*'
		xcQuery     += " INNER JOIN "+RetSqlName("SBM")+" SBM ON B1_GRUPO = BM_GRUPO AND SBM.D_E_L_E_T_ <> '*'
		xcQuery     += " WHERE B8_DTVALID <= '"+dValid+"' "
		xcQuery     += " AND B8_SALDO <> 0
		xcQuery     += " AND SB8.D_E_L_E_T_ <> '*'
		xcQuery     += " AND B8_LOCAL IN "+cLocal+" "
		xcQuery     += " AND B1_TIPO = '"+aTipo[N][1]+"' "
		xcQuery     += " ORDER BY 3,6,1 "

		xcQuery     := ChangeQuery(xcQuery)
		dbUseArea(.T.,"TOPCONN",tCGenQry(,,xcQuery),xSQL,.T.,.T.)

		While (xSQL)->(!Eof())

			AADD(_aArray,{DTOC(STOD(B8_DTVALID)),;
				ALLTRIM(B8_PRODUTO),;
				ALLTRIM(B1_DESC),;
				ALLTRIM(B8_LOCAL),;
				ALLTRIM(B1_UM),;
				Alltrim(cValToChar(B8_SALDO)),;
				Alltrim(cValToChar(BM_DESC))})

			( xSQL )->(DbSkip())

		ENDDO

		DbCloseArea(xSQL)
		RestArea(_aArea)

		IF Len(_aArray) >= 1

			cRem := SUPERGETMV("MV_RELACNT",.F.,"")
			cDest := eMail
			cAssunto    := ALLTRIM(aTipo[N][2])+" - Relação dos Lotes com vencimento para os próximos "+Alltrim(cValToChar(GetMv("GB_DIAS")))+" dias:"

			cCorpo:='<HTML>'
			cCorpo+='	<HEAD>'
			cCorpo+='		<TITLE></TITLE>'
			cCorpo+='		<META content="MSHTML 6.00.6000.16735" name=GENERATOR>'
			cCorpo+='	</HEAD>'
			cCorpo+='	<BODY bgcolor="FFFFFF">'
			cCorpo+='		<font face="CALIBRI" size="3">'
			cCorpo+='		Prezado(a)s, <br/>'
			cCorpo+='		<br/>'
			cCorpo+='		Segue relação dos lotes de '+Alltrim(aTipo[N][2])+' com vencimento para os próximos ' +Alltrim(cValToChar(GetMv("GB_DIAS")))+' dias:'

			cCorpo+='		<br/>'
			cCorpo+='<table border="1">'
			cCorpo+='<tr>'
			cCorpo+='<th>Código</th>'
			cCorpo+='<th>Descrição</th>'
			cCorpo+='<th>Grupo</th>'
			cCorpo+='<th>Local</th>'
			cCorpo+='<th>U.M.</th>'
			cCorpo+='<th>Saldo</th>'
			cCorpo+='<th>Validade</th>'
			cCorpo+='</tr>'

			For nt := 1 to Len(_aArray)

				cCorpo+='<tr>'
				cCorpo+='<td>'+_aArray[nt][2]+'</td>'
				cCorpo+='<td>'+_aArray[nt][3]+'</td>'
				cCorpo+='<td>'+_aArray[nt][7]+'</td>'
				cCorpo+='<td>'+_aArray[nt][4]+'</td>'
				cCorpo+='<td>'+_aArray[nt][5]+'</td>'
				cCorpo+='<td>'+_aArray[nt][6]+'</td>'
				cCorpo+='<td>'+_aArray[nt][1]+'</td>'
				cCorpo+='</tr>'

			Next

			cCorpo+='		</table>'

			cCorpo+='		<br/>'
			cCorpo+='		</FONT>'
			cCorpo+='	<body/>'

			cCorpo+='	<img style="display:block;" src="http://cdn.izap.com.br/www.superminas.org.br/uploads/listas/cache/400-400-crop/GEROGES-BROME.jpg" height="" alt="">'

			cCorpo+='<HTML/>'

			U_ENVEJOB(cRem,cDest,cAssunto,cCorpo)
		ENDIF
	Next

Return

User Function ENVEJOB(cRem,cDest,cAssunto,cCorpo)

	Local cServer		:= strtran( alltrim(GetMv("MV_RELSERV")) , ':587' , '' )
	Local cAccount		:= alltrim(GetMv("MV_RELACNT"))
	Local cPassword		:= alltrim(GetMv("MV_RELPSW"))
	Local nTime			:= GetMv("MV_RELTIME")
	Local nPorta		:= GetMv("MV_PORSMTP")
	Local lAuth         := GetMv("MV_RELAUTH")
	Local lSSL          := GetMv("MV_RELSSL")
	Local lTLS          := GetMv("MV_RELTLS")
	Local oServer
	Local oMessage

//*********************************************************************************************************************************************************************
// Início do envio dos emails
//*********************************************************************************************************************************************************************

	//Cria a conexão com o server STMP(Envio de e-mail)
	oServer := TMailManager():New()

	//Indica se será utilizará a comunicação segura através de SSL/TLS (.T.) ou não (.F.)
	oServer	:SetUseSSL(lSSL)
	oServer	:SetUseTLS(lTLS)

	//inicia o servidor de emails
	xRet := oServer:Init("", cServer, cAccount, cPassword, 0, nPorta)
	If xRet <> 0
		msgstop("Falha ao inicializar o servidor de emails : " + oServer:GetErrorString(xRet))
		return()
	EndIf

	//seta um tempo de time out com servidor
	xRet := oServer:SetSmtpTimeOut(nTime)
	If xRet <> 0
		msgstop("Falha ao setar o time out : " + oServer:GetErrorString(xRet))
		return()
	EndIf

	//realiza a conexão SMTP
	xRet := oServer:SmtpConnect()
	If xRet <> 0
		msgstop("Falha ao conectar : " + oServer:GetErrorString(xRet))
		return()
	EndIf

	//autentica no servidor
	if lAuth
		xRet := oServer:SmtpAuth(cAccount, cPassword)
		If xRet <> 0
			msgstop("Falha ao autenticar : " + oServer:GetErrorString(xRet))
			oServer:SMTPDisconnect()
			return()
		endif
	endif

	//Apos a conexão, cria o objeto da mensagem
	oMessage := TMailMessage():New()
	oMessage:Clear()

	//Popula com os dados de envio
	oMessage:cFrom		:= cRem
	oMessage:cTo		:= cDest
	oMessage:cBcc		:= cRem
	oMessage:cSubject	:= cAssunto
	oMessage:cBody		:= cCorpo
	oMessage:MsgBodyType("text/html")

	//Envia o e-mail
	xRet := oMessage:Send(oServer)
	If xRet <> 0
		msgstop("Erro ao enviar o e-mail : " + oServer:GetErrorString(xRet))
		return()
	EndIf

	//Desconecta do servidor
	xRet := oServer:SmtpDisconnect()
	If xRet <> 0
		msgstop("Erro ao disconectar do servidor SMTP : " + oServer:GetErrorString(xRet))
		return()
	EndIf

Return
