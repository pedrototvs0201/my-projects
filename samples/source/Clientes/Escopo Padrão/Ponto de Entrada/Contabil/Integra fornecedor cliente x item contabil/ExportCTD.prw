#INCLUDE 'PROTHEUS.CH'


// Exporta dados de Clientes e Fornecedores para a tabela CTD (ITEMCONTABIL)
User Function ExportaCTD()
Private oProcess

If MsgYesNo("Deseja realmente exportar os dados de clientes/fornecedores para a tabela CTD?","Alerta")
	oProcess := MsNewProcess():New({|lEnd| fExportCTD()})
	oProcess:Activate()
EndIf

Return()


Static Function fExportCTD()
ExportSA1()
ExportSA2()
Return(.T.)


// Exporta Clientes
Static Function ExportSA1()
Local aAreaSA1 := SA1->(GetArea())
Local aAreaCTD := CTD->(GetArea())

DbSelectArea("SA1")
DbSetOrder(1)
DbGoTop()

oProcess:SetRegua1(SA1->(RecCount()))
oProcess:SetRegua1(SA1->(RecCount()))

oProcess:IncRegua1("Exportando dados de clientes...")

While !SA1->(EOF())
	
	oProcess:IncRegua1("Exportando dados de clientes...")
	
	DbSelectArea("CTD")
	CTD->(DbSetOrder(1))
	
	If !(CTD->(DbSeek(xfilial("CTD")+"C"+ALLTRIM(SA1->A1_COD)+ALLTRIM(SA1->A1_LOJA))))
		
		oProcess:IncRegua2("Cliente: " + "C"+ALLTRIM(SA1->A1_COD)+ " - " + AllTrim(SA1->A1_NOME))
		If SA1->A1_MSBLQL <> "1"
			RecLock("CTD",.T.)
			CTD->CTD_FILIAL	:= xFilial("CTD")
			CTD->CTD_ITEM	:= "C"+ALLTRIM(SA1->A1_COD)+ALLTRIM(SA1->A1_LOJA)
			CTD->CTD_CLASSE	:= "2"
			CTD->CTD_DESC01	:= SA1->A1_NOME
			CTD->CTD_BLOQ	:= SA1->A1_MSBLQL 
			//CTD->CTD_NORMAL := "2"
			CTD->CTD_DTEXIS := CTOD("01/01/80")
			CTD->CTD_ITLP := "1"+ALLTRIM(SA1->A1_COD)+ALLTRIM(SA1->A1_LOJA)
			//CTD->CTD_YCGC   := SA1->A1_CGC    //- CASO O CLIENTE QUEIRA COLOCAR UM FILTRO NA CLASSE DE VALOR POR CNPJ	
			//CTD->CTD_YCLIFO := "C"            //- PARA TRATAR CONSULTA PADRÃO NO CT2 (CLASSE DÉBITO)
			CTD->(MsUnLock())	     
		EndIf
	EndIf
	
	oProcess:IncRegua2("Cliente: " + "C" + ALLTRIM(SA1->A1_COD)+ " - " + AllTrim(SA1->A1_NOME))
	
	SA1->(DbSkip())
	
EndDo

oProcess:IncRegua2("")
oProcess:IncRegua1("Exportação de clientes concluida...")

RestArea(aAreaSA1)
RestArea(aAreaCTD)

Return()


// Exporta Fornecedores
Static Function ExportSA2()
Local aAreaSA2 := SA2->(GetArea())
Local aAreaCTD := CTD->(GetArea())

DbSelectArea("SA2")
DbSetOrder(1)
DbGoTop()

oProcess:SetRegua1(SA2->(RecCount()))
oProcess:SetRegua2(SA2->(RecCount()))

oProcess:IncRegua1("Exportando dados de fornecedores...")

While !SA2->(EOF())
	
	oProcess:IncRegua1("Exportando dados de fornecedores...")
	
	DbSelectArea("CTD")
	CTD->(DbSetOrder(1))
	
	If !(CTD->(DbSeek(xFilial("CTD")+"F"+ALLTRIM(SA2->A2_COD)+ALLTRIM(A2_LOJA))))
		
		oProcess:IncRegua2("Fornecedor: " + "F"+ALLTRIM(SA2->A2_COD)+ " - " + AllTrim(SA2->A2_NOME))
		If SA2->A2_MSBLQL <> "1"
			RecLock("CTD",.T.)
			CTD->CTD_FILIAL	:= xFilial("CTD") 
			CTD->CTD_ITEM	:= "F"+ALLTRIM(SA2->A2_COD)+ALLTRIM(SA2->A2_LOJA)
			CTD->CTD_CLASSE	:= "2"          
			CTD->CTD_DESC01	:= SA2->A2_NOME
			CTD->CTD_BLOQ	:= SA2->A2_MSBLQL
			//CTD->CTD_NORMAL := "1"
			CTD->CTD_DTEXIS := CTOD("01/01/80")     
			CTD->CTD_ITEMLP := "2"+ALLTRIM(SA2->A2_COD)+ALLTRIM(SA2->A2_LOJA)
			//CTD->CTD_YCGC   := SA2->A2_CGC   //- CASO O CLIENTE QUEIRA COLOCAR UM FILTRO NA CLASSE DE VALOR POR CNPJ		
			//CTD->CTD_YCLIFO := "F"           //-      PARA TRATAR CONSULTA PADRÃO NO CT2 (CLASSE DÉBITO)
			CTD->(MsUnLock())          	
		EndIf
	EndIf
	
	oProcess:IncRegua2("Fornecedor: " + "F"+ALLTRIM(SA2->A2_COD)+ " - " + AllTrim(SA2->A2_NOME))
	
	SA2->(DbSkip())
	
EndDo

oProcess:IncRegua2("")
oProcess:IncRegua1("Exportação de fornecedores concluida...")

RestArea(aAreaSA2)
RestArea(aAreaCTD)

Return()
