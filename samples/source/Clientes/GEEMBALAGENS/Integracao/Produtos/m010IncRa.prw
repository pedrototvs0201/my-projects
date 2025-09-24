#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDef.ch'


User Function m010IncRa()
	Local oModel      := Nil
	Local aErroB1 as array
	Private cErro as character
	Private lMsErroAuto := .F.
	Private nloc1, nloc2 as numeric
	Private cTipo as character

	aErroB1 := {}
	cErro := ""


	oModel  := FwLoadModel ("MATA010")
	DbselectArea("SB1")
	DbsetOrder(14)
	If Dbseek(xFilial("SB1")+cCodTrim,.T.)
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
	else
		oModel:SetOperation(MODEL_OPERATION_INSERT)
	EndIf
	
	nloc1 := At("CX",cDesPro)
	nloc2 := At("CAIXA",cDesPro)

	If nloc1 > 0 .or. nloc2 > 0
		cTipo := "PA"
	Else
		cTipo := "MP"
	EndIf


	oModel:Activate()
	oModel:setValue("SB1MASTER","B1_FILIAL"  ,    FWxFilial("SB1") )
	//oModel:SetValue("SB1MASTER","B1_COD"     ,cProduto             )
	oModel:SetValue("SB1MASTER","B1_DESC"    ,cDesPro              )
	oModel:SetValue("SB1MASTER","B1_TIPO"    ,cTipo                )
	oModel:SetValue("SB1MASTER","B1_UM"      ,"UN"                 )
	oModel:SetValue("SB1MASTER","B1_LOCPAD"  ,"01"                 )
	oModel:SetValue("SB1MASTER","B1_PESBRU"  ,nPesoB               )
	oModel:SetValue("SB1MASTER","B1_PESO"    ,nPeso                )
	oModel:SetValue("SB1MASTER","B1_IPI"     ,nIpi                 )
	oModel:SetValue("SB1MASTER","B1_POSIPI"  ,cncm                 )
	oModel:SetValue("SB1MASTER","B1_ORIGEM"  ,'0'                  )
	oModel:SetValue("SB1MASTER","B1_CODTBOX" ,cCodTrim             )

	If oModel:VldData()
		oModel:CommitData()
		MsgInfo("Registro INCLUIDO!", "Atenção")
	Else
		aErroB1 := oModel:GetErrorMessage()
		cErro := AllToChar(aErroB1[06])
		//VarInfo("",oModel:GetErrorMessage())
	EndIf

	oModel:DeActivate()
	oModel:Destroy()

	oModel := NIL
	
	//m370incRa()

Return cErro

Static Function m370incRa()

	local oSA7Mod as object

	oSA7Mod := nil

//Define as variáveis
	lDeuCerto := .F.
	cLojaCli  := "01"
	dDataRef  := Date()

	//Instanciando a rotina MATA370, buscando o model dos campos da SA7MASTER e definindo a operação como inclusão
	oSA7Mod := FWLoadModel("MATA370")
	//oSA7Mod:GetModel("SA7MASTER")
	
	DbselectArea("SB1")
	DbsetOrder(14)
	If Dbseek(xFilial("SB1")+cCodTrim,.T.)
		cProduto := SB1->B1_COD
	EndIf
	
	DbselectArea("SA7")
	DbsetOrder(1)
	If Dbseek(xFilial("SA7")+cCliente+cLojaCli+cProduto,.T.)
		return
	EndIf

    oSA7Mod:SetOperation(MODEL_OPERATION_INSERT)
	oSA7Mod:Activate()

	//Define as informações básicas da rotina
	oSA7Mod:setValue("SA7MASTER","A7_FILIAL",    FWxFilial("SA7") )
	oSA7Mod:setValue("SA7MASTER","A7_CLIENTE",   cCliente         )
	oSA7Mod:setValue("SA7MASTER","A7_LOJA",      cLojaCli         )
	oSA7Mod:setValue("SA7MASTER","A7_PRODUTO",   cProduto         )
	oSA7Mod:setValue("SA7MASTER","A7_DTREF01",   dDataRef         )

	//Tenta validar as informações e realizar o commit
	If oSA7Mod:VldData()
		If oSA7Mod:CommitData()
			lDeuCerto := .T.
		EndIf
	EndIf

	//Se não deu certo a operação de inclusão
	If ! lDeuCerto
		//Busca o Erro do Modelo de Dados
		aErro := oSA7Mod:GetErrorMessage()
		cErro += AllToChar(aErro[06])
		//Monta o Texto que será mostrado na tela
		AutoGrLog("Id do formulário de origem:"  + ' [' + AllToChar(aErro[01]) + ']')
		AutoGrLog("Id do campo de origem: "      + ' [' + AllToChar(aErro[02]) + ']')
		AutoGrLog("Id do formulário de erro: "   + ' [' + AllToChar(aErro[03]) + ']')
		AutoGrLog("Id do campo de erro: "        + ' [' + AllToChar(aErro[04]) + ']')
		AutoGrLog("Id do erro: "                 + ' [' + AllToChar(aErro[05]) + ']')
		AutoGrLog("Mensagem do erro: "           + ' [' + AllToChar(aErro[06]) + ']')
		AutoGrLog("Mensagem da solução: "        + ' [' + AllToChar(aErro[07]) + ']')
		AutoGrLog("Valor atribuído: "            + ' [' + AllToChar(aErro[08]) + ']')
		AutoGrLog("Valor anterior: "             + ' [' + AllToChar(aErro[09]) + ']')

		//Mostra a mensagem de Erro
		//MostraErro()
	EndIf

	//Por fim, desativa o modelo de dados
	oSA7Mod:DeActivate()


return
