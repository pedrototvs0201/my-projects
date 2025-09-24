//Bibliotecas
#Include "tlpp-core.th"

//Declaração da namespace
Namespace custom.autumn.export

//Constantes
#Define CRLF Chr(13) + Chr(10) //Carriage Return Line Feed

/*/ OUTSA1
Exportar clientes
@author Pedro
@since 15/09/2025
@version 1.0
@type User Function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
@example custom.autumn.export.u_OUTSA1()
/*/

User Function OUTSA1()
	Local aArea := FWGetArea() As Array
	Local aParameters := {} As Array
	Local xPar0 := Space(30)
	Local xPar1 := Space(50)
	Local xPar2 := Space(16) As Character
	
	//Adicionando os parametros do ParamBox
	aAdd(aParameters, {1, "A1_COD", xPar0,  "", ".T.", "SA1", ".T.", 80,  .F.})
	aAdd(aParameters, {1, "A1_NOME", xPar1,  "", ".T.", "SA1", ".T.", 80,  .F.})
	aAdd(aParameters, {1, "A1_CGC", xPar2,  "", ".T.", "SA1", ".T.", 80,  .F.})
	
	//Se a pergunta for confirma, cria as definicoes do relatorio
	If ParamBox(aParameters, 'Informe os parâmetros', /*aRet*/, /*bOk*/, /*aButtons*/, /*lCentered*/, /*nPosx*/, /*nPosy*/, /*oDlgWizard*/, /*cLoad*/, .F., .F.)
		Processa({|| exportToFile()})
	EndIf
	
	FWRestArea(aArea)
Return
/*/{Protheus.doc} exportToFile
Preenchimento de dados no arquivo - OUTSA1
@author Pedro
@since 15/09/2025
@version 1.0
@type Static Function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

Static Function OUTSA1()
	Local aArea     := FWGetArea() As Array
	Local nCurrent  := 0 As Numeric
	Local nTotal    := 0 As Numeric
	Local cFileName := 'OUTSA1_' + dToS(Date()) + '_' + StrTran(Time(), ':', '-') + '.csv' As Character
	Local cFolder   := "C:\TOTVS\TRIMBOX\OUT\" As Character
	Local cQuery    := "" As Character
	Local oFWriter  := Nil As Object
	Local xVar      := Nil As Variant
	
	//Se o último caracter não for uma barra, será uma barra
	If SubStr(cFolder, Len(cFolder), 1) != '\'
		cFolder += '\'
	EndIf
	
	//Montando consulta de dados
	cQuery += "SELECT A1_COD , A1_NOME, A1_CGC FROM + "RetSqlName('SA1') "+"		+ CRLF
	
	//Chama a criação do arquivo
	oFWriter := FWFileWriter():New(cFolder + cFileName, .T.)
	
	//Se houve falha ao criar, mostra a mensagem
	If ! oFWriter:Create()
		FWAlertError('Houve um erro ao gerar o arquivo: ' + CRLF + oFWriter:Error():Message, 'Atenção')
		
	//Senão, continua com o processamento
	Else
		//Executando consulta e setando o total da regua
	    If '--' $ cQuery .Or. 'WITH' $ Upper(cQuery) .Or. 'NOLOCK' $ Upper(cQuery)
		    FWAlertInfo('Alguns comandos (como --, WITH e NOLOCK), não são executados pela PLSQuery devido ao ChangeQuery. Tente migrar da PLSQuery para TCQuery.', 'Atenção')
	    EndIf 
		PlsQuery(cQuery, "QRY_AUX")
		DbSelectArea("QRY_AUX")
		Count To nTotal
		ProcRegua(nTotal)
		QRY_AUX->(DbGoTop())
		
		//Adiciona a linha de cabeçalho
		cLinha := ''
		cLinha += 'A1_COD;'
		cLinha += 'A1_NOME;'
		cLinha += 'A1_CGC;'
		//Escreve a linha com a quebra do CRLF no fim
		oFWriter:Write(cLinha + CRLF)
		
		//Enquanto houver dados
		While ! QRY_AUX->(EoF())
			//Incrementando a régua
			nCurrent++
			IncProc('Adicionando registro ' + cValToChar(nCurrent) + ' de ' + cValToChar(nTotal) + '...')
			
			//Monta a linha que será escrita
			cLinha := ''
			
			xVar := QRY_AUX->A1_COD
			If ValType(xVar) != 'C'
				xVar := cValToChar(xVar)
			EndIf
			cLinha += xVar + ';'
			
			xVar := QRY_AUX->A1_NOME
			If ValType(xVar) != 'C'
				xVar := cValToChar(xVar)
			EndIf
			cLinha += xVar + ';'
			
			xVar := QRY_AUX->A1_CGC
			If ValType(xVar) != 'C'
				xVar := cValToChar(xVar)
			EndIf
			cLinha += xVar + ';'
			
			
			//Escreve a linha com a quebra do CRLF no fim
			oFWriter:Write(cLinha + CRLF)
			
			QRY_AUX->(DbSkip())
		EndDo
		QRY_AUX->(DbCloseArea())
		
		//Encerra o arquivo
		oFWriter:Close()
		
		//Pergunta se deseja abrir o arquivo
		If FWAlertYesNo('Arquivo gerado com sucesso (' + cFolder + cFileName + ')!' + CRLF + 'Deseja abrir?', 'Atencao')
			ShellExecute('OPEN', cFileName, '', cFolder, 1 )
		EndIf
	EndIf
	
	FWRestArea(aArea)
Return
