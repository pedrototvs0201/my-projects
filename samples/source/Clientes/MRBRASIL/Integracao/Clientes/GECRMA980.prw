#include "totvs.ch"

User Function GECRMA980()
 
Local aErroA1   := {}
Local oModel    := nil

Private lMsErroAuto := .F.
Private cErro as character


oModel  := FwLoadModel ("CRMA980")
	DbselectArea("SA1")
	DbsetOrder(3)
	If Dbseek(xFilial("SA1")+cCNPJ,.T.)
		oModel:SetOperation(4)
	else
		oModel:SetOperation(3)
	EndIf

	oModel:Activate()
	oModel:setValue("SA1MASTER","A1_FILIAL",    FWxFilial("SA1") )
	oModel:SetValue("SA1MASTER","A1_COD"        ,cCliente)
	oModel:SetValue("SA1MASTER","A1_LOJA"       ,'01')
	oModel:SetValue("SA1MASTER","A1_CGC"       ,cCNPJ)
	oModel:SetValue("SA1MASTER","A1_NOME"     ,cRSocial)
	oModel:SetValue("SA1MASTER","A1_NREDUZ" ,cNFant)
	oModel:SetValue("SA1MASTER","A1_TIPO"  ,cTCli)
	oModel:SetValue("SA1MASTER","A1_PESSOA"  ,cTipo)
	oModel:SetValue("SA1MASTER","A1_XTCLIEN"  ,cCodTrim)
	oModel:SetValue("SA1MASTER","A1_CODTBOX"  ,cCodTrim)
	oModel:SetValue("SA1MASTER","A1_INSCR"  ,cIE)
	oModel:SetValue("SA1MASTER","A1_XTOTMIN"  ,nTolmi)
    oModel:SetValue("SA1MASTER","A1_XTOTMAX"  ,nTolmx)
    oModel:SetValue("SA1MASTER","A1_EMAIL"  ,cEmail)
    oModel:SetValue("SA1MASTER","A1_XLAUDO"  ,cLaudo)
    oModel:SetValue("SA1MASTER","A1_XEMLAUD"  ,cELaud)
    oModel:SetValue("SA1MASTER","A1_XPRIORI"  ,cPrio)
    oModel:SetValue("SA1MASTER","A1_DDD"  ,cDDD)
    oModel:SetValue("SA1MASTER","A1_TEL"  ,cTel)
    oModel:SetValue("SA1MASTER","A1_CONTATO"  ,cCont)
    oModel:SetValue("SA1MASTER","A1_PAIS"  ,cPais)
    oModel:SetValue("SA1MASTER","A1_COMPLEM"  ,cCompl)
    oModel:SetValue("SA1MASTER","A1_VEND"  ,cVend)
    oModel:SetValue("SA1MASTER","A1_COMIS"  ,nPcom)
    oModel:SetValue("SA1MASTER","A1_END"  ,cEnd)
    oModel:SetValue("SA1MASTER","A1_BAIRRO"  ,cBairro)
    oModel:SetValue("SA1MASTER","A1_EST"  ,cUF)
    oModel:SetValue("SA1MASTER","A1_CEP"  ,cCep)
    oModel:SetValue("SA1MASTER","A1_MUN"  ,cMun)
    oModel:SetValue("SA1MASTER","A1_COD_MUN"  ,cIBGE)

	If oModel:VldData()
		oModel:CommitData()
	//	MsgInfo("Registro INCLUIDO!", "Atenção")
	Else
		aErroA1 := oModel:GetErrorMessage()
		cErro := AllToChar(aErroA1[06])
		//VarInfo("",oModel:GetErrorMessage())
	EndIf

	oModel:DeActivate()
	oModel:Destroy()

	oModel := NIL

Return cErro 
