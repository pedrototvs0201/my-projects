#INCLUDE "RWMAKE.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"

#Define OldLace RGB(253,245,230)
#Define Cinza   RGB(220,220,220)

//********************
User Function AKAPED()
//********************

	Private cStartPath  :=   AllTrim(GetSrvProfString("StartPath","\"))
	Private	cImag001    :=	cStartPath//+"akafloor.jpg"
	//Private	cImag001	:=	"C:\Users\William\Desktop\akafloor.jpg"
	Private oCrNew20N   :=  TFont():New('Courier new',,20,,.T.,,,,,.F.,.F.)
	Private oCrNew11N   :=  TFont():New('Courier new',,11,,.T.,,,,,.F.,.F.)
	Private oCrNew11    :=  TFont():New('Courier new',,11,,.F.,,,,,.F.,.F.)

	Private nLin := 0
	Private nTamLin := 10
	Private nBorda := 2

	Private oBrush1 := TBrush():New( ,OldLace)
	Private oBrush2 := TBrush():New( ,Cinza)

	Private lAdjustToLegacy := .F.
	Private lDisableSetup  := .T.

	Private cTRBPed   := ""
	Private nTotItem  := 0
	Private nTotDesc  := 0
	Private nValFrete := 0
	Private cDescCP   := ""
	Private cCompCP   := ""
	Private cInfComp  := "O prazo de entrega passar� a ser contado apenas a partir do pagamento inicial do pedido."
	Private cVenNome  := ""
	Private cVenMail  := ""
	Private cVenDDD   := ""
	Private cVenTel   := ""
	Private cTpFrete  := ""

	Private _cFilial := ''
	Private _cNum    := ''
	Private nNumPag  := 0

	Pergunte("AKAPED",.T.)
	cArq := "Pedido_"+ Alltrim(MV_PAR02)+".rel"

	Do Case
	Case MV_PAR01 == "0103" ; cImag001 += "akaflex.jpg"
	OTHERWISE
		cImag001 += "akafloor.jpg"
	EndCase

    /*
    IF MV_PAR01 = '0101'
    cImag001 += "akafloor.jpg"
    ELSEIF MV_PAR01 = '0101'
    ENDIF
    */

	Private oPrinter := FWMSPrinter():New(cArq, IMP_PDF, lAdjustToLegacy, , lDisableSetup)// Ordem obrig�toria de configura��o do relat�rio
	oPrinter:SetResolution(72)
	oPrinter:SetPortrait()
	oPrinter:SetPaperSize(DMPAPER_A4)
	oPrinter:SetMargin(20,20,20,20) // nEsquerda, nSuperior, nDireita, nInferior
	oPrinter:cPathPDF := "c:\directory\" // Caso seja utilizada impress�o em IMP_PDF

	BuscDados()

	If (cTRBPed)->(Eof())
		MsgAlert("N�o a dados para ser exibidos")
		Return
	EndIf


	ImpLogo()   // 000 / 190 = 190
	Impboxemp() // 190 / 250 = 60
	ImpBoxCli() // 250 / 320 = 70
	ImpBoxObs() // 320 / 400 = 80
	ImpCabDet() // 400 / 432 = 32
	ImpItmDet() // 432 / 828 = 396 => 828 � a ultima linha da pagina
	ImpRodape1() // 335 / 593 = 258
	ImpRodape2()

	(cTRBPed)->(dbCloseArea())

	oPrinter:Preview()

Return

//*************************
Static Function BuscDados()
//*************************
	Local cQuery := ""

    /*
    cQuery += " SELECT C5_FILIAL,C5_NUM,A1_NOME,A1_CGC,A1_RG,A1_INSCR,A1_END,A1_BAIRRO,A1_MUN,A1_EST,A1_CONTATO,A1_TEL,C5_CONDPAG,"
    cQuery += " A1_EMAIL,A1_CEP,C5_MENNOTA,C6_QTDVEN,C6_UM,C6_DESCRI,C6_UNSVEN,C6_SEGUM,C6_PRCVEN,C6_VALOR,C5_FRETE,C5_EMISSAO,C6_DESCONT,C6_VALDESC,C5_VEND1"
    cQuery += " FROM "+RetSQLName("SC5")+" INNER JOIN "+RetSQLName("SC6")+" ON"
    cQuery += " C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM"
    cQuery += " 			INNER JOIN "+RetSQLName("SA1")+" ON"
    cQuery += " C5_CLIENTE = A1_COD AND C5_LOJACLI = A1_LOJA"
    cQuery += " WHERE "+RetSQLName("SC5")+".D_E_L_E_T_ = '' AND "+RetSQLName("SC6")+".D_E_L_E_T_ = '' AND C5_FILIAL = '"+MV_PAR01+"' AND  C5_NUM = '"+MV_PAR02+"'"
    */

	cQuery += " SELECT C5_FILIAL,C5_NUM,C5_XCONDPG,A1_NOME,A1_CGC,A1_RG,A1_INSCR,A1_END,A1_BAIRRO,A1_MUN,"
	cQuery += " A1_EST,A1_CONTATO,A1_TEL,C5_CONDPAG,A3_NOME,A3_DDDTEL,A3_TEL,A3_EMAIL,"
	cQuery += " A1_EMAIL,A1_CEP,C5_MENNOTA,C6_QTDVEN,C6_UM,C6_ITEM,C6_DESCRI,C6_UNSVEN,C6_SEGUM,C6_PRCVEN,"
	cQuery += " C6_VALOR,C5_TPFRETE,C5_FRETE,C5_EMISSAO,C6_DESCONT,C6_VALDESC,C6_XPRCVEN"
	cQuery += " FROM "+RetSQLName("SC5")+" INNER JOIN "+RetSQLName("SC6")+" ON"
	cQuery += " C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM"
	cQuery += " 			INNER JOIN "+RetSQLName("SA1")+" ON"
	cQuery += " C5_CLIENTE = A1_COD AND C5_LOJACLI = A1_LOJA"
	cQuery += " 			LEFT JOIN "+RetSQLName("SA3")+" ON"
	cQuery += " C5_VEND1 = A3_COD "
	cQuery += " WHERE "+RetSQLName("SC5")+".D_E_L_E_T_ = '' AND "+RetSQLName("SC6")+".D_E_L_E_T_ = '' AND C5_FILIAL = '"+MV_PAR01+"' AND  C5_NUM = '"+MV_PAR02+"'"

	dbUseArea( .T. , "TOPCONN" , TCGenQry(,,cQuery) , cTRBPed := GetNextAlias() , .F. , .T. )

Return

//***********************
Static Function ImpLogo()
//***********************

	oPrinter:StartPage()
	oPrinter:SayBitMap(0040,0010,cImag001,560,118)

	nLin := 160

	oPrinter:SayAlign(nLin,160,"PEDIDO DE VENDA N�:",oCrNew20N,190,10, CLR_BLACK,2,2)
	oPrinter:SayAlign(nLin,300,(cTRBPed)->C5_NUM,oCrNew20N,160,10, CLR_RED,2,2)

	nLin += nTamLin
	nLin += nTamLin
	nLin += nTamLin
	nNumPag++

Return

//*************************
Static Function Impboxemp()
//*************************
	//Adicionada a condi��o para a filial 0301 - Douglas Silva em 24/05/2022
	If MV_PAR01 = '0101'
		oPrinter:Box(nLin,10,nLin+50,570)
		oPrinter:SayAlign(nLin,20,"AKAFLOOR INDUSTRIAL LTDA",oCrNew11N,250,10, CLR_BLACK,0,2)
		oPrinter:SayAlign(nLin,420,"DATA: "+DTOC(stod((cTRBPed)->C5_EMISSAO)),oCrNew11N,250,10, CLR_BLACK,0,2)
		nLin += nTamLin
		oPrinter:SayAlign(nLin,20,"Rua Dr Kleber Vasques Filgueiras - 140 - Matozinhos",oCrNew11N,306,10, CLR_BLACK,0,2)
		nLin += nTamLin
		oPrinter:SayAlign(nLin,20,"Sao Joao del Rei - MG - CEP: 36305-030 - Tel: (32)3371-1000",oCrNew11N,348,10, CLR_BLACK,0,2)
		nLin += nTamLin
		oPrinter:SayAlign(nLin,20,"CNPJ:19.550.599-0001/65 IE: 625.229.818.00.59",oCrNew11N,270,10, CLR_BLACK,0,2)
    /* 
    Condi��o adicionada para Filial 0103 - Akafloor ES 
    Ronald Barbosa - 20/11/2023
    */
	ElseIf MV_PAR01 = '0103'
		oPrinter:Box(nLin,10,nLin+50,570)
		oPrinter:SayAlign(nLin,20,"AKAFLEX INDUSTRIAL LTDA",oCrNew11N,250,10, CLR_BLACK,0,2)
		oPrinter:SayAlign(nLin,420,"DATA: "+DTOC(stod((cTRBPed)->C5_EMISSAO)),oCrNew11N,250,10, CLR_BLACK,0,2)
		nLin += nTamLin
		oPrinter:SayAlign(nLin,20,"Rod. Governador Mario Covas - 10600 - Complemento: BOX 36 - Serra do Anil",oCrNew11N,306,10, CLR_BLACK,0,2)
		nLin += nTamLin
		oPrinter:SayAlign(nLin,20,"Cariacica - ES - CEP: 29147-030  - Tel: (32)3371-1000",oCrNew11N,348,10, CLR_BLACK,0,2)
		nLin += nTamLin
		oPrinter:SayAlign(nLin,20,"CNPJ: 19.550.599/0003-27 IE 084117214",oCrNew11N,270,10, CLR_BLACK,0,2)
		// Final dos ajustes - Ronald Barbosa - 20/11/2023 //

	ElseIf MV_PAR01 = '0201'
		oPrinter:Box(nLin,10,nLin+50,570)
		oPrinter:SayAlign(nLin,20,"RS COMERCIO DE PISOS",oCrNew11N,250,10, CLR_BLACK,0,2)
		oPrinter:SayAlign(nLin,420,"DATA: "+DTOC(stod((cTRBPed)->C5_EMISSAO)),oCrNew11N,250,10, CLR_BLACK,0,2)
		nLin += nTamLin
		oPrinter:SayAlign(nLin,20,"Rua Dr Kleber Vasques Filgueiras - 140 - Matozinhos",oCrNew11N,306,10, CLR_BLACK,0,2)
		nLin += nTamLin
		oPrinter:SayAlign(nLin,20,"Sao Joao del Rei - MG - CEP: 36305-030 - Tel: (32)3371-1000",oCrNew11N,348,10, CLR_BLACK,0,2)
		nLin += nTamLin
		oPrinter:SayAlign(nLin,20,"CNPJ: 26.870.574/0001-04 IE 003.537.870.00.51",oCrNew11N,270,10, CLR_BLACK,0,2)
	Else
		oPrinter:Box(nLin,10,nLin+50,570)
		oPrinter:SayAlign(nLin,20,"D&D PISOS DE MADEIRA LTDA",oCrNew11N,250,10, CLR_BLACK,0,2)
		oPrinter:SayAlign(nLin,420,"DATA: "+DTOC(stod((cTRBPed)->C5_EMISSAO)),oCrNew11N,250,10, CLR_BLACK,0,2)
		nLin += nTamLin
		oPrinter:SayAlign(nLin,20,"Rua Americo Deodoro Brighenti - S/N - Colonia do Marcal",oCrNew11N,306,10, CLR_BLACK,0,2)
		nLin += nTamLin
		oPrinter:SayAlign(nLin,20,"Sao Joao del Rei - MG - CEP: 36302-478 - Tel: (32)3371-1000",oCrNew11N,348,10, CLR_BLACK,0,2)
		nLin += nTamLin
		oPrinter:SayAlign(nLin,20,"CNPJ: 44.648.906/0001-92 IE 004.226.718.00.14",oCrNew11N,270,10, CLR_BLACK,0,2)
	EndIf

	nLin += nTamLin
	nLin += nTamLin
	nLin += nTamLin

Return

//*************************
Static Function ImpBoxCli()
//*************************

	oPrinter:Box(nLin,10,nLin+60,570)
	oPrinter:SayAlign(nLin,20,"CLIENTE:",oCrNew11N,54,10, CLR_BLACK,0,2)//oPrinter:Say(0898,20,"Cliente: ",oArial20,,0)
	oPrinter:SayAlign(nLin,70,(cTRBPed)->A1_NOME,oCrNew11N,270,10, CLR_BLACK,0,2)//oPrinter:Say(0898,0301,"MADEL COMERCIO DE MADEIRAS E FERRAGENS LTDA",oArial20,,0)

	oPrinter:SayAlign(nLin,390,"CONTATO:",oCrNew11N,54,10, CLR_BLACK,0,2)//oPrinter:Say(0898,20,"Cliente: ",oArial20,,0)
	oPrinter:SayAlign(nLin,440,(cTRBPed)->A1_CONTATO,oCrNew11N,270,10, CLR_BLACK,0,2)//oPrinter:Say(0898,0301,"MADEL COMERCIO DE MADEIRAS E FERRAGENS LTDA",oArial20,,0)

	nLin += nTamLin

	oPrinter:SayAlign(nLin,20,"CPF/CNPJ:",oCrNew11N,54,10, CLR_BLACK,0,2)//oPrinter:Say(0947,0116,"CPF/CNPJ:",oArial20,,0)

	If Len(AllTrim((cTRBPed)->A1_CGC)) == 11
		oPrinter:SayAlign(nLin,70,TRANSFORM((cTRBPed)->A1_CGC,"@R 999.999.999-99"),oCrNew11N,270,10, CLR_BLACK,0,2)
	Else
		oPrinter:SayAlign(nLin,70,TRANSFORM((cTRBPed)->A1_CGC,"@R 99.999.999.9999/99"),oCrNew11N,270,10, CLR_BLACK,0,2)
	EndIf

	oPrinter:SayAlign(nLin,390,"RG/IE:",oCrNew11N,54,10, CLR_BLACK,0,2)//oPrinter:Say(1000,0115,"RG/IE:",oArial20,,0)
	oPrinter:SayAlign(nLin,440,IIF(Empty((cTRBPed)->A1_INSCR),(cTRBPed)->A1_RG,(cTRBPed)->A1_INSCR),oCrNew11N,270,10, CLR_BLACK,0,2)//oPrinter:Say(1001,0303,"635.179.304.110",oArial20,,0)

	nLin += nTamLin

	oPrinter:SayAlign(nLin,20,"ENDERECO:",oCrNew11N,54,10, CLR_BLACK,0,2)//oPrinter:Say(1045,0112,"Endereco:",oArial20,,0)
	oPrinter:SayAlign(nLin,70,AllTrim((cTRBPed)->A1_END)+" - "+AllTrim((cTRBPed)->A1_BAIRRO),oCrNew11N,270,10, CLR_BLACK,0,2)//oPrinter:Say(1047,0298,"RUA JOAQUIM NABUCO, 359, CENTRO",oArial20,,0)

	oPrinter:SayAlign(nLin,390,"CEP:",oCrNew11N,54,10, CLR_BLACK,0,2)//oPrinter:Say(1045,0112,"Endereco:",oArial20,,0)
	oPrinter:SayAlign(nLin,440,AllTrim((cTRBPed)->A1_CEP),oCrNew11N,270,10, CLR_BLACK,0,2)//oPrinter:Say(1047,0298,"RUA JOAQUIM NABUCO, 359, CENTRO",oArial20,,0)

	nLin += nTamLin

	oPrinter:SayAlign(nLin,20,"CIDADE:",oCrNew11N,54,10, CLR_BLACK,0,2)//oPrinter:Say(1101,0115,"Cidade:",oArial20,,0)
	oPrinter:SayAlign(nLin,70,AllTrim((cTRBPed)->A1_MUN)+" - "+AllTrim((cTRBPed)->A1_EST),oCrNew11N,270,10, CLR_BLACK,0,2)//oPrinter:Say(1104,0301,"SAO BERNARDO DO CAMPO - SP",oArial20,,0)

	nLin += nTamLin

	oPrinter:SayAlign(nLin,20,"EMAIL:",oCrNew11N,54,10, CLR_BLACK,0,2)//oPrinter:Say(1000,0115,"RG/IE:",oArial20,,0)
	oPrinter:SayAlign(nLin,70,(cTRBPed)->A1_EMAIL,oCrNew11N,270,10, CLR_BLACK,0,2)//oPrinter:Say(1001,0303,"635.179.304.110",oArial20,,0)

	oPrinter:SayAlign(nLin,390,"TELEFONE:",oCrNew11N,54,10, CLR_BLACK,0,2)//oPrinter:Say(0947,0116,"CPF/CNPJ:",oArial20,,0)
	oPrinter:SayAlign(nLin,440,(cTRBPed)->A1_TEL,oCrNew11N,270,10, CLR_BLACK,0,2)//oPrinter:Say(0947,0303,"573.142.880.0001/96",oArial20,,0)

	nLin += nTamLin
	nLin += nTamLin
	nLin += nTamLin

Return

//*************************
Static Function ImpBoxObs()
//*************************

	Local nQtdLin := 0
	Local i       := 0

	oPrinter:SayAlign(nLin,20,"OBSERVA��ES",oCrNew20N,190,10, CLR_BLACK,0,2)
	nLin += nTamLin
	nLin += nTamLin
	nLin += nTamLin

	oPrinter:Box(nLin,10,nLin+40,570)

	nQtdLin := mlcount(AllTrim((cTRBPed)->C5_MENNOTA),103)

	For i := 1 to nQtdLin
		oPrinter:SayAlign(nLin,20,memoline(AllTrim((cTRBPed)->C5_MENNOTA),103,i),oCrNew11,6000,10, CLR_BLACK,0,2)
		nLin += nTamLin
	Next


	//oPrinter:SayAlign(nLin,20,AllTrim((cTRBPed)->C5_MENNOTA),oCrNew11N,600,10, CLR_BLACK,0,2)//oPrinter:Say(0898,20,"Cliente: ",oArial20,,0)
	nLin += nTamLin
	nLin += nTamLin
	nLin += nTamLin
	nLin += nTamLin
Return

	//*************************
Static Function Impcabdet()
	//*************************

	nLin += nTamLin
	oPrinter:Fillrect( {nLin, 10, nLin+20, 80 }, oBrush1, "-2")
	oPrinter:SayAlign(nLin,35,"QNT",oCrNew11N,18,10, CLR_BLACK,0,2)//oPrinter:Say(1101,0115,"Cidade:",oArial20,,0)

	oPrinter:Fillrect( {nLin, 81, nLin+20, 140 }, oBrush1, "-2")
	oPrinter:SayAlign(nLin,100,"UNID",oCrNew11N,24,10, CLR_BLACK,0,2)//oPrinter:Say(1101,0115,"Cidade:",oArial20,,0)

	oPrinter:Fillrect( {nLin, 141, nLin+20, 400 }, oBrush1, "-2")
	oPrinter:SayAlign(nLin,241,"DESCRI��O",oCrNew11N,54,10, CLR_BLACK,0,2)//oPrinter:Say(1101,0115,"Cidade:",oArial20,,0)

	oPrinter:Fillrect( {nLin, 401, nLin+20, 480 }, oBrush1, "-2")
	oPrinter:SayAlign(nLin,412,"PRECO UNIT",oCrNew11N,60,10, CLR_BLACK,0,2)//oPrinter:Say(1101,0115,"Cidade:",oArial20,,0)

	oPrinter:Fillrect( {nLin, 481, nLin+20, 570 }, oBrush1, "-2")
	oPrinter:SayAlign(nLin,511,"VALOR",oCrNew11N,30,10, CLR_BLACK,0,2)//oPrinter:Say(1101,0115,"Cidade:",oArial20,,0)

	nLin+= nTamLin
	nLin+= nTamLin
	nLin+= nBorda

return

//*************************
Static Function ImpItmDet()
//*************************

	Local cDescri := ""
	Local i       := 0
	Local nQtdLin := 0

	IF alltrim((cTRBPed)->C5_TPFRETE) == "C"
		cTpFrete := "CIF"
	ELSE
		cTpFrete := "FOB"
	ENDIF

	nValFrete := (cTRBPed)->C5_FRETE
	cDescCP   := POSICIONE("SE4",1,xFilial("SE4")+ALLTRIM((cTRBPed)->C5_CONDPAG),"E4_DESCRI")

	IF !EMPTY(ALLTRIM((cTRBPed)->C5_XCONDPG))
		cDescCP   += " - " + ALLTRIM((cTRBPed)->C5_XCONDPG)
	ENDIF

	cVenNome  := AllTrim((cTRBPed)->A3_NOME)
	cVenMail  := Lower(AllTrim((cTRBPed)->A3_EMAIL))
	cVenDDD   := Transform(Alltrim((cTRBPed)->A3_DDDTEL),"@R (99)")
	cVenTel   := Transform(AllTrim((cTRBPed)->A3_TEL),"@R 99999-9999")

	nTotItem := 0
	nTotDesc := 0

	While (cTRBPed)->(!Eof())

		//Verifica quebra de p�gina
		If (nLin/800) >= 1
			ImpLogo()
			ImpCabDet()
		Endif
        /*
        If nLin > 808
            ImpLogo() // 828 / 190
            ImpCabDet() // 190 / 222
        Endif
        */
		If (cTRBPed)->C6_UNSVEN > 0
			cDescri := AllTrim((cTRBPed)->C6_DESCRI)+" - "+AllTrim(STR((cTRBPed)->C6_UNSVEN))+" "+AllTrim((cTRBPed)->C6_SEGUM)
		Else
			cDescri := AllTrim((cTRBPed)->C6_DESCRI)
		EndIf

		nQtdLin := mlcount(cDescri,43)

		oPrinter:Fillrect( {nLin, 10, nLin+nTamLin+(nQtdLin*nTamLin), 80 }, oBrush2, "-2")
		oPrinter:Fillrect( {nLin, 81, nLin+nTamLin+(nQtdLin*nTamLin), 140 }, oBrush2, "-2")
		oPrinter:Fillrect( {nLin, 141, nLin+nTamLin+(nQtdLin*nTamLin), 400 }, oBrush2, "-2")
		oPrinter:Fillrect( {nLin, 401, nLin+nTamLin+(nQtdLin*nTamLin), 480 }, oBrush2, "-2")
		oPrinter:Fillrect( {nLin, 481, nLin+nTamLin+(nQtdLin*nTamLin), 570 }, oBrush2, "-2")

		oPrinter:SayAlign(nLin,-010,Transform((cTRBPed)->C6_QTDVEN,'@E 999,999.9999'),oCrNew11,80,nQtdLin*nTamLin*2,CLR_BLACK,1,0)
		oPrinter:SayAlign(nLin,105,(cTRBPed)->C6_UM                                 ,oCrNew11,12,nQtdLin*nTamLin*2,CLR_BLACK,2,0)


		nPrcBruto := (cTRBPed)->(C6_XPRCVEN) //Alterado dia 02-06-2025, com foco em ajustar o Relatorio do Pedido de Venda. - Otavio Belchior
		nVrBruto  := ROUND((cTRBPed)->C6_QTDVEN*nPrcBruto,2)

		oPrinter:SayAlign(nLin,391,Transform(nPrcBruto           ,'@E 99,999,999.99'),oCrNew11,80,nQtdLin*nTamLin*2,CLR_BLACK,1,0)
		oPrinter:SayAlign(nLin,481,Transform(nVrBruto            ,'@E 99,999,999.99'),oCrNew11,80,nQtdLin*nTamLin*2,CLR_BLACK,1,0)

		For i := 1 to nQtdLin
			oPrinter:SayAlign(nLin,90,memoline(cDescri,43,i),oCrNew11,360,10, CLR_BLACK,2,0)
			nLin += nTamLin
		Next

		//nTotItem += (cTRBPed)->C6_VALOR
		nTotItem += nVrBruto
		nTotDesc += (cTRBPed)->C6_VALDESC

		nLin += nTamLin
		nLin += 1

		(cTRBPed)->(dbSkip())

	EndDo

	(cTRBPed)->(DbGoTop())

	nLin += nTamLin
	nLin += nTamLin

Return


//*************************
Static Function ImpRodape1()
//*************************
	//Verifica quebra de p�gina
	If nLin > 550
		ImpLogo() // 828 / 190
		ImpCabDet() // 190 / 222
	EndIf
	oPrinter:SayAlign(nLin,20,"RESPONS�VEL COMERCIAL: "+cVenNome,oCrNew11N,300,10, CLR_BLACK,0,2)

	oPrinter:Fillrect( {nLin, 401, nLin+20, 480 }, oBrush1, "-2")
	oPrinter:SayAlign(nLin,412,"SUBTOTAL",oCrNew11N,60,10, CLR_BLACK,0,2)

	oPrinter:Fillrect( {nLin, 481, nLin+20, 570 }, oBrush2, "-2")
	oPrinter:SayAlign(nLin,481,Transform(nTotItem,'@E 99,999,999.99'),oCrNew11,80,nLin+20,CLR_BLACK,1,0)

	nLin += nTamLin
	nLin += nTamLin

	nLin += 1

	oPrinter:SayAlign(nLin,20,"TELEFONE: "+cVenDDD+" "+cVenTel,oCrNew11N,300,10, CLR_BLACK,0,2)

	oPrinter:Fillrect( {nLin, 401, nLin+20, 480 }, oBrush1, "-2")
	oPrinter:SayAlign(nLin,412,"DESCONTO",oCrNew11N,60,10, CLR_BLACK,0,2)

	oPrinter:Fillrect( {nLin, 481, nLin+20, 570 }, oBrush2, "-2")
	oPrinter:SayAlign(nLin,481,Transform( nTotDesc ,'@E 99,999,999.99'),oCrNew11,80,nLin+20,CLR_BLACK,1,0)

	nLin += nTamLin
	nLin += nTamLin

	nLin += 1

	oPrinter:SayAlign(nLin,20,"EMAIL: "+cVenMail,oCrNew11N,300,10, CLR_BLACK,0,2)

	//-- Inclus�o de Campo Tipo de Frete - CIF / FOB --//

	oPrinter:Fillrect( {nLin, 401, nLin+20, 480 }, oBrush1, "-2")
	oPrinter:SayAlign(nLin,412,"TP DE FRETE",oCrNew11N,100,10, CLR_BLACK,0,2)

	oPrinter:Fillrect( {nLin, 481, nLin+20, 570 }, oBrush2, "-2")
	oPrinter:SayAlign(nLin,481,cTpFrete,oCrNew11,80,nLin+20,CLR_BLACK,1,0)

	nLin += nTamLin
	nLin += nTamLin

	nLin += 1

	//--------------------------------------------------//

	oPrinter:Fillrect( {nLin, 401, nLin+20, 480 }, oBrush1, "-2")
	oPrinter:SayAlign(nLin,412,"FRETE",oCrNew11N,60,10, CLR_BLACK,0,2)

	oPrinter:Fillrect( {nLin, 481, nLin+20, 570 }, oBrush2, "-2")
	oPrinter:SayAlign(nLin,481,Transform(nValFrete ,'@E 99,999,999.99'),oCrNew11,80,nLin+20,CLR_BLACK,1,0)

	nLin += nTamLin
	nLin += nTamLin

	nLin += 1

	oPrinter:Fillrect( {nLin, 401, nLin+20, 480 }, oBrush1, "-2")
	oPrinter:SayAlign(nLin,412,"TOTAL",oCrNew11N,60,10, CLR_BLACK,0,2)

	oPrinter:Fillrect( {nLin, 481, nLin+20, 570 }, oBrush2, "-2")
	oPrinter:SayAlign(nLin,481,Transform(nTotItem+nValFrete-nTotDesc,'@E 99,999,999.99'),oCrNew11,80,nLin+20,CLR_BLACK,1,0)

	nLin += nTamLin
	nLin += nTamLin
	nLin += nTamLin

	// Condi��o de pagamento
	oPrinter:SayAlign(nLin,20,"CONDICAO DE PAGAMENTO",oCrNew20N,300,10, CLR_BLACK,0,2)
	nLin += nTamLin
	nLin += nTamLin
	nLin += nTamLin

	oPrinter:Box(nLin,10,nLin+30,570)

	oPrinter:SayAlign(nLin,20,AllTrim(cDescCP),oCrNew11N,600,10, CLR_BLACK,0,2)//oPrinter:Say(0898,20,"Cliente: ",oArial20,,0)

	// Dados bancarios
	nLin += 35
	oPrinter:SayAlign(nLin,20,"DADOS BANC�RIOS",oCrNew20N,300,10, CLR_BLACK,0,2)
	nLin += nTamLin
	nLin += nTamLin
	nLin += nTamLin

	oPrinter:Box(nLin,10,nLin+30,570)
	cDadosBco := PADR("BANCO:",20)
	cDadosBco += PADR("AG�NCIA:",10)
	cDadosBco += PADR("CONTA:",10)
	cDadosBco += PADR("CNPJ:",20)
	cDadosBco += PADR("CHAVE PIX:",20)

	oPrinter:SayAlign(nLin,20,AllTrim(cDadosBco),oCrNew11N,600,10, CLR_BLACK,0,2)//oPrinter:Say(0898,20,"Cliente: ",oArial20,,0)
	nLin += nTamLin+5
	//Adicionada a condi��o para a filial 0301 - Douglas Silva em 24/05/2022
	If MV_PAR01 == "0101"
		cDadosBco := PADR("BANCO BRADESCO",20)
		cDadosBco += PADR("1471-0",10)
		cDadosBco += PADR("63668-1",10)
		cDadosBco += PADR("19.550.599/0001-65",20)
		cDadosBco += PADR("(32) 99823-1020",20)
	ElseIf MV_PAR01 == "0201"
		cDadosBco := PADR("BANCO BRADESCO",20)
		cDadosBco += PADR("1471-0",10)
		cDadosBco += PADR("66327-1",10)
		cDadosBco += PADR("26.870.574/0001-04",20)
		cDadosBco += PADR("26.870.574/0001-04",20)
	ElseIf MV_PAR01 == "0103"
		cDadosBco := PADR("BANCO ITA�",20)
		cDadosBco += PADR("3163-0",10)
		cDadosBco += PADR("99369-8",10)
		cDadosBco += PADR("19.550.599/0003-27",20)
		cDadosBco += PADR("contasareceber@akafloor.com.br",30)
	Else
		cDadosBco := PADR("BANCO BRADESCO",20)
		cDadosBco += PADR("1471-0",10)
		cDadosBco += PADR("69020-1",10)
		cDadosBco += PADR("44.648.906/0001-92",20)
		cDadosBco += PADR("44.648.906/0001-92",20)
	EndIf
	oPrinter:SayAlign(nLin,20,AllTrim(cDadosBco),oCrNew11,600,10, CLR_BLACK,0,2)//oPrinter:Say(0898,20,"Cliente: ",oArial20,,0)


	// Informa��es complementares
    /*
    IF MV_PAR01 <> "0101"
    cInfComp  += CHR(13)+CHR(10)
    cInfComp  += "Suspens�o do recolhimento do diferencial de al�quota a empresa do SN por for�a de"
    cInfComp  += CHR(13)+CHR(10)
    cInfComp  += "decis�o do Supremo Tribunal Federal, concedida em sede liminar na A��o Direta de"
    cInfComp  += CHR(13)+CHR(10)
    cInfComp  += "Inconstitucionalidade (ADIN) n� 5.464, at� o julgamento final da a��o."
    ENDIF
    */

	nLin += 25
	oPrinter:SayAlign(nLin,20,"INFORMA��ES COMPLEMENTARES",oCrNew20N,300,10, CLR_BLACK,0,2)
	nLin += nTamLin
	nLin += nTamLin
	nLin += nTamLin

	oPrinter:Box(nLin,10,nLin+45,570)

	//oPrinter:SayAlign(nLin,20,AllTrim(cInfComp),oCrNew11N,600,10, CLR_BLACK,0,2)

	IF MV_PAR01 != "0101"

		oPrinter:SayAlign(nLin,20,AllTrim(cInfComp),oCrNew11N,600,10, CLR_BLACK,3,2)

		nLin += nTamLin
		cInfComp  := "Suspens�o do recolhimento do diferencial de al�quota a empresa do SN por for�a de"
		oPrinter:SayAlign(nLin,20,AllTrim(cInfComp),oCrNew11N,600,10, CLR_BLACK,3,2)

		nLin += nTamLin
		cInfComp  := "decis�o do Supremo Tribunal Federal, concedida em sede liminar na A��o Direta de"
		oPrinter:SayAlign(nLin,20,AllTrim(cInfComp),oCrNew11N,600,10, CLR_BLACK,3,2)

		nLin += nTamLin
		cInfComp  := "Inconstitucionalidade (ADIN) n� 5.464, at� o julgamento final da a��o."
		oPrinter:SayAlign(nLin,20,AllTrim(cInfComp),oCrNew11N,600,10, CLR_BLACK,3,2)

	ELSE

		oPrinter:SayAlign(nLin,20,AllTrim(cInfComp),oCrNew11N,600,10, CLR_BLACK,3,2)

	ENDIF

	//nLin += nTamLin
	//nLin += nTamLin

	oPrinter:EndPage()
Return


Static Function ImpRodape2()
	oPrinter:StartPage()
	// Verifica se nLin est� pr�ximo do limite para for�ar uma nova p�gina
	//If nLin > 550
	//ImpLogo() // Se necess�rio, imprime o logo na nova p�gina
	//EndIf

	oPrinter:SayBitMap(0040,0010,cImag001,560,118)

	nLin := 180
	oPrinter:SayAlign(nLin, 20, "TERMO DE CI�NCIA AKAFLEX", oCrNew20N, 300, 10, CLR_BLACK, 0, 2)
	nLin += nTamLin * 3

	oPrinter:Box(nLin,10, nLin + 450,570)

	//Cabe�alho
	nLin += 8
	oPrinter:SayAlign(nLin, 20, "Importante: para acionar a garantia, � imprescind�vel a apresenta��o da nota fiscal de venda do produto,", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "bem como dos complementos e da instala��o.", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin * 2

	//Sobre o Akaflex
	oPrinter:SayAlign(nLin, 40, "O AKAFLEX � fabricado com mat�rias-primas de alta qualidade e passa por um rigoroso controle em todas", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "as etapas do processo.Por isso, garantimos o AKAFLEX contra defeitos de fabrica��o por 5 anos a partir", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "da data de aquisi��o do produto.", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "Esta garantia � v�lida apenas se o produto for instalado e conservado conforme as normas da empresa.", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin * 2

	//Garantia
	oPrinter:SayAlign(nLin, 40, "A durabilidade do seu piso vin�lico AKAFLEX come�a com uma instala��o adequada. No entanto,  se um", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "defeito de fabrica��o for identificado nas condi��es abaixo:", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin

	oPrinter:SayAlign(nLin, 20, "1. At� 1 ano - Garantia Fabricante: Se o defeito coberto por esta garantia for comunicado � AKAFLEX", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "por escrito at� 1 ano da data de compra, substituiremos, sem custos adicionais, o produto defeituoso", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "por um novo AKAFLEX do mesmo padr�o ou similar e pagaremos os custos  de instala��o � empresa", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "credenciada de sua escolha.", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin


	oPrinter:SayAlign(nLin, 20, "2. At� 5 anos: Se o defeito coberto por esta garantia for comunicado � AKAFLEX por escrito at� 5 anos da", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "data de compra, substituiremos, sem custos adicionais, o produto defeituoso por um novo AKAFLEX", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "do mesmo padr�o, mas n�o cobriremos as despesas de instala��o.", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin * 2


	//defeitos
	oPrinter:SayAlign(nLin, 40, "Para defeitos visuais que poderiam ser identificados antes da instala��o, substituiremos o AKAFLEX,", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "mas n�o nos responsabilizaremos pelos custos com m�o de obra de instala��o.", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "A inspe��o do defeito de fabrica��o existente sempre ser� realizada por um representante autorizado", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "pela AKAFLEX.", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "Durante a obra, � essencial proteger o piso j� instalado com lona pl�stica ou papel�o para evitar danos", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "causados por cimento, tinta, gesso, etc.", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin * 2


	//garantia exclui
	oPrinter:SayAlign(nLin, 40, "Esta garantia exclui:", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "1. Perda de brilho devido ao uso normal;", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "2. Diferen�a de tonalidade entre amostras ou ilustra��es impressas e o produto adquirido;", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "3. Diferen�a de nuances entre as r�guas;", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "4. Danos causados por sujeira ou irregularidades no contrapiso;", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "5. Descolora��o devido � exposi��o direta e cont�nua � luz solar;", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "6. Danos causados por cuidados inadequados, como queima, arranh�es de m�veis ou objetos abrasivos,", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 40, "marcas de salto alto ou falta de protetores de piso em m�veis;", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "7. Danos causados por manuten��o inadequada, arranh�es de sapatos e manchas causadas por", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 40, "excrementos de animais (fezes e urina);", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "8. Instala��o incorreta ou n�o conforme a norma ABNT NBR 14917 de Revestimentos de Pisos Vin�licos,", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 40, "sendo a responsabilidade exclusiva do instalador e revendedor", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 40, "sempre contrate m�o de obra especializada);", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "9. Insufici�ncia ou falhas do contrapiso;", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "10. Utiliza��o n�o conforme as orienta��es descritas na embalagem.", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin * 2

	oPrinter:SayAlign(nLin, 40, "A AKAFLEX n�o garante a disponibilidade da tonalidade/cor adquirida anteriormente.", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin

/*
	oPrinter:SayAlign(nLin, 20, "TERMO DE CI�NCIA E ACEITE AKAFLOOR", oCrNew20N, 300, 10, CLR_BLACK, 0, 2)
	nLin += nTamLin * 3

	oPrinter:Box(nLin,10, nLin + 450,570)

	nLin += 8
	oPrinter:SayAlign(nLin, 20, "A madeira � um material extremamente seguro e dur�vel. Por�m, esta durabilidade depende de uma correta", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "instala��o e manuten��o.", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin * 2

	oPrinter:SayAlign(nLin, 20, "O equil�brio da umidade da madeira em 12% � de extrema import�ncia para a performance do produto.", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin * 2

	oPrinter:SayAlign(nLin, 40, "O receptor deste termo reconhece e concorda com as seguintes condi��es:", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin

	oPrinter:SayAlign(nLin, 20, "1- O comprimento das r�guas varia de 30 cm a 2,20 m, seguindo a propor��o: 30% r�guas curtas,", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "(30 cm a 90 cm), 40% de r�guas m�dias (95 cm a 1,50 m) e 30% de r�guas longas (1,55 m a 2,20 m).", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin

	oPrinter:SayAlign(nLin, 20, "Frisamos que: Os pisos naturais ou tradicionais s�o nomeados de acordo com a madeira original e", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin

	oPrinter:SayAlign(nLin, 20, "possuem acabamento liso e unidade de brilho de 40%. Os pisos Mate apresentam acabamento liso com unidade", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin

	oPrinter:SayAlign(nLin, 20, "de brilho de 7%. J� os pisos Naturale t�m ranhuras e tamb�m possuem unidade de brilho de 7%.", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin

	oPrinter:SayAlign(nLin, 20, "2- A instala��o do piso de madeira somente ocorrer� ap�s a conclus�o de todos os outros servi�os", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "relacionados � constru��o, reforma ou renova��o da propriedade, garantindo que o local esteja", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "completamente seco e protegido contra a entrada de umidade durante o processo. Destaca-se que o", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "contrapiso deve estar seco por um per�odo superior a 30 dias.", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "O contrapiso precisa apresentar boaresist�ncia, possuindo no m�nimo 3 cm de espessura. O contrapiso � de", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "inteira responsabilidade do cliente.", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin

	oPrinter:SayAlign(nLin, 20, "3- A Akafloor n�o se responsabiliza pela instala��o realizada por terceiros, mesmo que esses tenham", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "sido indicados pela empresa.", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin

	oPrinter:SayAlign(nLin, 20, "4- No momento da expedi��o, a responsabilidade pelo transporte e pela mercadoria", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "� atribu�da � transportadora contratada, frete FOB. O cliente � respons�vel pelo custo do frete,", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "sujeito a poss�veis reajustes no momento da expedi��o, salvo negocia��es espec�ficas", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "nesses casos o frete ser� sinalizado como CIF, no pedido de venda.", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin

	oPrinter:SayAlign(nLin, 20, "5- O piso de madeira n�o deve ser coberto por papel�es, salva-pisos ou outros tipos de cobertura", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "por mais de 7 dias. A cobertura prolongada pode afetar negativamente o piso.", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "Recomenda-se o uso de papel�o ondulado por no m�ximo 7 dias consecutivos.", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin

	oPrinter:SayAlign(nLin, 20, "6- Cancelamentos realizados ap�s sete dias do pagamento estar�o sujeitos a uma penalidade de 20%", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "sobre o valor total do produto. A troca ser� aceita apenas se a produ��o n�o tiver sido iniciada,", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "caso iniciada incidir� multa de 20%.", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin

	oPrinter:SayAlign(nLin, 20, "7- Os revestimentos especiais da nossa linha, incluindo forro, deck e ripado, n�o s�o fornecidos com", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "acabamento envernizado de f�brica. O processo de envernizamento � opcional e pode ser realizado", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "conforme a necessidade espec�fica do cliente.", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin * 2

	oPrinter:SayAlign(nLin, 40, "Itens n�o inclusos na garantia Akafloor:", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "1. Caso a madeira apresente teor de umidade superior a 12%, o cliente perder� os benef�cios da garantia;", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "2. Danos causados por trabalhadores da obra;", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "3. Problemas de m� utiliza��o ou m� conserva��o do revestimento;", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "4. Danos por movimenta��o ou queda de m�veis e/ou objetos;", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "5. Qualquer dano ou sujeira causada pela m� utiliza��o do piso.", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin * 2

	oPrinter:SayAlign(nLin, 20, "Para decks, � fundamental que a madeira passe pelo tratamento apropriado, assegurando resist�ncia", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
	oPrinter:SayAlign(nLin, 20, "� exposi��o em �reas externas. Nenhum outro produto Akafloor � recomendado para uso em �reas molhadas.", oCrNew11N, 550, 10, CLR_BLACK, 3, 2)
	nLin += nTamLin
*/
Return
