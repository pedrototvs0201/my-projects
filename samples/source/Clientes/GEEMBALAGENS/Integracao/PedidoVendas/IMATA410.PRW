#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

User Function IMata410()

	Local nOpcX      as numeric          //Seleciona o tipo da operacao (3-Inclusao / 4-Alteracao / 5-Exclusao)
	//Local cDoc       := ""           //Numero do Pedido de Vendas (alteracao ou exclusao)
	Local cA1Cod     := cCliente     //Codigo do Cliente
	Local cA1Loja    := "01"       //Loja do Cliente
	Local cB1Cod     := cProduto     //Codigo do Produto
	Local cF4TES     := "501"        //Codigo do TES
	Local cE4Codigo  := "001"        //Codigo da Condicao de Pagamento
	Local cFilSA1    := ""
	Local cFilSB1    := ""
	Local cFilSE4    := ""
	Local cFilSF4    := ""
	Local nX         := 0
	Local nY         := 0
	Local aCabec     := {}
	Local aItens     := {}
	Local aLinhas     := {}
	Local lOk        := .T.
	Local nPed       := 0
	Local dEntreg    := DtEntr
	Local cErro := ""
	Local aErroA1 := {}

	Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .F.

	//****************************************************************
	//* ABERTURA DO AMBIENTE
	//****************************************************************

	//ConOut(Repl("-",80))
	//ConOut(PadC("Teste de Inclusao / Alteracao / Exclusao de Pedido de Venda", 80))

	//PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101" MODULO "FAT" TABLES "SC5","SC6","SA1","SA2","SB1","SB2","SF4"

	SA1->(dbSetOrder(1))
	SB1->(dbSetOrder(1))
	SE4->(dbSetOrder(1))
	SF4->(dbSetOrder(1))

	cFilAGG := xFilial("AGG")
	cFilSA1 := xFilial("SA1")
	cFilSB1 := xFilial("SB1")
	cFilSE4 := xFilial("SE4")
	cFilSF4 := xFilial("SF4")

	//****************************************************************
	//* VERIFICACAO DO AMBIENTE PARA TESTE
	//****************************************************************

	//ConOut("Verificando o ambiente")

	/*/VERIFICAR PRODUTO
	DbSelectArea("SB1")
	DbSetOrder(1)
	If DbSeek(cFilSB1 + cB1Cod,.t.)
		lOk     := .F.
		cErro += ("Cadastrar Produto: " + cB1Cod)
	EndIf

	//VERIFICAR TES
	If SF4->(! MsSeek(cFilSF4 + cF4TES))
		lOk     := .F.
		cErro += ("Cadastrar TES: " + cF4TES)
	EndIf

	//VERIFICAR CONDICAO DE PAGAMENTO
	If SE4->(! MsSeek(cFilSE4 + cE4Codigo))
		lOk     := .F.
		cErro += ("Cadastrar Condicao de Pagamento: " + cE4Codigo)
	EndIf

	//VERIFICAR CLIENTE
	If SA1->(! MsSeek(cFilSA1 + cA1Cod + cA1Loja))
		lOk     := .F.
		cErro += ("Cadastrar Cliente: " + cA1Cod + " - " + cA1Loja)
	EndIf
	/*/

	If lOk

		//****************************************************************
		//* INCLUSAO - INICIO
		//****************************************************************
		For nY := 1 To Len(aLinha1)

			cPedido := AllTrim(aLinha1[nY][21]) //Numero do Pedido de Vendas
			cA1Cod := Posicione("SA1",14,Xfilial("SA1")+AllTrim(aLinha1[nY][10]),"A1_COD") //Codigo do Cliente
			cA1Loja := Posicione("SA1",14,Xfilial("SA1")+AllTrim(aLinha1[nY][10]),"A1_LOJA") //Loja do Cliente

			DbSelectArea("SC5")
			DbSetOrder(1)
			iF DbSeek(xFilial("SC5")+cPedido,.T.)

				nOpcx := 4
			else
				nOpcx := 3
			EndIf

			//DbSelectArea("SC6")
			//DbSetOrder(2)
			//iF DbSeek(xFilial("SC6")+cB1Cod+cPedido,.T.)
			//	cItPd := posicione("SC6",2,xFilial("SC6")+cB1Cod+cPedido, 'C6_ITEM') //Numero do Item do Pedido
			//else
			//	nOpcx := 3
			//EndIf

			IF nOpcX = 3 //Inclusao
				//ConOut("Teste de Inclusao")
				//ConOut("Inicio: " + Time())

				//For nY := 1 To 1  //Quantidade de Pedidos

				RollBAckSx8()
				aCabec   := {}
				aItens   := {}
				aLinhas   := {}
				aadd(aCabec, {"C5_NUM"    , cPedido  , Nil})
				aadd(aCabec, {"C5_TIPO"   , "N"      , Nil})
				aadd(aCabec, {"C5_CLIENTE", cA1Cod   , Nil})
				aadd(aCabec, {"C5_LOJACLI", cA1Loja  , Nil})
				aadd(aCabec, {"C5_LOJAENT", cA1Loja  , Nil})
				aadd(aCabec, {"C5_CONDPAG", cE4Codigo, Nil})
				aadd(aCabec, {"C5_NATUREZ", "1.2", Nil})


				//CONOUT("Passou pelo Array do Cabecalho")
				//nX := 1 
				
				While cPedido = AllTrim(aLinha1[nY][21]) //For nX := 1 To 1  //Quantidade de Itens
					
					cB1Cod := Posicione("SB1",14,Xfilial("SB1")+AllTrim(aLinha1[nY][22]),"B1_COD") //Codigo do Produto
					nQuant := Val(aLinha1[nY][16]) //Quantidade do Item
					nPreUn := Val(aLinha1[nY][17]) //Preco Unitario do Item
					dEntreg := Stod( SubStr(AllTrim(aLinha1[nY][14]),1,4) + SubStr(AllTrim(aLinha1[nY][14]),6,2) + SubStr(AllTrim(aLinha1[nY][14]),9,2) ) //Data de Entrega
					cOp := AllTrim(aLinha1[nY][25])//NextNumero("SC2", 1, "C2_NUM", .T.) //GetSxeNum("SC2","C2_NUM") //Numero da Ordem de Producao
					cItPd := SubStr(AllTrim(aLinha1[nY][8]),7,2) //Numero do Item do Pedido
					

					aLinhas := {}
					aadd(aLinhas,{"C6_ITEM"   , cItPd          , Nil})
					aadd(aLinhas,{"C6_PRODUTO", cB1Cod         , Nil})
					aadd(aLinhas,{"C6_QTDVEN" , nQuant         , Nil})
					aadd(aLinhas,{"C6_PRCVEN" , nPreUn         , Nil})
					aadd(aLinhas,{"C6_PRUNIT" , nPreUn         , Nil})
					aadd(aLinhas,{"C6_VALOR"  , (nQuant*nPreUn), Nil})
					aadd(aLinhas,{"C6_TES"    , cF4TES         , Nil})
					aadd(aLinhas,{"C6_ENTREG" , dEntreg        , Nil})
					aadd(aLinhas,{"C6_NUMOP"  , cOP            , Nil})
					aadd(aItens, aLinhas)
					//CONOUT("Passou pelo Array dos itens")
					nY++
					If NY > Len(aLinha1) //Se for o ultimo item do pedido, sai do loop
						Exit
					EndIf
					//nX++
				EndDo 
				nY-- //Decrementa o contador para que na proxima iteracao do loop, ele pegue o proximo pedido

				//CONOUT("Iniciando a gravacao")
				MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabec, aItens, nOpcX, .F.)

				If !lMsErroAuto
					//nPed := nPed + 1
					//ConOut("Incluido com sucesso! Pedido " + AllTrim(str(nPed)) + ": " + cDoc)
					//U_IMATA650(cOP) //u_IMata410()
				Else
					aErroA1 := GetAutoGRLog()// GetAutoGRLog()
					cErro := AllToChar(aErroA1)
					//cErro += MOSTRAERRO()//("Erro na inclusao!")
					//MOSTRAERRO()
				EndIf
				//Next nY

				//ConOut("Fim: " + Time())

				//****************************************************************
				//* ALTERACAO - INICIO
				//****************************************************************

			ELSEIF nOpcX = 4 //Alteracao
				//ConOut("Teste de Alteracao")
				//ConOut("Inicio: " + Time())
				aCabec         := {}
				aItens         := {}
				aLinhas         := {}
				lMsErroAuto    := .F.
				lAutoErrNoFile := .F.

				aadd(aCabec,{"C5_NUM"    , cPedido  , Nil})
				aadd(aCabec,{"C5_TIPO"   , "N"      , Nil})
				aadd(aCabec,{"C5_CLIENTE", cA1Cod   , Nil})
				aadd(aCabec,{"C5_LOJACLI", cA1Loja  , Nil})
				aadd(aCabec,{"C5_LOJAENT", cA1Loja  , Nil})
				aadd(aCabec,{"C5_CONDPAG", cE4Codigo, Nil})

				//ALTERACAO NO ITEM
				//For nX := 1 To 1
				While cPedido = AllTrim(aLinha1[nY][21]) //For nX := 1 To 1  //Quantidade de Itens
					
					cB1Cod := Posicione("SB1",14,Xfilial("SB1")+AllTrim(aLinha1[nY][22]),"B1_COD") //Codigo do Produto
					nQuant := Val(aLinha1[nY][16]) //Quantidade do Item
					nPreUn := Val(aLinha1[nY][17]) //Preco Unitario do Item
					dEntreg := Stod( SubStr(AllTrim(aLinha1[nY][14]),1,4) + SubStr(AllTrim(aLinha1[nY][14]),6,2) + SubStr(AllTrim(aLinha1[nY][14]),9,2) ) //Data de Entrega
					cOp := posicione("SC6",2,xFilial("SC6")+cB1Cod+cPedido, 'C6_NUMOP') //GetSxeNum("SC6","C6_NUMOP") //Numero da Ordem de Producao
					cItPd := SubStr(AllTrim(aLinha1[nY][8]),7,2) //Numero do Item do Pedido

					aLinhas := {}
					aadd(aLinhas,{"LINPOS"    , "C6_ITEM"     ,strzero(val(cItPd),2)})
					aadd(aLinhas,{"AUTDELETA" , "N"           , Nil          })	
					aadd(aLinhas,{"C6_PRODUTO", cB1Cod        , Nil          })
					aadd(aLinhas,{"C6_QTDVEN" , nQuant        , Nil          })
					aadd(aLinhas,{"C6_PRCVEN" , nPreUn        , Nil          })
					aadd(aLinhas,{"C6_PRUNIT" , nPreUn        , Nil          })
					aadd(aLinhas,{"C6_VALOR"  ,(nQuant*nPreUn), Nil          })
					aadd(aLinhas,{"C6_TES"    , cF4TES        , Nil          })
					aadd(aLinhas,{"C6_NUMOP"  , cOp           , Nil          })
					aadd(aItens, aLinhas)

					nY++
					If NY > Len(aLinha1) //Se for o ultimo item do pedido, sai do loop
						Exit
					EndIf
				
				EndDo
				nY-- //Decrementa o contador para que na proxima iteracao do loop, ele pegue o proximo pedido
				MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabec, aItens, nOpcX, .F.)

				If !lMsErroAuto
					////ConOut("Alterado com sucesso! Pedido: " + cDoc)
				Else
					//ConOut("Erro na alteracao!")
					MOSTRAERRO()
				EndIf

				//ConOut("Fim: " + Time())

				//****************************************************************
				//* EXCLUSAO - INICIO
				//****************************************************************

			ELSEIF nOpcX = 5 //Exclusao
				//ConOut("Teste de Exclusao")
				//ConOut("Inicio: " + Time())
				aCabec         := {}
				aItens         := {}
				aLinhas         := {}
				lMsErroAuto    := .F.
				lAutoErrNoFile := .F.

				aadd(aCabec, {"C5_NUM",     cPedido,   Nil})
				aadd(aCabec, {"C5_TIPO",    "N",       Nil})
				aadd(aCabec, {"C5_CLIENTE", cA1Cod,    Nil})
				aadd(aCabec, {"C5_LOJACLI", cA1Loja,   Nil})
				aadd(aCabec, {"C5_LOJAENT", cA1Loja,   Nil})
				aadd(aCabec, {"C5_CONDPAG", cE4Codigo, Nil})


				MSExecAuto({|a, b, c| MATA410(a, b, c)}, aCabec, aItens, 5)

				If !lMsErroAuto
					//ConOut("Excluido com sucesso! Pedido: " + cPedido)
				Else
					//ConOut("Erro na exclusao!")
				EndIf

				//ConOut("Fim: " + Time())
				//ConOut(Repl("-",80))
			EndIf
		next
	EndIf

	//RESET ENVIRONMENT

Return(cErro)
