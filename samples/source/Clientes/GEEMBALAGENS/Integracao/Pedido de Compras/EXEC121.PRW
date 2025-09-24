#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "TbiConn.ch"

User FUnction EXEC121()

	Local aCabec := {}
	Local aItens := {}
	Local aLinha := {}
	Local aRatCC := {}
	Local aRatPrj := {}
	Local aAdtPC := {}
	Local aItemPrj := {{"01","02"},{"02","01"}} //Projeto, Tarefa
	Local aCCusto := {{40,"01","101010","333330","CL0001"},{60,"02","101011","333330","CL0001"}} //Porcentagem,Centro de Custo, Conta Contabil, Item Conta, CLVL
	Local nX := 0
	Local cDoc := ""
	Local nOpc := 3

	PRIVATE lMsErroAuto := .F.



	dbSelectArea("SC7")

//Teste de Inclusão
	cDoc := GetSXENum("SC7","C7_NUM")
	SC7->(dbSetOrder(1))
	While SC7->(dbSeek(xFilial("SC7")+cDoc))
		ConfirmSX8()
		cDoc := GetSXENum("SC7","C7_NUM")
	EndDo

	aadd(aCabec,{"C7_NUM" ,cDoc})
	aadd(aCabec,{"C7_EMISSAO" ,dDataBase})
	aadd(aCabec,{"C7_FORNECE" ,cFornece})
	aadd(aCabec,{"C7_LOJA" ,"01"})
	aadd(aCabec,{"C7_COND" ,"001"})
	aadd(aCabec,{"C7_CONTATO" ,"AUTO"})
	aadd(aCabec,{"C7_FILENT" ,cFilAnt})
	aadd(aCabec,{"C7_TPFRETE" ,"C"})
	aadd(aCabec,{"C7_FRETE" ,15})
	aadd(aCabec,{"C7_PRODUTO" ,cProduto,Nil})
	aadd(aCabec,{"C7_QUANT" ,nQuant ,Nil})
	aadd(aCabec,{"C7_PRECO" ,nPreUn ,Nil})
	aadd(aCabec,{"C7_TOTAL" ,nPreUn*nQuant ,Nil})
	aadd(aItens,aLinha)
	


	MSExecAuto({|a,b,c,d,e,f,g,h| MATA120(a,b,c,d,e,f,g,h)},1,aCabec,aItens,nOpc,.F.,,,)

	If !lMsErroAuto
		ConOut("Incluido PC: "+cDoc)
	Else
		ConOut("Erro na inclusao!")
		MostraErro()
	EndIf

	RESET ENVIRONMENT

Return
