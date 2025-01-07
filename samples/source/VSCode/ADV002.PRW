#Include "Totvs.ch"
#Include "FWMVCDef.ch"

//Variveis Estaticas
Static cTitulo := "Cadastro de Normas Técnicas"
Static cTabPai := "ZZB"
Static cTabFilho := "ZZE"

/*/{Protheus.doc} User Function ADV002
Elementos e sua faixa de trabalho
@author Pedro Eustaquio
@since 02/09/2024
@version 000
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

User Function ADV002()
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
Menu de opcoes na funcao ADV002
@author Pedro Eustaquio
@since 02/09/2024
@version 000
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

Static Function MenuDef()
	Local aRotina := {}

	//Adicionando opcoes do menu
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.ADV002" OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir" ACTION "VIEWDEF.ADV002" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar" ACTION "VIEWDEF.ADV002" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir" ACTION "VIEWDEF.ADV002" OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE "Copiar" ACTION "VIEWDEF.ADV002" OPERATION 9 ACCESS 0
	ADD OPTION aRotina TITLE "Imprimir" ACTION "VIEWDEF.ADV001" OPERATION 8 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
Modelo de dados na funcao ADV002
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
	oModel := MPFormModel():New("ADV002M", bPre, bPos, /*bCommit*/, bCancel)
	oModel:AddFields("ZZBMASTER", /*cOwner*/, oStruPai)
	oModel:AddGrid("ZZEDETAIL","ZZBMASTER",oStruFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)
	oModel:SetDescription(cTitulo)
	oModel:GetModel("ZZBMASTER"):SetDescription( "Dados de - " + cTitulo)
	oModel:GetModel("ZZEDETAIL"):SetDescription( "Grid de - " + cTitulo)
	oModel:SetPrimaryKey({})

	//Fazendo o relacionamento
	aAdd(aRelation, {"ZZE_FILIAL", "FWxFilial('ZZE')"} )
	aAdd(aRelation, {"ZZE_NORMA", "ZZB_COD"})
	oModel:SetRelation("ZZEDETAIL", aRelation, ZZE->(IndexKey(1)))

Return oModel

/*/{Protheus.doc} ViewDef
Visualizacao de dados na funcao ADV002
@author Pedro Eustaquio
@since 02/09/2024
@version 000
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

Static Function ViewDef()
	Local oModel := FWLoadModel("ADV002")
	Local oStruPai := FWFormStruct(2, cTabPai)
	Local oStruFilho := FWFormStruct(2, cTabFilho)
	Local oView

	//Cria a visualizacao do cadastro
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_ZZB", oStruPai, "ZZBMASTER")
	oView:AddGrid("VIEW_ZZE",  oStruFilho,  "ZZEDETAIL")

	//Partes da tela
	oView:CreateHorizontalBox("CABEC", 30)
	oView:CreateHorizontalBox("GRID", 70)
	oView:SetOwnerView("VIEW_ZZB", "CABEC")
	oView:SetOwnerView("VIEW_ZZE", "GRID")

	//Titulos
	oView:EnableTitleView("VIEW_ZZB", "Identificação")
	oView:EnableTitleView("VIEW_ZZE", "Faixa de composição quimica")
	//Adicionando campo incremental na grid
	oView:AddIncrementField("VIEW_ZZE", "ZZE_ITEM")
	//Removendo campos
	oStruFilho:RemoveField("ZZE_FILIAL")
	oStruFilho:RemoveField("ZZE_ITEM")
	oStruFilho:RemoveField("ZZE_NORMA")




Return oView
