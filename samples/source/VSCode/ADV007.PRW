#Include "Totvs.ch"
#Include "FWMVCDef.ch"

//Variveis Estaticas
Static cTitulo := "Ficha de Fusão"
Static cTabPai := "ZZD"
Static cTabFilho := "ZZF"

/*/{Protheus.doc} User Function ADV007
Cadastrar a ficha de fusão e seus materiais
@author Pedro Eustaquio
@since 04/09/2024
@version 000
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

User Function ADV00Z()
	Local aArea   := FWGetArea()
	Local oBrowse
	Local nIgnore := 1
	Private aRotina := {}

	//Definicao do menu
	aRotina := MenuDef()

	//Instanciando o browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(cTabPai)
	oBrowse:SetDescription(cTitulo)
	oBrowse:DisableDetails()
	oBrowse:DisableReport()

	//Ativa a Browse
	oBrowse:Activate()

	//Tratativa para ignorar warnings de ViewDef e ModelDef nunca chamados
	If nIgnore == 0
		ModelDef()
		ViewDef()
	EndIf

	FWRestArea(aArea)
Return Nil

/*/{Protheus.doc} MenuDef
Menu de opcoes na funcao ADV007
@author Pedro Eustaquio
@since 04/09/2024
@version 000
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

Static Function MenuDef()
	Local aRotina := {}

	//Adicionando opcoes do menu
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.ADV007" OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir" ACTION "VIEWDEF.ADV007" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar" ACTION "VIEWDEF.ADV007" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir" ACTION "VIEWDEF.ADV007" OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE "Copiar" ACTION "VIEWDEF.ADV007" OPERATION 9 ACCESS 0
	ADD OPTION aRotina TITLE "Imprimir" ACTION "VIEWDEF.ADV007" OPERATION 8 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
Modelo de dados na funcao ADV007
@author Pedro Eustaquio
@since 02/09/2024
@version 000
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

Static Function ModelDef()
	Local oStruPai := FWFormStruct(1, cTabPai)
	Local oStruFilho := FWFormStruct(1, cTabFilho)
	Local aRelation := {}
	Local oModel
	Local bPre := Nil
	Local bPos := Nil
	Local bCancel := Nil


	//Cria o modelo de dados para cadastro
	oModel := MPFormModel():New("ADV007M", bPre, bPos, /*bCommit*/, bCancel)
	oModel:AddFields("ZZDMASTER", /*cOwner*/, oStruPai)
	oModel:AddGrid("ZZFDETAIL","ZZDMASTER",oStruFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)
	oModel:SetDescription(cTitulo)
	oModel:GetModel("ZZDMASTER"):SetDescription( "Dados de - " + cTitulo)
	oModel:GetModel("ZZFDETAIL"):SetDescription( "Grid de - " + cTitulo)
	oModel:SetPrimaryKey({})

	//Fazendo o relacionamento
	aAdd(aRelation, {"ZZF_FILIAL", "FWxFilial('ZZF')"} )
	aAdd(aRelation, {"ZZF_NUMCOR", "ZZD_NUMCOR"})
	oModel:SetRelation("ZZFDETAIL", aRelation, ZZF->(IndexKey(1)))

Return oModel

/*/{Protheus.doc} ViewDef
Visualizacao de dados na funcao ADV007
@author Pedro Eustaquio
@since 02/09/2024
@version 000
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

Static Function ViewDef()
	Local oModel := FWLoadModel("ADV007")
	Local oStruPai := FWFormStruct(2, cTabPai)
	Local oStruFilho := FWFormStruct(2, cTabFilho)
	Local oView

	//Cria a visualizacao do cadastro
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_ZZD", oStruPai, "ZZDMASTER")
	oView:AddGrid("VIEW_ZZF",  oStruFilho,  "ZZFDETAIL")

	//Partes da tela
	oView:CreateHorizontalBox("CABEC", 30)
	oView:CreateHorizontalBox("GRID", 70)
	oView:SetOwnerView("VIEW_ZZD", "CABEC")
	oView:SetOwnerView("VIEW_ZZF", "GRID")

	//Titulos
	oView:EnableTitleView("VIEW_ZZD", "Ficha de Fusão")
	oView:EnableTitleView("VIEW_ZZF", "Materiais da Carga")
	//Adicionando campo incremental na grid
	oView:AddIncrementField("VIEW_ZZF", "ZZF_ITEM")
	//Removendo campos
	oStruFilho:RemoveField("ZZF_FILIAL")
	oStruFilho:RemoveField("ZZF_ITEM")
	oStruFilho:RemoveField("ZZF_NUMCOR")




Return oView
