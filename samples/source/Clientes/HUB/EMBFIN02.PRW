#Include 'Protheus.ch'

/*/{Protheus.doc} EMBFIN02
Customizacao para Cheques Devolvidos

@author Wemerson Randolfo Bastos
@since 09/12/2020
@version 1.00
/*/

User Function EMBFIN02()

	//|Valida o tipo do titulo selecionado |
	If !AllTrim(SE1->E1_TIPO) $ ('CH/CHV')
		
		MsgAlert("Para utilizar esse rotina o titulo deve ser tipo CH ou CHV!","EMBFIN02")
		Return
	
	EndIf
	
	//|Valida se o cheque ja foi devolvido |
	If SE1->E1_YDEVOLV == 'S'
		
		MsgAlert("Esse cheque ja foi devolvido anteriormente!","EMBFIN02")
		Return	
	
	EndIf
	
	//|Valida se o titulo esta baixado |
	If SE1->E1_SALDO > 0
	
		MsgAlert("O cheque deve estar baixado para realizar a devolucao!","EMBFIN02")
		Return
	
	EndIf
	
	//|Valida se o titulo tem portador |
	If Empty(SE1->E1_PORTADO)
	
		//MsgAlert("O cheque nao foi baixado em banco!","EMBFIN02")
		//Return
		
	EndIf
	
	//|Verifica se o cliente esta bloqueado |
	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1") + SE1->(E1_CLIENTE + E1_LOJA)))
	If SA1->A1_MSBLQL == "1"
		
		MsgAlert("O cliente está bloqueado!","EMBFIN02")
		Return
			
	EndIf
	
	If MsgYesNo("Deseja informar a devolução desse cheque?","EMBFIN02")
		
		Processa({|| SFP001()},'Processando devolucao do cheque...','Aguarde')
		
	EndIf

Return



Static Function SFP001()

	Local aFina100		:= {}
	Local aFina040		:= {}
	
	Private lMsErroAuto := .F.
	
	Begin Transaction
	
	//|Atualiza campo de cheque devolvido |
	RecLock("SE1",.F.)
	SE1->E1_YDEVOLV	:= "S"
	SE1->(MsUnLock())
	
	cTitulo	:= AllTrim(SE1->E1_PREFIXO) +"/"+ AllTrim(SE1->E1_NUM) +"/"+ AllTrim(SE1->E1_PARCELA) +"/"+ AllTrim(SE1->E1_TIPO)

	//|Gera a movimentacao bancaria do estorno |
	AADD(aFINA100, 	{"E5_DATA"		,     dDataBase,             	Nil})
	AADD(aFINA100, {"E5_PREFIXO"	,  SE1->E1_PREFIXO,             Nil})
	AADD(aFINA100, {"E5_PARCELA"	,  SE1->E1_PARCELA,             Nil})
	AADD(aFINA100, {"E5_TIPO"		,  SE1->E1_TIPO,             	Nil})
	AADD(aFINA100, {"E5_NUMERO"		,   SE1->E1_NUM,              	Nil})
	AADD(aFINA100, {"E5_MOEDA"		,    '01',                 		Nil})
	AADD(aFINA100, {"E5_VALOR"		,    SE1->E1_VALOR,         	Nil})
	AADD(aFINA100, {"E5_NATUREZ"	,  '10002   ',           		Nil})
	AADD(aFINA100, {"E5_BANCO"		,   SE1->E1_PORTADO,       		Nil})
	AADD(aFINA100, {"E5_AGENCIA"	,  SE1->E1_AGEDEP,             	Nil})
	AADD(aFINA100, {"E5_CONTA"		,   SE1->E1_CONTA,         		Nil})
	AADD(aFINA100, {"E5_HISTOR"		,   "CH DEV.: " + cTitulo,   	Nil})
	AADD(aFINA100, {"E5_BENEF"		,   SE1->E1_NOMCLI,             Nil})
	//AADD(aFINA100, {"E5_CLIFOR"		,  SE1->E1_CLIENTE,             Nil})
	//AADD(aFINA100, {"E5_LOJA"		,  SE1->E1_LOJA,             	Nil})
	  
    MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFina100,3)	//|Movimento a Pagar |

    If lMsErroAuto
        MostraErro()
        DisarmTransaction()
        Return
    EndIf       
	
	cTipo	:= IIf(AllTrim(SE1->E1_TIPO) == 'CH','CHV','CHD')
	//|Gera novo titulo do cheque em aberto |
	aFina040 := {{"E1_PREFIXO" 	,SE1->E1_PREFIXO  				,Nil},;
				{"E1_NUM"	   	,SE1->E1_NUM   					,Nil},;
				{"E1_PARCELA" 	,SE1->E1_PARCELA  				,Nil},;
				{"E1_TIPO"	   	,cTipo     						,Nil},;
				{"E1_NATUREZ" 	,SE1->E1_NATUREZ				,Nil},;
    	    	{"E1_CLIENTE" 	,SE1->E1_CLIENTE  				,Nil},;
        	 	{"E1_LOJA"	   	,SE1->E1_LOJA     				,Nil},;
        		{"E1_EMISSAO" 	,dDataBase 						,Nil},;
				{"E1_VENCTO"	,dDataBase						,Nil},;
				{"E1_VENCREA" 	,DataValida(dDataBase,.T.)		,Nil},;
				{"E1_VALOR"		,SE1->E1_VALOR					,Nil}}
	
	Private lMsErroAuto := .F.
	
	MsExecAuto({|x,y| FINA040(x,y)},aFina040,3) //|Inclusao |
	
	If lMsErroAuto
        MostraErro()
        DisarmTransaction()
        Return
    EndIf  
	
	End Transaction
	
	MsgInfo("Processo de Devolucao do cheque gerado com sucesso!","EMBFIN02")
	

Return

