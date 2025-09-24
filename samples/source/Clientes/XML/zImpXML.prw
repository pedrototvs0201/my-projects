//Bibliotecas
#INCLUDE "PROTHEUS.CH"
#Include "TopConn.ch"

/*/{Protheus.doc} zImpXML
Fun��o criada para importar os xmls de fornecedores com op��o de pr� nota ou classificar direto em Documento de Entrada
@author Igor Brand�o Rodrigues
@since 09/11/2024
@version 1.0
@type function
/*/

User Function zImpXML()
	Local aArea       := GetArea()
	Local aPergs      := {}
	Local aRetorn     := {}
	Local oProcess    := Nil
	Local aButtons    := {}
	Local lOk         := .F.
	//Conte�dos dos par�metros
	Private cDirect   := "C:\xmls\" + Space(100)
	Private cTipoImp  := "1"
	Private cPedCom   := "2"
	Private cVldCNPJ  := "1"
	Private cAmarra   := "1"
	Private cCamFull  := cDirect + "*.xml"
	//Vari�veis usadas na importa��o
	Private aProd     := {}
	Private aCabec    := {}
	Private aItens    := {}
	Private cCadastro := "Importa��o XML"
	//Vari�veis usadas no MarkBrowse
	Private aCampos   := {}
	Private oMark
	Private oDlgXML
	Private aCpos     := {}
	Private cMarca    := GetMark()
	Private cArq
	Private lInvert
	//Dimensionamentos
	Private aTamanho  := MsAdvSize()
	Private	nJanLarg  := aTamanho[5]
	Private	nJanAltu  := aTamanho[6]
	Private nTopAux   := Iif(GetSrvProfString("RPOVERSION", "") == '120', aTamanho[1]+35, aTamanho[1]+5)
	Private aPos      := {nTopAux, aTamanho[1]+5, aTamanho[4]-15, aTamanho[3]}
	//Outras vari�veis
	Private nXML      := 0

	//Adiciona os parametros para a pergunta
	aAdd(aPergs, {1, "Diret�rio com arquivos xml",    cDirect, "", ".T.", "", ".T.", 80, .T.})
	aAdd(aPergs, {2, "Tipo Importa��o",               Val(cTipoImp), {"1=Pr� Nota"/*, "2=Classifica��o em Documento de Entrada"*/},     122, ".T.", .F.})
	aAdd(aPergs, {2, "Vincula Pedido de Compra",      Val(cPedCom),  {"1=Sim (Automaticamente)", "2=N�o"},                                       090, ".T.", .F.})
	aAdd(aPergs, {2, "Valida CNPJ Destinat�rio",      Val(cVldCNPJ), {"1=Sim",                   "2=N�o"},                                       040, ".T.", .F.})
	aAdd(aPergs, {2, "Incl Amarra��o Prod x Forn",    Val(cAmarra),  {"1=Sim",                   "2=N�o"},                                       040, ".T.", .F.})

	//Se a pergunta for confirmada
	If ParamBox(aPergs, "Informe os par�metros", @aRetorn, , , , , , , , .F., .F.)
		cDirect  := Alltrim(aRetorn[1])
		cTipoImp := cValToChar(aRetorn[2])
		cPedCom  := cValToChar(aRetorn[3])
		cVldCNPJ := cValToChar(aRetorn[4])
		cAmarra  := cValToChar(aRetorn[5])

		//Se o �ltimo caracter n�o for uma barra, ser� uma barra
		If SubStr(cDirect, Len(cDirect), 1) != '\'
			cDirect += "\"
		EndIf

		//Define o caminho full
		cCamFull := cDirect + "*.xml"

		//Campos para criar a estrutura da tempor�ria
		aAdd(aCampos, {"OK",        "C", 002,                   0})
		aAdd(aCampos, {"TIPO",      "C", 010,                   0})
		aAdd(aCampos, {"CODIGO",    "C", TamSX3('A2_COD')[1],   0})
		aAdd(aCampos, {"LOJA",      "C", TamSX3('A2_LOJA')[1],  0})
		aAdd(aCampos, {"RAZAO",     "C", TamSX3('A2_NOME')[1],  0})
		aAdd(aCampos, {"DOCUMENTO", "C", TamSX3('F1_DOC')[1],   0})
		aAdd(aCampos, {"SERIE",     "C", TamSX3('F1_SERIE')[1], 0})
		aAdd(aCampos, {"XML",       "C", 100,                   0})

		//Cria a Tempor�ria
		cArq := CriaTrab(aCampos)
		DbUseArea(.T., , cArq, "TMP", .T., .F.)
		IndRegua("TMP", cArq, "DOCUMENTO+SERIE", , , "Criando Controles")

		//Carregando os dados da tempor�ria
		oProcess := MsNewProcess():New({|| fCarrega(@oProcess) }, "Carregando tempor�ria", "Processando", .F.)
		oProcess:Activate()

		//Campos que ser�o mostrados na dialog
		aAdd(aCpos, {"OK"        , , " "            })
		aAdd(aCpos, {"TIPO"      , , "Tipo"         })
		aAdd(aCpos, {"CODIGO"    , , "Codigo"       })
		aAdd(aCpos, {"LOJA"      , , "Loja"         })
		aAdd(aCpos, {"RAZAO"     , , "Raz�o Social" })
		aAdd(aCpos, {"DOCUMENTO" , , "Documento"    })
		aAdd(aCpos, {"SERIE"     , , "Serie"        })
		aAdd(aCpos, {"XML"       , , "XML"          })

		//Bot�o de Pesquisar Nota
		aAdd(aButtons, {"PESQUISA", {|| u_zXMLPesq()}, "Pesquisar Nota" })

		DbSelectArea("TMP")
		TMP->(DbGoTop())

		//Se tem arquivos xml para importa��o
		If nXML > 0

			//Cria a janela para sele��o dos dados
			DEFINE MSDIALOG oDlgXML TITLE "Importacao XML" FROM 000, 000 To nJanAltu, nJanLarg PIXEL
			//Cria o objeto de sele��o dos dados
			lInvert := .F.
			oMark := MsSelect():New("TMP", "OK", , aCpos, @lInvert, cMarca, aPos)
			oMark:oBrowse:lHasMark    := .T.
			oMark:oBrowse:lCanAllMark := .T.
			oMark:oBrowse:bAllMark    := {|| fMarkAll(cMarca), oMark:oBrowse:Refresh()}
			oMark:bMark               := {|| oMark:oBrowse:Refresh()}
			ACTIVATE MSDIALOG oDlgXML CENTERED ON INIT EnchoiceBar(oDlgXML, {|| lOk := .T., oDlgXML:End()}, {|| lOk := .F., oDlgXML:End()}, , aButtons)

			//Se a tela foi confirmada, gera a importa��o dos dados
			If lOk
				oProcess := MsNewProcess():New({|| fGeraNfe(@oProcess) }, "Importando os documentos", "Processando", .F.)
				oProcess:Activate()
			EndIf
		Else
			MsgAlert("N�o h� XML(s) para importa��o, observe se o WEBAgent est� ativo!", "Aten��o")

		EndIf

		//Exclui a tempor�ria
		TMP->(DbCloseArea())
		fErase(cArq)
	EndIf

	RestArea(aArea)
Return

/*---------------------------------------------------------------------*
 | Func:  fCarrega                                                     |
 | Desc:  Fun��o que carrega os dados dos xml na tempor�ria            |
 *---------------------------------------------------------------------*/

Static Function fCarrega(oProc)
	Local nI            := 0
	Local aFiles        := {}
	Local cFile         := ""
	Local nHdl          := 0
	Local nTamFile      := 0
	Local cBuffer       := ""
	Local nBtLidos      := 0
	Local cAviso        := ""
	Local cErro         := ""
	Local cDocBranco    := Replicate('0', TamSX3('F1_DOC')[1])
	Local nTamSerie     := TamSX3('F1_SERIE')[1]
	Private oNfe
	Private oNF
	Private oEmitente
	Private oIdent
	Private oDestino
	Private oDet
	Private cCgcDest    := Space(14)
	Private cTipo       := ''
	Private cCodigo     := ''
	Private cLoja       := ''
	Private cRazao      := ''
	Private cCgcEmit    := ''
	Private cDoc        := ''
	Private cSerie      := ''
	Private lInclui 	 
	
	DbSelectArea('SA2')
	SA2->(DbSetOrder(3))
	DbSelectArea('SA1')
	SA1->(DbSetOrder(3))
	
	//Identificando os arquivos e colocando no array aFile
	aDir(cCamFull, aFiles)
	oProc:SetRegua1(Len(aFiles))
	
	//Percorre todos os arquivos
	For nI := 1 To Len(aFiles)
		//Pegando o arquivo
		cFile := cDirect + aFiles[nI]
		
		oProc:IncRegua1("Analisando arquivo "+cValToChar(nI)+" de "+cValToChar(Len(aFiles))+"...")
		oProc:SetRegua2(1)
		oProc:IncRegua2("...")
		
		//Se for a extens�o xml, abre o arquivo
		If Upper(Right(cFile, 4)) == ".XML"
			nHdl  := fOpen(cFile, 0)
		
			//Se n�o foi poss�vel abrir
			If nHdl == -1
				If !Empty(cFile)
					Aviso("Aten��o", "Erro #001:"+ CRLF +"O arquivo de nome '"+cFile+"' n�o pode ser aberto!", {"Ok"}, 2)
				EndIf
			Else
				oProc:SetRegua2(4)
				oProc:IncRegua2("Analisando arquivo "+cFile+"...")
				
				//Pega o conte�do do arquivo (n�o foi usado MemoRead pois o limite de uma vari�vel caracter pode mudar)
				nTamFile := fSeek(nHdl, 0, 2)
				fSeek(nHdl, 0, 0)
				cBuffer  := Space(nTamFile)
				nBtLidos := fRead(nHdl, @cBuffer, nTamFile)
				fClose(nHdl)
				
				//Transforma o XML em Objeto
				cAviso := ""
				cErro  := ""
				oNfe   := XmlParser(cBuffer, "_", @cAviso, @cErro)
				
				//Caso n�o tenha erro
				If (Empty(cErro))
					oNF      := Nil
					cTipo    := ''
					cCodigo  := ''
					cLoja    := ''
					cRazao   := ''
					
					//Se tiver a tag NfeProc, pega dela
					If Type("oNFe:_NfeProc") != "U"
						If Type("oNFe:_NfeProc:_NFe") != "U"
							oNF := oNFe:_NFeProc:_NFe
						EndIf
						
					//Sen�o pega direto da tag NFe
					ElseIf Type("oNFe:_Nfe") != "U"
						oNF := oNFe:_NFe
					EndIf
					
					//Se tiver dados de NF
					If oNF != Nil
						oProc:IncRegua2("Transformando em objeto...")
						
						//Pega as tags para definir as vari�veis
						oEmitente  := oNF:_InfNfe:_Emit
						oIdent     := oNF:_InfNfe:_IDE
						oDestino   := oNF:_InfNfe:_Dest
						oDet       := oNF:_InfNfe:_Det
						cCgcDest   := Space(14)
						oDet       := IIf(ValType(oDet)=="O", {oDet}, oDet)
						cCgcEmit   := Alltrim(IIf(Type("oEmitente:_CPF")=="U", oEmitente:_CNPJ:TEXT, oEmitente:_CPF:TEXT))
						cCgcDest   := Alltrim(IIf(Type("oDestino:_CPF")=="U", oDestino:_CNPJ:Text, oDestino:_CPF:Text))
						cDoc       := Right(cDocBranco+Alltrim(oIdent:_nNF:TEXT), Len(cDocBranco))
						cSerie     := PadR(oIdent:_serie:TEXT, nTamSerie)
					    
					    oProc:IncRegua2("Pegando atributos...")
					    
						//Se n�o conseguir posicionar no fornecedor
						If ! SA2->(DbSeek(FWxFilial("SA2") + cCgcEmit))
							//Se n�o conseguir posicionar no cliente
							If ! SA1->(DbSeek(FWxFilial("SA1") + cCgcEmit))
								Aviso("Aten��o", "Erro #002:"+ CRLF +"CNPJ Origem n�o encontrado - arquivo '"+cFile+"'!", {"Ok"}, 2)
		
							Else
								//Caso o cliente esteja bloqueado, percorre os clientes enquanto for o mesmo CNPJ at� encontrar 1 que n�o esteja bloqueado
								If SA1->A1_MSBLQL == '1'
									While ! SA1->(EoF()) .And. SA1->A1_FILIAL == FWxFilial('SA1') .And. SA1->A1_CGC == cCgcEmit .And. SA1->A1_MSBLQL == '1'
										SA1->(DbSkip())
									EndDo
								EndIf
								
								//Define as vari�veis para inclus�o no browse
								cTipo   := 'CLIENTE'
								cCodigo := SA1->A1_COD
								cLoja   := SA1->A1_LOJA
								cRazao  := SA1->A1_NOME
								lInclui := .T.
								If SA1->A1_CGC != cCgcEmit
									lInclui := .F.
								EndIf
							EndIf
		
						Else
							//Caso o fornecedor esteja bloqueado, percorre os fornecedores at� encontrar 1 que n�o esteja
							If SA2->A2_MSBLQL == '1'
								While ! SA2->(EoF()) .And. SA2->A2_FILIAL == FWxFilial('SA2') .And. SA2->A2_CGC == cCgcEmit .And. SA2->A2_MSBLQL == '1'
									SA2->(DbSkip())
								EndDo
							EndIf
							
							//Define as vari�veis para inclus�o no browse
							cTipo   := 'FORNECEDOR'
							cCodigo := SA2->A2_COD
							cLoja   := SA2->A2_LOJA
							cRazao  := SA2->A2_NOME
							lInclui := .T.
							If SA2->A2_CGC != cCgcEmit
								lInclui := .F.
							EndIf
						EndIf
						
						//Se for para validar o CNPJ do Destinat�rio
						If cVldCNPJ == "1"
							//Caso seja diferente do CNPJ, n�o ser� inclus�o
							If cCgcDest != SM0->M0_CGC
								Aviso("Aten��o", "Erro #009:"+ CRLF +"Documento/s�rie '"+cDoc+"/"+cSerie+"' foi emitido com destinat�rio para '"+cCgcDest+"' e n�o para '"+SM0->M0_CGC+"'!"+CRLF+CRLF+"Arquivo: "+cFile, {"Ok"}, 2)
								lInclui := .F.
							EndIf
						EndIf
						
						oProc:IncRegua2("Incluindo na tempor�ria...")
						
						//Caso seja inclus�o
						If lInclui
							//Se tiver um tipo
							If ! Empty(cTipo)
								RecLock('TMP', .T.)
									OK        := ''
									TIPO      := cTipo
									CODIGO    := cCodigo
									LOJA      := cLoja
									RAZAO     := cRazao
							        DOCUMENTO := cDoc
							        SERIE     := cSerie
									XML       := aFiles[nI]
								TMP->(MsUnlock())
								
								nXML++
							EndIf
						EndIf
					EndIf
				Else
					Aviso("Aten��o", "Erro #003:"+ CRLF +"Falha ao transformar em objeto o XML - '"+cFile+"'!"+CRLF+cErro, {"Ok"}, 2)
				EndIf
			EndIf
	    EndIf
	Next
Return

/*---------------------------------------------------------------------*
 | Func:  fGeraNfe                                                     |
 | Desc:  Fun��o que gera os dados da nota                             |
 *---------------------------------------------------------------------*/

Static Function fGeraNfe(oProc)
	Local nCont
	Local nContLote
	Local cQuery
	Local nItem        := 0
	Local lGera        := .T.
	Local cFile        := ''
	Local nHdl         := 0
	Local nTamFile     := 0
	Local cBuffer      := ''
	Local nBtLidos     := 0
	Local cAviso       := ''
	Local cErro        := ''
	Local cDocBranco   := Replicate('0', TamSX3('F1_DOC')[1])
	Local nTamSerie    := TamSX3('F1_SERIE')[1]
	Local cCodFornAx   := ''
	Local lOkItem
	Local cDescProF    := ''
	Local nFator
	Local lMed
	Local nTotalMed
	Local nQtdeLote
	Local cLote
	Local cValidade
	Local nDescTT
	Local nValorTT
	Local nDescLote
	Local nValLote
	Local cPedAut
	Local cItPedAut
	Local nTamProd     := TamSX3('B1_COD')[1]
	//Local nTamForn     := TamSX3('A2_COD')[1]
	//Local nTamLoja     := TamSX3('A2_LOJA')[1]
	Local nPosProd
	Local nFrete
	Local nSeguro
	Local nIcmsSubs
	Local nTotalMerc
	Local cData
	Local dData
	Local cChaveNFE
	Local cFileImp
	Local nAtuMark     := 0
	Local nTotalMark   := 0
	Local cCodProInc   := ""
	Local cQryFOR
	Local cQryCLI
	Private cCodPro
	Private oNfe
	Private oNF
	Private oEmitente
	Private oIdent
	Private oDet
	Private oDlgAmarra
	Private oGetProd, cGetProd := Space(nTamProd)
	Private oSayForn
	Private oSaySemA
	Private oSayProd
	Private oBtnGrav
	Private oBtnFech
	Private oNFAux
	Private aProd        := {}
	Private aCabec       := {}
	Private aItens       := {}
	Private lMsErroAuto  := .F.
	Private aRotina      := {}
	Private aHeadSD1     := {}
	Private cCodigo
	Private cLoja
	Private cRazao
	Private cCodForn
	Private cUnidad
	

	
	
	DbSelectArea('SA2')
	SA2->(DbSetOrder(3))
	DbSelectArea('SA1')
	SA1->(DbSetOrder(3))
	DbSelectArea('SF1')
	SF1->(DbSetOrder(1))
	DbSelectArea("SA5")
	DbSelectArea("SB1")
	DbSelectArea("SLK")
	
	//Enquanto houver registros
	TMP->(DbGoTop())
	While ! TMP->(EoF())
	
		//Se o registro tiver marcado, incrementa a vari�vel
		If TMP->OK == cMarca
			nTotalMark++
		EndIf
		
		TMP->(DbSkip())
	EndDo
	oProc:SetRegua1(nTotalMark)
	
	//Percorre os dados da tempor�ria
	DbSelectArea('TMP')
	TMP->(DbGoTop())
	While ! TMP->(EoF())
		aProd := {}
		
		//Se o registro tiver marcado
		If TMP->OK == cMarca
			nAtuMark++
			oProc:IncRegua1("Analisando documento '"+TMP->DOCUMENTO+"' ("+cValToChar(nAtuMark)+" de "+cValToChar(nTotalMark)+")...")
			oProc:SetRegua2(1)
			oProc:IncRegua2("...")
			
			nItem  := 0
			lGera  := .T.
			aCabec := {}
			aItens := {}
			
			//Abrindo o arquivo
			cFile    := cDirect + Alltrim(TMP->XML)
			nHdl     := fOpen(cFile, 0)
			nTamFile := fSeek(nHdl, 0, 2)
			fSeek(nHdl, 0, 0)
			cBuffer  := Space(nTamFile)
			nBtLidos := fRead(nHdl, @cBuffer, nTamFile)
			fClose(nHdl)
			
			//Transformando texto em um objeto
			cAviso := ""
			cErro  := ""
			oNfe := XmlParser(cBuffer, "_", @cAviso, @cErro)
			
			//Caso tenha a tag NfeProc, pega dentro dela a tag NFe
			If Type("oNFe:_NfeProc") != "U"
				oNF := oNFe:_NFeProc:_NFe
			Else
				oNF := oNFe:_NFe
			EndIf
			
			//Pegando os atributos das tags
			oEmitente  := oNF:_InfNfe:_Emit
			oIdent     := oNF:_InfNfe:_IDE
			oDet       := oNF:_InfNfe:_Det
			oDet       := IIf(ValType(oDet)=="O", {oDet}, oDet)
			cCgcEmit   := Alltrim(IIf(Type("oEmitente:_CPF")=="U", oEmitente:_CNPJ:TEXT, oEmitente:_CPF:TEXT))
			cDoc       := Right(cDocBranco + Alltrim(oIdent:_nNF:TEXT), Len(cDocBranco))
			cSerie     := PadR(oIdent:_Serie:TEXT, nTamSerie)
			cTipo      := ''
			cCodigo    := TMP->CODIGO
			cLoja      := TMP->LOJA
			cRazao     := TMP->RAZAO
			
			oProc:SetRegua2(Len(oDet) +3)
			oProc:IncRegua2("Analisando dados do documento...")

			// faz select no banco para verificar se existe fornecedor com o mesmo CGC
		
		cQryFOR := " SELECT "
		cQryFOR += " COUNT(A2_COD) CONTA"
		cQryFOR += " FROM "
		cQryFOR += " 	"+RetSQLName('SA2')+" SA2 " 
		cQryFOR += " WHERE  A2_CGC ='"+cCgcEmit+"'"
		cQryFOR += " 	AND D_E_L_E_T_ = ' ' group by A2_COD "
		TCQuery cQryFOR New Alias "QRY_FOR"

		cQryCLI := " SELECT "
		cQryCLI += " COUNT(A1_COD) CONTA"
		cQryCLI += " FROM "
		cQryCLI += " 	"+RetSQLName('SA1')+" SA1 " 
		cQryCLI += " WHERE  A1_CGC ='"+cCgcEmit+"'"
		cQryCLI += " 	AND D_E_L_E_T_ = ' ' group by A1_COD "
		TCQuery cQryCLI New Alias "QRY_CLI"

// se tiver fornecedor traz a conta contabil e finaliza o ponto de entrada
			
			
			//Se n�o conseguir posicionar no fornecedor
			//If !SA2->(DbSeek(FWxFilial("SA2") + cCgcEmit))
			//	MsgAlert("Teste fonecedor " + cCgcEmit +'  ' +TMP->CODIGO)
				//Caso n�o encontre o cliente
				//If !SA1->(DbSeek(FWxFilial("SA1") + cCgcEmit))
				//MsgAlert("Teste cliente " + cCgcEmit+'  ' +TMP->CODIGO)
				
					//Aviso("Aten��o", "Erro #004:"+ CRLF +"CNPJ Origem N�o Localizado,'"+cCgcEmit+"' verificar o xml - '"+cFile+"'!", {"Ok"}, 2)
				//	lGera := .F.
				//Else
				//	cTipo   := 'C'
				//EndIf
			
			//Else

			IF QRY_FOR->CONTA > 0
				cTipo   := 'F'
				QRY_FOR->(DbCloseArea())
					QRY_CLI->(DbCloseArea())
				ELSEIF QRY_CLI->CONTA > 0
				cTipo := 'C'
				QRY_FOR->(DbCloseArea())
					QRY_CLI->(DbCloseArea())
				else 	
				Aviso("Aten��o", "Erro #004:"+ CRLF +"CNPJ Origem N�o Localizado,'"+cCgcEmit+"' verificar o xml - '"+cFile+"'!", {"Ok"}, 2)
					QRY_FOR->(DbCloseArea())
					QRY_CLI->(DbCloseArea())
					lGera := .F.
			EndIf
			
			//Se conseguir posicionar na nota
			If SF1->(DbSeek(FWxFilial("SF1") + cDoc + cSerie + cCodigo + cLoja))
				//Se a nota for da Esp�cie SPED
				If Alltrim(SF1->F1_ESPECIE) == 'SPED'
					Aviso("Aten��o", "Erro #005:"+ CRLF +"Nota '"+cDoc+"' com a S�rie '"+cSerie+"' j� foi importada para o "+Iif(cTipo=='F', "Fornecedor", "Cliente")+" '"+cCodigo+"/"+cLoja+"'!", {"Ok"}, 2)
					lGera := .F.
					TMP->(DbSkip())
					Loop
				EndIf
			EndIf
			
			//Percorre os itens da Nota
			cCodFornAx := Alltrim(oDet[01]:_Prod:_cProd:Text)
			For nCont := 1 To Len(oDet)
				cDescProF := oDet[nCont]:_Prod:_xProd:Text
				cCodBarra := oDet[nCont]:_Prod:_CEAN:Text
				cCodForn  := Alltrim(oDet[nCont]:_Prod:_CPROD:Text)
				nQuant    := Val(oDet[nCont]:_Prod:_QCOM:Text)
				nPrcUnBrt := Val(oDet[nCont]:_Prod:_VUNCOM:Text)
				nPrcTtBrt := nQuant * nPrcUnBrt
				nValDesc  := 0
				lOkItem   := .F.
				cCodPro   := ''
				cUnidad   := ''
				
				oProc:IncRegua2("Analisando produto ("+cValToChar(nCont)+" de "+cValToChar(Len(oDet))+")...")
				
				//Se tiver a tag VDESC, pega o valor de desconto
				If XmlChildEx(oDet[nCont]:_PROD, "_VDESC")!= Nil
					nValDesc := Val(oDet[nCont]:_Prod:_VDESC:Text)
				EndIf
				
				//Ir� ser verificado se existem zeros a esquerda
				If Alltrim(Str(Val(cCodForn))) != cCodForn .And. Val(cCodForn) > 0
					cCodForn     := Alltrim(Str(val(cCodForn)))
					
					//Caso exista o produto na SA5
					SA5->(DbSetOrder(5))
					If SA5->(DbSeek(FWxFilial("SA5") + cCodForn))
						//Enquanto houver dados na SA5 para esse c�gio
						While ! SA5->(EoF()) .And. Alltrim(SA5->A5_CODPRF) == cCodForn
							//Se for o mesmo Fornecedor e Loja
							If SA5->(A5_FORNECE+A5_LOJA) == cCodigo+cLoja
								lOkItem    := .T.
								cCodFornAx := cCodForn
								cCodPro    := SA5->A5_PRODUTO
								cUnidad    := SA5->A5_UNID
								Exit
							EndIf
							
							SA5->(DbSkip())
						EndDo
					EndIf
				EndIf
				
				//Caso n�o tenha encontrado
				If ! lOkItem
					//Procura pelo c�digo na SA5 com o c�digo do fornecedor
					SA5->(DbSetOrder(5))
					If SA5->(DbSeek(FWxFilial("SA5") + cCodForn))
						//Enquanto houver dados na SA5 para esse c�digo
						While  ! SA5->(EoF()) .And. Alltrim(SA5->A5_CODPRF) == cCodForn
							//Se for o mesmo fornecedor
							If SA5->(A5_FORNECE+A5_LOJA) == cCodigo+cLoja
								lOkItem := .T.
								cCodPro := SA5->A5_PRODUTO
								cUnidad := SA5->A5_UNID
								Exit
							EndIf
							SA5->(DbSkip())
						EndDo
					EndIf
				EndIf
				
				//Se tiver c�digo de barras
				If ! lOkItem .And. ! Empty(cCodBarra)
					//Busca pelo Codigo de Barras no cadastro do produto
					SB1->(DbSetOrder(5))
					If SB1->(DbSeek(FWxFilial("SB1")+cCodBarra))
						cCodPro := SB1->B1_COD
						
						//Verifica se existe uma amarracao para o produto encontrado
						SA5->(DbSetOrder(2))
						If ! (SA5->(DbSeek(FWxFilial("SA5") + cCodPro + cCodigo + cLoja)))
							//Inclui a amarracao do produto X Fornecedor
							lOkItem := .T.
							RecLock("SA5", .T.)
								A5_FILIAL  := FWxFilial("SA5")
								A5_FORNECE := cCodigo
								A5_LOJA    := cLoja
								A5_NOMEFOR := SA2->A2_NOME
								A5_PRODUTO := cCodPro
								A5_NOMPROD := SB1->B1_DESC
								A5_CODPRF  := cCodForn
							SA5->(MsUnLock())
						Else
							//Atualiza a amarracao se nao tiver o codigo do fornecedor cadastrado.
							If Empty(SA5->A5_CODPRF) .Or. SA5->A5_CODPRF == "0"
								lOkItem := .T.
								RecLock("SA5", .F.)
									A5_CODPRF := cCodForn
								SA5->(MsUnLock())
							EndIf
						EndIf
					EndIf
					
					//Caso n�o esteja ok, procura na tabela SLK pelo c�digo de barras
					If !lOkItem
						SLK->(DbSetOrder(1))
						If SLK->(DbSeek(FWxFilial("SLK") + cCodBarra))
							lOkItem := .T.
							cUnidad := "3"
							cCodigo := SLK->LK_CODIGO
						EndIf
					EndIf
				EndIf
				
				//Se o c�digo do fornecedor estiver diferente
				If Alltrim(cCodForn) != Alltrim(cCodFornAx)
					lOkItem    := .F.
					cCodFornAx := cCodForn
				EndIf
				
				//Se n�o tiver OK
				If ! lOkItem
					//Se for para incluir amarra��o entre produto e fornecedor
					If cAmarra == "1"
						//Seleciona a quantidade de registros existente entre Fornecedor e Produto
						cQuery := " SELECT "
						cQuery += "    COUNT(*) QTDE "
						cQuery += " FROM "
						cQuery += "    "+RetSqlName('SA5')+" SA5 "
						cQuery += " WHERE "
						cQuery += "    A5_FORNECE = '"+cCodigo+"' "
						cQuery += "    AND A5_LOJA = '"+cLoja+"' "
						cQuery += "    AND A5_CODPRF = '"+cCodForn+"' "
						cQuery += "    AND SA5.D_E_L_E_T_ = ' ' "
						TcQuery cQuery New Alias "QSA5"
						
						//Caso n�o tenha a amarra��o
						If (QSA5->QTDE == 0)
							cGetProd := Space(nTamProd)
							/*
							//Mostra a janela para cria��o da amarra��o
							DEFINE MSDIALOG oDlgAmarra TITLE "Incluir Amarra��o" FROM 000, 000  To 150, 420 COLORS 0, 16777215 PIXEL
								@ 010, 015 SAY    oSayForn PROMPT "Fornecedor: "+ cCodigo +"/"+ cLoja +" ("+ Alltrim(SubStr(cRazao, 1, 40)) +")"     SIZE 150, 007 OF oDlgAmarra COLORS 0, 16777215 PIXEL
								@ 020, 015 SAY    oSaySemA PROMPT "Produto Sem Amarra��o: "+ cCodForn +" ("+ Alltrim(SubStr(cDescProF, 1, 50)) +")"  SIZE 150, 007 OF oDlgAmarra COLORS 0, 16777215 PIXEL
								@ 030, 015 SAY    oSayProd PROMPT "Produto : "                                                              SIZE 150, 007 OF oDlgAmarra COLORS 0, 16777215 PIXEL
								@ 030, 040 MSGET  oGetProd VAR    cGetProd                                                                  SIZE 060, 010 OF oDlgAmarra COLORS 0, 16777215 F3 'SB1' PIXEL
								@ 050, 120 BUTTON oBtnGrav PROMPT "&OK"                                                                     SIZE 037, 012 ACTION (fGravaProd(), oDlgAmarra:End()) OF oDlgAmarra PIXEL
								@ 050, 160 BUTTON oBtnFech PROMPT "&Fechar"                                                                 SIZE 037, 012 ACTION oDlgAmarra:End() OF oDlgAmarra PIXEL
							Activate Dialog oDlgAmarra Centered
							*/

	//REALIZA INCLUS�O DO PRODUTO A PARTIR DO XML

	// Gera proximo c�digo para o produto
	cCodProInc := GetSXENum("SB1","B1_COD")
	//if !FWAlertYesNo( '<strong>'+Alltrim(cCodForn) + " - " + Alltrim(oDet[nCont]:_Prod:_XPROD:TEXT) + '</strong>.'+chr(13)+chr(10)+chr(13)+chr(10)+'Informe <strong>SIM para cadastrar este produto automaticamente</strong> ou N�O para encerrar a importa��o.', "Produto n�o Cadastrado!")
	//	Exit ALTERADO IGOR 11/04/2025
	//endif

	// Realiza execauto de inclus�o de produto
	U_IncProd(cCodProInc, Alltrim(oDet[nCont]:_Prod:_XPROD:TEXT), "MP", oDet[nCont]:_Prod:_UTRIB:TEXT, "01", Alltrim(oDet[nCont]:_Prod:_XPROD:TEXT), oDet[nCont]:_Prod:_NCM:TEXT)
	// Captura recno do produto que acabou de ser cadastrado
	DBSelectArea("SB1")
	SB1->(DBSetOrder(1))
	SB1->(Recno())
	FWAlertWarning( '<strong>'+Alltrim(cCodForn) + " - " + Alltrim(oDet[nCont]:_Prod:_XPROD:TEXT) + '</strong>.'+chr(13)+chr(10)+chr(13)+chr(10)+'Foi relizado o cadastro autom�tico do produto <strong>'+SB1->B1_COD+' - '+SB1->B1_DESC+'</strong>.'+chr(13)+chr(10)+'Na tela a seguir, voc� pode alterar ou complementar informa��es desse produto. Caso n�o tenha nenhuma altera��o a fazer no produto, clique em FECHAR/CANCELAR na tela a seguir.', "Novo Produto Cadastrado!")
	// Chama MVC de altera��o de produto, para que usuario possa
	// complementar informa��o do produto que foi cadastrado automaticamente.
	A010ALTERA("SB1",SB1->(Recno()),4)

	// Garante posicionamento no produto que foi cadastrado automaticamente.
	SB1->(DbSeek(xFilial("SB1")+cCodProInc))

	//Realiza amarra��o de Produto x Fornecedor
	U_EXEC061(cCodProInc,cCodForn,SB1->B1_DESC, cCodigo, cLoja)

	// Atribui c�digo do produto cadastrado a vari�vel que faz o DE / PARA do c�digo do fornecedor
	// para o c�digo do produto interno (no caso o produto que acabou de ser cadastrado automaticamente)
	cCodPro := SB1->B1_COD

EndIf
QSA5->(DbCloseArea())

Else
	// Gera proximo c�digo para o produto
	cCodProInc := GetSXENum("SB1","B1_COD")
	//if !FWAlertYesNo( '<strong>'+Alltrim(cCodForn) + " - " + Alltrim(oDet[nCont]:_Prod:_XPROD:TEXT) + '</strong>.'+chr(13)+chr(10)+chr(13)+chr(10)+'Informe <strong>SIM para cadastrar este produto automaticamente</strong> ou N�O para encerrar a importa��o.', "Produto n�o Cadastrado!")
	//	Exit ALTERADO IGOR 11/04/2025
	//endif

	// Realiza execauto de inclus�o de produto
	U_IncProd(cCodProInc, Alltrim(oDet[nCont]:_Prod:_XPROD:TEXT), "PA", oDet[nCont]:_Prod:_UTRIB:TEXT, "01", Alltrim(oDet[nCont]:_Prod:_XPROD:TEXT), oDet[nCont]:_Prod:_NCM:TEXT)
	// Captura recno do produto que acabou de ser cadastrado
	DBSelectArea("SB1")
	SB1->(DBSetOrder(1))
	SB1->(Recno())
	FWAlertWarning( '<strong>'+Alltrim(cCodForn) + " - " + Alltrim(oDet[nCont]:_Prod:_XPROD:TEXT) + '</strong>.'+chr(13)+chr(10)+chr(13)+chr(10)+'Foi relizado o cadastro autom�tico do produto <strong>'+SB1->B1_COD+' - '+SB1->B1_DESC+'</strong>.'+chr(13)+chr(10)+'Na tela a seguir, voc� pode alterar ou complementar informa��es desse produto. Caso n�o tenha nenhuma altera��o a fazer no produto, clique em FECHAR/CANCELAR na tela a seguir.', "Novo Produto Cadastrado!")
	// Chama MVC de altera��o de produto, para que usuario possa
	// complementar informa��o do produto que foi cadastrado automaticamente.
	A010ALTERA("SB1",SB1->(Recno()),4)

	// Garante posicionamento no produto que foi cadastrado automaticamente.
	SB1->(DbSeek(xFilial("SB1")+cCodProInc))

	// Atribui c�digo do produto cadastrado a vari�vel que faz o DE / PARA do c�digo do fornecedor
	// para o c�digo do produto interno (no caso o produto que acabou de ser cadastrado automaticamente)
	cCodPro := SB1->B1_COD
EndIf

//Se tiver em branco o c�digo do produto
If Empty(cCodPro)
	Aviso("Aten��o", "Erro #006:"+ CRLF +"Produto sem amarra��o '"+cCodForn+"' ("+cDescProF+")!"+CRLF+"C�digo de Barras: "+cCodBarra, {"Ok"}, 2)
	lGera := .F.
	TMP->(DbSkip())
	Loop
EndIf
EndIf

//Se n�o encontrar o item, adiciona no array
If (aScan(aProd, {|x| x[01] == StrZero(nCont, 3)}) == 0)
	aAdd(aProd, {StrZero(nCont, 3), cCodPro})
EndIf

//Posiciona no produto encontrado
SB1->(DbSetOrder(1))
SB1->(DbSeek(FWxFilial("SB1")+cCodPro))

//Se o produto estiver bloqueado
If SB1->B1_MSBLQL == '1'
	Aviso("Aten��o", "Erro #007:"+ CRLF +"Produto '"+Alltrim(SB1->B1_COD)+"' ("+Alltrim(SB1->B1_DESC)+") est� bloqueado!", {"Ok"}, 2)
	lGera := .F.
	TMP->(DbSkip())
	Loop
EndIf

//Pegando o fator de m�ltiplica��o
nFator := 1
If cUnidad == "2"
	nFator := SB1->B1_CONV
ElseIf cUnidad == "3" .And. SLK->LK_QUANT > 1
	nFator := SLK->LK_QUANT
EndIf

//Possui a tag MED
lMed := XmlChildEx(oDet[nCont]:_Prod , "_MED" ) != Nil

//Se existir a tag
If lMed
	//Converte a tag em um array, caso exista mais de um lote para o produto
	If ValType(oDet[nCont]:_PROD:_MED) == "O"
		XmlNode2Arr(oDet[nCont]:_PROD:_MED, "_MED")
	EndIf
	nTotalMed := Len(oDet[nCont]:_PROD:_MED)
Else
	nTotalMed := 1
	nQtdeLote := nQuant
	cLote     := ""
	cValidade := ""
EndIf
nDescTT  := 0
nValorTT := 0

//Percorre os lotes para o produto
For nContLote := 1 To nTotalMed
	//Se tiver a tag MED
	If lMed
		cLote     := oDet[nCont]:_Prod:_MED[nContLote]:_NLote:Text
		cValidade := oDet[nCont]:_Prod:_MED[nContLote]:_DVal:Text
		cValidade := SubStr(cValidade, 9, 2)+"/"+SubStr(cValidade, 6, 2)+"/"+SubStr(cValidade, 1, 4)
		nQtdeLote := Val(oDet[nCont]:_Prod:_MED[nContLote]:_QLote:Text)
	EndIf

	//Se o numero atual for diferente do total de lotes
	If nContLote != nTotalMed
		nDescLote := Round(nValDesc/nQuant*nQtdeLote, 2)  //Desconto do Lote Atual
		nValLote  := Round(nPrcTtBrt/nQuant*nQtdeLote, 2) //Valor do Lote Atual

		nDescTT   += nDescLote
		nValorTT  += nValLote
	Else
		nDescLote := nValDesc  - nDescTT  //Desconto do Lote Atual - Diferenca
		nValLote  := nPrcTtBrt - nValorTT //Valor do Lote Atual - Diferenca
	EndIf

	//Se tiver fator de convers�o, multiplica a quantidade
	If nFator > 1
		nQtdeLote := nQtdeLote*SB1->B1_CONV
	EndIf

	//Se for buscar pedido de compra automaticamente
	cPedAut   := ''
	cItPedAut := ''
	If cPedCom == "1"
						/*
						DbSelectArea('SC7')
						SC7->(DbSetOrder(2))
						
						//Se conseguir posicionar no pedido
						If SC7->(DbSeek( FWxFilial('SC7') + PadR(cCodPro, nTamProd) + PadR(cCodigo, nTamForn) + PadR(cLoja, nTamLoja) ))
							
							//Se ainda houver quantidade a ser utilizada
							If  C7_FILIAL  == FWxFilial('SC7')        .And. ;
								C7_PRODUTO == PadR(cCodPro, nTamProd) .And. ;
								C7_FORNECE == PadR(cCodigo, nTamForn) .And. ;
								C7_LOJA    == PadR(cLoja,   nTamLoja) .And. ;
								C7_QUANT - C7_QUJE >= nQtdeLote
								
								cPedAut   := C7_NUM
								cItPedAut := C7_ITEM
							EndIf
						EndIf
						*/

		//Mudando a forma de buscar o pedido de compra, da outra forma se o primeiro pedido n�o desse certo, ele n�o buscava outros
		cQryPedC := " SELECT "
		cQryPedC += " 	C7_NUM, C7_ITEM "
		cQryPedC += " FROM "
		cQryPedC += " 	"+RetSQLName('SC7')+" SC7 "
		cQryPedC += " WHERE "
		cQryPedC += " 	C7_FILIAL = '"+FWxFilial('SC7')+"' "
		cQryPedC += " 	AND C7_PRODUTO = '"+cCodPro+"' "
		cQryPedC += " 	AND C7_FORNECE = '"+cCodigo+"' "
		cQryPedC += " 	AND C7_LOJA = '"+cLoja+"' "
		cQryPedC += " 	AND (C7_QUANT - C7_QUJE) >= "+cValToChar(nQtdeLote)+" "
		cQryPedC += " 	AND C7_ENCER != 'E' "
		cQryPedC += " 	AND C7_RESIDUO = '' "
		cQryPedC += " 	AND D_E_L_E_T_ = ' ' "
		TCQuery cQryPedC New Alias "QRY_PED"

		//Se existir pedido
		If ! QRY_PED->(EoF())
			cPedAut   := QRY_PED->C7_NUM
			cItPedAut := QRY_PED->C7_ITEM
		EndIf

		QRY_PED->(DbCloseArea())
	EndIf

	//Incrementa o item e procura por ele no array aProd
	nItem++
	aLinha := {}
	nPosProd := aScan(aProd, {|x| x[01] == StrZero(nItem, 3)})

	//Se n�o encontrar, ser� o primeiro item
	If (nPosProd == 0)
		nPosProd := 1
	EndIf

	cDescAux := Posicione('SB1', 1, FWxFilial('SB1') + aProd[nPosProd][02], 'B1_DESC')

	//Adiciona os dados do item atual do documento de entrada
	aAdd(aLinha,     {"D1_ITEM",    StrZero(nItem, 3),   Nil})
	aAdd(aLinha,     {"D1_FILIAL",  FWxFilial('SD1'),    Nil})
	aAdd(aLinha,     {"D1_COD",     aProd[nPosProd][02], Nil})
	//aAdd(aLinha,     {"D1_X_DESC",  cDescAux,            Nil}) //Caso voc� tenha um campo de descri��o do produto
	aAdd(aLinha,     {"D1_QUANT",   nQtdeLote,           Nil})
	aAdd(aLinha,     {"D1_VUNIT",   nValLote/nQtdeLote,  Nil})
	aAdd(aLinha,     {"D1_TOTAL",   nValLote,            Nil})
	aAdd(aLinha,     {"D1_TES",     "",                  Nil})
	aAdd(aLinha,     {"D1_LOCAL",   "01",                Nil})
	aAdd(aLinha,     {"D1_VALDESC", nDescLote,           Nil})
	aAdd(aLinha,     {"D1_LOTEFOR", cLote,               Nil})
	If ! Empty(cPedAut)
		aAdd(aLinha, {"D1_PEDIDO",  cPedAut,             Nil})
		aAdd(aLinha, {"D1_ITEMPC",  cItPedAut,           Nil})
	EndIf
	aAdd(aLinha,     {"AUTDELETA",  "N",                 Nil})
	aAdd(aItens, aLinha)
Next
Next

//Se houver itens e n�o houver falhas para gera��o
If Len(aItens) > 0 .And. lGera
	oNFAux := Nil

	oProc:IncRegua2("Finalizando dados do documento...")

	//Se existir a tag NfeProc pega dela, sen�o pega da tag Nfe
	If Type("oNFe:_NfeProc") != "U"
		oNFAux := oNFe:_NFeProc:_NFe
	Else
		oNFAux := oNFe:_NFe
	EndIf

	//Pegando os dados que ser�a
	nFrete        := 0
	nSeguro       := Val(oNFAux:_INFNFE:_TOTAL:_ICMSTOT:_VSeg:Text)
	nIcmsSubs     := Val(oNFAux:_INFNFE:_TOTAL:_ICMSTOT:_VST:Text)
	nTotalMerc    := Val(oNFAux:_INFNFE:_TOTAL:_ICMSTOT:_VPROD:Text) //Valor Mercadorias
	cData         := Alltrim(oIdent:_dHEmi:TEXT)
	dData         := cToD(SubStr(cData, 9, 2) +'/'+ SubStr(cData, 6, 2) +'/'+ SubStr(cData, 1, 4))
	cChaveNFE     := SubStr(oNFAux:_INFNFE:_ID:TEXT, 4, 44)

	//Monta o cabe�alho do execauto
	aAdd(aCabec, {"F1_TIPO",    Iif(cTipo=='F', 'N', 'D'),                 Nil})
	aAdd(aCabec, {"F1_FORMUL",  "N",                                       Nil})
	aAdd(aCabec, {"F1_DOC",     cDoc,                                      Nil})
	aAdd(aCabec, {"F1_SERIE",   cSerie,                                    Nil})
	aAdd(aCabec, {"F1_EMISSAO", dData,                                     Nil})
	aAdd(aCabec, {"F1_FORNECE", cCodigo,                                   Nil})
	aAdd(aCabec, {"F1_LOJA",    cLoja,                                     Nil})
	aAdd(aCabec, {"F1_ESPECIE", "SPED",                                    Nil})
	aAdd(aCabec, {"F1_SEGURO",  nSeguro,                                   Nil})
	aAdd(aCabec, {"F1_FRETE",   nFrete,                                    Nil})
	aAdd(aCabec, {"F1_VALMERC", nTotalMerc,                                Nil})
	aAdd(aCabec, {"F1_VALBRUT", nTotalMerc + nSeguro + nFrete + nIcmsSubs, Nil})
	aAdd(aCabec, {"F1_CHVNFE",  cChaveNFE,                                 Nil})

	oProc:IncRegua2("Gerando documento...")
	SA2->(MsUnLock())


	//Chama a inclus�o da pr� nota
	SB1->(DbSetOrder(1))
	lMsErroAuto := .F.
	MATA140(aCabec, aItens, 3)

	//Se n�o houve erros
	If !lMsErroAuto
		//Posiciona na SF1
		SF1->(DbSeek(FWxFilial("SF1") + cDoc + cSerie + cCodigo + cLoja))

		//Se for apenas inclus�o de pr� nota, abre como altera��o
		If cTipoImp == "1"
			aRotina	:= {;
				{ "Pesquisar",             "AxPesqui",    0, 1,0, .F.},;
				{ "Visualizar",            "A140NFiscal", 0, 2,0, .F.},;
				{ "Incluir",               "A140NFiscal", 0, 3,0, Nil},;
				{ "Alterar",               "A140NFiscal", 0, 4,0, Nil},;
				{ "Excluir",               "A140NFiscal", 0, 5,0, Nil},;
				{ "Imprimir",              "A140Impri",   0, 4,0, Nil},;
				{ "Estorna Classificacao", "A140EstCla",  0, 5,0, Nil},;
				{ "Legenda",               "A103Legenda", 0, 2,0, .F.}}

			//Chama a pr� nota, como altera��o
			aHeadSD1    := {}
			ALTERA      := .T.
			INCLUI      := .F.
			l140Auto    := .F.
			nMostraTela := 1
			A140NFiscal('SF1', SF1->(RecNo()), 4)

			//Sen�o, se for classifica��o, abre o documento de Entrada
		ElseIf cTipoImp == "2" //Classifica
			aRotina := {;
				{ "Pesquisar",   "AxPesqui",    0, 1}, ;
				{ "Visualizar",  "A103NFiscal", 0, 2}, ;
				{ "Incluir",     "A103NFiscal", 0, 3}, ;
				{ "Classificar", "A103NFiscal", 0, 4}, ;
				{ "Retornar",    "A103Devol",   0, 3}, ;
				{ "Excluir",     "A103NFiscal", 3, 5}, ;
				{ "Imprimir",    "A103Impri",   0, 4}, ;
				{ "Legenda",     "A103Legenda", 0, 2} }

			//Abre a tela de documento de entrada
			A103NFiscal('SF1', SF1->(RecNo()), 4)
		EndIf

		//Se n�o existir o diret�rio de importados, ser� criado
		If !ExistDir(cDirect + 'Importados\')
			MakeDir(cDirect + 'Importados\')
		EndIf

		//Copia o arquivo para o diret�rio de importados
		cFileImp := cDirect + 'Importados\' + Alltrim(TMP->XML)
		FRename(cFile, cFileImp)

		//Exclui o xml atual da tempor�ria
		RecLock('TMP', .F.)
		DbDelete()
		TMP->(MsUnlock())

		//Sen�o, mostra o erro do execauto
	Else
		Aviso("Aten��o", "Erro #008:"+ CRLF +"Falha ao incluir Documento / S�rie ('"+cDoc+"/"+cSerie+"')!", {"Ok"}, 2)
		MostraErro()
	EndIf
EndIf
EndIf

TMP->(DbSkip())
EndDo
Return

/*---------------------------------------------------------------------*
 | Func:  fGravaProd                                                   |
 | Desc:  Fun��o para gravar o produto na SA5                          |
 *---------------------------------------------------------------------*/

Static Function fGravaProd()
	Local aArea := GetArea()
	cCodPro := ''
	
	//Se tiver produto digitado
	If ! Empty(cGetProd)
		//Se conseguir posicionar no produto
		SB1->(DbSetOrder(1))
		If SB1->(DbSeek(FWxFilial('SB1')+cGetProd))
	    	cCodPro := SB1->B1_COD
	    	cUnidad := ''
		EndIf
		
		//Se conseguir posicionar na tabela de pre�o do fornecedor
		DbSelectArea("SA5")
		SA5->(DbSetOrder(1)) //A5_FILIAL + A5_FORNECE + A5_LOJA + A5_PRODUTO
		If (SA5->(DbSeek(FWxFilial('SA5') + cCodigo + cLoja + cCodPro)))
			//Se tiver em branco o c�digo do fornecedor, sobrep�e
			If (Empty(SA5->A5_CODPRF))
				RecLock('SA5', .F.)
					A5_CODPRF := cCodForn
				SA5->(MsUnlock())
			EndIf
			
		//Sen�o, ser� inclu�do um registro na tabela de pre�o do fornecedor
		Else
			RecLock("SA5", .T.)
		    	A5_FILIAL   := FWxFilial("SA5")
		    	A5_FORNECE  := cCodigo
		    	A5_LOJA     := cLoja
		    	A5_NOMEFOR  := cRazao
		    	A5_PRODUTO  := cCodPro
		    	A5_NOMPROD  := SB1->B1_DESC
		    	A5_CODPRF   := cCodForn
	    	SA5->(MSUnLock())
	  	EndIf
	EndIf
	
	RestArea(aArea)
Return

/*---------------------------------------------------------------------*
 | Func:  fMarkAll                                                     |
 | Desc:  Fun��o para marcar todos os registros                        |
 *---------------------------------------------------------------------*/

Static Function fMarkAll(cMarca)
	TMP->(DbGoTop())
	
	//Enquanto houver dados
	While ! TMP->(EoF())
		//Atualiza a marca
		RecLock("TMP", .F.)
			OK := Iif(cMarca != TMP->OK, cMarca, Space(Len(cMarca)))
		TMP->(MsUnlock())
		
		TMP->(DbSkip())
	EndDo
	
	TMP->(DbGoTop())
Return

/*/{Protheus.doc} zXMLPesq
Fun��o para pesquisar um Documento e s�rie no Browse
@author Atilio
@since 19/07/2017
@version 1.0
@type function
/*/

User Function zXMLPesq()
	Local oDlgPesq
	Local oBtnConf
	Local oBtnCanc
	Local oCmbOrdem, cCmbOrdem := "1"
	Local oGetChave, cGetChave := Space(TamSX3('F1_DOC')[01] + TamSX3('F1_SERIE')[01])
	Local aOrdens  := {"1=Documento + S�rie"}
	Local lOk      := .F.
	
	//Cria a janela de pesquisa
	DEFINE MSDIALOG oDlgPesq TITLE "Pesquisa" FROM 000, 000 To 100, 500 PIXEL
		//Cria o combo e o get
		@ 005, 005 MSCOMBOBOX oCmbOrdem VAR cCmbOrdem ITEMS aOrdens SIZE 210, 08 OF oDlgPesq PIXEL
		@ 020, 005 MSGET      oGetChave VAR cGetChave               SIZE 210, 08 OF oDlgPesq PIXEL
		
		//Cria os bot�es
		DEFINE SBUTTON oBtnConf FROM 005, 218 TYPE 1 ACTION (lOk := .T., oDlgPesq:End()) ENABLE OF oDlgPesq PIXEL
		DEFINE SBUTTON oBtnCanc FROM 020, 218 TYPE 2 ACTION (lOk := .F., oDlgPesq:End()) ENABLE OF oDlgPesq PIXEL
	ACTIVATE MSDIALOG oDlgPesq CENTERED

	//Se a tela foi confirmada, posiciona no registro procurado
	If lOk
		TMP->(DbSetOrder(Val(cOrdem)))
		TMP->(DbSeek(Alltrim(cGetChave)))
	EndIf
Return



User Function IncProd(cCod, cDesc, cTipo, cUM, cLocPad, cCEME, cNcm)//Pegando o modelo de dados, setando a opera��o de inclus�o

oModel  := FwLoadModel ("MATA010")
oModel:SetOperation(3)
oModel:Activate()
oModel:SetValue("SB1MASTER","B1_COD"        ,cCod)
oModel:SetValue("SB1MASTER","B1_DESC"       ,SubStr(cDesc,1,TamSX3("B1_DESC")[1]))
oModel:SetValue("SB1MASTER","B1_TIPO"       ,cTipo)
oModel:SetValue("SB1MASTER","B1_UM"     ,cUM)
oModel:SetValue("SB1MASTER","B1_LOCPAD" ,"01")
oModel:SetValue("SB1MASTER","B1_POSIPI" , cNcm)

 
//Setando o complemento do produto
oSB5Mod := oModel:GetModel("SB5DETAIL")
If oSB5Mod != Nil
    oSB5Mod:SetValue("B5_CEME"   , cCEME     )
EndIf
   
//Se conseguir validar as informa��es
If oModel:VldData()
       
    //Tenta realizar o Commit
    If oModel:CommitData()
        lOk := .T.
           
    //Se n�o deu certo, altera a vari�vel para false
    Else
        lOk := .F.
    EndIf
       
//Se n�o conseguir validar as informa��es, altera a vari�vel para false
Else
    lOk := .F.
EndIf
   
//Se n�o deu certo a inclus�o, mostra a mensagem de erro
If ! lOk
    //Busca o Erro do Modelo de Dados
    aErro := oModel:GetErrorMessage()
       
    //Monta o Texto que ser� mostrado na tela
    cMessage := "Id do formul�rio de origem:"  + ' [' + cValToChar(aErro[01]) + '], '
    cMessage += "Id do campo de origem: "      + ' [' + cValToChar(aErro[02]) + '], '
    cMessage += "Id do formul�rio de erro: "   + ' [' + cValToChar(aErro[03]) + '], '
    cMessage += "Id do campo de erro: "        + ' [' + cValToChar(aErro[04]) + '], '
    cMessage += "Id do erro: "                 + ' [' + cValToChar(aErro[05]) + '], '
    cMessage += "Mensagem do erro: "           + ' [' + cValToChar(aErro[06]) + '], '
    cMessage += "Mensagem da solu��o: "        + ' [' + cValToChar(aErro[07]) + '], '
    cMessage += "Valor atribu�do: "            + ' [' + cValToChar(aErro[08]) + '], '
    cMessage += "Valor anterior: "             + ' [' + cValToChar(aErro[09]) + ']'
     
    //Mostra mensagem de erro
    lRet := .F.
    ConOut("Erro: " + cMessage)
	RollBackSX8()
Else
    lRet := .T.
    ConOut("Produto incluido!")
	ConfirmSX8()
EndIf
   
//Desativa o modelo de dados
oModel:DeActivate()
Return Nil


User Function AltProd(cCodPro)

Local cMsgRet := ""
Local lRet    := .T.
Local oModel  := Nil

oModel := FwLoadModel("MATA010")
oModel:SetOperation(4)
oModel:Activate()
 
oModel:LoadValue("SB1MASTER", "B1_COD", cCodPro)

    If oModel:VldData()
        oModel:CommitData()
        Alert("PRODUTO ALTERADO COM SUCESSO!")
    Else
        lRet := .F.
        cMsgRet := oModel:GetErrorMessage()[4] + " - " + oModel:GetErrorMessage()[6]
		Alert(cMsgRet)
    EndIf

    oModel:DeActivate()
    oModel:Destroy()

Return




User Function EXEC061(cCodPro,cProFor,cDescProd, cCodFor, cLojaFor)

Local nOpc := 3
Local oModel := Nil
Local cProdInt := cCodPro //Codigo do Produto Interno
Local cForn := cCodFor    // Codigo do Fornecedor
Local cLoja := cLojaFor   // Loja Fornecedor


oModel := FWLoadModel('MATA061')

oModel:SetOperation(nOpc)
oModel:Activate()

//Cabe�alho
oModel:SetValue('MdFieldSA5','A5_PRODUTO',cProdInt)
oModel:SetValue('MdFieldSA5','A5_NOMPROD',cDescProd)

//Grid
oModel:SetValue('MdGridSA5','A5_FORNECE',cCodFor)
oModel:SetValue('MdGridSA5','A5_LOJA' ,cLojaFor)
oModel:SetValue('MdGridSA5','A5_CODPRF' ,cProFor)
oModel:SetValue('MdGridSA5','A5_NOMEFOR', POSICIONE("SA2",1,XFILIAL("SA2")+cCodFor+cLojaFor,"A2_NOME"))

//Nova linha na Grid
//oModel:GetModel("MdGridSA5"):AddLine()
// aqui repetir a estrutura de MDGRIDSA5 caso queira incluir mais um fornecedor

If oModel:VldData()
oModel:CommitData()
Endif

oModel:DeActivate()

oModel:Destroy()


Return 



/*

User Function EXEC061(cCodPro,cProFor,cDescProd, cCodFor, cLojaFor)

Local nOpc := 3
Local oModel := Nil
Local cProdInt := cCodPro //Codigo do Produto Interno
Local cForn := cCodFor    // Codigo do Fornecedor
Local cLoja := cLojaFor   // Loja Fornecedor
Local aDados := {}


aadd(aDados, {"A5_PRODUTO"		,cCodPro	 			,nil})
aadd(aDados, {"A5_NOMPROD"		,SubStr(cDescProd,1,TamSX3('B1_DESC')[1])	 			,nil})
aadd(aDados, {"A5_FORNECE"		,cCodFor	 			,nil})
aadd(aDados, {"A5_LOJA"		,cLojaFor	 			,nil})
aadd(aDados, {"A5_CODPRF"		,cProFor		,nil})											
												
lMsErroAuto := .F.			
MSExecAuto({|x,y| Mata060(x,y)},aDados,3)

Return 


*/
