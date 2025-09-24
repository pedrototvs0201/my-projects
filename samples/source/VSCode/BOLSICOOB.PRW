//Bibliotecas
#Include "RWMake.ch"
#INCLUDE "TOPCONN.CH"




#DEFINE _cCarteira "1"
#DEFINE _cMoeda    "9"

/*        
+-----------+------------+----------------+----------------------+-------+------------+
| Programa  | BOLSICOOB  | Desenvolvedor  | Pedro Sousa\Denilson | Data  | 12/12/2024 |
+-----------+------------+----------------+----------------------+-------+------------+
| Descricao |Impressão do boleto SICOOB		                                          |
+-----------+-------------------------------------------------------------------------+
| Modulos   |                                                                         |
+-----------+-------------------------------------------------------------------------+
| Processos |                                                                         |
+-----------+-------------------------------------------------------------------------+
|                  Modificacoes desde a construcao inicial                            |
+----------+-------------+------------------------------------------------------------+
| DATA     | PROGRAMADOR | MOTIVO                                                     |
+----------+-------------+------------------------------------------------------------+
|17/12/2024| PEDRO EUST. | ADEQUAÇÕES PARA ZM PEDRAS                                  |
+----------+-------------+------------------------------------------------------------+
*/

User Function BOLSICOOB()

	Local cAliasAnt := GetArea()
	Local ::cDiretorio as character
	Local ::cNomeArq as character
	Local ::cNomerel as character
	Local cNF as character
	Local cCliente as character
	Local cEmail as character
	Local cNomCli as character

	Local oPrint
	Local nX			:= 0

	Local aDadosEmp   	:= {alltrim(SM0->M0_NOMECOM)   					      ,; //[1]Nome da Empresa
	SM0->M0_ENDCOB                                   						  ,; //[2]Endereço
	AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,; //[3]Complemento
	"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)             ,; //[4]CEP
	"PABX/FAX: "+SM0->M0_TEL                                                  ,; //[5]Telefones
	"CNPJ: "+TRANSFORM(SM0->M0_CGC,"@R 99.999.999/9999-99")				 	  ,; //[6]CNPJ
	"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+            ; //[7]
	Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)                        }  //[7]I.E

	Local aDadosTit   := {}
	Local aDadosBanco := {}
	Local aDatSacado  := {}
	Local nI          := 1
	Local aCB_RN_NN   := {}
	Local nVlrAbat	:= 0.00
	Local nRegs as numeric

	nRegs := 0


	lAdjustToLegacy := .T.
	lDisableSetup   := .F.
	::cDiretorio  	:= 'c:\spool\' //'\boletos'

	Private cStartPath:= GetSrvProfString("Startpath","")
	Private cCart			:= ""
	Private cNroDoc 	:= " "
	cPerg:= "BOLETOSSICOOB"
	ValidPerg()

	If !Pergunte(cPerg, .t.)
		MSGBOX("Emissao de boletos de cobranca cancelada!", "Boleto Laser", "INFO")
		Return
	EndIf

	//QSA6->A6_COD+QSA6->A6_AGENCIA+QSA6->A6_NUMCON

	cChavBanc := MV_PAR04+MV_PAR05+MV_PAR06

	If select("QRY") > 0
		QRY->(dbCloseArea())
	Endif

	cSql := " SELECT * "
	cSql += " FROM " +RetSqlName("SE1")+" SE1 "
	cSql += " WHERE SE1.D_E_L_E_T_<>'*'"
	cSql += " AND E1_FILIAL = '" + xFilial("SE1") + "'"
	cSql += " AND E1_NUM BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'
	cSql += " AND E1_PARCELA BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "'
	cSql += " AND E1_FILORIG BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "'
	cSql += " AND E1_NATUREZ BETWEEN '" + mv_par11 + "' AND '" + mv_par12 + "'
	cSql += " AND E1_CLIENTE BETWEEN '" + mv_par13 + "' AND '" + mv_par14 + "'
	cSql += " AND E1_EMISSAO BETWEEN '" + DtoS(mv_par15) + "' AND '" + DtoS(mv_par16) + "'
	cSql += " AND E1_VENCTO BETWEEN '" + DtoS(mv_par17) + "' AND '" + DtoS(mv_par18) + "'
	If !Empty(MV_PAR03)
		cSql += " AND E1_PREFIXO = '" + mv_par03 + "'"
	EndIf

	cSql += " AND E1_SALDO > 0 "
	cSql += " ORDER BY E1_NUM, E1_PREFIXO"

//MemoWrit("C:\TEMP\boleto.sql", cSql)
	TcQuery cSql NEW ALIAS "QRY"

	dbSelectArea("QRY")
	dbGotop()

	Do While !Eof()
		nRegs++
		dbSkip()
	Enddo

	
			if MV_PAR04!='756' 
	

	DbGoTop()
	ProcRegua(RecCount())


	cNF := QRY->E1_NUM
	cNF1 := cNF
	cCliente := QRY->E1_CLIENTE+QRY->E1_LOJA
	::cNomeArq 		:= "Boleto_" + QRY->E1_NUM + "_"+DtoS(Date())+"_" + StrTran(Time(),':','') + '.pdf'
	::cNomerel      := "Boleto_" + QRY->E1_NUM + "_"+DtoS(Date())+"_" + StrTran(Time(),':','') + '.rel'

	oPrint:= FWMSPrinter():New(::cNomeArq        ,           ,lAdjustToLegacy    ,::cDiretorio     ,lDisableSetup    ,            , NIL            , "PDF"      , .T.       , NIL         , NIL    , .T.        ,1)//TMSPrinter():New( "Boleto Laser" )
	//FWMsPrinter():New( < cFilePrintert >, [ nDevice], [ lAdjustToLegacy], [ cPathInServer], [ lDisabeSetup ], [ lTReport], [ @oPrintSetup], [ cPrinter], [ lServer], [ lPDFAsPNG], [ lRaw], [ lViewPDF], [ nQtdCopy] )
	//FWMSPrinter():New(cNome     ,,lAdjustToLegacy,cLocal      ,lDisableSetup,NIL, NIL, "PDF", lServer, NIL, NIL, lViewPDF,2) //<--- a impressão deve ser realizada por IMP_SPOOL, caso contrário não dará certo.
	oPrint:SetPortrait() // ou SetLandscape()
	//oPrint:StartPage()   // Inicia uma nova página
	::cDiretorio := oPrint:CPATHPDF

	Do While QRY->(!Eof())

		//if aMarked[nI]
		//Posiciona o SA6 (Bancos)
		dbSelectArea("SA6")
		dbSetOrder(1)
		dbSeek(xFilial("SA6")+cChavBanc,.T.)

		//Posiciona o SEE (Bancos)
		dbSelectArea("SEE")
		dbSetOrder(1)
		dbSeek(xFilial("SEE")+cChavBanc,.T.)

		//Posiciona o SA1 (Cliente)
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek(xFilial()+QRY->E1_CLIENTE+QRY->E1_LOJA,.T.)

		// Efetua o Preenchimento do Campo E1_NUMBCO com
		// o Numero Sequencial da Tabela EE_FAXATU.
		PrimVia:=.f.

		DbSelectArea("SE1")
		DBSETORDER(1)
		If DbSeek(xFilial("SE1")+QRY->E1_PREFIXO+QRY->E1_NUM+QRY->E1_PARCELA+QRY->E1_TIPO+QRY->E1_VENCTO,.T.)
			If Empty(SE1->E1_NUMBCO)

				PrimVia:=.t.

				RecLock("SE1",.f.)

				SE1->E1_PORTADO := Substr(cChavBanc,1,3)
				SE1->E1_AGEDEP  := Substr(cChavBanc,4,4)
				SE1->E1_CONTA   := Substr(cChavBanc,8)
				SE1->E1_OCORREN := "01"
				MsUnlock()

				nNossoNum := Right(Alltrim(SEE->EE_FAXATU),11)
				If Len(Alltrim(nNossoNum)) <> 11
					nNossoNum := Strzero(Val(nNossoNum),11)
				Endif

				// Verifica se nao estourou o contador, se estourou reinicializa
				// e grava o proximo numero
				dbSelectArea("SEE")
				RecLock("SEE",.F.)
				If nNossoNum == "99999999999"
					Replace EE_FAXATU With "00000000001"
				Else
					_nFaxAtu := Val(nNossoNum) + 1
					_nFaxAtu := Strzero(_nFaxAtu,11)
					Replace EE_FAXATU With _nFaxAtu
				Endif
				MsUnlock()

				//nNossoNum := val(nNossoNum)
				//nNossoDig   := CDigitoNosso()
				//nNossoNum := StrZero(nNossoNum,11)+nNossoDig

				MrnAg:=Left(Alltrim(SEE->EE_AGENCIA),4)
				MrnCart:=Alltrim(SEE->EE_CODCART)
				MrnDig:=fCalcDac(MrnAg,MrnCart,nNossoNum)

				RecLock('SE1',.f.)
				SE1->E1_NUMBCO := nNossoNum+MrnDig
				MsUnlock('SE1')
			Else
				nNossoNum := substr(SE1->E1_NUMBCO,1,11)
			EndIf
		EndIf

		MrnAg:=Left(Alltrim(SEE->EE_AGENCIA),4)
		MrnCart:=Alltrim(SEE->EE_CODCART)
		MrnDig:=fCalcDac(MrnAg,MrnCart,nNossoNum)

		/*DbSelectArea("SE1")
		If Empty(SE1->E1_NUMBCO)
		NossoNum()
		RECLOCK("SE1",.F.)
		SE1->E1_NUMBCO:=SUBSTR(SE1->E1_NUMBCO,3,10)
		SE1->(MSUNLOCK() )
		PrimVia:=.t.
		Endif*/
		cCart := Alltrim(SEE->EE_CODCART)
		aAdd(aDadosBanco, Alltrim(SEE->EE_CODIGO))              // [1]Numero do Banco
		aAdd(aDadosBanco, Alltrim(SA6->A6_NOME))                // [2]Nome do Banco
		aAdd(aDadosBanco, Left(Alltrim(SEE->EE_AGENCIA),4))     // [3]Agência
		aAdd(aDadosBanco, substr(Alltrim(SEE->EE_CONTA),1,6)) // [4]Conta Corrente
		aAdd(aDadosBanco, Right(Alltrim(SEE->EE_DVCTA),1))      // [5]Dígito da conta corrente
		aAdd(aDadosBanco, Alltrim(SEE->EE_CODCART))                  // [6]Codigo da Carteira
		aAdd(aDadosBanco, Right(Alltrim(SE1->E1_PARCELA),1))    // [7] PARCELA

		If Empty(SA1->A1_ENDCOB)
			aDatSacado   := {AllTrim(SA1->A1_NOME)           	,;      	// [1]Razão Social
			AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA           	,;      	// [2]Código
			AllTrim(SA1->A1_END )								,;      	// [3]Endereço
			AllTrim(SA1->A1_MUN )                            	,;  		// [4]Cidade
			SA1->A1_EST                                      	,;	     	// [5]Estado
			SA1->A1_CEP                                      	,;      	// [6]CEP
			SA1->A1_CGC											,;  	    // [7]CGC
			SA1->A1_PESSOA										,;      	// [8]PESSOA
			AllTrim(SA1->A1_BAIRRO)                             ,;			// [9]Bairro
			SA1->A1_EMAIL                           	         }        	// [10]Email
		Else
			aDatSacado   := {AllTrim(SA1->A1_NOME)            	,;   	// [1]Razão Social
			AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA              ,;   	// [2]Código
			AllTrim(SA1->A1_ENDCOB)					   			,;   	// [3]Endereço
			AllTrim(SA1->A1_MUNC)	                            ,;   	// [4]Cidade
			SA1->A1_ESTC	                                    ,;   	// [5]Estado
			SA1->A1_CEPC                                        ,;   	// [6]CEP
			SA1->A1_CGC								        	,;		// [7]CGC
			SA1->A1_PESSOA								        ,;		// [8]PESSOA
			AllTrim(SA1->A1_BAIRRO)                             ,;     	// [9]Bairro
			SA1->A1_EMAIL                           	         }      // [10]Email
		Endif

		//nVlrAbat   :=  SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
		nVlrAbat   := (E1_SALDO+E1_SDACRES)*((E1_DESCFIN+E1_SDACRES)/100)
		nVlrTitulo := (E1_SALDO+E1_SDACRES-nVlrAbat)

		//--------------------------------------------------------------
		//Parte do Nosso Numero. Sao 8 digitos para identificar o titulo
		//--------------------------------------------------------------

		//	if .not. empty ( SE1->E1_PARCELA)
		//		_cParcela := StrZero( Asc( Upper( ALLTRIM( SE1->E1_PARCELA ) ) ) - 64, 3, 0 )
		//	else
		_cParcela := '001'
		//	endif

		cNroDoc	 := STRZERO(VAL(Right(alltrim(SE1->E1_NUM),8)),8)+SE1->E1_PARCELA//StrZero( Val( Alltrim ( SE1->E1_NUM ) + _cParcela ), 8 )
		/*/
		----------------------
		Monta codigo de barras
		----------------------
		/*//*/
		aCB_RN_NN := fLinhaDig(aDadosBanco[1]      ,; // Numero do Banco
		_cMoeda             ,; // Codigo da Moeda
		aDadosBanco[6]      ,; // Codigo da Carteira
		aDadosBanco[3]      ,; // Codigo da Agencia
		aDadosBanco[4]      ,; // Codigo da Conta
		aDadosBanco[5]      ,; // DV da Conta
		nVlrTitulo		    ,; // Valor do Titulo
		E1_VENCTO           ,; // Data de Vencimento do Titulo
		cNroDoc              ) // Numero do Documento no Contas a Receber
		/*/
		aCB_RN_NN    := Ret_cBarra(Subs(aDadosBanco[1],1,3)+"9",aDadosBanco[3],aDadosBanco[4],aDadosBanco[5],cNroDoc,nVlrTitulo/*/(E1_VALOR-nVlrAbat)/*/,E1_VENCTO)

		aDadosTit	:= {AllTrim(E1_NUM)+AllTrim(E1_PARCELA)	,;  // [1] Número do título
		E1_EMISSAO                          	,;  // [2] Data da emissão do título
		dDataBase                    	   		,;  // [3] Data da emissão do boleto
		E1_VENCTO                           	,;  // [4] Data do vencimento
		nVlrTitulo		               			,;  // [5] Valor do título
		aCB_RN_NN[3]                        	,;  // [6] Nosso número (Ver fórmula para calculo)
		E1_PREFIXO                          	,;  // [7] Prefixo da NF
		E1_TIPO	                           		}   // [8] Tipo do Titulo

		if cCliente == QRY->E1_CLIENTE+QRY->E1_LOJA
			if cNF1 != QRY->E1_NUM
				cNF := cNF + "/"+ QRY->E1_NUM
				cNF1 := QRY->E1_NUM
			EndIf

			cEmail := aDatSacado[10]
			cNomCli := aDatSacado[1]
			Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,,aCB_RN_NN)

			nX := nX + 1
		else
			
			oPrint:SetViewPDF(.T.)
			oPrint:GetViewPDF(.T.)
			oPrint:Preview(.T.)
			/*/CpyT2S(::cDiretorio + ::cNomeArq,'\Boletos\',.T.)
			cAnexo := '\Boletos\' + ::cNomeArq
			U_EPMMAIL01(cAnexo,cEmail,cNomCli,cNF)
			//Apagando o arquivo
			IF (File(::cDiretorio + ::cNomerel))
				FERASE(::cDiretorio + ::cNomerel)
			EndIF
			IF (File(::cDiretorio + ::cNomeArq))
				FERASE(::cDiretorio + ::cNomeArq)
			EndIF
			/*/
			IF (File(::cDiretorio + ::cNomerel))
				FERASE(::cDiretorio + ::cNomerel)
			EndIF
			::cNomeArq 		:= "Boleto_" + QRY->E1_NUM + "_"+DtoS(Date())+"_" + StrTran(Time(),':','') + '.pdf'
			::cNomerel      := "Boleto_" + QRY->E1_NUM + "_"+DtoS(Date())+"_" + StrTran(Time(),':','') + '.rel'
			cNF := QRY->E1_NUM
			cNF1 := cNF
			cCliente := QRY->E1_CLIENTE+QRY->E1_LOJA
			cEmail := aDatSacado[10]
			cNomCli := aDatSacado[1]

			oPrint:= FWMSPrinter():New(::cNomeArq        ,           ,lAdjustToLegacy    ,::cDiretorio     ,.t.    ,     , NIL            , "PDF"      , .T.       , NIL         , NIL    , .T.        ,1)
			//FWMsPrinter():New( < cFilePrintert >, [ nDevice], [ lAdjustToLegacy], [ cPathInServer], [ lDisabeSetup ], [ lTReport], [ @oPrintSetup], [ cPrinter], [ lServer], [ lPDFAsPNG], [ lRaw], [ lViewPDF], [ nQtdCopy] )
			//FWMSPrinter():New(cNome     ,,lAdjustToLegacy,cLocal      ,lDisableSetup,NIL, NIL, "PDF", lServer, NIL, NIL, lViewPDF,2) //<--- a impressão deve ser realizada por IMP_SPOOL, caso contrário não dará certo.
			oPrint:SetPortrait() // ou SetLandscape()
			//oPrint:StartPage()   // Inicia uma nova página
			oPrint:CPATHPDF := ::cDiretorio
			Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,,aCB_RN_NN)
		EndIf
		//nX := nX + 1
		//EndIf
		QRY->(DbSkip())
		IncProc()
		nI++
	EndDo

	//oPrint:Preview()     // Visualiza antes de imprimir
	oPrint:SetViewPDF(.T.)
	oPrint:GetViewPDF(.T.)
	oPrint:Preview(.T.)
	/*/
	CpyT2S(::cDiretorio + ::cNomeArq,'\Boletos\',.T.)
	cAnexo := '\Boletos\' + ::cNomeArq
	U_EPMMAIL01(cAnexo,cEmail,cNomCli,cNF)
	//Apagando o arquivo
	IF (File(::cDiretorio + ::cNomerel))
		FERASE(::cDiretorio + ::cNomerel)
	EndIF
	IF (File(::cDiretorio + ::cNomeArq))
		FERASE(::cDiretorio + ::cNomeArq)
	EndIF
	/*/
	IF (File(::cDiretorio + ::cNomerel))
		FERASE(::cDiretorio + ::cNomerel)
	EndIF
	RestArea(cAliasAnt)

	WINEXEC("Explorer.exe" + Space(1) + ::cDiretorio)

Return Nil


Static Function Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)
	Local oFont8
	Local oFont11c
	Local oFont10
	Local oFont14
	Local ofont13
	Local oFont16n
	Local oFont15
	Local oFont14n
	Local oFont24
	Local nI := 0
	Local cStartPath := GetSrvProfString("StartPath","")
	Local cBmp := 030

	cBmp := cStartPath + "\logos\sicoob.png" //Logo do Banco


	//Parametros de TFont.New()
	//1.Nome da Fonte (Windows)
	//3.Tamanho em Pixels
	//5.Bold (T/F)
	//oFont8   := TFont():New("Arial",9,8,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont8  := TFont():New("Arial",,10,,.T.,,,,,.F. )
	oFont11c := TFont():New("Courier New",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont11  := TFont():New("Arial",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont9  := TFont():New("Arial",9,8,.T.,.T.,5,.T.,5,.T.,.F.)
	//oFont10  := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont10 := TFont():New("Arial",,12,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont14  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont20  := TFont():New("Arial",9,20,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont21  := TFont():New("Arial",9,21,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont16n := TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont15  := TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont15n := TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
	//oFont14n := TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont14n := TFont():New("Arial",,16,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont24  := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont13:= TFont():New( "Arial"       ,,06,,.f.,,,,,.f. )


	oPrint:StartPage()   // Inicia uma nova página

	/******************/
	/* PRIMEIRA PARTE */
	/******************/

	nRow1 := 0

	If File(cBmp)
		oPrint:SayBitmap(0030,150,cBmp,250,80)
	Endif
	//oPrint:Say  (0084,100,aDadosBanco[2],oFont10 )	        // [2]Nome do Banco - Retirado a pedido do banco - trocado pelo logo


	oPrint:Box  (0110,0090,0660,2250)
	oPrint:Line (0180,1500,0180,2250)
	oPrint:Line (0265,1500,0265,2250)
	oPrint:Line (0350,0090,0350,2250)
	//oPrint:Line (0450,1500,0450,2250 ) //---
	oPrint:Line (0570,1500,0570,2250 )
	//oPrint:Line (nRow1+0750, 100,nRow1+0750,2300 )
	oPrint:Line (0460,1500,0460,2250 )

	//oPrint:Line (nRow1+0150,2300,nRow1+0750,2300 )
	//oPrint:Line (nRow1+0150,0100,nRow1+0750,0100 )
	oPrint:Line (0110,1500,0660,1500 ) //--
	oPrint:Line (0110,1900,0570,1900 )

	oPrint:Say  (0135,100 ,"Beneficiário",oFont10)
	oPrint:Say  (0170,100 ,aDadosEmp[1]+" ("+aDadosEmp[6]+")"             ,oFont8)
	oPrint:Say  (0220,100 ,aDadosEmp[2]                                    ,oFont8)
	oPrint:Say  (0270,100 ,aDadosEmp[4]+"    "+aDadosEmp[3] ,oFont8) // CEP+Cidade+Estado
	oPrint:Say  (0320,100 ,aDadosEmp[6] ,oFont8)

	oPrint:Say  (0600,1510,"Nosso Número"                                 ,oFont8)
	//cString :=  Right(AllTrim(SE1->E1_NUMBCO),6)+'-'+SE1->E1_YDV_NN
	//cString :=  Left(AllTrim(SE1->E1_NUMBCO),7)+'-'+SE1->E1_YDV_NN
	//cString :=  Alltrim(SEE->EE_CODCART) + "/" + Right(Alltrim(nNossoNum),8)+"-"+mrnDiG
	cString := Alltrim(Substr(aDadosTit[6],1,2)+"/"+Substr(aDadosTit[6],3))

	nCol := 1810+(374-(len(cString)*22))
	oPrint:Say  (0650,nCol+60,cString,oFont11c)

	oPrint:Say  (0500,1510,"Agência/Código Beneficiário",oFont8)
	oPrint:Say  (0550,1540,alltrim(aDadosBanco[3]+" / "+aDadosBanco[4]+"-"+aDadosBanco[5]),oFont10)

	oPrint:Say  (0135,1510,"Vencimento",oFont8)
	oPrint:Say  (0170,1510,StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4),oFont10)

	oPrint:Say  (0400,1510,"Data de emissão",oFont8)
	oPrint:Say  (0450,1510,StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4),oFont10)


	oPrint:Say  (0135,1910,"Valor do Documento",oFont8)
	oPrint:Say  (0170,2000,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)

	oPrint:Say  (0400,0100,"Instruções(texto de responsabilidade do beneficiário)",oFont10)

	njuros := 0
	//njuros := (mv_par22/30)/100
	//njuros := Round(SE1->E1_VLCRUZ * 5.5,2)
	//If RecLock("SE1",.F.)
	//	Replace SE1->E1_VALJUR   With nJuros
	//	Replace SE1->E1_PORCJUR  With 5.5
	//	MsUnLock()
	//EndIf
	/*/
	oPrint:Say  (0450,110 ,"Após o Vencimento, cobrar mora diária de R$ "+ AllTrim(Transform((aDadosTit[5]*(5.5/100)/30),"@E 999,999,999.99"))+ ".",oFont10)
	oPrint:Say  (0500,110 ,"Após o Vencimento, cobrar multa de 2.00 %."   ,oFont10)
	oPrint:Say  (0550,110 ,"Protestar após 5 dias úteis. ",oFont10)
	
	oPrint:Say  (0600,110 ,"Não utilize DOC, TED, transferência ou depósito bancário como formas de pagamento, pois nosso"   ,oFont9)
	oPrint:Say  (0650,110 ,"sistema não identifica esses formatos como liquidação do título."   ,oFont9)
	/*/

	/*
	oPrint:Say  (nRow1+0600,0100,"Vencido mora 0,13%ad/multa 2,00%",oFont10)
	oPrint:Say  (nRow1+0650,0100,"Protesto no 5º dia útil após vencimento",oFont10)
	oPrint:Say  (nRow1+0250,1510,"Outros acrécimos",oFont8)
	oPrint:Say  (nRow1+0250,1910,"Mora / Multa",oFont8)
	oPrint:Say  (nRow1+0350,1510,"Desconto / Abatimento",oFont8)
	oPrint:Say  (nRow1+0350,1910,"Outras Deduções",oFont8)
	oPrint:Say  (nRow1+0450,1910,"Valor Cobrado",oFont8)
	*/


	/*****************/
	/* SEGUNDA PARTE */
	/*****************/

		nRow2   := 0

		//Pontilhado separador
	/*
	For nI := 100 to 2300 step 50
	oPrint:Line(nRow2+0580, nI,nRow2+0580, nI+30)
	Next nI
	*/


		//If File(cBmp)
		//	oPrint:SayBitmap(nRow2+0644,100,cBmp,215,65)
		//Endif



		oPrint:Say  (750,100,"Dados do Pagador",oFont10)
		oPrint:Box  (0800,0090,1440,2250)
		//oPrint:Line (nRow2+0950,100,nRow2+0950,2300 )
		oPrint:Line (0900,0090,0900,2250 )
		oPrint:Line (0990,0090,0990,2250 )
		oPrint:Line (1100,0090,1100,2250 )
		oPrint:Line (1210,0090,1210,2250 )
		//oPrint:Line (nRow2+1600,100,nRow2+1600,2300 )

		//oPrint:Line (nRow2+0950,0100,nRow2+1600,0100)
		oPrint:Line (0800,1800,0900,1800)
		oPrint:Line (1100,1700,1210,1700)
		oPrint:Line (1100,1500,1210,1500)
		//oPrint:Line (nRow2+0950,2300,nRow2+1600,2300)

		oPrint:Say  (0825,110 ,"Nome do Pagador"                                        ,oFont8)
		//oPrint:Say  (nRow2+1000,110 ,aDatSacado[1]+"                   ",oFont10)			 //Nome
		if aDatSacado[8] = "J"
			oPrint:Say  (0875,110 ,aDatSacado[1]+"                    CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99") ,oFont10)	 //Nome
		Else
			oPrint:Say  (0875,110 ,aDatSacado[1]+"                    CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99") ,oFont10)	 //Nome
		EndIf


		oPrint:Say  (0825,1810 ,"Nro.Documento"                                  ,oFont8)
		oPrint:Say  (0875,1810 ,cNroDoc/*Alltrim(SE1->E1_NUM)+SE1->E1_PARCELA/*aDadosTit[7]+aDadosTit[1]*/						   ,oFont10) //Prefixo +Numero+Parcela

		oPrint:Say  (0930,110 ,"Endereço"                                        ,oFont8)
		oPrint:Say  (0970,110 ,aDatSacado[3]+"                   ",oFont10) //Endereco

		oPrint:Say  (1020,110 ,"Bairro"                                        ,oFont8)
		oPrint:Say  (1070,110 ,aDatSacado[9]+"                   ",oFont10) //Bairro

		oPrint:Say  (1130,110 ,"Municipio"                                        ,oFont8)
		oPrint:Say  (1180,110 ,aDatSacado[4]+"                   ",oFont10) //Cidade

		oPrint:Say  (1130,1510 ,"UF"                                        ,oFont8)
		oPrint:Say  (1180,1510,aDatSacado[5]+"                   ",oFont10) //UF

		oPrint:Say  (1130,1710 ,"CEP"                                        ,oFont8)
		oPrint:Say  (1180,1710,aDatSacado[6]+"                   ",oFont10) //CEP


		oPrint:Say  (1240,110 ,"Mensagem Pagador"                                        ,oFont8)
		oPrint:Say  (1480,200 ,"Este recibo somente terá validade com a  autenticação mecânica ou"                                        ,oFont8)
		oPrint:Say  (1530,200 ,"acompanhado do recibo de pagamento emitido pelo Banco. Recebimento"                                        ,oFont8)
		oPrint:Say  (1580,200 ,"através do cheque n.          do banco. Esta esta quitação só terá"                                        ,oFont8)
		oPrint:Say  (1630,200 ,"validade após o pagamento do cheque pelo banco pagador."                                        ,oFont8)
		oPrint:Say  (1480,1350 ," Autenticação Mecânica  -  Recibo do Pagador" ,oFont8)


		oPrint:Line (1480,1200,1480,1300)
		oPrint:Line (1480,1200,1640,1200)
		oPrint:Line (1480,2000,1480,2100)
		oPrint:Line (1480,2100,1640,2100)


	/******************/
	/* TERCEIRA PARTE */
	/******************/

		nRow3 := 0

		For nI := 0080 to 2250 step 50
			oPrint:Line(1700, nI, 1700, nI+30)
		Next nI

		If File(cBmp)
			oPrint:SayBitmap(1790,150,cBmp,250,85)
		Endif

		oPrint:Box  (1880,0090,2795,2250)

		//oPrint:Line (nRow3+2000,100,nRow3+2000,2300)
		oPrint:Line (1880,500,1800, 500)
		oPrint:Line (1880,710,1800, 710)


		//oPrint:Say  (1850,100,aDadosBanco[2],oFont10 ) // NOME DO BANCO

		oPrint:Say  (1850,575,"756-0",oFont14n) 	// 	[1]Numero do Banco
		oPrint:Say  (1850,0900,aCB_RN_NN[2],oFont15n)	//	Linha Digitavel do Codigo de Barras

		oPrint:Line (1980,0090,1980,2250 )
		oPrint:Line (2070,0090,2070,2250 )
		oPrint:Line (2160,0090,2160,2250 )
		oPrint:Line (2260,0090,2260,2250 )

		//oPrint:Line (nRow3+2000,2300 ,nRow3+2850,2300 )
		//oPrint:Line (nRow3+2000,100 ,nRow3+2850,100 )
		oPrint:Line (2070,500 ,2260,500 )
		oPrint:Line (2160,750 ,2260,750 )
		oPrint:Line (2070,1000,2260,1000)
		oPrint:Line (2070,1300,2160,1300)
		oPrint:Line (2070,1480,2260,1480)

		oPrint:Say  (1920,110 ,"Local de Pagamento",oFont8)
		oPrint:Say  (1960,400 ,"Pagável Preferencialmente no Banco Sicoob",oFont10)


		oPrint:Say  (1920,1810,"Vencimento",oFont8)
		cString := StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
		nCol	 	 := 1810+(374-(len(cString)*22))
		oPrint:Say  (1960,nCol,cString,oFont10)
		oPrint:Say  (2010,100 ,"Beneficiário",oFont8)
		oPrint:Say  (2040,100 ,aDadosEmp[1]+"               - "+aDadosEmp[6]	,oFont10) //Nome + CNPJ
		oPrint:Say  (2010,1810,"Agência/Código Beneficiário",oFont8)
		cString := Alltrim(aDadosBanco[3]+" / "+aDadosBanco[4]+"-"+aDadosBanco[5])
		nCol 	 := 1810+(374-(len(cString)*22))
		oPrint:Say  (2040,nCol+30,cString ,oFont10)
		oPrint:Say (2100,100 ,"Data do Documento"                             ,oFont8)
		oPrint:Say (2130,100, StrZero(Day(dDataBase),2) +"/"+ StrZero(Month(dDataBase),2) +"/"+ Right(Str(Year(dDataBase)),4), oFont10)
		oPrint:Say (2100,505 ,"Nro.Documento"                                 ,oFont8)
		oPrint:Say (2130,605 ,cNroDoc/*alltrim(SE1->E1_NUM)+SE1->E1_PARCELA/*aDadosTit[7]+aDadosTit[1]*/	    ,oFont10) //Prefixo +Numero+Parcela
		oPrint:Say (2100,1005,"Espécie Doc."                                  ,oFont8)
		oPrint:Say (2130,1050,"DM"									,oFont10) //Tipo do Titulo
		oPrint:Say (2100,1305,"Aceite"                                        ,oFont8)
		oPrint:Say (2130,1400,"N"                                             ,oFont10)
		oPrint:Say (2100,1485,"Data do Processamento"                        ,oFont8)
		oPrint:Say (2130,1550,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4)                               ,oFont10) // Data impressao
		oPrint:Say (2100,1810,"Nosso Número"                                 ,oFont8)
		cString := Alltrim(Substr(aDadosTit[6],1,2)+"/"+Substr(aDadosTit[6],3))
		//cString :=  Alltrim(SEE->EE_CODCART) + "/" + Right(Alltrim(nNossoNum),8)+"-"+MrnDig


		oPrint:Say  (2130,nCol+60,cString,oFont10)
		oPrint:Say  (2190,100 ,"Uso do Banco"                                 ,oFont8)
		oPrint:Say  (2190,505 ,"Carteira"                                     ,oFont8)
		oPrint:Say  (2230,555 ,aDadosBanco[6]                                 ,oFont10)
		oPrint:Say  (2190,755 ,"Espécie"                                      ,oFont8)
		oPrint:Say  (2230,805 ,"R$"                                           ,oFont10)
		oPrint:Say  (2190,1005,"Quantidade"                                   ,oFont8)
		oPrint:Say  (2190,1485,"Valor"                                        ,oFont8)
		oPrint:Say  (2190,1810,"Valor do Documento"                          	,oFont8)
		cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
		oPrint:Say  (2230,nCol+60,cString,oFont10)
		oPrint:Say  (2290,100 ,"Instruções (texto de responsabilidade do beneficiário) ",oFont8)

		njuros := 0
		//njuros := (mv_par22/30)/100
		//njuros := Round(SE1->E1_VLCRUZ * 5.5,2)
		//If RecLock("SE1",.F.)
		//	Replace SE1->E1_VALJUR   With nJuros
		//	Replace SE1->E1_PORCJUR  With 5.5
		//	MsUnLock()
		//EndIf
	/*/
		oPrint:Say  (2340,110 ,"Após o Vencimento, cobrar mora diária de R$ "+ AllTrim(Transform((aDadosTit[5]*(5.5/100)/30),"@E 999,999,999.99"))+ ".",oFont10)
		oPrint:Say  (2390,110 ,"Após o Vencimento, cobrar multa de 2.00 %."   ,oFont10)
		oPrint:Say  (2440,110 ,"Protestar após 5 dias úteis. ",oFont10)

		oPrint:Say  (2490,110 ,"Não utilize DOC, TED, transferência ou depósito bancário como formas de pagamento,"   ,oFont10)
		oPrint:Say  (2540,110 ,"pois nosso sistema não identifica esses formatos como liquidação do título."   ,oFont10)
	/*/

		oPrint:Say  (2290,1810,"(-)Desconto/Abatimento"                       ,oFont8)
		oPrint:Say  (2360,1810,"(-)Outras Deduções"                           ,oFont8)
		oPrint:Say  (2430,1810,"(+)Mora/Multa"                                ,oFont8)
		oPrint:Say  (2500,1810,"(+)Outros Acréscimos"                         ,oFont8)
		oPrint:Say  (2570,1810,"(=)Valor Cobrado"                             ,oFont8)


		oPrint:Say  (2650,100 ,"Pagador"                                       ,oFont8)
		oPrint:Say  (2660,400 ,aDatSacado[1]+" ("+aDatSacado[2]+")"           ,oFont10)

		if aDatSacado[8] = "J"
			oPrint:Say  (2660,1750,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CGC
		Else
			oPrint:Say  (2660,1750,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10) 	// CPF
		EndIf

		oPrint:Say  (2700,400 ,aDatSacado[3]+"    "+aDatSacado[9]                          ,oFont10)
		oPrint:Say  (2740,400 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado


		oPrint:Say  (2790,100 ,"Pagador/Avalista"                             ,oFont8)
		oPrint:Say  (2820,1500,"Autenticação Mecânica - Ficha de Compensação" ,oFont8)

		oPrint:Line (1880,1800,2620,1800 )
		oPrint:Line (2330,1800,2330,2250 )
		oPrint:Line (2400,1800,2400,2250 )
		oPrint:Line (2470,1800,2470,2250 )
		oPrint:Line (2540,1800,2540,2250 )
		oPrint:Line (2620,0090,2620,2250 )
		//oPrint:Line (nRow3+2850,100,nRow3+2850,2300  )

		oPrint:Int25(2825,120,aCB_RN_NN[1],0.80,35,.F.,.F., oFont8)
		//MSBAR3("INT25",25.3,3.00,aCB_RN_NN[1],oPrint,.F.,Nil,nil,0.0253,1.3,.F.,Nil,Nil,.F.)
		//MSBAR(cTypeBar,nRow,nCol,cCode,oPrint,lCheck,Color,lHorz,nWidth,nHeigth,lBanner,cFont,cMode)

		oPrint:EndPage() // Finaliza a página
		Return Nil




Static Function fLinhaDig(cCodBanco, ; // Codigo do Banco ()
	cCodMoeda, ; // Codigo da Moeda (9)
	cCarteira, ; // Codigo da Carteira
	cAgencia , ; // Codigo da Agencia
	cConta   , ; // Codigo da Conta
	cDvConta , ; // Digito verificador da Conta
	nValor   , ; // Valor do Titulo
	dVencto  , ; // Data de vencimento do titulo
	cNroDoc   )  // Numero do Documento Ref ao Contas a Receber

	Local cValorFinal := StrZero(int(Round(nValor*100,2)),10)
	Local cFator      :=  (dVencto - CtoD("03/07/2000")) + 1000


	//em observação - acredito que sejam desnecessários
	//Local cCodBar   	:= Replicate("0",43)
	//Local cCampo1   	:= Replicate("0",05)+"."+Replicate("0",05)
	//Local cCampo2   	:= Replicate("0",05)+"."+Replicate("0",06)
	//Local cCampo3   	:= Replicate("0",05)+"."+Replicate("0",06)
	//Local cCampo4   	:= Replicate("0",01)
	//Local cCampo5   	:= Replicate("0",14)

	Local cTemp     	:= ""
	Local cDV			:= "" // Digito verificador dos campos
	Local cLinDig		:= ""

	Local _cNumDoBco

	Local _cParcela
	//Local _cCodCliente	:= padl(ALLTRIM(SEE->EE_CODEMP),10,'0') //0001007416 O uso do codigo inteiro estava gerando um codigo de barras com mais digitos que o correto
	Local _cCodCliente	:= Left(SEE->EE_CODEMP,7)
	Local _cCodCAR 	:= Alltrim(SEE->EE_CODCART)
	Local _cDV_CB		:= ""
	Local _nI

	_cCodCliente:='5008131'


	//if .not. empty ( SE1->E1_PARCELA)
	//	_cParcela := StrZero( Asc( Upper( ALLTRIM( SE1->E1_PARCELA ) ) ) - 64, 3, 0 )
	//else
	_cParcela := '001'
	//endif

	_cNumDoBco  	:= SE1->E1_NUMBCO // Nosso numero

	if cFator>9999 // logica para Fator de vencimento de boleto, foi alterada para titulos com vencimento a partir de 22/02/2025 , caso passe de 10.000 ele deve retornar para 1.000
	 cFator      := StrZero(cFator-8999,4)
	else 
	cFator      := StrZero(cFator,4)
	EndIf
	//	-------------------------
	//	Definicao do NOSSO NUMERO
	//	-------------------------
	If At("-",cConta) > 0
		cDig   := Right(AllTrim(cConta),1)
		cConta := AllTrim(Str(Val(Left(cConta,At('-',cConta)-1) + cDig)))
	Else
		cConta := AllTrim(Str(Val(cConta)))
	Endif


	cTemp			:= Alltrim(cAgencia) + _cCodCAR + _cNumDoBco //base numérica para calcular o digito verificador do nosso número
	cConstRep			:= "21212121212121212" //constante fornecida pelo SICOOB "3197"
	nSoma_Resultado 	:= 0

	FOR _nI := 1 TO 21  STEP 1

		_nD_NN :=  VAL( SUBSTR( cTemp, _nI, 1 ) ) // PEGA UM DIGITO DO NOSSO NUMERO
		_nD_CR :=  VAL( SUBSTR( cConstRep   , _nI, 1 ) ) // PEGA UM DIGITO DA CONSTANTE REPETIDA

		nResultado := _nD_NN * _nD_CR

		If nResultado > 9

			nResultado := VAL(STR(nResultado,1,1)) + VAL(STR(nResultado,2,1))

		EndIf

		nSoma_Resultado += nResultado



	NEXT


	_nRestoOperacao	:= Mod( nSoma_Resultado, 10 )

	_cDV_NumBco  := STR( 10 - _nRestoOperacao, 1 ) //digito verificador do número do banco
	_cDV_NumBco:=MrnDig

	cNossoNum	:= _cNumDoBco + _cDV_NumBco
	cNossoNum   :=StrZero(Val(cNossoNum),10)

	//GRAVA O DÍGITO VERIFICAR DO NOSSO NÚMERO
	If Empty(SE1->E1_NUMBCO) .or. PrimVia
		RECLOCK("SE1",.F.)
		//SE1->E1_YDV_NN := _cDV_NumBco
		SE1->E1_NUMBCO:=cNossoNum
		SE1->(MSUNLOCK() )
	Endif

	//	-----------------------------
	//	Definicao do CODIGO DE BARRAS
	//	-----------------------------

	//Campo Obrigatório: determinado pelo BACEN
	cCodBar := Alltrim(cCodBanco)        // 01 a 03
	cCodBar += Alltrim(cCodMoeda)        // 04 a 04

	cCodBar += "0"						 // 05 a 05 - DV (será preenchido após o cálculo, conforme função delphi

	cCodBar += cFator		             // 06 a 09
	cCodBar += Alltrim(cValorFinal)      // 10 a 19

	//Campo Livre, conforme definição de cada banco
	//cCodBar += cCarteira             	// 20 a 20
	cCodBar += cAgencia		   		// 20 a 23
	cCodBar += _cCodCAR				// 24 A 26
	cCodBar += _cCodCliente			// 27 a 33
	//cCodBar += _cNumDoBco + _cDV_NumBco	// 34 a 44
	cCodBar+= Right(cNossoNum,9) + MrnDig

	cCodBar := LEFT( cCodBar, 4 ) + (_cDV_CB := Modulo11( cCodBar )) + SUBSTR( cCodBar, 6 )

	//Campo livre
	//25 posições, onde:
	//Agência sem DV – 4 posições (vide e-mail)
	//Carteira – 3 posições (vide e-mail)
	//Operação – 7 posições (vide e-mail)
	//Nosso Número + DV – 11 posições (utilizar o range disponibilizado – vide e-mail)


	/*
	-----------------------------------------------------
	Definicao da LINHA DIGITAVEL (Representacao Numerica)
	-----------------------------------------------------

	Campo 1			Campo 2			Campo 3			Campo 4		Campo 5
	AAABC.CCDDX		DDDDD.DDFFFY	FGGGG.GGHHHZ	K			UUUUVVVVVVVVVV

	CAMPO 1:
	AAA = Codigo do banco na Camara de Compensacao                                            Substr(Right(AllTrim(SE1->E1_NUMBCO
	B = Codigo da moeda, sempre 9
	CCC = Codigo da Carteira de Cobranca
	DD = Dois primeiros digitos no nosso numero
	X = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
	*/

	cTemp   := cCodBanco + cCodMoeda + cAgencia + Alltrim(SubStr(_cCodCAR,1,1))
	cDV		:= Alltrim( Str( Modulo10(cTemp) ) )

	cCampo1 := SubStr( cTemp, 1, 5 ) + Alltrim( SubStr( cTemp, 6 ) ) + cDV


	/*

	CAMPO 2:
	DDDDDD = Restante do Nosso Numero
	E = DAC do campo Agencia/Conta/Carteira/Nosso Numero
	FFF = Tres primeiros numeros que identificam a agencia
	Y = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
	*/

	cTemp	:= Alltrim(SubStr(_cCodCAR,2,2)) + _cCodCliente
	cDV		:= Alltrim( Str( Modulo10(cTemp) ) )

	cCampo2 := Substr( cTemp, 1, 5 ) + Substr( cTemp, 6 )  + cDV

	/*
	CAMPO 3:
	F = Restante do numero que identifica a agencia
	GGGGGG = Numero da Conta + DAC da mesma
	HHH = Zeros (Nao utilizado)
	Z = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
	*/

	cTemp  	:= Right(cNossoNum,9) + MrnDig//Right(_cNumDoBco,9) + _cDV_NumBco
	cDV		:= Alltrim( Str (Modulo10(cTemp) ) )

	cCampo3	:= Substr( cTemp, 1, 5 ) +  Substr(cTemp,6)  + cDV

	//Campo livre
	//25 posições, onde:
	//Agência sem DV – 4 posições (vide e-mail)
	//Carteira – 3 posições (vide e-mail)
	//Operação – 7 posições (vide e-mail)
	//Nosso Número + DV – 11 posições (utilizar o range disponibilizado – vide e-mail)



	/*
	CAMPO 4:
	K = DAC do Codigo de Barras
	*/

	cCampo4 :=  _cDV_CB


	/*
	CAMPO 5:
	UUUU = Fator de Vencimento
	VVVVVVVVVV = Valor do Titulo
	*/

	cCampo5 := Strzero(cFator,4) + StrZero(cValorFinal,10)



	cLinDig := cCampo1 + cCampo2 + cCampo3 + cCampo4 + cCampo5

	cTemp := substr(cLinDig,01,03) //codigo do banco
	cTemp += substr(cLinDig,04,01) //moeda
	cTemp += substr(cLinDig,33,01) //digito verificador
	cTemp += substr(cLinDig,34,04) //fator de vencimento
	cTemp += substr(cLinDig,38,10) //valor do documento
	cTemp += substr(cLinDig,05,01) //carteira
	cTemp += substr(cLinDig,06,04) //agencia
	cTemp += substr(cLinDig,11,02) //modalidade de cobrança
	cTemp += substr(cLinDig,13,07) //código do cliente
	cTemp += substr(cLinDig,20,01) //nosso número inicio
	cTemp += substr(cLinDig,22,07) //nosso número fim
	cTemp += substr(cLinDig,29,03) //parcela

	cLinDig := cCampo1 + cCampo2 + cCampo3 + Modulo11(cTemp) + cCampo5


Return {cCodBar, cLinDig, cNossoNum}

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³Ret_cBarra³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASE DO SICOOB COM CODIGO DE BARRAS      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cNroDoc,nValor,dVencto)

	LOCAL cValorFinal := strzero(int(nValor*100),10)
	LOCAL nDvnn			:= 0
	LOCAL nDvcb			:= 0
	LOCAL nDv			:= 0
	LOCAL cNN			:= ''
	LOCAL cRN			:= ''
	LOCAL cCB			:= ''
	LOCAL cS				:= ''
	LOCAL cFator      := (dVencto - ctod("07/10/97"))


	if  cFator >9999 // logica para Fator de vencimento de boleto, foi alterada para titulos com vencimento a partir de 22/02/2025 , caso passe de 10.000 ele deve retornar para 1.000
	cFator := StrZero(cFator-9999,4)
	else
	cFator :=StrZero(cFator,4)   
	EndIf


//-----------------------------
// Definicao do NOSSO NUMERO
// ----------------------------
	cS    := nNossoNum//cNroDoc //19 001000012
	nDvnn := MrnDig//modulo11(cS) // digito verifacador
	cNNSD := padl(cS,11,"0") //Nosso Numero sem digito
	cNN   := cCart + cS+ '-' + AllTrim(nDvnn)//cCart + cNroDoc + '-' + AllTrim(nDvnn)
//----------------------------------
//	 Definicao do CODIGO DE BARRAS
//----------------------------------
	cLivre := Strzero(Val(cAgencia),4)+ cCart+ cNNSD + Strzero(Val(cConta),7) + "0"

	cS:= cBanco + cFator +  cValorFinal + cLivre // + Subs(cNN,1,11) + Subs(cNN,13,1) + cAgencia + cConta + cDacCC + '000'
	nDvcb := modulo11(cS)
	cCB   := SubStr(cS, 1, 4) + AllTrim(Str(nDvcb)) + SubStr(cS,5)// + SubStr(cS,31)

//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
//	Campo 1			Campo 2			Campo 3			Campo 4		Campo 5
//	AAABC.CCCCX		DDDDD.DDDDDY	FFFFF.FFFFFZ	K			UUUUVVVVVVVVVV

// 	CAMPO 1:
//	AAA	= Codigo do banco na Camara de Compensacao
//	B     = Codigo da moeda, sempre 9                          		
//	CCCCC = 5 primeiros digidos do cLivre
//	X     = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

	cS    := cBanco + Substr(cLivre,1,5)
	nDv   := modulo10(cS)  //DAC
	cRN   := SubStr(cS, 1, 5) + '.' + SubStr(cS, 6, 4) + AllTrim(Str(nDv)) + '  '

// 	CAMPO 2:
//	DDDDDDDDDD = Posição 6 a 15 do Nosso Numero 
//	Y          = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

	cS :=Subs(cLivre,6,10)
	nDv:= modulo10(cS)
	cRN += Subs(cS,1,5) +'.'+ Subs(cS,6,5) + Alltrim(Str(nDv)) + ' '

// 	CAMPO 3:
//	FFFFFFFFFF = Posição 16 a 25 do Nosso Numero 
//	Z          = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
	cS :=Subs(cLivre,16,10)
	nDv:= modulo10(cS)
	cRN += Subs(cS,1,5) +'.'+ Subs(cS,6,5) + Alltrim(Str(nDv)) + ' '

//	CAMPO 4:
//	     K = DAC do Codigo de Barras
	cRN   += AllTrim(Str(nDvcb)) + '  '

// 	CAMPO 5:
//	      UUUU = Fator de Vencimento
//	VVVVVVVVVV = Valor do Titulo
	cRN   += cFator + StrZero(Int(nValor * 100),10)

Return({cCB,cRN,cNN})



Static Function Modulo10(cData)

	LOCAL L,D,P := 0
	LOCAL B     := .F.
	L := Len(cData)
	B := .T.
	D := 0
	While L > 0
		P := Val(SubStr(cData, L, 1))
		If (B)
			P := P * 2
			If P > 9
				P := P - 9
			End
		End
		D := D + P
		L := L - 1
		B := !B
	End
	D := 10 - (Mod(D,10))
	If D = 10
		D := 0
	End
Return(D)

Static Function Modulo11(cData)
	LOCAL L, D, P := 0
	L := Len(cdata)
	D := 0
	P := 1
	While L > 0
		P := P + 1
		D := D + (Val(SubStr(cData, L, 1)) * P)
		If P = 9
			P := 1
		End
		L := L - 1
	End
	D := 11 - (mod(D,11))
	If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
		D := 1
	End
Return(D)

/*/
Static Function Modulo11( _cCodBarra )

	LOCAL _cDvMod11 	:= ''
	LOCAL cIndice 	:= "43290876543298765432987654329876543298765432"
	LOCAL nContador	:= 0
	LOCAL nSoma		:= 0

	FOR nContador := 1 TO 44  STEP 1
		nSoma +=  VAL( SUBSTR( _cCodBarra, nContador, 1 ) ) *  VAL( SUBSTR( cIndice , nContador, 1 ) ) // SOMATÓRIA PARA COMPOR A BASE DE CÁLCULO PARA O DÍGITO VERIFICADOR
	NEXT

	_cDvMod11 := ALLTRIM( STR( 11 - MOD( nSoma, 11 ) ) )

	IF _cDvMod11 <= '1' .OR. _cDvMod11 > '9'
		_cDvMod11 := '1'
	ENDIF

Return _cDvMod11
/*/

Static Function fCalcDac(MAg,MCa,MNo)
	Local x
	//private _Sequen := "124801875109"+_cNossoNum
	private _Sequen := MCa+StrZero(Val(MNo),11)
	private _nFator:= {2,7,6,5,4,3,2,7,6,5,4,3,2}
	private _soma := 0
	for x:= 1 to len(_Sequen)
		_Produto := val(substr(_Sequen,x,1))*_nFator[x]
		//if _Produto < 10
		_soma := _Soma+_produto
		//else
		//	_soma := _soma +((_produto % 10)+1)
		//endif
	next

	if _soma%11 = 0
		_cDAC := 	'0'
	else
		_cDAC := alltrim(str(11-(_soma%11)))
	endIf

	if _cDAC = '10'
		_cDAC := 'P'
	EndIf
	//_cDAC := 	alltrim(str(iif(_soma%11=0,0,11-(_soma%11))))

return(_cDAC)


	*--------------------------------------------------------------------------------------

Static Function ValidPerg()

	Local _nI, _nJ

	cPerg := PadR( cPerg, 10, " ")

	_aPerguntas := {}
	_aSX1Cpos := 	 {"X1_GRUPO","X1_ORDEM","X1_PERGUNT"                  ,"X1_VARIAVL","X1_TIPO","X1_TAMANHO","X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID"                     ,"X1_VAR01","X1_DEF01"         ,"X1_CNT01"            ,"X1_DEF02"       ,"X1_DEF03"      ,"X1_DEF04"       ,"X1_F3"            ,"X1_HELP"}
	Aadd(_aPerguntas,{ cPerg    ,"01"      ,"Titulo de:    "              ,"mv_ch1"    ,"C"      ,09          ,0           ,0          ,"G"     ,""                             ,"MV_PAR01",""                 ,""                    ,""               ,""              ,""               ,"SE1"              ,"         "})
	Aadd(_aPerguntas,{ cPerg    ,"02"      ,"Titulo Até:   "              ,"mv_ch2"    ,"C"      ,09          ,0           ,0          ,"G"     ,""                             ,"MV_PAR02",""                 ,""                    ,"" 			    ,""              ,""               ,"SE1"              ,"         "})
	Aadd(_aPerguntas,{ cPerg    ,"03"      ,"Prefixo:      "              ,"mv_ch3"    ,"C"      ,03          ,0           ,0          ,"G"     ,""                             ,"MV_PAR03",""                 ,"" 		              ,""               ,""              ,""               ,"   "              ,"         "})
	Aadd(_aPerguntas,{ cPerg    ,"04"      ,"Banco:        "       	      ,"mv_ch4"    ,"C"      ,03          ,0           ,0          ,"G"     ,""                             ,"MV_PAR04",""                 ,""       		      ,""               ,""              ,""               ,"SA6"              ,"         "})
	Aadd(_aPerguntas,{ cPerg    ,"05"      ,"Agencia:      "              ,"mv_ch5"    ,"C"      ,05          ,0           ,0          ,"G"     ,""                             ,"MV_PAR05",""                 ,""             		  ,""               ,""              ,""               ,"   "              ,"         "})
	Aadd(_aPerguntas,{ cPerg    ,"06"      ,"Conta:        "              ,"mv_ch6"    ,"C"      ,10          ,0           ,0          ,"G"     ,""                             ,"MV_PAR06",""                 ,""          		  ,""               ,""              ,""               ,"   "              ,"         "})
	Aadd(_aPerguntas,{ cPerg    ,"07"      ,"Parcela de:   "              ,"mv_ch7"    ,"C"      ,03          ,0           ,0          ,"G"     ,""                             ,"MV_PAR07",""                 ,""      	          ,""               ,""              ,""               ,"   "              ,"         "})
	Aadd(_aPerguntas,{ cPerg    ,"08"      ,"Parcela Até:  "              ,"mv_ch8"    ,"C"      ,03          ,0           ,0          ,"G"     ,""                             ,"MV_PAR08",""                 ,"ZZZ"      		      ,""               ,""              ,""               ,"   "              ,"         "})
	Aadd(_aPerguntas,{ cPerg    ,"09"      ,"Filial de:    "              ,"mv_ch9"    ,"C"      ,04          ,0           ,0          ,"G"     ,""                             ,"MV_PAR09",""                 ,""        		      ,""               ,""              ,""               ,"SM0"              ,"         "})
	Aadd(_aPerguntas,{ cPerg    ,"10"      ,"Filial Até:   "              ,"mv_chA"    ,"C"      ,04          ,0           ,0          ,"G"     ,""                             ,"MV_PAR10",""                 ,"999"       	      ,""               ,""              ,""               ,"SM0"              ,"         "})
	Aadd(_aPerguntas,{ cPerg    ,"11"      ,"Natureza de:  "              ,"mv_chB"    ,"C"      ,10          ,0           ,0          ,"G"     ,""                             ,"MV_PAR11",""                 ,""        		      ,""               ,""              ,""               ,"SED"              ,"         "})
	Aadd(_aPerguntas,{ cPerg    ,"12"      ,"Natureza Até: "              ,"mv_chC"    ,"C"      ,10          ,0           ,0          ,"G"     ,""                             ,"MV_PAR12",""                 ,"ZZZZZZ"    	      ,""               ,""              ,""               ,"SED"              ,"         "})
	Aadd(_aPerguntas,{ cPerg    ,"13"      ,"Cliente de:   "              ,"mv_chD"    ,"C"      ,10          ,0           ,0          ,"G"     ,""                             ,"MV_PAR13",""                 ,""       		      ,""               ,""              ,""               ,"SA1"              ,"         "})
	Aadd(_aPerguntas,{ cPerg    ,"14"      ,"Cliente até:  "              ,"mv_chE"    ,"C"      ,10          ,0           ,0          ,"G"     ,""                             ,"MV_PAR14",""                 ,"ZZZZZ"       	      ,""               ,""              ,""               ,"SA1"              ,"         "})
	Aadd(_aPerguntas,{ cPerg    ,"15"      ,"Emissão de:   "              ,"mv_chF"    ,"D"      ,8           ,0           ,0          ,"G"     ,""                             ,"MV_PAR15",""                 ,'01/01/2000'          ,""               ,""              ,""               ,""                 ,"         "})
	Aadd(_aPerguntas,{ cPerg    ,"16"      ,"Emissão até:  "              ,"mv_chG"    ,"D"      ,8           ,0           ,0          ,"G"     ,""                             ,"MV_PAR16",""                 ,'31/12/2099'  	      ,""               ,""              ,""               ,""                 ,"         "})
	Aadd(_aPerguntas,{ cPerg    ,"17"      ,"Vencto de:    "              ,"mv_chH"    ,"D"      ,8           ,0           ,0          ,"G"     ,""                             ,"MV_PAR17",""                 ,'01/01/2000'          ,""               ,""              ,""               ,""                 ,"         "})
	Aadd(_aPerguntas,{ cPerg    ,"18"      ,"Vencto até:   "              ,"mv_chI"    ,"D"      ,8           ,0           ,0          ,"G"     ,""                             ,"MV_PAR18",""                 ,'31/12/2099'  	      ,""               ,""              ,""               ,""                 ,"         "})
	
	//Aadd(_aPerguntas,{ cPerg    ,"11"      ,"Categoria:  "              ,"mv_chB"    ,"C"      ,15          ,0           ,0          ,"G"     ,"fCategoria() .And. NaoVazio()","MV_PAR11",""                 ,""                    ,""               ,""              ,""               ,"   "              ,"         "})

	//Aadd(_aPerguntas,{ cPerg    ,"03"      ,"Local para gerar o arquivo: ","mv_ch3"    ,"C"      ,40          ,0           ,0          ,"G"     ,"MV_PAR03",""                 ,            ,""                      ,""              ,""               ,"   "              ,"       "})

	DbSelectArea("SX1")

	For _nI:=1 to Len(_aPerguntas)
		If DbSeek( _aPerguntas[_nI,1]+_aPerguntas[_nI,2] )
			RecLock("SX1",.F.)    // .T. novo  .F. altera existente
		Else
			RecLock("SX1",.T.)    // .T. novo  .F. altera existente

		EndIf

		For _nJ:=1 to Len(_aPerguntas[_nI])
			FieldPut( FieldPos(_aSX1Cpos[_nJ]) ,_aPerguntas[_nI,_nJ] )
		Next

		SX1->( MsUnLock() )

	Next _nI

Return
