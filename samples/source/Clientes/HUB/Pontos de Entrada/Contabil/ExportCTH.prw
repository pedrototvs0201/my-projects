#INCLUDE 'PROTHEUS.CH'


// Exporta dados de Clientes e Fornecedores para a tabela CTH (CLASSE DE VALOR)
User Function ExportCTH()
Private oProcess

If MsgYesNo("Deseja realmente exportar os dados de clientes/fornecedores para a tabela CTH?","Alerta")
	oProcess := MsNewProcess():New({|lEnd| fExportCTH()})
	oProcess:Activate()
EndIf

Return()


Static Function fExportCTH()
ExportSA1()
ExportSA2()
Return(.T.)


// Exporta Clientes
Static Function ExportSA1()
Local aAreaSA1 := SA1->(GetArea())
Local aAreaCTH := CTH->(GetArea())

DbSelectArea("SA1")
DbSetOrder(1)
DbGoTop()

oProcess:SetRegua1(SA1->(RecCount()))
oProcess:SetRegua1(SA1->(RecCount()))

oProcess:IncRegua1("Exportando dados de clientes...")

While !SA1->(EOF())
	
	oProcess:IncRegua1("Exportando dados de clientes...")
	
	DbSelectArea("CTH")
	CTH->(DbSetOrder(1))
	
	If !(CTH->(DbSeek(xfilial("CTH")+"C"+ALLTRIM(SA1->A1_COD))))
		
		oProcess:IncRegua2("Cliente: " + "C"+ALLTRIM(SA1->A1_COD)+ " - " + AllTrim(SA1->A1_NOME))
		If SA1->A1_MSBLQL <> "1"
			RecLock("CTH",.T.)
			CTH->CTH_FILIAL	:= xFilial("CTH")
			CTH->CTH_CLVL	:= "C"+ALLTRIM(SA1->A1_COD)
			CTH->CTH_CLASSE	:= "2"
			CTH->CTH_DESC01	:= SA1->A1_NOME
			CTH->CTH_BLOQ	:= SA1->A1_MSBLQL 
			CTH->CTH_NORMAL := "2"
			CTH->CTH_DTEXIS := CTOD("01/01/80")
			CTH->CTH_CLVLLP := "C"+ALLTRIM(SA1->A1_COD)
			//CTH->CTH_YCGC   := SA1->A1_CGC    //- CASO O CLIENTE QUEIRA COLOCAR UM FILTRO NA CLASSE DE VALOR POR CNPJ	
			//CTH->CTH_YCLIFO := "C"            //- PARA TRATAR CONSULTA PADRÃO NO CT2 (CLASSE DÉBITO)
			CTH->(MsUnLock())	     
		EndIf
	EndIf
	
	oProcess:IncRegua2("Cliente: " + "C" + ALLTRIM(SA1->A1_COD)+ " - " + AllTrim(SA1->A1_NOME))
	
	SA1->(DbSkip())
	
EndDo

oProcess:IncRegua2("")
oProcess:IncRegua1("Exportação de clientes concluida...")

RestArea(aAreaSA1)
RestArea(aAreaCTH)

Return()


// Exporta Fornecedores
Static Function ExportSA2()
Local aAreaSA2 := SA2->(GetArea())
Local aAreaCTH := CTH->(GetArea())

DbSelectArea("SA2")
DbSetOrder(1)
DbGoTop()

oProcess:SetRegua1(SA2->(RecCount()))
oProcess:SetRegua2(SA2->(RecCount()))

oProcess:IncRegua1("Exportando dados de fornecedores...")

While !SA2->(EOF())
	
	oProcess:IncRegua1("Exportando dados de fornecedores...")
	
	DbSelectArea("CTH")
	CTH->(DbSetOrder(1))
	
	If !(CTH->(DbSeek(xFilial("CTH")+"F"+ALLTRIM(SA2->A2_COD))))
		
		oProcess:IncRegua2("Fornecedor: " + "F"+ALLTRIM(SA2->A2_COD)+ " - " + AllTrim(SA2->A2_NOME))
		If SA2->A2_MSBLQL <> "1"
			RecLock("CTH",.T.)
			CTH->CTH_FILIAL	:= xFilial("CTH") 
			CTH->CTH_CLVL	:= "F"+ALLTRIM(SA2->A2_COD)
			CTH->CTH_CLASSE	:= "2"          
			CTH->CTH_DESC01	:= SA2->A2_NOME
			CTH->CTH_BLOQ	:= SA2->A2_MSBLQL
			CTH->CTH_NORMAL := "1"
			CTH->CTH_DTEXIS := CTOD("01/01/80")     
			CTH->CTH_CLVLLP := "F"+ALLTRIM(SA2->A2_COD)
			//CTH->CTH_YCGC   := SA2->A2_CGC   //- CASO O CLIENTE QUEIRA COLOCAR UM FILTRO NA CLASSE DE VALOR POR CNPJ		
			//CTH->CTH_YCLIFO := "F"           //-      PARA TRATAR CONSULTA PADRÃO NO CT2 (CLASSE DÉBITO)
			CTH->(MsUnLock())          	
		EndIf
	EndIf
	
	oProcess:IncRegua2("Fornecedor: " + "F"+ALLTRIM(SA2->A2_COD)+ " - " + AllTrim(SA2->A2_NOME))
	
	SA2->(DbSkip())
	
EndDo

oProcess:IncRegua2("")
oProcess:IncRegua1("Exportação de fornecedores concluida...")

RestArea(aAreaSA2)
RestArea(aAreaCTH)

Return()
