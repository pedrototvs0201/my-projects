
#Include "Totvs.ch"
#Include "FWMVCDef.ch"
 
//Variveis Estaticas
Static cTitulo := "Tabelas Genericas"
Static cAliasMVC := "SX5"
 
 //Funcao para cadastrar dados na tabela DJ da SX5
 //Autor: Gustavo Duia

User Function zCadSX5(cTabela, cTitTela)
    
    Local aArea      := FWGetArea()
    Local oBrowse
    Local aColunas   := {}
    
    Private aRotina  := {}
    Private cTabGen  := ""
    Default cTabela  := "DJ"
    Default cTitTela := ""
 
    //Somente se tiver tabela
    If !Empty(cTabela)

        //Atualiza a tabela em uso e o Título
        cTabGen := cTabela
        cTitulo := cTitTela

 
        //Se o Título tiver vazio, busca do cadastro do Cabecalho da tabela
        If Empty(cTitulo)
            cTitulo  := 'Tabela ' + cTabela
        EndIf
 
        //Definicao do menu
        aRotina := MenuDef()
 
        //Adiciona as colunas que vao ser apresentadas no browse
        aAdd(aColunas, { 'Codigo',    'X5_CHAVE',     'C',  TamSX3('X5_CHAVE')[1],  0, ''})
        aAdd(aColunas, { 'Descricao', 'X5_DESCRI',    'C',  TamSX3('X5_DESCRI')[1], 0, ''})
 
        //Instanciando o browse
        oBrowse := FWMBrowse():New()
        oBrowse:SetAlias(cAliasMVC)
        oBrowse:SetOnlyFields({"X5_FILIAL"})
        oBrowse:SetFields(aColunas)
        oBrowse:SetDescription(cTitulo)
        oBrowse:DisableDetails()
 
        //Filtrando conforme a tabela que veio
        oBrowse:SetFilterDefault("SX5->X5_TABELA == '" + cTabGen + "'")
 
        //Ativa a Browse
        oBrowse:Activate()
    EndIf
 
    FWRestArea(aArea)

Return Nil
 
/*/{Protheus.doc} MenuDef
Menu de opcoes na funcao zCadSX5
@author Atilio
@since 15/02/2024
@version 1.0
@type function
/*/
 
Static Function MenuDef()
    
    Local aRotina := {}
 
    //Adicionando opcoes do menu
    ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.zCadSX5" OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir" ACTION "VIEWDEF.zCadSX5" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar" ACTION "VIEWDEF.zCadSX5" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir" ACTION "VIEWDEF.zCadSX5" OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE "Copiar" ACTION "VIEWDEF.zCadSX5" OPERATION 9 ACCESS 0
 
Return aRotina
 
/*/{Protheus.doc} ModelDef
Modelo de dados na funcao zCadSX5
@author Atilio
@since 15/02/2024
@version 1.0
@type function
/*/
 
Static Function ModelDef()
    
    Local oStruct := FWFormStruct(1, cAliasMVC)
    Local oModel
    Local bPre := Nil
    Local bPos := {|| u_zSX5Vld()}
    Local bCancel := Nil
 
    //Editando caracterasticas do dicionario
    oStruct:SetProperty('X5_TABELA',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                       //Modo de Edicao
    oStruct:SetProperty('X5_TABELA',   MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'cTabGen'))                   //Ini PAdrao
    oStruct:SetProperty('X5_CHAVE',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    'Iif(INCLUI, .T., .F.)'))     //Modo de Edicao
    oStruct:SetProperty('X5_CHAVE',    MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'u_zSX5Vld()'))               //Validacao de Campo
    oStruct:SetProperty('X5_CHAVE',    MODEL_FIELD_OBRIGAT, .T. )                                                                //Campo Obrigatorio
    oStruct:SetProperty('X5_DESCRI',   MODEL_FIELD_OBRIGAT, .T. )                                                                //Campo Obrigatorio
 
    //Cria o modelo de dados para cadastro
    oModel := MPFormModel():New("zCadSX5M", bPre, bPos, /*bCommit*/, bCancel)
    oModel:AddFields("SX5MASTER", /*cOwner*/, oStruct)
    oModel:SetPrimaryKey({'X5_FILIAL', 'X5_TABELA', 'X5_CHAVE'})
    oModel:SetDescription("Modelo de dados - " + cTitulo)
    oModel:GetModel("SX5MASTER"):SetDescription( "Dados de - " + cTitulo)
    oModel:SetPrimaryKey({})
    
Return oModel
 
/*/{Protheus.doc} ViewDef
Visualizacao de dados na funcao zCadSX5
@author Atilio
@since 15/02/2024
@version 1.0
@type function
/*/
 
Static Function ViewDef()
    Local cCamposPrin := "X5_CHAVE|X5_DESCRI|"
    Local oModel := FWLoadModel("zCadSX5")
    Local oStructPrin := FWFormStruct(2, cAliasMVC, {|cCampo| AllTrim(cCampo) $ cCamposPrin})
    Local oStructOutr := FWFormStruct(2, cAliasMVC, {|cCampo| ! AllTrim(cCampo) $ cCamposPrin})
    Local oView
 
    //Retira as abas padrões
    oStructPrin:SetNoFolder()
    oStructOutr:SetNoFolder()
 
    //Altera o Título dos campos principais
    oStructPrin:SetProperty('X5_CHAVE',   MVC_VIEW_TITULO, 'Codigo')
    oStructPrin:SetProperty('X5_DESCRI',  MVC_VIEW_TITULO, 'Descricao')
 
    //Altera o Título dos outros campos
    oStructOutr:SetProperty('X5_TABELA',  MVC_VIEW_TITULO, 'Codigo Interno Tabela')
    oStructOutr:SetProperty('X5_DESCSPA', MVC_VIEW_TITULO, 'Descricao Espanhol')
    oStructOutr:SetProperty('X5_DESCENG', MVC_VIEW_TITULO, 'Descricao Inglês')
  
    //Cria a visualizacao do cadastro
    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_PRIN", oStructPrin, "SX5MASTER")
    oView:AddField("VIEW_OUTR", oStructOutr, "SX5MASTER")
  
    //Cria o controle de Abas
    oView:CreateFolder('ABAS')
    oView:AddSheet('ABAS', 'ABA_PRIN', 'Cadastro')
    oView:AddSheet('ABAS', 'ABA_OUTR', 'Outros Campos')
  
    //Cria os Box que serao vinculados as abas
    oView:CreateHorizontalBox('BOX_PRIN' ,100, /*owner*/, /*lUsePixel*/, 'ABAS', 'ABA_PRIN')
    oView:CreateHorizontalBox('BOX_OUTR' ,100, /*owner*/, /*lUsePixel*/, 'ABAS', 'ABA_OUTR')
  
    //Amarra as Abas aos Views de Struct criados
    oView:SetOwnerView('VIEW_PRIN', 'BOX_PRIN')
    oView:SetOwnerView('VIEW_OUTR', 'BOX_OUTR')
 
Return oView
 
/*/{Protheus.doc} zSX5Vld
Funcao que valida a digitaaao do campo Chave, para verificar se ja existe
@type function
@author Atilio
@since 15/02/2024
@version 1.0
/*/
  
User Function zSX5Vld()
    Local aArea    := GetArea()
    Local lRet     := .T.
    Local cX5Chave := FWFldGet("X5_CHAVE")
    Local oModel   := FWModelActive()
    Local nOper    := oModel:GetOperation()
 
    //Se for operacao de inclusao (ou a copia)
    If nOper == 3
      
        DbSelectArea('SX5')
        SX5->(DbSetOrder(1)) // X5_FILIAL+X5_TABELA+X5_CHAVE
        SX5->(DbGoTop())
         
        //Se conseguir posicionar, ja existe
        If SX5->(DbSeek(FWxFilial('SX5') + cTabGen + cX5Chave))
            ExibeHelp("Help", "Codigo ja existe!", "Informe um Codigo diferente.")
            lRet := .F.
        EndIf
    EndIf
      
    RestArea(aArea)
Return lRet
