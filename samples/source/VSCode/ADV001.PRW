//Bibliotecas
#Include "Totvs.ch"
#Include "FWMVCDef.ch"

//Variveis Estaticas
Static cTitulo := "Cadastro de Liga Metálica"
Static cTabPai := "ZZA"
Static cTabFilho := "ZZC"

/*/{Protheus.doc} User Function ADV001
Materiais da Liga
@author Pedro Eustaquio
@since 30/08/2024
@version 000
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

User Function ADV001()
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
Menu de opcoes na funcao ADV001
@author Pedro Eustaquio
@since 30/08/2024
@version 000
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

Static Function MenuDef()
	Local aRotina := {}

	//Adicionando opcoes do menu
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.ADV001" OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir" ACTION "VIEWDEF.ADV001" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar" ACTION "VIEWDEF.ADV001" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir" ACTION "VIEWDEF.ADV001" OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE "Copiar" ACTION "VIEWDEF.ADV001" OPERATION 9 ACCESS 0
	ADD OPTION aRotina TITLE "Imprimir" ACTION "VIEWDEF.ADV001" OPERATION 8 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
Modelo de dados na funcao ADV001
@author Pedro Eustaquio
@since 30/08/2024
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
	oModel := MPFormModel():New("ADV001M", bPre, bPos, /*bCommit*/, bCancel)
	oModel:AddFields("ZZAMASTER", /*cOwner*/, oStruPai)
	oModel:AddGrid("ZZCDETAIL","ZZAMASTER",oStruFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)
	oModel:SetDescription("Modelo de dados - " + cTitulo)
	oModel:GetModel("ZZAMASTER"):SetDescription(  cTitulo)
	oModel:GetModel("ZZCDETAIL"):SetDescription( "Grid de - " + cTitulo)
	oModel:SetPrimaryKey({})

	//Fazendo o relacionamento
	aAdd(aRelation, {"ZZC_FILIAL", "FWxFilial('ZZC')"} )
	aAdd(aRelation, {"ZZC_COD", "ZZA_COD"})
	oModel:SetRelation("ZZCDETAIL", aRelation, ZZC->(IndexKey(1)))

Return oModel

/*/{Protheus.doc} ViewDef
Visualizacao de dados na funcao ADV001
@author Pedro Eustaquio
@since 30/08/2024
@version 000
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

Static Function ViewDef()
	Local oModel := FWLoadModel("ADV001")
	Local oStruPai := FWFormStruct(2, cTabPai)
	Local oStruFilho := FWFormStruct(2, cTabFilho)
	Local oView

	//Cria a visualizacao do cadastro
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_ZZA", oStruPai, "ZZAMASTER")
	oView:AddGrid("VIEW_ZZC",  oStruFilho,  "ZZCDETAIL")

	//Partes da tela
	oView:CreateHorizontalBox("CABEC", 30)
	oView:CreateHorizontalBox("GRID", 70)
	oView:SetOwnerView("VIEW_ZZA", "CABEC")
	oView:SetOwnerView("VIEW_ZZC", "GRID")

	//Titulos
	oView:EnableTitleView("VIEW_ZZA", "Pedro")
	oView:EnableTitleView("VIEW_ZZC", "Carga Metalica")

	//Adicionando campo incremental na grid
	oView:AddIncrementField("VIEW_ZZC", "ZZC_ITEM")

	//Removendo campos
	oStruFilho:RemoveField("ZZC_FILIAL")
	oStruFilho:RemoveField("ZZC_COD")

Return oView
