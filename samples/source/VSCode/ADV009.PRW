//Bibliotecas
#Include "Totvs.ch"
#Include "FWMVCDef.ch"

//Variveis Estaticas
Static cTitulo := "Cadastro de Marca"
Static cAliasMVC := "ZZH"

/*/{Protheus.doc} User Function ADV001
Cadastro de Marcas
@author ANA MARÇAL
@since 25/09/2024
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

User Function ADV009()
	Local aArea   := FWGetArea()
	Local oBrowse
	Private aRotina := {}

	//Definicao do menu
	aRotina := MenuDef()

	//Instanciando o browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(cAliasMVC)
	oBrowse:SetDescription(cTitulo)

	//Ativa a Browse
	oBrowse:Activate()

	FWRestArea(aArea)
Return Nil

/*/{Protheus.doc} MenuDef
Menu de opcoes na funcao ADV001
@author ANA MARÇAL
@since 25/09/2024
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

Static Function MenuDef()
	Local aRotina := {}

	//Adicionando opcoes do menu
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.ADV009" OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir" ACTION "VIEWDEF.ADV009" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar" ACTION "VIEWDEF.ADV009" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir" ACTION "VIEWDEF.ADV009" OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE "Imprimir" ACTION "VIEWDEF.ADV009" OPERATION 8 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
Modelo de dados na funcao ADV001
@author ANA MARÇAL
@since 25/09/2024
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

Static Function ModelDef()
	Local oStruct := FWFormStruct(1, cAliasMVC)
	Local oModel
	Local bPre := Nil
	Local bCancel := Nil

	
	//Cria o modelo de dados para cadastro
	oModel := MPFormModel():New("ADV009M", bPre, /*bCommit*/, bCancel)
	oModel:AddFields("ZZHMASTER", /*cOwner*/, oStruct)
	oModel:SetDescription("Modelo de dados - " + cTitulo)
	oModel:GetModel("ZZHMASTER"):SetDescription( "Dados de - " + cTitulo)
	oModel:SetPrimaryKey({})
Return oModel

/*/{Protheus.doc} ViewDef
Visualizacao de dados na funcao ADV001
@author ANA MARÇAL
@since 25/09/2024
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

Static Function ViewDef()
	Local oModel := FWLoadModel("ADV009")
	Local oStruct := FWFormStruct(2, cAliasMVC)
	Local oView

	//Cria a visualizacao do cadastro
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_ZZH", oStruct, "ZZHMASTER")
	oView:CreateHorizontalBox("TELA" , 80 )
	oView:SetOwnerView("VIEW_ZZH", "TELA")

Return oView
