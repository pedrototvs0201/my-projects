    #Include "FWMVCDef.CH"
    #Include "FWBROWSE.CH"
    #Include "TopConn.CH"
    #Include "PROTHEUS.CH"
    #Include "RWMAKE.CH"
    #Include "FONT.CH"
    #Include "COLORS.CH"
    #Include "TOTVS.CH"
    #Include "TBICONN.CH"
    #Include "FileIO.CH" 
    #Include "RPTDef.ch"
    #Include "FWPrintSetup.ch"


    #DEFINE ENTER CHR(13)+CHR(10) 
    #Define STR0001 "Processado com sucesso"
    #Define STR0014 "Processar"
    #Define STR0015 "Processar"
    #Define STR0016 "Processar"    
    //Variáveis estáticas

    Static cTitulo := "Manutenção da cobrança"
    //+----------------------------------------------------------------------+//
        //+ Desenvolvido por: Givanildo de Rezende          Em: 15/10/2024   +//
        //+------------------------------------------------------------------+//
        // Manutenção da cobrança                                       //
        //                                                                    //
        //                                                                    //
        //+------------------------------------------------------------------+//
        //--------------------------------------------------------------------//
        // Revisoes                | Givanildo  	          | 15/10/2024    //
        //--------------------------------------------------------------------//
        //  CAMPOS PERSONALIZADOS  |  PARAMETROS              | GATILHO       //
        //  =======================|==========================|===============//
        //  				       |   			              |               //
        //  				       |                          |               //
        //--------------------------------------------------------------------//
    //-

User Function TCOM271()
    Local aArea       := GetArea()


    Private oBrowse

    //Instanciando FWMBrowse - Somente com dicionario de dados
    oBrowse := FWMBrowse():New()

    //Setando a tabela de propostas
    oBrowse:SetAlias("SE1")
    //Setando a descricao da rotina 
    
    // Indica a opção do Browse a ser executada no duplo clique no item
    oBrowse:SetExecuteDef(1)

     // Adicionar a legenda no browse
    oBrowse:AddLegend("EMPTY(ALLTRIM(DTOS(E1_BAIXA))) .and. EMPTY(E1_NUMBCO)"                           ,"GREEN" ,"Aguardando a geração do boleto"                     ,"1")
    oBrowse:AddLegend("EMPTY(ALLTRIM(DTOS(E1_BAIXA))) .and. !EMPTY(E1_NUMBCO) .AND. EMPTY(E1_NUMBOR)"   ,"YELLOW" ,"Boleto gerado, aguardando gerar bordero"           ,"1")
    oBrowse:AddLegend("EMPTY(ALLTRIM(DTOS(E1_BAIXA))) .and. !EMPTY(E1_NUMBCO) .AND. !EMPTY(E1_NUMBOR)"  ,"BLUE"   ,"Boleto gerado, bordero gerado"                     ,"1")
    oBrowse:AddLegend("!EMPTY(ALLTRIM(DTOS(E1_BAIXA)))"                                                 ,"RED"    ,"Titulo baixado"                                    ,"1")

    oBrowse:SetDescription(cTitulo)
    //Ativa a Browse
    oBrowse:Activate()
     
    RestArea(aArea)
Return Nil 
//----------------------------------------------- quebra da rotina ------------------------------------------------------//
 
Static Function MenuDef()
    Local aRot     := {}

    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar'                          ACTION 'VIEWDEF.TCOM271' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 
    ADD OPTION aRot TITLE 'Gerar boleto Pdf'                    ACTION 'u_TCOM271A()'    OPERATION MODEL_OPERATION_VIEW   ACCESS 9 
    ADD OPTION aRot TITLE 'Cancelar boleto'                     ACTION 'u_TCOM271B()'    OPERATION MODEL_OPERATION_VIEW   ACCESS 9 
    ADD OPTION aRot TITLE 'Estatistica de cobranca'             ACTION 'u_TCOM271G()'    OPERATION MODEL_OPERATION_VIEW   ACCESS 9 
    ADD OPTION aRot TITLE 'Bordero de cobranca'                 ACTION 'u_TCOM271H()'    OPERATION MODEL_OPERATION_VIEW   ACCESS 9 
Return aRot
//----------------------------------------------- quebra da rotina ------------------------------------------------------//

User Function TCOM271A() // Gerar Boleto
    Local aArea := FWGetArea()
    Local aPergs   := {}
    Local aPergsB  := {}
    Local aRet     := {}
    Local aRetB    := {}
    Local cQryDados := ""
    Local aCampos   := {}
    Local nk := 0
    Local cDescricao := "Gerar Boleto de Cobrança"
    Local cTituloTel := "Seleção de Títulos para Cobrança"
    Local aBuscaCol     := {"E1_FILIAL","E1_PREFIXO","E1_NUM","E1_PARCELA","E1_TIPO"}
    Local cCampoAux := "E1_NUM"

    Private aStruTRB := {}
    Private oDlgMark
    Private oPanGrid
    Private oMarkBrowse
    Private cAliasTmp := GetNextAlias()
    Private oTempTable
    Private lRet := .f.
	Private aBoleto :={}
    Private cFaxAtu := ""

    //Adicionando os parametros do ParamBox
    aAdd(aPergs, {1, "Emissão De" , Stod('')   ,  "", ".T.", "", ".T.", 50,  .F.})
    aAdd(aPergs, {1, "Emissão Até", dDataBase  ,  "", ".T.", "", ".T.", 50,  .T.})
    aAdd(aPergs, {1, "Prefixo De" , Space(3)   ,  "", ".T.", "", ".T.", 30,  .F.})
    aAdd(aPergs, {1, "Prefixo Até", "ZZZ"      ,  "", ".T.", "", ".T.", 30,  .T.})
    aAdd(aPergs, {1, "Número De"  , Space(9)   ,  "", ".T.", "", ".T.", 50,  .F.})
    aAdd(aPergs, {1, "Número Até" , "ZZZZZZZZZ",  "", ".T.", "", ".T.", 50,  .T.})
    aAdd(aPergs, {1, "Parcela De" , Space(2)   ,  "", ".T.", "", ".T.", 30,  .F.})
    aAdd(aPergs, {1, "Parcela Até", "ZZ"       ,  "", ".T.", "", ".T.", 30,  .T.})
    aAdd(aPergs, {1, "Tipo De"    , Space(3)   ,  "", ".T.", "", ".T.", 30,  .F.})
    aAdd(aPergs, {1, "Tipo Até"   , "ZZZ"      ,  "", ".T.", "", ".T.", 30,  .T.})
    aAdd(aPergs, {1, "Vencimento De" , Stod('')   ,  "", ".T.", "", ".T.", 50,  .F.})
    aAdd(aPergs, {1, "Vencimento Até", dDataBase+60  ,  "", ".T.", "", ".T.", 50,  .T.})
      
    //Se a pergunta for confirma, chama a tela
    If ParamBox(aPergs, "Informe os parametros",aRet)
        //Monta a consulta
        cQryDados += "SELECT E1_FILIAL"
        cQryDados += " ,E1_PREFIXO"
        cQryDados += " ,E1_NUM"
        cQryDados += " ,E1_PARCELA"
        cQryDados += " ,E1_TIPO   "
        cQryDados += " ,E1_NATUREZ"
        cQryDados += " ,E1_PORTADO"
        cQryDados += " ,E1_AGEDEP"
        cQryDados += " ,E1_CONTA" 
        cQryDados += " ,E1_CLIENTE"
        cQryDados += " ,E1_LOJA"
        cQryDados += " ,E1_NOMCLI "
        cQryDados += " ,E1_EMISSAO"
        cQryDados += " ,E1_VENCTO "
        cQryDados += " ,E1_VENCREA"
        cQryDados += " ,E1_VALOR"
        cQryDados += " ,E1_NUMBCO"
        cQryDados += " ,E1_NUMBOR"
        cQryDados += " ,E1_IDCNAB"
        cQryDados += " ,E1_CODBAR"+ CRLF
        cQryDados += " FROM "+RetSqlName("SE1")+ " SE1 "        + CRLF
        cQryDados += " WHERE SE1.D_E_L_E_T_ <> '*' "+ CRLF
		cQryDados += " AND SE1.E1_FILIAL = '"+XFILIAL('SE1')+"'"+ CRLF
		cQryDados += " AND E1_EMISSAO >= '" + DtoS(aRet[01]) + "' AND E1_EMISSAO <= '" + DtoS(aRet[02]) + "' "+ CRLF
        cQryDados += " AND E1_PREFIXO >= '" + aRet[03] + "' AND E1_PREFIXO <= '" + aRet[04] + "' "+ CRLF
        cQryDados += " AND E1_NUM     >= '" + aRet[05] + "' AND E1_NUM     <= '" + aRet[06] + "' "+ CRLF
        cQryDados += " AND E1_PARCELA >= '" + aRet[07] + "' AND E1_PARCELA <= '" + aRet[08] + "' "+ CRLF
        cQryDados += " AND E1_TIPO    >= '" + aRet[09] + "' AND E1_TIPO    <= '" + aRet[10] + "' "+ CRLF
        cQryDados += " AND E1_VENCREA >= '" + DtoS(aRet[11]) + "' AND E1_VENCREA <= '" + DtoS(aRet[12]) + "' "+ CRLF
        cQryDados += " AND E1_BAIXA   = ''" + CRLF
		cQryDados += " AND E1_TIPO NOT IN('RA','NCC','CH','AB-')"+ CRLF
        cQryDados += " ORDER BY 1,2,3,4,5 "
        //Consulta os dados - SQL
        Processa({|| fConsSQL(cQryDados)}, 'Consultando dados...')

        //Adiciona as colunas que serão criadas na temporária
        aAdd(aCampos, { 'OK', 'C', 2, 0}) //Flag para marcação
        For nK:= 1 to Len(aStruTRB)
            aAdd(aCampos, aStruTRB[nk])
        Next

        u_fMontaTela(cTituloTel, cDescricao, aStruTRB, aCampos, aBuscaCol, cCampoAux)
        
        If lRet
            aPergsB    :={}
            aAdd(aPergsB, {1, "Banco"      , Space(3)   ,  "", ".T.", "SEE", ".T.", 30,  .T.})
            aAdd(aPergsB, {1, "Agência"    , Space(5)   ,  "", ".T.", "", ".F.", 30,  .T.})
            aAdd(aPergsB, {1, "Conta"      , Space(10)  ,  "", ".T.", "", ".F.", 50,  .T.})
            aAdd(aPergsB, {1, "SubConta"   , Space(3)   ,  "", ".T.", "", ".F.", 30,  .T.})
            aAdd(aPergsB, {2, "Banco a considerar",      "1", {"1=Informado acima", "2=Do cadastro do cliente"},090, ".T.", .F.})
            aAdd(aPergsB, {2, "Gerar Arquivo"     ,      "1", {"1=Único", "2=Por Documento"},090, ".T.", .F.})
			aAdd(aPergsB, {2, "Visualizar Arquivo",      "1", {"1=Sim", "2=Não"},090, ".T.", .F.})

            //Se a pergunta for confirma, chama a tela
            If ParamBox(aPergsB, "Informe os parametros",aRetB,,,,,,,,.F.,)
				cChvSA6 := XFILIAL("SA6")+aRetB[1]+aRetB[2]+aRetB[3]
				cBcoOfi := Posicione("SA6",1,cChvSA6,"A6_BCOOFI")
				If !Empty(Alltrim(cBcoOfi))
					MsgStop("Os parametros informados só pode ser utilizado para gerar boleto on-line! Verifique...","Parametros de banco")
					Return.f.
				Else
                	Processa({|| fProcessa(aRetB)}, 'Processando...')
				EndIf
            EndIf
        EndIf
    EndIf
    If TYPE('oTempTable') == "O"
        oTempTable:Delete()  
    EndIf
    FWRestArea(aArea)
    oBrowse:Refresh()
Return
//----------------------------------------------- quebra da rotina ------------------------------------------------------//

Static Function ModelDef()
    //Criação do objeto do modelo de dados
    Local oModel := Nil
     
    //Criação da estrutura de dados utilizada na interface
    Local oStSE1 := FWFormStruct(1, "SE1")
     
    //Editando caracterÃ­sticas do dicionÃ¡rio

    //Instanciando o modelo, nao e recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("TCOM271M",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
     
    //Atribuindo formularios para o modelo
    oModel:AddFields("FORMSE1",/*cOwner*/,oStSE1)
     
    //Setando a chave primaria da rotina
    oModel:SetPrimaryKey({'E1_FILIAL','E1_PREFIXO','E1_NUM','E1_PARCELA','E1_TIPO'})
     
    //Adicionando descricao ao modelo
    oModel:SetDescription("Contas a Receber")
     
    //Setando a descricao do formulÃ¡rio
    oModel:GetModel("FORMSE1"):SetDescription("Contas a Receber")
 
Return oModel
//----------------------------------------------- quebra da rotina ------------------------------------------------------//

Static Function ViewDef()
     
    //Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
    Local oModel := FWLoadModel("TCOM271")
     
    //Criação da estrutura de dados utilizada na interface do cadastro de Autor
    Local oStSE1 := FWFormStruct(2, "SE1")  //pode se usar um terceiro parÃ¢metro para filtrar os campos exibidos { |cCampo| cCampo $ 'SE1_NOME|SE1_DTAFAL|'}
     
    //Criando oView como nulo
    Local oView := Nil
 
    //Criando a view que sera o retorno da funcao e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Atribuindo formularios para interface
    oView:AddField("VIEW_SE1", oStSE1, "FORMSE1")
     
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
     
    //Colocando titulo do formulario
    oView:EnableTitleView('VIEW_SE1', "Contas a Receber" )  
     
    //Forca o fechamento da janela na confirmacao
    oView:SetCloseOnOk({||.T.})
     
    //O formulario da interface sera colocado dentro do container
    oView:SetOwnerView("VIEW_SE1","TELA")
     
Return oView
//----------------------------------------------- quebra da rotina ------------------------------------------------------//
Static Function fConsSQL(cQryDados)
    PLSQuery(cQryDados, 'QRYTRB')
  
    //Definindo o tamanho da régua
    DbSelectArea('QRYTRB')
    aStruTRB := DBStruct()
Return
//----------------------------------------------- quebra da rotina ------------------------------------------------------//
User Function fMontaTela(cTituloTel, cDescricao, aStruTRB, aCampos, aBuscaCol, cCampoAux)
    Local aArea         := GetArea()
    //Local oTempTable := Nil
    Local aColunas := {}
    Local cFontPad    := 'Tahoma'
    Local oFontGrid   := TFont():New(cFontPad,,-14)
    

    //Janela e componentes
    Private aRotina   := MenuDefX()
    //Tamanho da janela
    Private aTamanho := MsAdvSize()
    Private nJanLarg := aTamanho[5]
    Private nJanAltu := aTamanho[6]

  
    //Cria a tabela temporária
    oTempTable:= FWTemporaryTable():New(cAliasTmp)
    oTempTable:SetFields( aCampos )
    oTempTable:AddIndex("1", aBuscaCol )
    oTempTable:Create()  
  
    //Popula a tabela temporária
    Processa({|| fPopula()}, 'Processando...')
  
    //Adiciona as colunas que serão exibidas no FWMarkBrowse
    aColunas := fCriaCols(aStruTRB)
  
    aSeek := {}
    aAdd(aSeek,{GetSX3Cache(cCampoAux, "X3_TITULO"), {{"", GetSX3Cache(cCampoAux, "X3_TIPO"), GetSX3Cache(cCampoAux, "X3_TAMANHO"), GetSX3Cache(cCampoAux, "X3_DECIMAL"), AllTrim(GetSX3Cache(cCampoAux, "X3_TITULO")), AllTrim(GetSX3Cache(cCampoAux, "X3_PICTURE"))}} } )
       
    //Criando a janela
    DEFINE MSDIALOG oDlgMark TITLE cTituloTel FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
        //Dados
        oPanGrid := tPanel():New(001, 001, '', oDlgMark, , , , RGB(000,000,000), RGB(254,254,254), (nJanLarg/2)-1,     (nJanAltu/2 - 1))
        oMarkBrowse:= FWMarkBrowse():New()
        oMarkBrowse:SetDescription(cDescricao) //Titulo da Janela
        oMarkBrowse:SetAlias(cAliasTmp)
        oMarkBrowse:oBrowse:SetDBFFilter(.T.)
        oMarkBrowse:oBrowse:SetUseFilter(.F.) //Habilita a utilização do filtro no Browse
        oMarkBrowse:oBrowse:SetFixedBrowse(.T.)
        oMarkBrowse:SetWalkThru(.F.) //Habilita a utilização da funcionalidade Walk-Thru no Browse
        oMarkBrowse:SetAmbiente(.T.) //Habilita a utilização da funcionalidade Ambiente no Browse
        oMarkBrowse:SetTemporary(.T.) //Indica que o Browse utiliza tabela temporária
        oMarkBrowse:oBrowse:SetSeek(.T.,aSeek) //Habilita a utilização da pesquisa de registros no Browse
        oMarkBrowse:oBrowse:SetFilterDefault("") //Indica o filtro padrão do Browse
        oMarkBrowse:SetFieldMark('OK')
        oMarkBrowse:SetFontBrowse(oFontGrid)
        oMarkBrowse:SetOwner(oPanGrid)
        oMarkBrowse:SetColumns(aColunas)
        oMarkBrowse:Activate()
    ACTIVATE MsDialog oDlgMark CENTERED
  
    oMarkBrowse:DeActivate()
      
    RestArea(aArea)
Return
//----------------------------------------------- quebra da rotina ------------------------------------------------------//
Static Function fCriaCols(aStruTRB)
    Local nAtual       := 0 
    Local aColunas := {}
    Local aEstrut  := {}
    Local oColumn
    Local nK := 0
      
    //Adicionando campos que serão mostrados na tela
    //[1] - Campo da Temporaria
    //[2] - Titulo
    //[3] - Tipo
    //[4] - Tamanho
    //[5] - Decimais
    //[6] - Máscara
    For nK:= 1 to Len(aStruTRB)
        aAdd(aEstrut, { aStruTRB[nk,1], GetSX3Cache(aStruTRB[nk,1], "X3_TITULO"), aStruTRB[nk,2], aStruTRB[nk,3], aStruTRB[nk,4], GetSX3Cache(aStruTRB[nk,1], "X3_PICTURE"), IIF(ALLTRIM(aStruTRB[nk,2])=="N",2,iif(ALLTRIM(aStruTRB[nk,2])=="D",0,1)), aStruTRB[nk,4] })
    Next
  
    //Percorrendo todos os campos da estrutura
    For nAtual := 1 To Len(aEstrut)
        //Cria a coluna
        oColumn := FWBrwColumn():New()
        oColumn:SetData(&('{|| ' + cAliasTmp + '->' + aEstrut[nAtual][1] +'}'))
        oColumn:SetTitle(aEstrut[nAtual][2])
        oColumn:SetType(aEstrut[nAtual][3])
        oColumn:SetSize(aEstrut[nAtual][4])
        oColumn:SetDecimal(aEstrut[nAtual][5])
        oColumn:SetPicture(aEstrut[nAtual][6])
        oColumn:SetAlign(aEstrut[nAtual][7])
        //Adiciona a coluna
        aAdd(aColunas, oColumn)
    Next
Return aColunas
//----------------------------------------------- quebra da rotina ------------------------------------------------------//
Static Function fProcessa(aRet)
    Local aArea     := FWGetArea()
    Local cMarca    := oMarkBrowse:Mark()
    Local nAtual    := 0
    Local nTotal    := 0
    Local nTotMarc  := 0
    Local lPreview  := iif(aRet[7]=="1",.t.,.f.)
    
    //Define o tamanho da régua
    DbSelectArea(cAliasTmp)
    (cAliasTmp)->(DbGoTop())
    Count To nTotal
    ProcRegua(nTotal)
      
    //Percorrendo os registros
    (cAliasTmp)->(DbGoTop())
    While ! (cAliasTmp)->(EoF())
        nAtual++
        IncProc('Analisando registro ' + cValToChar(nAtual) + ' de ' + cValToChar(nTotal) + '...')
      
        //Caso esteja marcado
        If oMarkBrowse:IsMark(cMarca)
            nTotMarc++
            If aRet[5] == "1"
                cSerie      := (cAliasTmp)->(E1_PREFIXO)
                cNota       := (cAliasTmp)->(E1_NUM)
                cParc       := (cAliasTmp)->(E1_PARCELA)
                cTipo       := (cAliasTmp)->(E1_TIPO)
                cBanco      := aRet[1]
                cAgencia    := aRet[2]
                cConta      := aRet[3] 
                cSubConta   := aRet[4] 
            Else
                cChvSA1 :=  xFilial("SA1")+(cAliasTmp)->(E1_CLIENTE+E1_LOJA)
                // Posicionar no cadastro de cliente
                SA1->(DbSetOrder(1))
                SA1->(DbGoTop())
                SA1->(DbSeek(cChvSA1))

                cSerie      := (cAliasTmp)->(E1_PREFIXO)
                cNota       := (cAliasTmp)->(E1_NUM)
                cParc       := (cAliasTmp)->(E1_PARCELA)
                cTipo       := (cAliasTmp)->(E1_TIPO)
                If !Empty(Alltrim(SA1->A1_XBCOCOB))
                    cBanco      := SA1->A1_XBCOCOB
                    cAgencia    := SA1->A1_XAGECOB
                    cConta      := SA1->A1_XCTACOB 
                    cSubConta   := SA1->A1_XSUBCOB
                Else
                    cBanco      := aRet[1]
                    cAgencia    := aRet[2]
                    cConta      := aRet[3] 
                    cSubConta   := aRet[4]
                EndIf
            EndIf
            TCOM271C(cSerie,cNota,cParc,cTipo,cBanco,cAgencia,cConta,cSubConta,lPreview)
        EndIf
           
        (cAliasTmp)->(DbSkip())
    EndDo

    If Len(aBoleto) > 0
        GrvDados() // Gravar o nosso número e o Codigo de Barras nos títulos 
        Imprimir(lPreview,aRet) // Gerar o pdf dos boletos
        If !lPreview
			MsgInfo("Boleto(s) gerado com sucesso!"+chr(13)+;
                    "Acesse a pasta: C:\Totvs_relatorio\boletos\","Geração de boleto de cobrança")
		EndIf
    EndIf
      
    FWRestArea(aArea)
Return
//----------------------------------------------- quebra da rotina ------------------------------------------------------//
Static Function fPopula()
    Local nTotal := 0
    Local nAtual := 0
    Local nK     := 0
    
    //Definindo o tamanho da régua
    DbSelectArea('QRYTRB')
    Count to nTotal
    ProcRegua(nTotal)
    QRYTRB->(DbGoTop())
  
    //Enquanto houver registros, adiciona na temporária
    While ! QRYTRB->(EoF())
        nAtual++
        IncProc('Analisando registro ' + cValToChar(nAtual) + ' de ' + cValToChar(nTotal) + '...')
  
        RecLock(cAliasTmp, .T.)
         (cAliasTmp)->OK := Space(2)
         
         For nK:=1 to Len(aStruTRB)
             cCampo := aStruTRB[nK,1]
             (cAliasTmp)->&cCampo := QRYTRB->&cCampo
         Next
        (cAliasTmp)->(MsUnlock())
  
        QRYTRB->(DbSkip())
    EndDo
    QRYTRB->(DbCloseArea())
    (cAliasTmp)->(DbGoTop())
Return
//----------------------------------------------- quebra da rotina ------------------------------------------------------//
Static Function MenuDefX()
    Local aRotina := {}
       
    //Criação das opções
    ADD OPTION aRotina TITLE 'Confirmar'  ACTION 'u_TCOM271OK'     OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Sair'       ACTION 'u_TCOM271SA'     OPERATION 2 ACCESS 0
Return aRotina
//----------------------------------------------- quebra da rotina ------------------------------------------------------//
User Function TCOM271OK() // Confirmar
    lRet := .T.
    oDlgMark:End()
Return
//----------------------------------------------- quebra da rotina ------------------------------------------------------//
User Function TCOM271SA() // Sair
    lRet := .F.
    oDlgMark:End()
Return
//----------------------------------------------- quebra da rotina ------------------------------------------------------//
User Function TCOM271B
	If Empty(Alltrim(SE1->E1_NUMBCO))
		MsgStop("Não foi gerado boleto para este título, verifique...","Cancelar Boleto")
		Return.f.
	EndIf

	If MsgYesNo("Confirma o cancelamento do boleto selecionado?")
		If !EMPTY(ALLTRIM(SE1->E1_NUMBOR))
		    Alert("Você precisa retirar o título do bordero" + chr(13)+;
		    	  "Antes de cancela-lo!!!!","Cancelar Boleto")
		    Return.f.
		Else
			Begin Transaction
			    //Iniciar transacao para gravar os dados
				// Atualizar os dados do título
				RecLock("SE1",.F.)
				// Gravar o Codigo Barras
    			SE1->E1_NUMBCO  := ""
		        // Calcular o Codigo Barras
				SE1->E1_CODBAR  := ""
		        // Calcular a linha Digitavel
                SE1->E1_PORTADO := ""
                SE1->E1_AGEDEP  := ""
                SE1->E1_CONTA   := ""
				SE1->E1_IDCNAB  := ""
		        MsUnlock()
			End Transaction
            MsgInfo("Processo executado com sucesso!")
            oBrowse:Refresh()
		EndIf
	EndIf
Return
//----------------------------------------------- quebra da rotina ------------------------------------------------------//
//+------------------------------------------------------------------+//
//+ Desenvolvido por: Givanildo de Rezende          Em: 03/02/2021   +//
//+------------------------------------------------------------------+//
// GERAR BOLETOS EM PDF A PARTIR DA SERIE + NOTA FISCAL               //
//+------------------------------------------------------------------+//
// Revisoes                    | Givanildo            | 04/11/2016    //
// Revisoes                    | Givanildo            | 15/10/2024    //
//--------------------------------------------------------------------//
//  CAMPOS PERSONALIZADOS  |  PARAMETROS              | GATILHO       //
//  =======================|==========================|===============//
//  EE_XACEITE C(1)        |   MV_XIDCNAB             |               //
//  EE_XESPECI C(2)        |                          |               //
//  E1_NUMBCO C(20)        |                          |               //
//--------------------------------------------------------------------//
//-
Static Function TCOM271C(cSerie,cNota,cParc,cTipo,cBanco,cAgencia,cConta,cSubConta,lPreview)
    Local cNossoNum := ""
    Local cCodBarra := ""
    Local cLinDigit := ""

	Default cParc := Space(2)
	Default cTipo := "NF"

    // Posicionar nos titulos e verificar se já foram emitidos SE1->E1_NUMBCO
    dbSelectArea("SE1")
    dbSetOrder(1)
    dbGoTop()
    dbSeek(XFILIAL("SE1")+cSerie+cNota+cParc+cTipo)
    If Found()
		// Posicionar no cadastro de cliente
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbGoTop()
		DbSeek(xFilial("SA1")+ SE1->E1_CLIENTE+ SE1->E1_LOJA)
                
        Do While SE1->(!Eof()) .and. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) == XFILIAL("SE1")+cSerie+cNota+cParc+cTipo
            // Notas a vista não gera boleto
            If SE1->E1_VENCREA <> SE1->E1_EMISSAO .AND. SE1->E1_VENCTO <> SE1->E1_EMISSAO
                cNossoNum := ""
                If !Empty(AllTrim(SE1->E1_NUMBCO))

                    cBanco    := SE1->E1_PORTADO
                    cAgencia  := SE1->E1_AGEDEP
                    cConta    := SE1->E1_CONTA
                    cSubConta := "001"
                    cNossoNum := SE1->E1_NUMBCO
                    cChvSEE   := cBanco+cAgencia+cConta+Alltrim(cSubConta)

                    dbSelectArea("SEE")
                    dbSetOrder(1)
                    dbGoTop()
                    If !dbSeek(XFILIAL("SEE")+cChvSEE)
                        MsgStop("Parametro não encontrado! Verifique..."+chr(13)+;
                                "Banco: "+ cBanco + chr(13)+;
                                "Agencia: "+ cAgencia + chr(13)+;
                                "Conta: "+ cConta + chr(13)+;
                                "Subconta: "+ cSubConta,;
                                "Tabela SEE" )
                        Return.f.
                    EndIf

                    cCodBarra := TCOM271E(cBanco,cAgencia,cConta,cSubConta,cNossoNum) // Calcula o Codigo de barras
                    cLinDigit := TCOM271F(cCodBarra) // Calcula a Linha Digitavel                
                Else
                    cNossoNum := TCOM271D(cBanco,cAgencia,cConta,cSubConta) // calcula o Nosso Numero
                    cCodBarra := TCOM271E(cBanco,cAgencia,cConta,cSubConta,cNossoNum) // Calcula o Codigo de barras
                    cLinDigit := TCOM271F(cCodBarra) // Calcula a Linha Digitavel
                EndIf
                AddBoleto(cBanco,cAgencia,cConta,cSubConta,cNossoNum,cCodBarra,cLinDigit)// Adiciona as informaçoes no array aBoleto
            EndIf
            SE1->(dbSkip())
        EndDo
    Else
        If lPreview 
			Alert("Não foi localizado Título para esta nota!!!")
		EndIf
        Return.f.
    EndIf
Return
//--------------------------------------------------------------------------------------//
// Calcular o nosso número
//--------------------------------------------------------------------------------------//
Static Function TCOM271D(cBanco,cAgencia,cConta,cSubConta)
    Local cNossoNum := ""
    Local cChvSEE   := cBanco+cAgencia+cConta+Alltrim(cSubConta)

	dbSelectArea("SEE")
	dbSetOrder(1)
	dbGoTop()
	dbSeek(XFILIAL("SEE")+cChvSEE)
	If !Found()
		Alert("Não foi localizada esta subconta!")
		Return.f.	
	EndIf

	Do Case
		Case TRIM(cBanco) == "001" // Brasil  
			If Empty(Alltrim(cFaxAtu)) // Faixa atual
          		cFaxAtu := StrZero(val(SEE->EE_FAXATU),10)
			EndIf
			cFaxAtu = Soma1(cFaxAtu)
            If Len(Alltrim(SEE->EE_CODEMP)) == 7 // Convenio com 7 posições
                cNossoNum := Alltrim(StrZero(Val(SEE->EE_CODEMP),7)) + cFaxAtu
            Else
                cNossoNum := cFaxAtu
            EndIf 
            
		Case TRIM(cBanco) == "033" // Santander 
            If Empty(Alltrim(cFaxAtu)) // Faixa atual
                cFaxAtu := StrZero(val(SEE->EE_FAXATU),10)
            EndIf
            cFaxAtu = Soma1(cFaxAtu)
			_cNNumSDV := alltrim(StrZero(Val(cFaxAtu),12))
			cCpoInv   := InvSTR(_cNNumSDV) // inverter a ordem (de tras pra frente) 
			_cDVNNum  := CalMod11(cCpoInv,"23456789","10") // Base 9

 	       cNossoNum := Alltrim(_cNNumSDV) + alltrim(_cDVNNum)

		Case TRIM(cBanco) == "104" // Caixa 
			cCodCart := StrZero(Val(SEE->EE_CODCART),2)
			cFaxIni  := StrZero(val(SEE->EE_FAXINI),6) // particularidade da CAIXA
		    If Empty(Alltrim(cFaxAtu)) // Faixa atual
                cFaxAtu := StrZero(val(SEE->EE_FAXATU),09)
            EndIf
            cFaxAtu = Soma1(cFaxAtu)
			// CCNNNNNNNNNNNNNNN, onde CC = 14 (título Registrado, emissão Beneficiário)
 	        cNossoNum := cCodCart + cFaxIni + cFaxAtu

		Case TRIM(cBanco) == "237" // Bradesco  
            If Empty(Alltrim(cFaxAtu)) // Faixa atual
                cFaxAtu := StrZero(val(SEE->EE_FAXATU),10)
            EndIf
            cFaxAtu = Soma1(cFaxAtu)
			_cNNumSDV := alltrim(StrZero(Val(cFaxAtu),11))
			_cCodCart := StrZero(Val(SEE->EE_CODCART),2)
			cCpoInv   := InvSTR(_cCodCart + _cNNumSDV) // inverter a ordem (de tras pra frente) 
			_cDVNNum  := CalMod11(cCpoInv,"234567","P0") // Base 7

 	       cNossoNum := Alltrim(_cNNumSDV) + alltrim(_cDVNNum)

		Case TRIM(cBanco) == "341" // Itau
            If Empty(Alltrim(cFaxAtu)) // Faixa atual
                cFaxAtu := StrZero(val(SEE->EE_FAXATU),10)
            EndIf
            cFaxAtu = Soma1(cFaxAtu)  

		    _cAgencia := StrZero(Val(SEE->EE_AGENCIA),4)   // Agencia - 4
		    _cConta   := StrZero(Val(SEE->EE_CONTA),5)     // Conta - 5
			_cCodCart := StrZero(Val(SEE->EE_CODCART),3)   // Carteira - 3
			_cNNumSDV := StrZero(Val(cFaxAtu),8)  // Nosso Número - 8
			_cDados	  := Alltrim(_cAgencia) + Alltrim(_cConta) + Alltrim(_cCodCart) + Alltrim(_cNNumSDV)
			_cDVNNum  := CalMod10(_cDados)
			                                                                             	
			cNossoNum := _cNNumSDV + _cDVNNum

		Case TRIM(cBanco) == "707" // Daycoval
            If Empty(Alltrim(cFaxAtu)) // Faixa atual
                cFaxAtu := StrZero(val(SEE->EE_FAXATU),10)
            EndIf
            cFaxAtu = Soma1(cFaxAtu)  

		    _cAgencia := StrZero(Val(SEE->EE_AGENCIA),4)   // Agencia - 4
		    _cConta   := StrZero(Val(SEE->EE_CONTA),5)     // Conta - 5
			_cCodCart := StrZero(Val(SEE->EE_CODCART),3)   // Carteira - 3
			_cNNumSDV := StrZero(Val(cFaxAtu),8)  // Nosso Número - 8
			_cDados	  := Alltrim(_cAgencia) + Alltrim(_cConta) + Alltrim(_cCodCart) + Alltrim(_cNNumSDV)
			_cDVNNum  := CalMod10(_cDados)
			                                                                             	
			cNossoNum := _cNNumSDV + _cDVNNum

		Case TRIM(cBanco) == "756" // Sicoob 
            If Empty(Alltrim(cFaxAtu)) // Faixa atual
                cFaxAtu := StrZero(val(SEE->EE_FAXATU),10)
            EndIf
            cFaxAtu = Soma1(cFaxAtu)  

		    _cAgencia := ALLTRIM(SEE->EE_AGENCIA)   // 4
		    _cConta   := StrZero(Val(SEE->EE_CODEMP),10)   // 10//StrZero(Val(SA6->A6_NUMCON),9)+ ALLTRIM(SA6->A6_DVCTA)   // 10
			_cNNumSDV := alltrim(StrZero(Val(cFaxAtu),7)) //7
			_cDados	  := Alltrim(_cAgencia) + Alltrim(_cConta) + Alltrim(_cNNumSDV)
			_cDVNNum  := CalMod11(_cDados,"3197","00")
			                                                                             	
			cNossoNum := alltrim(StrZero(Val(_cNNumSDV),10))+ _cDVNNum
 	EndCase

    // Atualizar o auto incremento
    dbSelectArea("SEE")
    RecLock("SEE",.F.)
    SEE->EE_FAXATU := cFaxAtu
    MsUnlock()

Return(cNossoNum)
//------------------------------------------------------- quebra da funcao ------------------------------------------------//

//--------------------------------------------------------------------------------------//
// Inverter a ordem dos caracteres na string
//--------------------------------------------------------------------------------------//
Static Function InvSTR(cDados)
    Local cDadoInv := ""
	Local nK	 := 0   
    For nk:=Len(cDados) to 1 Step -1
	   cDadoInv += Substr(cDados,nk,1)
	Next
Return(cDadoInv)
//------------------------------------------------------- quebra da funcao ------------------------------------------------//

//--------------------------------------------------------------------------------------//
// Calcular o Modulo 11
//--------------------------------------------------------------------------------------//
Static Function CalMod11(cDados,cKonst,cRest1011)
	Local cX     := ""
	Local nCt    := 0
	Local nLen   := Len(Alltrim(cDados))
	Local nAcum  := 0
	Local nPeso  := 0
	Local nResto := 0
	//Local nPos   := 0
	Local nPosK  := 0
	//Local nK	 := 0         //  4-0- 3- 4-0-0-0-0-0-0- 8-0-1-0-0-0-0-0-0-1- 4
	                          //  3-1- 9- 7-3-1-9-7-3-1- 9-7-3-1-9-7-3-1-9-7- 3
	For nCt := 1 To nLen      // 12-0-27-28-0-0-0-0-0-0-72-0-3-0-0-0-0-0-0-7-12
		If nPosK >= Len(cKonst)
			nPosK := 1
		Else 
			nPosK++
		EndIf
		nPeso := Val(substr(cKonst,nPosk,1))		
		nAcum += Val(Substr(cDados,nCt,1)) * nPeso 
	Next
	nResto	:= 11 - MOD(nAcuM,11)
	If nResto == 10
		cX := substr(cRest1011,1,1)
	ElseIf nResto == 11
		cX := substr(cRest1011,2,1)
	Else
		cX := Alltrim(Str(nResto))
	EndIf
Return(cX)
//------------------------------------------------------- quebra da funcao ------------------------------------------------//

//--------------------------------------------------------------------------------------//
// Calcular o codigo de barras
//--------------------------------------------------------------------------------------//
Static Function TCOM271E(cBanco,cAgencia,cConta,cSubConta,_cNNum)
	Local cArea      := GetArea()
	Local cX 		 := ""
    Local cFatorVenc := ""
    //-------------------------------------------------------------------------------------------------------------------------------
    // A partir de 22/02/2025, o fator de vencimento retornará para “1000”, e será adicionado “1” a cada dia subsequente a esse fator. 
    // Por exemplo, o fator de vencimento para 22/02/2025 será 1000, para 23/02/2025 será 1001, para 24/02/2025 será 1002, 
    // e assim por diante.
    //-------------------------------------------------------------------------------------------------------------------------------
    If SE1->E1_VENCTO < CtoD("22/02/2025")
		cFatorVenc := IIF( SE1->E1_VENCTO == SE1->E1_EMISSAO, ; // Fator vencimento [4]
						cValToChar((SE1->E1_VENCTO +15) - CTOD("07/10/1997")), ;
						cValToChar(SE1->E1_VENCTO - CTOD("07/10/1997")) )	
    Else
        cFatorVenc := cValToChar(1000 +(SE1->E1_VENCTO < CtoD("22/02/2025")))
    EndIf

	// Tratamento para cada instituicao bancaria
	Do Case 
		Case TRIM(cBanco) == "001" // Brasil
			cPos0103 := "001"   // Banco [3]
			cPos0404 := "9"     // Moeda [1]
			cPos0505 := ""      // DV Cod. Barra [1] *** Nao admite Zero ***
			cPos0609 := cFatorVenc	

			cPos1019 := StrZero(Int((SE1->E1_VALOR + SE1->E1_ACRESC - SE1->E1_DECRESC)*100),10) // Valor [10,2] 
			//Campo obrigatorio composto pelos campos cPos0103 + cPos0404 + cPos0505 + cPos0609 + cPos1019 + cPos2025
			cCpoObr  := cPos0103 + cPos0404 + cPos0505 + cPos0609 + cPos1019
			cPos2025 := StrZero(Val("0"),6)     // Código Beneficiario - Cedente [6]
            cPos2632 := Substr(_cNNum,1,7)              // 26 a 32   9(7)  Número do Convênio fornecido pelo Banco (CCCCCCC) 
            cPos3342 := Substr(_cNNum,8,10)      // 33 a 42   9(10) Complemento do Nosso-Número, sem DV (NNNNNNNNNN) 
			cPos4344 := Alltrim(SEE->EE_CODCART) // 43 a 44  02  9(2)  Tipo de Carteira/Modalidade de Cobrança 			
			// Campo Livre composto das variaveis: cPos2025+cPos2626+cPos2729+cPos3030+cPos3133+cPos3434+cPos3543
			cCpoLiv   := cPos2025 + cPos2632 + cPos3342 + cPos4344

			cCpoInv  := InvSTR(cCpoObr+cCpoLiv) // inverter a ordem (de tras pra frente) 
   			cPos0505:= CalMod11(cCpoInv,"23456789","X1")// Calculo modulo 11  
		    cPos0505:= iif(cPos0505 == "0","1",cPos0505)
            // Campo Obrigatorio já com o DV
			cCpoObr := cPos0103 + cPos0404 + cPos0505 + cPos0609 + cPos1019 
			cX 		  := cCpoObr+cCpoLiv
        //--------------------------------------------------------------------//    
		Case TRIM(cBanco) == "033" // Santander [ Preencher o codigo da empresa=0249939 e carteira=101]
			cPos0103 := "033" // codigo do banco 
			cPos0404 := "9" // codigo da moeda = 9 (real)
			cPos0505 := "" // DV do codigo de barras
			cPos0609 := cFatorVenc

			cPos1019 := StrZero(Val(StrTran(Alltrim(str(SE1->E1_VALOR + SE1->E1_ACRESC - SE1->E1_DECRESC,10,2)),'.','')),10)
			//Campo obrigatorio composto pelos campos cPos0103 + cPos0404 + cPos0505 + cPos0609 + cPos1019
			cCpoObr  := cPos0103 + cPos0404 + cPos0505 + cPos0609 + cPos1019  

			cPos2020 := "9" // Fixo 9
			cPos2127 := StrZero(Val(SEE->EE_CODEMP),7) // Codigo do beneficiario padrao Santander [0249939]
			cPos2840 := StrZero(Val(_cNNum),13) // Nosso Numero com DV
            cPos4141 := "0" // Fixo 0
            cPos4244 := StrZero(Val(SEE->EE_CODCART),3) // 101-Cobrança Rapida com registro ou 104-Cobrança Eletronica com Registro
			// Campo Livre composto das variaveis: 
			cCpoLiv  := cPos2020 + cPos2127 + cPos2840 + cPos4141 + cPos4244 

			cCpoInv  := InvSTR(cCpoObr+cCpoLiv) // inverter a ordem (de tras pra frente) 
   			cPos0505 := CalMod11(cCpoInv,"23456789","10")// Calculo modulo 11  
            // Campo Obrigatorio já com o DV
			cCpoObr  := cPos0103 + cPos0404 + cPos0505 + cPos0609 + cPos1019
			cX 		 := cCpoObr+cCpoLiv	
			
        //--------------------------------------------------------------------//
		Case TRIM(cBanco) == "104" // Caixa 
 			cPos0103 := "104"   // Banco [3]
			cPos0404 := "9"     // Moeda [1]
			cPos0505 := ""      // DV Cod. Barra [1] *** Nao admite Zero ***
			cPos0609 := cFatorVenc	

			cPos1019 := StrZero(Int((SE1->E1_VALOR + SE1->E1_ACRESC - SE1->E1_DECRESC)*100),10) // Valor [10,2] 
			//Campo obrigatorio composto pelos campos cPos0103 + cPos0404 + cPos0505 + cPos0609 + cPos1019 + cPos2025
			cCpoObr  := cPos0103 + cPos0404 + cPos0505 + cPos0609 + cPos1019

			cPos2026 := StrZero(Val(SEE->EE_CODEMP),7)  // Código Beneficiario - Cedente [7]
            cPos2729 := Substr(_cNNum,3,3)              // 27 a 29  9(3)  Nosso Número – Sequência 1 (3ª a 5ª posição do Nosso Número) 
            cPos3030 := Substr(_cNNum,1,1)      		// 30 a 30  9(1) Constante 1 – Modalidade/Carteira Cobrança (1ª posição do Nosso Número) 
			cPos3133 := Substr(_cNNum,6,3) 				// 31 a 33  9(3)  Nosso Número – Seqüência 2 (6ª a 8ª posição do Nosso Número) 			
			cPos3434 := Substr(_cNNum,2,1) 				// 34 a 34  9(1)  Constante 2 – Identificador de Emissão do boleto (2ª posição do Nosso Número) 			
			cPos3543 := Substr(_cNNum,9,9) 				// 35 a 43  9(9)  Nosso Número – Seqüência 3 (9ª a 17ª posição do Nosso Número)
			// Campo Livre composto das variaveis: cPos2026 + cPos2729 + cPos3030 + cPos3133 + cPos3434 + cPos3543
			cCpoLiv  := cPos2026 + cPos2729 + cPos3030 + cPos3133 + cPos3434 + cPos3543
			cCpoInv  := InvSTR(cCpoLiv) // inverter a ordem (de tras pra frente) 
			cPos4444 := CalMod11(cCpoInv,"23456789","00")// Calculo modulo 11
			cCpoLiv  += cPos4444

			cCpoInv  := InvSTR(cCpoObr+cCpoLiv) // inverter a ordem (de tras pra frente) 
   			cPos0505:= CalMod11(cCpoInv,"23456789","11")// Calculo modulo 11  
		    cPos0505:= iif(cPos0505 == "0","1",cPos0505)
            // Campo Obrigatorio já com o DV
			cCpoObr := cPos0103 + cPos0404 + cPos0505 + cPos0609 + cPos1019 
			cX 		  := cCpoObr+cCpoLiv
        //--------------------------------------------------------------------//
		Case TRIM(cBanco) == "237" // Bradesco   
			cPos0103 := "237" // codigo do banco 
			cPos0404 := "9" // codigo da moeda = 9 (real)
			cPos0505 := "" // DV do codigo de barras
			cPos0609 := cFatorVenc

			cPos1019 := StrZero(Val(StrTran(Alltrim(str(SE1->E1_VALOR + SE1->E1_ACRESC - SE1->E1_DECRESC,10,2)),'.','')),10)
			//Campo obrigatorio composto pelos campos cPos0103 + cPos0404 + cPos0505 + cPos0609 + cPos1019
			cCpoObr  := cPos0103 + cPos0404 + cPos0505 + cPos0609 + cPos1019  

			cPos2023 := Strzero(Val(SEE->EE_AGENCIA),4) // Agencia
			cPos2425 := Strzero(VAL(substr(Alltrim(SEE->EE_CODCART),1,2)),2) // Carteira
			cPos2636 := Substr(_cNNum,1,11) // Nosso Numero
			cPos3743 := StrZero(Val(SEE->EE_CONTA),7)// Conta
			cPos4444 := "0"// Zero
			// Campo Livre composto das variaveis: 
			cCpoLiv  := cPos2023 + cPos2425 + cPos2636 + cPos3743 + cPos4444
			
            cCpoInv  := InvSTR(cCpoObr+cCpoLiv) // inverter a ordem (de tras pra frente) 
   			cPos0505 := CalMod11(cCpoInv,"23456789","11")// Calculo modulo 11  
            // Campo Obrigatorio já com o DV
			cCpoObr  := cPos0103 + cPos0404 + cPos0505 + cPos0609 + cPos1019
			cX 		 := cCpoObr+cCpoLiv	
        //--------------------------------------------------------------------//


		Case TRIM(cBanco) == "341" // Itau - Carteira =109; 
			cPos0103 := "341" // codigo do banco 
			cPos0404 := "9" // codigo da moeda = 9 (real)
			cPos0505 := "" // DV do codigo de barras
			cPos0609 := cFatorVenc

			cPos1019 := StrZero(Val(StrTran(Alltrim(str(SE1->E1_VALOR + SE1->E1_ACRESC - SE1->E1_DECRESC,10,2)),'.','')),10)
			//Campo obrigatorio composto pelos campos cPos0103 + cPos0404 + cPos0505 + cPos0609 + cPos1019
			cCpoObr  := cPos0103 + cPos0404 + cPos0505 + cPos0609 + cPos1019  

			cPos2022 := Strzero(VAL(SEE->EE_CODCART),3) // Carteira
			cPos2331 := Strzero(VAL(_cNNum),9) // Nosso Numero
			cPos3235 := Strzero(Val(SEE->EE_AGENCIA),4) // Agencia
			cPos3640 := StrZero(Val(SEE->EE_CONTA),5)// Conta
			cPos4141 := "8"// DAC Agencia/Conta
			cPos4244 := "000"// Zero
			// Campo Livre composto das variaveis: 
			cCpoLiv  := cPos2022 + cPos2331 + cPos3235 + cPos3640 + cPos4141 + cPos4244
			
            cCpoInv  := InvSTR(cCpoObr+cCpoLiv) // inverter a ordem (de tras pra frente) 
   			cPos0505 := CalMod11(cCpoInv,"23456789","11")// Calculo modulo 11  
            // Campo Obrigatorio já com o DV
			cCpoObr  := cPos0103 + cPos0404 + cPos0505 + cPos0609 + cPos1019
			cX 		 := cCpoObr+cCpoLiv	
        //--------------------------------------------------------------------//

		Case TRIM(cBanco) == "707" // Daycoval - Carteira =112; 
			cPos0103 := "707" // codigo do banco 
			cPos0404 := "9" // codigo da moeda = 9 (real)
			cPos0505 := "" // DV do codigo de barras
			cPos0609 := cFatorVenc

			cPos1019 := StrZero(Val(StrTran(Alltrim(str(SE1->E1_VALOR + SE1->E1_ACRESC - SE1->E1_DECRESC,10,2)),'.','')),10)
			//Campo obrigatorio composto pelos campos cPos0103 + cPos0404 + cPos0505 + cPos0609 + cPos1019
			cCpoObr  := cPos0103 + cPos0404 + cPos0505 + cPos0609 + cPos1019  

			cPos2022 := Strzero(VAL(SEE->EE_CODCART),3) // Carteira
			cPos2331 := Strzero(VAL(_cNNum),9) // Nosso Numero
			cPos3235 := Strzero(Val(SEE->EE_AGENCIA),4) // Agencia
			cPos3640 := StrZero(Val(SEE->EE_CONTA),6)// Conta
			cPos4141 := ""//"8"// DAC Agencia/Conta
			cPos4244 := "000"// Zero
			// Campo Livre composto das variaveis: 
			cCpoLiv  := cPos2022 + cPos2331 + cPos3235 + cPos3640 + cPos4141 + cPos4244
			
            cCpoInv  := InvSTR(cCpoObr+cCpoLiv) // inverter a ordem (de tras pra frente) 
   			cPos0505 := CalMod11(cCpoInv,"23456789","11")// Calculo modulo 11  
            // Campo Obrigatorio já com o DV
			cCpoObr  := cPos0103 + cPos0404 + cPos0505 + cPos0609 + cPos1019
			cX 		 := cCpoObr+cCpoLiv	
        //--------------------------------------------------------------------//

		Case TRIM(cBanco) == "756" // Sicoob
			cPos0103 := "756" // codigo do banco '756'
			cPos0404 := "9"   // codigo da moeda = 9 (real)
			cPos0505 := ""    // DV do codigo de barras
			cPos0609 := cFatorVenc

			cPos1019 := StrZero(Val(StrTran(Alltrim(str(SE1->E1_VALOR + SE1->E1_ACRESC - SE1->E1_DECRESC,10,2)),'.','')),10)
			//Campo obrigatorio composto pelos campos cPos0103 + cPos0404 + cPos0505 + cPos0609 + cPos1019
			cCpoObr  := cPos0103 + cPos0404 + cPos0505 + cPos0609 + cPos1019            

			cPos2020 := "1" // Codigo da carteira
			cPos2124 := ALLTRIM(SA6->A6_AGENCIA) // Codigo da agencia/cooperativa
			cPos2526 := "01" // Codigo da modalidade    SEE->EE_CODEMP
			cPos2733 := StrZero(Val(SEE->EE_CODEMP),7)//StrZero(Val(SA6->A6_NUMCON),6)+ ALLTRIM(SA6->A6_DVCTA) // Codigo do associado/cliente
			
            _cNNum := substr(_cNNum,1,Len(Alltrim(_cNNum))-1)
			cPos3441 := StrZero(Val(_cNNum),8) //StrZero(Val(_cNNumSDV),8) // (8) Nosso numero do boleto sem o DV
			If empty(SE1->E1_PARCELA)
				cPos4144 := "001" // Numero da parcela a que o boleto se refere - "001"  
			Else
				cPos4144 := StrZero(VAL(SE1->E1_PARCELA),3)    
			EndIf
			// Campo Livre composto das variaveis: cPos2020 + cPos2124 + cPos2526 + cPos2733 + cPos3441 + cPos4144
			cCpoLiv  := cPos2020 + cPos2124 + cPos2526 + cPos2733 + cPos3441 + cPos4144 
			
            cCpoInv  := InvSTR(cCpoObr+cCpoLiv) // inverter a ordem (de tras pra frente) 
   			cPos0505 := CalMod11(cCpoInv,"23456789","11")// Calculo modulo 11  
            // Campo Obrigatorio já com o DV
			cCpoObr  := cPos0103 + cPos0404 + cPos0505 + cPos0609 + cPos1019
			cX 		 := cCpoObr+cCpoLiv	
        //--------------------------------------------------------------------//
	EndCase

	RestArea(cArea)
Return (cX)           
//------------------------------------------------------- quebra da funcao ------------------------------------------------//
//--------------------------------------------------------------------------------------//
// Calcular a linha digitavel
//--------------------------------------------------------------------------------------//
Static Function TCOM271F(cCodBarra)
	Local cArea := GetArea()
	Local cX	:= ""

	// Campos 1 (AAABC.CCCCX)
	cCpo1   := alltrim(Substr(cCodBarra,1,4)) + alltrim(Substr(cCodBarra,20,5))
	cDvCpo1 := CalMod10(cCpo1)
	cCpo1	+= cDvCpo1
	// Campo 2 (DDDDD.DDDDDY)	
	cCpo2	:= Alltrim(Substr(cCodBarra,25,10))
	cDvCpo2 := CalMod10(cCpo2)
	cCpo2	+= cDvCpo2
	// Campo 3 (EEEEE.EEEEEZ)
	cCpo3	:= Alltrim(Substr(cCodBarra,35,10))
	cDvCpo3 := CalMod10(cCpo3)
	cCpo3	+= cDvCpo3
	// Campo 4 (K)  Digito verificado do codigo de barras
	cCpo4   := Alltrim(Substr(cCodBarra,5,1))
	cCpo4   := Iif(cCpo4=="X","1",cCpo4)
	// Campo 5 (UUUUVVVVVVVVVV) Fator de vencimento + valor do titulo
	cCpo5   := Alltrim(Substr(cCodBarra,6,14))
		
	cX := Alltrim(cCpo1) + Alltrim(cCpo2) + Alltrim(cCpo3) + Alltrim(cCpo4) + Alltrim(cCpo5)
	//cLinhaDigitavel := Transform(cLinhaDigitavel, "@R 99999.99999 99999.999999 99999.999999 9 99999999999999")  len(cX)

	RestArea(cArea)
Return(cX)  
//------------------------------------------------------- quebra da funcao ------------------------------------------------//
Static Function CalMod10(cDados)
    //Local cDados := alltrim(cDados)
	Local cX     := ""
	Local nCt    := 0
	Local nLen   := Len(Alltrim(cDados))
	Local nAcum1 := 0
	Local nAcum2 := 0
	Local nPeso  := 2
	Local nResto := 0    
	Local nX	 := 0
	For nX := 1 To nLen
		If nPeso < 1
			nPeso := 2
		EndIf 
		
		nAcum1 := Val(Substr(cDados,nLen - nCt,1)) * nPeso
		nAcum2 += iif(Len(Alltrim(Str(nAcum1)))> 1,	( Val(Substr(Alltrim(Str(nAcum1)), 1,1)) + Val(Substr(Alltrim(Str(nAcum1)), 2,1)) ),nAcum1)
		nPeso  := nPeso -1
		nCt ++
	Next   // 19000022077 -9  00577219219898712345         
    nUltDig := Val(Substr(alltrim(Str(nAcum2)), Len(alltrim(Str(nAcum2))), 1))
	nResto	:= 10 - nUltDig
	
	If nResto == 10
		cX := '0'
	Else
		cX := Alltrim(Str(nResto))
	EndIf

Return(cX) 
//--------------------------------------------------------------------------------------//
// Preencher o array aBoleto com os dados que serão impressos
//--------------------------------------------------------------------------------------//
Static Function AddBoleto(cBanco,cAgencia,cConta,cSubConta,cNossoNum,cCodBarra,cLinDigit)
    Local cLogo := "lgr"+cBanco
	Local cFebraban := Posicione("SA6",1,XFILIAL("SA6")+cBanco+cAgencia+cConta,"A6_NUMBCO")
    Local cChvSEE   := cBanco+cAgencia+cConta+Alltrim(cSubConta)
    cLogo := Alltrim(cLogo)+".png"
	cFebraban := Alltrim(cFebraban)
    // Posicionar na SEE
	dbSelectArea("SEE")
	dbSetOrder(1)
	dbGoTop()
	dbSeek(XFILIAL("SEE")+cChvSEE)    

	cXTxt1 	 := SEE->EE_FORMEN1
	cXInstr1 := &cXTxt1 
	cXTxt2	 := SEE->EE_FORMEN2
	cXInstr2 := &cXTxt2
	cXTxt3   := SEE->EE_FOREXT1
	cXInstr3 := &cXTxt3 
	cXTxt4   := SEE->EE_FOREXT2
	cXInstr4 := &cXTxt4 


    aAdd(aBoleto,{ "N",;	//01
                    cCodBarra       ,; 	//02 Codigo Barras
                    "DM",;	//03
                    cLinDigit      ,; 	//04 Linha Digitavel
                    SEE->EE_FORMEN1,;	//05
                    cNossoNum       ,; 	//06 Nosso Numero
                    SA1->A1_BAIRRO,;	//07
                    SA1->A1_BAIRROC,;	//08
                    SA1->A1_CEP,;		//09
                    SA1->A1_CEPC,;		//10
                    SA1->A1_CGC,;		//11
                    SA1->A1_COD,;       //12
                    SA1->A1_END,;       //13
                    SA1->A1_ENDCOB,;    //14
                    SA1->A1_EST,;       //15
                    SA1->A1_ESTC,;      //16
                    SA1->A1_MUN,;       //17
                    SA1->A1_MUNC,;      //18
                    SA1->A1_NOME,;      //19
                    SA1->A1_PESSOA,;            //20
                    SUBSTR(SEE->EE_AGENCIA,1,4),;   //21
                    SEE->EE_DVAGE,;                     //22
                    IIF(SEE->EE_CODIGO =="104",SUBSTR(SEE->EE_CODEMP,LEN(ALLTRIM(SEE->EE_CODEMP)),1),SEE->EE_DVCTA),;//23
                    SUBSTR(SEE->EE_CODIGO,1,5),;                                                                      //24
                    IIF(SEE->EE_CODIGO =="104",SUBSTR(SEE->EE_CODEMP,1,LEN(ALLTRIM(SEE->EE_CODEMP))-1),SEE->EE_CONTA),;     //25
                    cLogo,;//26
                    SE1->E1_ACRESC,;   	//27
                    SE1->E1_DECRESC,;       //28
                    SE1->E1_EMISSAO,; //29
                    SE1->E1_NUM,;//30
                    SE1->E1_PARCELA,;//31
                    SE1->E1_VALOR,;   //32
                    SE1->E1_VENCTO,;      //33
                    dDataBase,;               //34
                    SEE->EE_CODEMP,;              //35
                    SEE->EE_CODCART,;                   //36
                    cXInstr1,; 				                    // 37
                    cXInstr2,;                         			// 38
                    0,;                                         // 39
                    SM0->M0_BAIRCOB,;                           // 40
                    SM0->M0_CEPCOB,;                            // 41
                    SM0->M0_CGC,;                               // 42
                    SM0->M0_CIDCOB,;                            // 43
                    SM0->M0_ENDCOB,;                            // 44
                    SM0->M0_ESTCOB,;                            // 45
                    SM0->M0_NOMECOM,;				            // 46
                    cXInstr3,; 									// 47
                    cXInstr4,; 									// 48
                    SE1->E1_IDCNAB,;                  			// 49
                    cLogo,;   				                    // 50
                    SA1->A1_LOJA,;                              // 51
                    SE1->E1_PREFIXO,;                           // 52         
                    SE1->E1_TIPO,;								// 53
					cFebraban,;                                 // 54
                    cBanco,;                                    // 55
                    cAgencia,;                                  // 56 
                    cConta ,;                                   // 57
                    cSubConta ,;                                // 58
                    cFaxAtu })                                  // 59
			
Return(nil)
//--------------------------------------------------------------------------------------//
// Gravar os dados na tabela SE1 (Portador, NossoNumero e Codigo Barras)
//--------------------------------------------------------------------------------------//
Static Function GrvDados()
	Local nK	 := 0   
	Local aArea := GetArea()

    Begin Transaction
        For nK:= 1 to Len(aBoleto)
            //Iniciar transacao para gravar os dados
            // Atualizar os dados do título
            dbSelectArea("SE1")
            dbSetOrder(1)
            dbGoTop()
            dbSeek(XFILIAL("SE1")+aBoleto[nk,52]+aBoleto[nk,30]+aBoleto[nk,31]+aBoleto[nk,53]) //52-30-31-53
            RecLock("SE1",.F.)
            // Gravar o nosso número
            SE1->E1_NUMBCO  := aBoleto[nk,6]
            // Calcular o Codigo Barras
            SE1->E1_CODBAR  := aBoleto[nK,2]

			If Empty(Alltrim(SE1->E1_IDCNAB))
				// Incrementar o IdCnab
				cIdCnab := StrZero(Val(GETMV("MV_XIDCNAB"))+1,10)
				PUTMV("MV_XIDCNAB",cIdCnab)	
				SE1->E1_IDCNAB := cIdCnab
			EndIf

            If Empty(Alltrim(SE1->E1_PORTADO))
                // Dados do portador
                SE1->E1_PORTADO := aBoleto[nk,55] // Banco
                SE1->E1_AGEDEP  := aBoleto[nk,56] // Agência
                SE1->E1_CONTA   := aBoleto[nk,57] // Conta
            EndIf
            MsUnlock()
        Next
    End Transaction
	RestArea(aArea)
Return(nil)
//--------------------------------------------------------------------------------------//
// Imprimir os dados em pdf
//--------------------------------------------------------------------------------------//
Static Function Imprimir(lPreview,aRet)
	Local cArea		:= GetArea()
	//
	Local oF06  := TFont():New("Arial"      ,09,06,,.F.,,,,,.F.)
	Local oF06N := TFont():New("Arial"      ,09,06,,.T.,,,,,.F.)
	Local oF07  := TFont():New("Arial"      ,09,07,,.F.,,,,,.F.)
	Local oF08  := TFont():New("Arial"      ,09,08,,.F.,,,,,.F.)
	Local oF08N := TFont():New("Arial"      ,09,08,,.T.,,,,,.F.)
	Local oF09  := TFont():New("Arial"      ,09,09,,.F.,,,,,.F.)
	Local oF09N := TFont():New("Arial"      ,09,09,,.T.,,,,,.F.)
	Local oF12N := TFont():New("Arial"      ,09,12,,.T.,,,,,.F.)
	Local oF14N := TFont():New("Arial"      ,09,14,,.T.,,,,,.F.)
	Local oF17  := TFont():New("Arial"      ,09,17,,.F.,,,,,.F.)
	Local oF17N := TFont():New("Arial"      ,09,17,,.T.,,,,,.F.)
	//----------------------------------------------------------

	Local nXParte    := 0
	Local nRowIni    := 0
	Local nCIni      := 0
	Local nRowFin    := 0
	Local nCFin      := 0
	Local nIntC	     := 050
	Local nLin1      := 0
	Local nX	     := 0
	Local nCt 		 := 0

	Local lAdjustToLegacy := .T.
	Local lDisableSetup   := .T.

    Local lArqUnico := iif(aRet[6]=="1",.t.,.f.)
    Local lArqCriado:= .f.

	Private oPrinter := Nil
	Private cDirSpool :=  "C:\Totvs_relatorio\boletos\" //'\system\boleto\' //
	Private aEmail   := {}


    //Verifica se existe o diretório, caso não existe irá tentar criar, caso negativo irá informar o usuário do problema
	If !ExistDir(cDirSpool)
		If MakeDir(cDirSpool) <> 0
			MsgAlert("O diretório não foi encontrado, contacte o departamento de TI! " + cValToChar( FError() ) )
			Return
		EndIf
	EndIf

    //Limpa diretorio
	ProcRegua( Len(aBoleto)) //seta o total de registros
	//--------------------------------------------------------------------
	For nX:= 1 to Len(aBoleto)
	
		_cNFProg := "NF-"+AllTrim(aBoleto[nX,30])+ IIF(!EMPTY(aBoleto[nX,31]),"-Parc-","")+AllTrim(aBoleto[nX,31])
		IncProc(_cNFProg + " Processando registro " + cValToChar(nX) + " de " + cValToChar( Len(aBoleto)) + ", aguarde.")
 
        If lArqCriado
            oPrinter:StartPage()
        Else
            If lArqUnico
                cNomArq      := "Boletos"+"-"+cValtoChar(int(Seconds()))+".pdf"
                lArqCriado := .t.
            Else
                cNomArq      := AllTrim(aBoleto[nX,52])  + "-NF-"+AllTrim(aBoleto[nX,30])+ IIF(!EMPTY(aBoleto[nX,31]),"Parc-","")+AllTrim(aBoleto[nX,31])+"-"+cValtoChar(int(Seconds()))+".pdf"
            EndIf
            //Criando o objeto de impressao
			//          FWMsPrinter():New( < cFilePrintert >, [ nDevice], [ lAdjustToLegacy], [ cPathInServer], [ lDisabeSetup ], [ lTReport], [ @oPrintSetup], [ cPrinter], [ lServer], [ lPDFAsPNG], [ lRaw], [ lViewPDF], [ nQtdCopy] )
		    //oPrinter := FWMSPrinter():New(cNomArq,6,lAdjustToLegacy,cDirSpool,  lDisableSetup,.T., , ,.T., ,.F.,.F., )//.T., , ,, ,.F.,.T., ) //instaciando a classe
		    oPrinter := FWMSPrinter():New(cNomArq,IMP_PDF,lAdjustToLegacy,cDirSpool,  lDisableSetup,.T., , ,.T., ,.F.,.F., )//.T., , ,, ,.F.,.T., ) //instaciando a classe
		    oPrinter:SetResolution(72)
		    oPrinter:SetPortrait()
		    oPrinter:SetPaperSize(DMPAPER_A4)
		    oPrinter:cPathPDF := cDirSpool //"C:\Totvs_relatorio\boletos\"
		    oPrinter:lViewPDF:= lPreview
            oPrinter:StartPage()

        EndIf
        
		_aEmail := {}
		AADD( _aEmail , AllTrim(aBoleto[nX,12])  								) // cliente
		AADD( _aEmail , AllTrim(aBoleto[nX,51])  								) // Loja
		AADD( _aEmail , AllTrim(aBoleto[nX,30])  								) // NF
		AADD( _aEmail , AllTrim(aBoleto[nX,31])  								) // Parcela
		AADD( _aEmail , cDirSpool + cNomArq         							) // Diretorio+Arquivo
		AADD( _aEmail , cNomArq                     							) // Arquivo
		AADD( _aEmail , cNomArq                     							) // Arquivo
		AADD( _aEmail , AllTrim(Transform(aBoleto[nX,32] ,"@E 999,999,999.99")) ) // Valor
		AADD( _aEmail , dtoc( aBoleto[nX,33]  )     ) 							  // Vencimento
		AADD( _aEmail , dtoc( aBoleto[nX,29]  )     ) 							  // Emissao
		AADD(  aEmail , _aEmail )
        
		nXParte ++

		nRowIni := 30 // 050
		nCIni := 100
		nRowFin := nRowIni + 150    //nRowFin := 150 //200
		nCFin := 250

		// Imprimir Conforme layout
		// Linha 1
		If Substr(Alltrim(aBoleto[nX,24]),1,3) == "104"
			oPrinter:SayBitmap(nRowIni,0100,aBoleto[nX,50],430,80)
		Else
			oPrinter:SayBitmap(nRowIni,0100,aBoleto[nX,26],430,80)
		EndIf
		oPrinter:Say(nRowIni,0200,"",oF17N,100)
		oPrinter:Say(nRowIni+35,0550," | "+ alltrim(aBoleto[nX,54])+" | ",oF14N,100)
		oPrinter:Say(nRowIni+35,0800,"Recibo do Pagador",oF12N,100)



		If Substr(Alltrim(aBoleto[nX,24]),1,3) == "001"
			oPrinter:SayBitmap(nRowIni,1240,aBoleto[nX,50],430,80)
		Else
			oPrinter:SayBitmap(nRowIni,1240,aBoleto[nX,26],430,80)
		EndIf

		oPrinter:Say(nRowIni,1350,"",oF17N,100)
		oPrinter:Say(nRowIni+35,1680," | "+ alltrim(aBoleto[nX,54])+" | ",oF14N,100)
		oPrinter:Say(nRowIni+35,1900,"Recibo de Entrega",oF12N,100)

		nLin1 := nRowIni
		For nCt = 1 to 10
			oPrinter:Say(nLin1,1210,"|",oF07,100)
			nLin1 += 50
		Next

		// Linha 2
		nRowIni += 90
		oPrinter:Box(nRowIni,nCIni,nRowFin,nCFin)
		oPrinter:Say(nRowIni+05,nCIni+05,"Vencimento",oF07,100)
		oPrinter:Say(nRowIni+35,nCIni+20,SubStr(DTOS(aBoleto[nX,33]),7,2)+"/"+SubStr(DTOS(aBoleto[nX,33]),5,2)+"/"+SubStr(DTOS(aBoleto[nX,33]),1,4),oF06N,100)

		nCIni := nCFin
		nCFin := nCIni + 300
		oPrinter:Box(nRowIni,nCIni,nRowFin,nCFin)
		If  TRIM(aBoleto[nX,55]) == "001" // BANCO DO BRASIL
			oPrinter:Say(nRowIni+05,nCIni+05,"Agencia/Cód Benefic",oF07,100)
			oPrinter:Say(nRowIni+35,nCIni+20,ALLTRIM(aBoleto[nX,21]) +"/"+ ALLTRIM(aBoleto[nX,25])+ "-"+ ALLTRIM(aBoleto[nX,23]),oF06,100)
		ElseIF TRIM(aBoleto[nX,55]) == "104" // CAIXA ECONOMICA FEDERAL
			oPrinter:Say(nRowIni+05,nCIni+05,"Agencia/Cód Benefic",oF07,100)
			cCpoInv  := InvSTR(ALLTRIM(aBoleto[nX,35])) // inverter a ordem (de tras pra frente) 
			_cDVCta:= CalMOD11(cCpoInv,"23456789","00")
			oPrinter:Say(nRowIni+35,nCIni+20,ALLTRIM(aBoleto[nX,21]) + "/"+ ALLTRIM(aBoleto[nX,35])+ "-"+ ALLTRIM(_cDVCta),oF06,100)
		ElseIf TRIM(aBoleto[nX,55]) == "756" // SICOOB
			//oPrinter:Say(nRowIni+05,nCIni+05,"Coop.Contr./Cód Benefic",oF07,100)
			//oPrinter:Say(nRowIni+35,nCIni+20,ALLTRIM(aBoleto[nX,21]) + "/"+ ALLTRIM(aBoleto[nX,35]),oF06,100)
			oPrinter:Say(nRowIni+05,nCIni+05,"Agencia/Cód Benefic",oF07,100)
			oPrinter:Say(nRowIni+35,nCIni+20,ALLTRIM(aBoleto[nX,21]) + "/"+ ALLTRIM(aBoleto[nX,25])+ "-"+ ALLTRIM(aBoleto[nX,23]),oF06,100)

		ElseIf TRIM(aBoleto[nX,55]) == "237" // BRADESCO
			oPrinter:Say(nRowIni+05,nCIni+05,"Agencia/Cód Benefic",oF07,100)
			oPrinter:Say(nRowIni+35,nCIni+20,ALLTRIM(aBoleto[nX,21]) + "/"+ StrZero(Val(aBoleto[nX,35]),7)+ "-"+ ALLTRIM(aBoleto[nX,23]),oF06,100)
		ELSE
			oPrinter:Say(nRowIni+05,nCIni+05,"Agencia/Cód Benefic",oF07,100)
			oPrinter:Say(nRowIni+35,nCIni+20,ALLTRIM(aBoleto[nX,21]) +"-"+ ALLTRIM(aBoleto[nX,22])+ "/"+ ALLTRIM(aBoleto[nX,25])+ "-"+ ALLTRIM(aBoleto[nX,23]),oF06,100)
		ENDIF
		nCIni := nCFin
		nCFin := nCIni + 110
		oPrinter:Box(nRowIni,nCIni,nRowFin,nCFin)
		oPrinter:Say(nRowIni+05,nCIni+05,"Espécie",oF06,100)
		oPrinter:Say(nRowIni+35,nCIni+20,aBoleto[nX,3],oF06,100)

		nCIni := nCFin
		nCFin := nCIni + 530
		oPrinter:Box(nRowIni,nCIni,nRowFin,nCFin)
		oPrinter:Say(nRowIni+05,nCIni+05,"Beneficiário " + " - CNPJ: "+Transform(AllTrim(aBoleto[nX,42]),"@R 99.999.999/9999-99"),oF07,200)
		oPrinter:Say(nRowIni+35,nCIni+20,aBoleto[nX,46],oF06N,100)

		nCIni := nCFin + nIntC
		nCFin := nCIni + 150
		oPrinter:Box(nRowIni,nCIni,nRowFin,nCFin)
		oPrinter:Say(nRowIni+05,nCIni+05,"Vencimento",oF07,100)
		oPrinter:Say(nRowIni+35,nCIni+20,SubStr(DTOS(aBoleto[nX,33]),7,2)+"/"+SubStr(DTOS(aBoleto[nX,33]),5,2)+"/"+SubStr(DTOS(aBoleto[nX,33]),1,4),oF06N,100)

		nCIni := nCFin
		nCFin := nCIni + 300
		oPrinter:Box(nRowIni,nCIni,nRowFin,nCFin)
		If  TRIM(aBoleto[nX,55]) == "001" // BANCO DO BRASIL
			oPrinter:Say(nRowIni+05,nCIni+05,"Agencia/Cód Benefic",oF07,100)
			oPrinter:Say(nRowIni+35,nCIni+20,ALLTRIM(aBoleto[nX,21]) +"/"+ ALLTRIM(aBoleto[nX,25])+ "-"+ ALLTRIM(aBoleto[nX,23]),oF06,100)
		ElseIF TRIM(aBoleto[nX,55]) == "104" // CAIXA ECONOMICA FEDERAL
			oPrinter:Say(nRowIni+05,nCIni+05,"Agencia/Cód Benefic",oF07,100)
			cCpoInv  := InvSTR(ALLTRIM(aBoleto[nX,35])) // inverter a ordem (de tras pra frente) 
			_cDVCta:= CalMOD11(cCpoInv,"23456789","00")
			oPrinter:Say(nRowIni+35,nCIni+20,ALLTRIM(aBoleto[nX,21]) +"/"+ ALLTRIM(aBoleto[nX,35])+ "-"+ ALLTRIM(_cDVCta),oF06,100)
		ElseIF TRIM(aBoleto[nX,55]) == "756" // SICOOB
			//oPrinter:Say(nRowIni+05,nCIni+05,"Coop.Contr./Cód Benefic",oF07,100)
			//oPrinter:Say(nRowIni+35,nCIni+20,ALLTRIM(aBoleto[nX,21]) +"/"+ ALLTRIM(aBoleto[nX,35]),oF06,100)
			oPrinter:Say(nRowIni+05,nCIni+05,"Agencia/Cód Benefic",oF07,100)
			oPrinter:Say(nRowIni+35,nCIni+20,ALLTRIM(aBoleto[nX,21]) + "/"+ ALLTRIM(aBoleto[nX,25])+ "-"+ ALLTRIM(aBoleto[nX,23]),oF06,100)

		ElseIf TRIM(aBoleto[nX,55]) == "237" // BRADESCO
			oPrinter:Say(nRowIni+05,nCIni+05,"Agencia/Cód Benefic",oF07,100)
			oPrinter:Say(nRowIni+35,nCIni+20,ALLTRIM(aBoleto[nX,21]) + "-"+ ALLTRIM(aBoleto[nX,22])+"/"+ StrZero(Val(aBoleto[nX,25]),7)+ "-"+ ALLTRIM(aBoleto[nX,23]),oF06,100)
		ELSE
			oPrinter:Say(nRowIni+05,nCIni+05,"Agencia/Cód Benefic",oF07,100)
			oPrinter:Say(nRowIni+35,nCIni+20,ALLTRIM(aBoleto[nX,21]) + "-"+ ALLTRIM(aBoleto[nX,22])+"/"+ ALLTRIM(aBoleto[nX,25])+ "-"+ ALLTRIM(aBoleto[nX,23]),oF06,100)
		ENDIF

		nCIni := nCFin -5
		nCFin := nCIni + 120
		oPrinter:Box(nRowIni,nCIni,nRowFin,nCFin)
		oPrinter:Say(nRowIni+05,nCIni+05,"Espécie",oF07,100)
		oPrinter:Say(nRowIni+35,nCIni+20,aBoleto[nX,3],oF06,100)

		nCIni := nCFin
		nCFin := nCIni + 522
		oPrinter:Box(nRowIni,nCIni,nRowFin,nCFin)
		oPrinter:Say(nRowIni+05,nCIni+05,"Beneficiário"+ " - CNPJ: "+Transform(AllTrim(aBoleto[nX,42]),"@R 99.999.999/9999-99"),oF07,200)
		oPrinter:Say(nRowIni+35,nCIni+20,aBoleto[nX,46],oF06N,100)
		nCIni := nCFin + nIntC
		// Linha 3
		nRowIni := nRowFin     // linha inicio
		nCIni := 100           // coluna inicio

		nRowFin := nRowIni + 70// linha final
		nCFin:= 1190           // coluna final
		oPrinter:Box(nRowIni,nCIni,nRowFin,nCFin)
		oPrinter:Say(nRowIni+05,nCIni+05,"Endereco",oF07,100)
		oPrinter:Say(nRowIni+40,nCIni+10,Alltrim(aBoleto[nX,44]) + " " + Alltrim(aBoleto[nX,40]) + " " + Alltrim(aBoleto[nX,43]) + " "+ Alltrim(aBoleto[nX,45]) + " - "+Alltrim(aBoleto[nX,41]),oF07,100)


		nCIni := nCFin +nIntC
		nCFin := nCIni + 1090
		oPrinter:Box(nRowIni,nCIni,nRowFin,nCFin)
		oPrinter:Say(nRowIni+05,nCIni+05,"Endereco",oF07,100)
		oPrinter:Say(nRowIni+40,nCIni+10,Alltrim(aBoleto[nX,44]) + " " + Alltrim(aBoleto[nX,40]) + " " + Alltrim(aBoleto[nX,43]) + " "+ Alltrim(aBoleto[nX,45]) + " - "+Alltrim(aBoleto[nX,41]),oF07,100)

		// Linha 3
		nRowIni := nRowFin         // linha inicio
		nCIni := 100           // coluna inicio

		nRowFin := nRowIni + 70    // linha final
		nCFin := nCIni + 360  // coluna final
		oPrinter:Box(nRowIni,nCIni,nRowFin,nCFin)
		oPrinter:Say(nRowIni+05,nCIni+05,"(=) Valor do documento",oF07,100)
		oPrinter:Say(nRowIni+40,nCIni+200,Transform((aBoleto[nX,32] + aBoleto[nX,27] - aBoleto[nX,28]),"@E 999,999,999.99"),oF07,100)

		nCIni := nCFin
		nCFin := nCIni + 360
		oPrinter:Box(nRowIni,nCIni,nRowFin,nCFin)
		oPrinter:Say(nRowIni+05,nCIni+05,"(-) Desconto / Abatimento",oF07,100)
		oPrinter:Say(nRowIni+40,nCIni+20,'',oF07,100)

		nCIni := nCFin
		nCFin := nCIni + 370
		oPrinter:Box(nRowIni,nCIni,nRowFin,nCFin)
		oPrinter:Say(nRowIni+05,nCIni+05,"(+) Mora / Multa / Juros",oF07,100)
		oPrinter:Say(nRowIni+40,nCIni+20,'',oF07,100)


		nCIni := nCFin +nIntC
		nCFin := nCIni + 450
		oPrinter:Box(nRowIni,nCIni,nRowFin,nCFin)
		oPrinter:Say(nRowIni+05,nCIni+05,"(=) Valor do Documento",oF07,100)
		oPrinter:Say(nRowIni+40,nCIni+200,Transform((aBoleto[nX,32] + aBoleto[nX,27] - aBoleto[nX,28]),"@E 999,999,999.99"),oF07,100)

		nCIni := nCFin -2
		nCFin := nCIni + 640
		oPrinter:Box(nRowIni,nCIni,nRowFin,nCFin)
		oPrinter:Say(nRowIni+05,nCIni+05,"Nosso Numero",oF07,100)
		IF TRIM(aBoleto[nX,55]) == "104" // CAIXA ECONOMICA FEDERAL
			cCpoInv   := InvSTR(aBoleto[nX,6])
			_cDvNN    := CALMOD11(AllTrim(cCpoInv),"23456789","00")
			oPrinter:Say(nRowIni+40,nCIni+050,transform(AllTrim(aBoleto[nX,6])+_cDVNN,"@R 99999999999999999-9"),oF07,120)
		ElseIF TRIM(aBoleto[nX,55]) == "237" // BRADESCO
			oPrinter:Say(nRowIni+40,nCIni+050,transform(StrZero(Val(aBoleto[nX,36]),3)+StrTran(aBoleto[nX,6],"-",""),"@R 999/99999999999-9"),oF07,120)
		ElseIF TRIM(aBoleto[nX,55]) == "341" // ITAU
			oPrinter:Say(nRowIni+40,nCIni+050,transform(StrZero(Val(aBoleto[nX,36]),3)+StrTran(aBoleto[nX,6],"-",""),"@R 999/99999999-9"),oF07,120)
		ElseIF TRIM(aBoleto[nX,55]) == "756" // SICOOB
			oPrinter:Say(nRowIni+40,nCIni+050,transform(StrZero(Val(aBoleto[nX,59]),8),"@R 99999999"),oF07,120)
		Else
			oPrinter:Say(nRowIni+30,1820,aBoleto[nX,6],oF09,120)
		EndIf

		// Linha 4
		nRowIni := nRowFin         // linha inicio
		nCIni := 100           // coluna inicio

		nRowFin := nRowIni + 70    // linha final
		nCFin := nCIni + 360  // coluna final
		oPrinter:Box(nRowIni,nCIni,nRowFin,nCFin)
		oPrinter:Say(nRowIni+05,nCIni+05,"(=) Valor cobrado",oF07,100)
		oPrinter:Say(nRowIni+40,nCIni+10,'',oF07,100)

		nCIni := nCFin
		nCFin := nCIni + 362
		oPrinter:Box(nRowIni,nCIni,nRowFin,nCFin)
		oPrinter:Say(nRowIni+05,nCIni+05,"Nosso Numero",oF07,100)
		If TRIM(aBoleto[nX,55]) == "104" // CAIXA
			cCpoInv   := InvSTR(aBoleto[nX,6])
			_cDvNN    := CALMOD11(AllTrim(cCpoInv),"23456789","00")
			oPrinter:Say(nRowIni+40,nCIni+050,transform(AllTrim(aBoleto[nX,6])+_cDVNN,"@R 99999999999999999-9"),oF07,120)
		ElseIf TRIM(aBoleto[nX,55]) == "237" // BRADESCO
			oPrinter:Say(nRowIni+40,nCIni+050,transform(Strzero(Val(aBoleto[nX,36]),3)+StrTran(aBoleto[nX,6],"-",""),"@R 999/99999999999-9"),oF07,120)
		ElseIf TRIM(aBoleto[nX,55]) == "341" // ITAU
			oPrinter:Say(nRowIni+40,nCIni+050,transform(Strzero(Val(aBoleto[nX,36]),3)+StrTran(aBoleto[nX,6],"-",""),"@R 999/99999999-9"),oF07,120)
		ElseIf TRIM(aBoleto[nX,55]) == "756" // SICOOB
			oPrinter:Say(nRowIni+40,nCIni+050,transform(StrZero(Val(aBoleto[nX,59]),8),"@R 99999999"),oF07,120)
		Else
			oPrinter:Say(nRowIni+40,nCIni+050,aBoleto[nX,6],oF07,120)
		EndIf

		nCIni := nCFin
		nCFin := nCIni + 370
		oPrinter:Box(nRowIni,nCIni,nRowFin,nCFin)
		oPrinter:Say(nRowIni+05,nCIni+05,"Nº do Documento",oF07,100)
		oPrinter:Say(nRowIni+40,nCIni+10,AllTrim(aBoleto[nX,30])+ IIF(!EMPTY(aBoleto[nX,31])," / ","")+AllTrim(aBoleto[nX,31]),oF07,100)    //IIF(EMPTY(aBoleto[nX,31]),"1",AllTrim(aBoleto[nX,31]))

		nCIni := nCFin +nIntC -2
		nCFin := nCIni + 1090
		oPrinter:Box(nRowIni,nCIni,nRowFin,nCFin)
		oPrinter:Say(nRowIni+05,nCIni+20,"Pagador",oF07,100)
		oPrinter:Say(nRowIni+40,nCIni+20,SUBSTR(aBoleto[nX,19],1,45),oF07,100)

		// Linha 5
		nRowIni := nRowFin -2       // linha inicio
		nCIni:= 100           // coluna inicio

		nRowFin:= nRowIni + 70    // linha final
		nCFin:= 1190           // coluna final
		oPrinter:Box(nRowIni,nCIni,nRowFin,nCFin)
		oPrinter:Say(nRowIni+05,nCIni+05,"Pagador",oF07,100)
		If AllTrim(aBoleto[nX,20]) == "J"
			cCgcCpf := "    CNJP: "+ Transform(AllTrim(aBoleto[nX,11]),"@R 99.999.999/9999-99")
		Else
			cCgcCpf := "    CPF: "+ Transform(AllTrim(aBoleto[nX,11]),"@R 999.999.999-99")
		EndIf
		oPrinter:Say(nRowIni+40,nCIni+10,Alltrim(aBoleto[nX,12])+" - "+ Alltrim(aBoleto[nX,19]) + cCGCCpf,oF07,100)

		nCIni := nCFin + nIntC
		nCFin := nCIni + 770
		oPrinter:Box(nRowIni,nCIni,nRowFin,nCFin)
		oPrinter:Say(nRowIni+05,nCIni+05,"Assinatura do Recebedor",oF07,100)
		oPrinter:Say(nRowIni+40,nCIni+10,'',oF07,100)

		nCIni := nCFin -5
		nCFin := nCIni + 322
		oPrinter:Box(nRowIni,nCIni,nRowFin,nCFin)
		oPrinter:Say(nRowIni+05,nCIni+05,"Data de Entrega",oF07,110)
		oPrinter:Say(nRowIni+40,nCIni+10,'',oF07,110)

		// Linha 6
		nRowIni := nRowFin         // linha inicio
		nCIni:= 100            // coluna inicio
		oPrinter:Say(nRowIni+05,nCIni+400,"Autenticação Mecanica",oF07,100)
		oPrinter:Say(nRowIni+75,nCIni,Replicate("-  ",54),oF17,100)

		// Linha 7
		nRowIni:= nRowFin +150

		oPrinter:SayBitmap(nRowIni,0100,aBoleto[nX,26],430,80)
		oPrinter:Say(nRowIni+35,0200,"",oF17N,100)
		oPrinter:Say(nRowIni+35,0550," | "+alltrim(aBoleto[nX,54])+" | ",oF17N,100)
		oPrinter:Say(nRowIni+35,990,Transform(aBoleto[nX,4], "@R 99999.99999 99999.999999 99999.999999 9 99999999999999"),oF17N,100)  //  Say(nRowIni+20,850,Transform(aBoleto[nX,4], "@R 99999.99999 99999.999999 99999.999999 9 99999999999999"),oF14N,100)

		// Linha 8
		nRowIni += 100
		nRowFin:= nRowIni + 70
		oPrinter:Box(nRowIni,0100,nRowFin,1600)
		oPrinter:Say(nRowIni+05,0120,"Local de Pagamento",oF07,100)
		IF TRIM(aBoleto[nX,55]) == "104" // CAIXA ECONOMICA FEDERAL
			oPrinter:Say(nRowIni+32,0120,"PREFERENCIALMENTE NAS CASAS LOTÉRICAS ATÉ O VALOR LIMITE",oF08,100)
		ElseIF TRIM(aBoleto[nX,55]) == "237" // BRADESCO
			oPrinter:Say(nRowIni+32,0120,"Pagável Preferencialmente nas agências Bradesco",oF08,100)
		Else
			oPrinter:Say(nRowIni+32,0120,"PAGÁVEL EM QUALQUER BANCO ATÉ A DATA DE VENCIMENTO",oF08,100)
		EndIf
		//  oBrush1 := TBrush():New( , CLR_LIGHTGRAY )
		//  oPrinter:FillRect( {nRowIni,1700,nRowFin,2320}, oBrush1 )
		oPrinter:Box(nRowIni,1600,nRowFin,2320)
		oPrinter:Say(nRowIni+05 ,1620,"Vencimento",oF07,100)
		oPrinter:Say(nRowIni+20,1820,SubStr(DTOS(aBoleto[nX,33]),7,2)+"/"+SubStr(DTOS(aBoleto[nX,33]),5,2)+"/"+SubStr(DTOS(aBoleto[nX,33]),1,4),oF12N,100)

		// Linha 9
		nRowIni:= nRowFin
		nRowFin:= nRowIni + 70
		oPrinter:Box(nRowIni,0100,nRowFin,1600)
		oPrinter:Say(nRowIni+05,0120,"Beneficiário",oF07,100)
		oPrinter:Say(nRowIni+30,0120,aBoleto[nX,46] + " CNPJ: "+Transform(AllTrim(aBoleto[nX,42]),"@R 99.999.999/9999-99"),oF08,100)
		oPrinter:Box(nRowIni,1600,nRowFin,2320)
		IF TRIM(aBoleto[nX,55]) == "001" // BANCO DO BRASIL
			oPrinter:Say(nRowIni+05,1620,"Agencia /Código Benefic",oF07,100)
			oPrinter:Say(nRowIni+30,1820,ALLTRIM(aBoleto[nX,21]) + "/"+ ALLTRIM(aBoleto[nX,25])+ "-"+ ALLTRIM(aBoleto[nX,23]),oF09,100)
		ElseIF TRIM(aBoleto[nX,55]) == "104" // CAIXA ECONOMICA FEDERAL
			oPrinter:Say(nRowIni+05,1620,"Agencia /Código Benefic",oF07,100)
			cCpoInv    := InvSTR(aBoleto[nX,35])
			_cDVCta    := CALMOD11(AllTrim(cCpoInv),"23456789","00")			
			oPrinter:Say(nRowIni+30,1820,ALLTRIM(aBoleto[nX,21]) +"/"+ ALLTRIM(aBoleto[nX,35])+ "-"+ ALLTRIM(_cDVCta),oF09,100)
		ElseIf TRIM(aBoleto[nX,55]) == "756" // SICOOB
			//oPrinter:Say(nRowIni+05,1620,"Cooperativa contratante /Código Benefic",oF07,100)
			//oPrinter:Say(nRowIni+30,1820,ALLTRIM(aBoleto[nX,21]) +"/"+ ALLTRIM(aBoleto[nX,35]),oF09,100)
			oPrinter:Say(nRowIni+05,1620,"Agencia /Código Benefic",oF07,100)
			oPrinter:Say(nRowIni+30,1820,ALLTRIM(aBoleto[nX,21]) +"/"+ ALLTRIM(aBoleto[nX,25])+ "-"+ ALLTRIM(aBoleto[nX,23]),oF09,100)

		ElseIf TRIM(aBoleto[nX,55]) == "237" // BRADESCO
			oPrinter:Say(nRowIni+05,1620,"Agencia /Código Benefic",oF07,100)
			oPrinter:Say(nRowIni+30,1820,ALLTRIM(aBoleto[nX,21]) + "-"+ ALLTRIM(aBoleto[nX,22])+"/"+ StrZero(Val(aBoleto[nX,25]),7)+ "-"+ ALLTRIM(aBoleto[nX,23]),oF09,100)
		ELSE
			oPrinter:Say(nRowIni+05,1620,"Agencia /Código Benefic",oF07,100)
			oPrinter:Say(nRowIni+30,1820,ALLTRIM(aBoleto[nX,21]) + "-"+ ALLTRIM(aBoleto[nX,22])+"/"+ ALLTRIM(aBoleto[nX,25])+ "-"+ ALLTRIM(aBoleto[nX,23]),oF09,100)
		ENDIF
		// Linha 10
		nRowIni:= nRowFin
		nRowFin:= nRowIni + 70
		oPrinter:Box(nRowIni,0100,nRowFin,1600)
		oPrinter:Say(nRowIni+05,0120,"Endereço",oF07,100)
		oPrinter:Say(nRowIni+30,0120,Alltrim(aBoleto[nX,44]) + " Bairro: " + Alltrim(aBoleto[nX,40]) + " - " + Alltrim(aBoleto[nX,43]) + " - "+ aBoleto[nX,45] + " CEP: "+Transform(aBoleto[nX,41],"@R 99.999-999"),oF08,100)
		//oPrinter:Box(nRowIni,1600,nRowFin,2320)
		//NOSSO NÚMERO
		oPrinter:Box(nRowIni,1600,nRowFin,2320)
		oPrinter:Say(nRowIni+05,1620,"Nosso Número",oF07,100)
		IF TRIM(aBoleto[nX,55]) == "104" // CAIXA ECONOMICA FEDERAL
			cCpoInv   := InvSTR(aBoleto[nX,6])
			_cDvNN    := CALMOD11(AllTrim(cCpoInv),"23456789","00")
			oPrinter:Say(nRowIni+30,1820,transform(AllTrim(aBoleto[nX,6])+_cDVNN,"@R 99999999999999999-9"),oF09,120)
		ElseIF TRIM(aBoleto[nX,55]) == "237" // BRADESCO
			oPrinter:Say(nRowIni+30,1820,transform(Strzero(Val(aBoleto[nX,36]),3)+STRTRAN(aBoleto[nX,6],"-",""),"@R 999/99999999999-9"),oF09,120)
		ElseIF TRIM(aBoleto[nX,55]) == "341" // ITAU
			oPrinter:Say(nRowIni+30,1820,transform(Strzero(Val(aBoleto[nX,36]),3)+STRTRAN(aBoleto[nX,6],"-",""),"@R 999/99999999-9"),oF09,120)
		ElseIF TRIM(aBoleto[nX,55]) == "756" // SICOOB
			oPrinter:Say(nRowIni+30,1820,transform(StrZero(Val(aBoleto[nX,6]),8),"@R 99999999"),oF09,120)
		Else
			oPrinter:Say(nRowIni+30,1820,aBoleto[nX,6],oF09,120)
		EndIf

		// Linha 11
		nRowIni:= nRowFin -2
		nRowFin:= nRowIni + 70
		oPrinter:Box(nRowIni,0100,nRowFin,0500)
		oPrinter:Say(nRowIni+05,0120,"Data do Documento",oF07,100)
		oPrinter:Say(nRowIni+30,0120,SubStr(DTOS(aBoleto[nX,29]),7,2)+"/"+SubStr(DTOS(aBoleto[nX,29]),5,2)+"/"+SubStr(DTOS(aBoleto[nX,29]),1,4),oF08,100)
		//NÚMERO DO DOCUMENTO
		oPrinter:Box(nRowIni,0500,nRowFin,0850)
		oPrinter:Say(nRowIni+05,0520,"Nº do Documento",oF07,100)
		oPrinter:Say(nRowIni+30,0520,AllTrim(aBoleto[nX,30])+ IIF(!EMPTY(aBoleto[nX,31])," / ","")+AllTrim(aBoleto[nX,31]),oF08,100)
		//ESPÉCIE DO DOCUMENTO
		oPrinter:Box(nRowIni,0850,nRowFin,1050)
		oPrinter:Say(nRowIni+05,0870,"Espécie Doc.",oF07,100)
		oPrinter:Say(nRowIni+30,0870,aBoleto[nX,3],oF08,100)
		//ACEITE
		oPrinter:Box(nRowIni,1050,nRowFin,1210)
		oPrinter:Say(nRowIni+05,1070,"Aceite",oF07,100)
		oPrinter:Say(nRowIni+30,1070,"N",oF08N,100)
		//DATA PROCESSAMENTO
		oPrinter:Box(nRowIni,1210,nRowFin,1600)
		oPrinter:Say(nRowIni+05,1230,"Data Processamento",oF07,100)
		oPrinter:Say(nRowIni+30,1230,SubStr(DTOS(aBoleto[nX,34]),7,2)+"/"+SubStr(DTOS(aBoleto[nX,34]),5,2)+"/"+SubStr(DTOS(aBoleto[nX,34]),1,4),oF08,100)
		//(=) VALOR DO DOCUMENTO
		oPrinter:Box(nRowIni,1600,nRowFin,2320)
		oPrinter:Say(nRowIni+05,1620,"(=) Valor do Documento",oF07,100)
		oPrinter:Say(nRowIni+20,1820,Padl(Transform((aBoleto[nX,32] + aBoleto[nX,27] - aBoleto[nX,28]),"@E 999,999,999.99"),30),oF12N,100)
		// Linha 11
		nRowIni:= nRowFin -2
		nRowFin:= nRowIni + 70
		oPrinter:Box(nRowIni,0100,nRowFin,0500)
		IF TRIM(aBoleto[nX,55]) == "104" // CAIXA ECONOMICA FEDERAL
			oPrinter:Say(nRowIni+05,0120,"Uso do Banco",oF07,100)
		Else
			oPrinter:Say(nRowIni+05,0120,"Nº da Conta / Respons.",oF07,100)
		EndIf

		// CARTEIRA
		oPrinter:Box(nRowIni,0500,nRowFin,0650)
		oPrinter:Say(nRowIni+05,0520,"Carteira",oF07,100)
		IF TRIM(aBoleto[nX,55]) == "104" // CAIXA ECONOMICA FEDERAL
			oPrinter:Say(nRowIni+30,0520,"RG",oF08,100)
		Else
			oPrinter:Say(nRowIni+30,0520,ALLTRIM(aBoleto[nX,36]),oF08,100)
		Endif
		//ESPÉCIE
		oPrinter:Box(nRowIni,0650,nRowFin,0850)
		oPrinter:Say(nRowIni+05,0670,"Moeda",oF07,100)
		oPrinter:Say(nRowIni+30,0670,"R$",oF08,100)
		//QUANTIDADE
		oPrinter:Box(nRowIni,0850,nRowFin,1210)
		oPrinter:Say(nRowIni+05,0870,"Quantidade",oF07,100)
		//VALOR
		oPrinter:Box(nRowIni,1210,nRowFin,1600)
		oPrinter:Say(nRowIni+05,1230,"Valor",oF07,100)

		//(-)DESCONTO/ABATIMENTO
		//nRowFin:= nRowIni + 70
		oPrinter:Box(nRowIni,1600,nRowFin,2320)
		oPrinter:Say(nRowIni+05,1620,"(-) Desconto / Abatimento",oF07,100)

		// Linha 12
		nRowIni:= nRowFin -2
		nRowFin:= nRowIni + 280//350
		oPrinter:Box(nRowIni,0100,nRowFin,1600)
		oPrinter:Say(nRowIni,0120,"Instruções: (Texto de responsabilidade do beneficiário)",oF07,100)

		IF !Empty(aBoleto[nX,37])
			oPrinter:Say(nRowIni+060,0150,aBoleto[nX,37],oF08N,200)
		Endif

		IF !Empty(aBoleto[nX,38])
			oPrinter:Say(nRowIni+100,0150,aBoleto[nX,38],oF08N,200)
		Endif

		IF !Empty(aBoleto[nX,47])
			oPrinter:Say(nRowIni+140,0150,aBoleto[nX,47],oF08N,200)
		Endif

		IF !Empty(aBoleto[nX,48])
			oPrinter:Say(nRowIni+180,0150,aBoleto[nX,48],oF08N,200)
		Endif

		// Linha 13
		nRowIni:= nRowFin - 280
		nRowFin:= nRowIni + 70
		oPrinter:Box(nRowIni,1600,nRowFin,2320)
		oPrinter:Say(nRowIni+05,1620,"(-) Outras Deduções",oF07,100)

		// Linha 14
		//(+)MORA/MULTA
		nRowIni:= nRowFin -2
		nRowFin+= 70
		oPrinter:Box(nRowIni,1600,nRowFin,2320)
		oPrinter:Say(nRowIni+05,1620,"(+) Mora/Multa",oF07,100)

		// Linha 15
		nRowIni:= nRowFin
		nRowFin+= 70
		oPrinter:Box(nRowIni,1600,nRowFin,2320)
		oPrinter:Say(nRowIni+05,1620,"(+) Outros Acréscimos",oF07,100)

		// Linha 16
		nRowIni:= nRowFin -2
		nRowFin+= 70
		oPrinter:Box(nRowIni,1600,nRowFin,2320)
		oPrinter:Say(nRowIni+05,1620,"(=) Valor Cobrado",oF07,100)

		// Linha 17
		nRowIni:= nRowFin -2
		nRowFin += 165
		oPrinter:Box(nRowIni,0100,nRowFin,2320-2)
		If AllTrim(aBoleto[nX,20]) == "J"
			cCgcCpf := "    CNJP: "+ Transform(AllTrim(aBoleto[nX,11]),"@R 99.999.999/9999-99")
		Else
			cCgcCpf := "    CPF: "+Transform(AllTrim(aBoleto[nX,11]),"@R 999.999.999-99")
		EndIf
		oPrinter:Say(nRowIni+05,0120,"Pagador",oF07,100)
		oPrinter:Say(nRowIni+10,0250,AllTrim(aBoleto[nX,12])+" - "+ AllTrim(aBoleto[nX,19]) +SPACE(30)+ cCGCCpf,oF08,100)
		If Empty(AllTrim(aBoleto[nX,14])) //Criar configuração/parametrização
			oPrinter:Say(nRowIni+50,0250,AllTrim(aBoleto[nX,13])+ SPACE(30)+ "CEP: "+ Transform(AllTrim(aBoleto[nX,9]),"@R 99.999-999"),oF08,100)
			oPrinter:Say(nRowIni+90,0250,AllTrim(aBoleto[nX,7])+ " - " + AllTrim(aBoleto[nX,17]) + " - " + AllTrim(aBoleto[nX,15]),oF08,100)
		Else
			oPrinter:Say(nRowIni+50,0250,AllTrim(aBoleto[nX,14])+ SPACE(30)+ "CEP: "+ Transform(AllTrim(aBoleto[nX,10]),"@R 99.999-999"),oF08,100)
			oPrinter:Say(nRowIni+90,0250,AllTrim(aBoleto[nX,8])+ " - " + AllTrim(aBoleto[nX,18]) + " - " + AllTrim(aBoleto[nX,16]),oF08,100)
		EndIf
		oPrinter:Say(nRowIni+135,0120,"Pagador / Avalista",oF07,100)
		oPrinter:Say(nRowIni+135,1720,"Código da baixa: "+ space(10)+ aBoleto[nX,49],oF07,120)

		// Linha 18
		oPrinter:Say(nRowIni+170,1600,"Autenticação Mecânica",oF07,100)
		oPrinter:Say(nRowIni+175,1910," Ficha de compensação",oF09N,100)

		// Fim de impressao do layout
		oFont := TFont():New('Courier new',,-16,.T.)
		oPrinter:Int25(nRowFin,100,aBoleto[nX,2],0.73,40,.F.,.F., oFont)


        If !lArqUnico
        	oPrinter:Print()
            oPrinter := Nil
        EndIf
        
	Next
    
    If lArqUnico .and. lArqCriado
       	oPrinter:Print()
        oPrinter := Nil
    EndIf
    
	RestArea(cArea)
RETURN nil

Static Function fFDPExist(cArqPDF)
	Local nX := 0

	For nX := 1 to 20

		If !File(cArqPDF)
			conout('#####---->Nao existe - Tentantiva: '+ cvaltochar(nX)+ " ::: " + cArqPDF)
			Sleep(1000)
		EndIf

	Next nX

	For nX := 1 to 20

		aFilePDF := Directory(cArqPDF)    // Retorna um array com { cNomeArq, cTamanho, dData, cHora, cAtributos }

		If !EMPTY(aFilePDF)
			// Verifica se tamanho do PDF gerado está maior que zero
			If aFilePDF[1,2] > 0
				// Se maior que zero, OK! Então sai do loop
				Exit
			Else
				conout('#####---->Arquivo vazio - Tentantiva: '+ cvaltochar(nX)+ " ::: " +cArqPDF)
				Sleep(1000)
			EndIf
		EndIf
	Next nX

Return

//------------------------------------------------------- quebra da funcao ------------------------------------------------//
// Ponto de entrada utilizado na montagem do bordero para filtrar os boletos já gerados
User Function FA60FIL
	//*******************
	Private _Fil := ""
	 _Fil := "SE1->E1_PORTADO == cPort060 " 
	 _Fil += ".and. SE1->E1_AGEDEP == cAgen060 " 
	 _Fil += ".and. SE1->E1_CONTA == cConta060 " 
	//_Fil := 'SE1->E1_PORTADO != "" '
Return (_Fil)
//------------------------------------------------------- quebra da funcao ------------------------------------------------//
User Function TCOM271G()
	Local aArea     := GetArea()
	Local aPergs  	:= {}
	Local aRet 		:= {}
	Local nk := 0
	Local oDlg := nil
	Local aCampos := {}
	Local aDados := {}
	Local aButtons := {}
	Local cQuery := ""

    //Adicionando os parametros do ParamBox
    aAdd(aPergs, {1, "Filial De"     , Space(4)      ,  "", ".T.", "", ".T.", 30,  .F.})
    aAdd(aPergs, {1, "Filial Até"    , "ZZZZ"        ,  "", ".T.", "", ".T.", 30,  .T.})	
    aAdd(aPergs, {1, "Emissão De" 	 , Stod('20240101')   	 ,  "", ".T.", "", ".T.", 50,  .F.})
    aAdd(aPergs, {1, "Emissão Até"	 , dDataBase  	 ,  "", ".T.", "", ".T.", 50,  .T.})
    aAdd(aPergs, {1, "Vencimento De" , dDataBase	 ,  "", ".T.", "", ".T.", 50,  .F.})
    aAdd(aPergs, {1, "Vencimento Até", dDataBase+360 ,  "", ".T.", "", ".T.", 50,  .T.})
    aAdd(aPergs, {1, "Prefixo De" 	 , Space(3)      ,  "", ".T.", "", ".T.", 30,  .F.})
    aAdd(aPergs, {1, "Prefixo Até"	 , "ZZZ"         ,  "", ".T.", "", ".T.", 30,  .T.})
    aAdd(aPergs, {1, "Tipo De"    	 , Space(3)      ,  "", ".T.", "", ".T.", 30,  .F.})
    aAdd(aPergs, {1, "Tipo Até"   	 , "ZZZ"         ,  "", ".T.", "", ".T.", 30,  .T.})	
      
    //Se a pergunta for confirma, chama a tela
    If ParamBox(aPergs, "Informe os parametros",aRet,,,,,,,,.F.,)
		cQuery += " SELECT E1_NOME, E1_BANCO, E1_AGENCIA, E1_CONTA, COUNT(*) E1_QUANT, ROUND(SUM(E1_SALDO),2) E1_VALOR FROM("
		cQuery += " SELECT E1_FILIAL"
		cQuery += " ,E1_EMISSAO"
		cQuery += " ,E1_VENCREA"
		cQuery += " , CASE WHEN E1_PORTADO = '' THEN 'CARTEIRA' ELSE (SELECT A6_NREDUZ FROM "+RetSqlName('SA6')+" SA6 (NOLOCK) "
		cQuery += " WHERE D_E_L_E_T_ <> '*' AND A6_FILIAL = '"+XFILIAL('SA6')+"' AND A6_COD = E1_PORTADO AND A6_AGENCIA = E1_AGEDEP AND A6_NUMCON = E1_CONTA) END E1_NOME"
		cQuery += " ,E1_PORTADO E1_BANCO"
		cQuery += " ,E1_AGEDEP E1_AGENCIA"
		cQuery += " ,E1_CONTA  E1_CONTA"
		cQuery += " ,E1_VALOR + E1_ACRESC - E1_DECRESC AS E1_SALDO"
		cQuery += " FROM "+RetSqlName('SE1')+" SE1 (NOLOCK) "
		cQuery += " WHERE D_E_L_E_T_ <> '*' AND E1_BAIXA = ''"
		cQuery += " AND E1_FILIAL BETWEEN '"+aRet[1]+"' AND '"+aRet[2]+"'"
		cQuery += " AND E1_PREFIXO BETWEEN '"+aRet[7]+"' AND '"+aRet[8]+"'"
		cQuery += " AND E1_TIPO BETWEEN '"+aRet[9]+"' AND '"+aRet[10]+"'"
		cQuery += " AND E1_TIPO NOT IN('RA','NCC','CH','AB-')"
		cQuery += " )X"
		cQuery += " WHERE E1_EMISSAO BETWEEN '"+DtoS(aRet[3])+"' AND '"+DtoS(aRet[4])+"' "
		cQuery += " AND E1_VENCREA BETWEEN '"+DtoS(aRet[5])+"' AND '"+DtoS(aRet[6])+"'"
		cQuery += " GROUP BY E1_NOME, E1_BANCO, E1_CONTA, E1_AGENCIA"
		cQuery += " ORDER BY 6 DESC,5 DESC"


		aAdd(aCampos,{'Nome do banco'   ,'C',030,000,'@!',1})
		aAdd(aCampos,{'Banco'           ,'C',003,000,'@!',1})
		aAdd(aCampos,{'Agência'         ,'C',005,000,'@!',1})
		aAdd(aCampos,{'Conta'           ,'C',010,000,'@!',1})
		aAdd(aCampos,{'Qtd Titulo'      ,'N',006,000,'@E 999,999',2})
		aAdd(aCampos,{'Valor Total'     ,'N',012,002,'@E 999,999,999.99',2})

		//Se o alias estiver aberto, irei fechar, isso ajuda a evitar erros
		IF Select("QRYTRB") <> 0
			DbSelectArea("QRYTRB")
			DbCloseArea()
		ENDIF

		// Transforma resultado da query em dbf
		cQuery := ChangeQuery(cQuery)

		TCQuery cQuery New Alias QRYTRB
		dbSelectArea("QRYTRB")
		QRYTRB->(dbGoTop())
		If QRYTRB->(!EOF()) .and. QRYTRB->(!BOF())
			QRYTRB->(dbGoTop())
			nQtdTit  := 0
			nVlrTotal:= 0
			While !QRYTRB->(Eof())
				//           Nome             Banco             Agencia             Conta              Qtd. Titulo        Saldo         
				aAdd(aDados,{QRYTRB->E1_NOME, QRYTRB->E1_BANCO, QRYTRB->E1_AGENCIA, QRYTRB->E1_CONTA,  QRYTRB->E1_QUANT , QRYTRB->E1_VALOR })
				nQtdTit   += QRYTRB->E1_QUANT
				nVlrTotal += QRYTRB->E1_VALOR
				QRYTRB->(dbSkip())
			EndDo
		EndIf

		DEFINE DIALOG oDlg TITLE 'Situação de cobrança: Emissão entre '+ dtoc(aRet[3]) +' e '+ dtoc(aRet[4]) PIXEL
		oDlg:nWidth  := 1040 // 1100
		oDlg:nHeight := 400 // 800

		oPanel:= tPanel():New(032,003,"",oDlg,,,,,,515,130) // 20,70  / 300,300
		oDefSiz := FWDefSize():New( .T. , .F. , Nil , .T. )	 
		oDefSiz:aMargins := { 0 , 0 , 1 , 1 }
		oDefSiz:Process()
		
		oBrw := fwBrowse():New()

		oBrw:setOwner( oPanel )
		oBrw:setDataArray()
		oBrw:setArray( aDados )
		oBrw:disableConfig()
		oBrw:disableReport()
		oBrw:SetLocate() // Habilita a Localização de registros

		For nk:=1 to Len(aCampos)
			cTitle      := aCampos[nk,1]
			cTipo       := aCampos[nk,2]
			nTamanho    := aCampos[nk,3]
			nDecimal	:= aCampos[nk,4]
			cMascara    := aCampos[nk,5]
			nAlignm     := aCampos[nk,6]
			cMatriz := "{||aDados[oBrw:nAt,"+Strzero(nk,2)+"]}"
			oBrw:addColumn({cTitle             , &cMatriz, cTipo, cMascara  , nAlignm, nTamanho     ,                            , .F. , , .F.,, "aDados[oBrw:nAt,"+Strzero(nk,2)+"]",       , .F., .T.,                                    , ""    })
		Next
		oBrw:setEditCell( .T. , { || .T. } ) //activa edit and code block for validation
		oBrw:Activate(.T.)

		oGroup	:= TGroup():New(165, 001, 185,515,'',oDlg,,,.T.)
		oTGet1  := TGet():New(  168, 260, {|u|if(PCount()>0,nQtdTit  :=u,nQtdTit  )}       , oDlg  , 080       , 011        , "@E 999,999"             ,           ,0            ,             ,          ,.F.          ,             ,.T.        ,             ,.F.          ,  {|| .F.},.F.          ,.F.          ,            ,.F.           ,.F.           ,             , "nQtdTit"     ,             ,             ,             ,               ,              ,             , "Quant.Titulo:"  , 2            ,               ,                ,               ,                     ,             )
		oTGet1  := TGet():New(  168, 390, {|u|if(PCount()>0,nVlrTotal  :=u,nVlrTotal  )}   , oDlg  , 080       , 011        , "@E 999,999,999.99"      ,           ,0            ,             ,          ,.F.          ,             ,.T.        ,             ,.F.          ,  {|| .F.},.F.          ,.F.          ,            ,.F.           ,.F.           ,             , "nVlrTotal"     ,             ,             ,             ,               ,              ,             , "Valor Total:"  , 2            ,               ,                ,               ,                     ,             )



		ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg, {|| oDlg:End()} ,;
														  {||oDlg:End()} ,,@aButtons))    
	EndIf
	RestArea(aArea)

Return
//------------------------------------------------------- quebra da funcao ------------------------------------------------//
User Function TCOM271H()
    Private cAlias := "SE1"
    Private nReg   :=  Recno()
    Private nOpc   := 3
    Fina060(3)
Return
//------------------------------------------------------- quebra da funcao ------------------------------------------------//
User Function ViewDoc(cDirP, cNomeArqP)
    Local aArea:= GetArea()
     
    //Tentando abrir o objeto
    nRet := ShellExecute("open", cNomeArqP, "", cDirP, 1)
     
    //Se houver algum erro
    If nRet <= 32
        MsgStop("Não foi possível abrir o arquivo " +cDirP+cNomeArqP+ "!", "Atenção")
    EndIf 
     
    RestArea(aArea)
Return
