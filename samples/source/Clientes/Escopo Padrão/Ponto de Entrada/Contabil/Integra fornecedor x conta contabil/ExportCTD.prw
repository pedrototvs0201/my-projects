#INCLUDE 'PROTHEUS.CH'


// Exporta dados de Clientes e Fornecedores para a tabela CT1 (ITEMCONTABIL)
User Function ExportaCT1()
Private oProcess

If MsgYesNo("Deseja realmente exportar os dados de clientes/fornecedores para a tabela de plano de Contas?","Alerta")
	oProcess := MsNewProcess():New({|lEnd| fExportCT1()})
	oProcess:Activate()
EndIf

Return()


Static Function fExportCT1()
ExportSA1()
ExportSA2()
Return(.T.)


// Exporta Clientes
Static Function ExportSA1()

Local aAreaSA1 := SA1->(GetArea())
Local aAreaCT1 := CT1->(GetArea())

DbSelectArea("SA1")
DbSetOrder(1)
DbGoTop()

oProcess:SetRegua1(SA1->(RecCount()))
oProcess:SetRegua1(SA1->(RecCount()))

oProcess:IncRegua1("Exportando dados de clientes...")

While !SA1->(EOF())
	
	oProcess:IncRegua1("Exportando dados de clientes...")
	
	DbSelectArea("CT1")
	CT1->(DbSetOrder(1))
	
	If !(CT1->(DbSeek(xFilial("CT1")+"1.1.2.01."+RIGHT(ALLTRIM(SA1->A1_COD),3))))
		
		oProcess:IncRegua2("Cliente: " +"1.1.2.01."+RIGHT(ALLTRIM(SA1->A1_COD),3))
		If SA1->A1_MSBLQL <> "1"
			RecLock("CT1",.T.)
			CT1->CT1_FILIAL	:= xFilial("CT1")
		CT1->CT1_CONTA	:= "1.1.2.01."+RIGHT(ALLTRIM(SA1->A1_COD),3)
		//CTD->CTD_CLASSE	:= "2"
		CT1->CT1_DESC01	:= SA1->A1_NOME
		CT1->CT1_CLASSE := "2"
		CT1->CT1_NORMAL	:= "2"
		CT1->CT1_CTASUP := "1.1.2.01"
		//CTD->CTD_NORMAL := "2"
		CT1->CT1_NATCTA := "01"
		CT1->CT1_NTSPED := "01"
		CT1->CT1_BLOQ   := "2"
		CT1->CT1_CVD02  := "1"
		CT1->CT1_CVD03  := "1"
		CT1->CT1_CVD04  := "1"
		CT1->CT1_CVD05  := "1"
   		CT1->CT1_CVC02  := "1"
   		CT1->CT1_CVC03  := "1"
   		CT1->CT1_CVC04  := "1"	
   		CT1->CT1_ACITEM := "1"		
		CT1->CT1_ACCUST := "1"		
		CT1->CT1_ACCLVL := "1"	
		CT1->CT1_DTEXIS := CTOD("01/01/80")  
		CT1->CT1_AGLSLD := "2"
		CT1->CT1_CCOBRG := "2"
		CT1->CT1_ITOBRG := "2"
		CT1->CT1_CLOBRG := "2"
		CT1->CT1_LALHIR := "2"
		CT1->CT1_LALUR  := "0"
		CT1->CT1_ACATIV := "2"
		CT1->CT1_ATOBRG := "2"
		CT1->CT1_ACET05 := "2"
		CT1->CT1_05OBRG := "2"
		CT1->CT1_INTP   := "1"
		CT1->CT1_PVARC  := "1"
			CT1->(MsUnLock())	     
		EndIf
	EndIf
	
	oProcess:IncRegua2("Cliente: " +"1.1.2.01."+RIGHT(ALLTRIM(SA1->A1_COD),3))
	
	SA1->(DbSkip())


EndDo

oProcess:IncRegua2("")
oProcess:IncRegua1("Exportação de clientes concluida...")

RestArea(aAreaSA1)
RestArea(aAreaCT1)

Return()


// Exporta Fornecedores
Static Function ExportSA2()
Local aAreaSA2 := SA2->(GetArea())
Local aAreaCT1 := CT1->(GetArea())

DbSelectArea("SA2")
DbSetOrder(1)
DbGoTop()

oProcess:SetRegua1(SA2->(RecCount()))
oProcess:SetRegua2(SA2->(RecCount()))

oProcess:IncRegua1("Exportando dados de fornecedores...")

While !SA2->(EOF())
	
	oProcess:IncRegua1("Exportando dados de fornecedores...")
	
	DbSelectArea("CT1")
	CT1->(DbSetOrder(1))
	
	If !(CT1->(DbSeek(xFilial("CT1")+"2.1.1.01."+RIGHT(ALLTRIM(SA2->A2_COD),3))))
		
		oProcess:IncRegua2("Fornecedor: " +RIGHT(ALLTRIM(SA2->A2_COD),3))
		If SA2->A2_MSBLQL <> "1"
			RecLock("CT1",.T.)
			CT1->CT1_FILIAL	:= xFilial("CT1")
		CT1->CT1_CONTA	:= "2.1.1.01."+RIGHT(ALLTRIM(SA2->A2_COD),3)
		CT1->CT1_CLASSE	:= "2"
		CT1->CT1_DESC01	:= SA2->A2_NOME
		CT1->CT1_CLASSE := "2"
		CT1->CT1_NORMAL	:= "2"
		CT1->CT1_CTASUP := "2.1.1.01"
		//CTD->CTD_NORMAL := "2"
		CT1->CT1_NATCTA := "01"
		CT1->CT1_NTSPED := "01"
		CT1->CT1_BLOQ   := "2"
		CT1->CT1_CVD02  := "1"
		CT1->CT1_CVD03  := "1"
		CT1->CT1_CVD04  := "1"
		CT1->CT1_CVD05  := "1"
   		CT1->CT1_CVC02  := "1"
   		CT1->CT1_CVC03  := "1"
   		CT1->CT1_CVC04  := "1"	
		CT1->CT1_ACITEM := "1"		
		CT1->CT1_ACCUST := "1"		
		CT1->CT1_ACCLVL := "1"	
		CT1->CT1_DTEXIS := CTOD("01/01/80")  
		CT1->CT1_AGLSLD := "2"
		CT1->CT1_CCOBRG := "2"
		CT1->CT1_ITOBRG := "2"
		CT1->CT1_CLOBRG := "2"
		CT1->CT1_LALHIR := "2"
		CT1->CT1_LALUR  := "0"
		CT1->CT1_ACATIV := "2"
		CT1->CT1_ATOBRG := "2"
		CT1->CT1_ACET05 := "2"
		CT1->CT1_05OBRG := "2"
		CT1->CT1_INTP   := "1"
		CT1->CT1_PVARC  := "1"
		
   		//CTD->CTD_YCGC   := SA1->A1_CGC    //- CASO O CLIENTE QUEIRA COLOCAR UM FILTRO NA CLASSE DE VALOR POR CNPJ
       	//CTD->CTD_YCLIFO := "C"            //- PARA TRATAR CONSULTA PADRÃO NO CT2 (CLASSE DÉBITO)		
		CT1->(MsUnLock())	           	
		EndIf
	EndIf
	SA2->A2_CONTA :="2.1.1.01."+RIGHT(ALLTRIM(SA2->A2_COD),3)
	oProcess:IncRegua2("Fornecedor: " + "F"+ALLTRIM(SA2->A2_COD)+ " - " + AllTrim(SA2->A2_NOME))
	
		
EndDo

oProcess:IncRegua2("")
oProcess:IncRegua1("Exportação de fornecedores concluida...")


RestArea(aAreaSA2)
RestArea(aAreaCT1)

Return()
