#INCLUDE "RWMAKE.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"     
#INCLUDE 'TOTVS.CH'    
#INCLUDE "SHELL.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWPrintSetup.ch"  
#INCLUDE "FileIO.CH" 


#DEFINE IMP_SPOOL 2   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma: TCOM094    ºAutor: Givanildo Rezende   º Data ³  20/10/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Orcamento de venda - pedido simples                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Ceramica Ramos                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MA410MNU
    AADD(aRotina, {"@Alterar e Manter Liberacao", "U_ExemploM3()", 0, 4})
Return


User function MT410INC()
	 local aArea     := GetArea()

	 If MsgYesNo("Deseja imprimir o pedido de venda?")	 
		 U_TCOM094()
	 EndIf 
	 RestArea(aArea)
return NIL

User function MT410ALT()
	// local aArea     := GetArea()
	

	Local cNumPed := SC5->C5_NUM
    Local oJson, cPayload, oHTTP
    FWLogMsg(">>> M410GRV executado - Pedido: " + cNumPed)
    oJson := JsonObject():New()
    oJson:Set("numero_pedido", cNumPed)
    cPayload := oJson:ToJson()
    oHTTP := HttpPost("https://bb54-2804-1b1-b8c0-4817-d5ac-2c12-11b8-abdd.ngrok-free.app/webhook/protheus", cPayload, "application/json")

    If oHTTP:StatusCode == 200
        FWLogMsg("Webhook enviado com sucesso - Pedido: " + cNumPed)
    Else
        FWLogMsg("Erro ao enviar webhook - Pedido: " + cNumPed + " | Status: " + AllTrim(Str(oHTTP:StatusCode)))
    EndIf


	 if MsgYesNo("Deseja imprimir o pedido de venda?")	 
		 U_TCOM094()
	 EndIf 
//	 RestArea(aArea)
	

return NIL
//-------------------------------------------------(quebra)---------------------------------------------------// 
User Function TCOM094 
	Local cQuery			:= ""
	//Local cPergs    		:= "TCOM094" //Utilizada na geração de boletos modelo 2.
	//Local aPergs    		:= {} 
	Local nY  

	// Variaveis Private
	Private oPrinter      
	Private cLocArq := "C:\TEMP\"
	Private cNomArq := "TCOM094"
	Private nLinPag := 9
	Private nLinImp := 0
	Private lCriar  := .F. 
	Private nValorTot := 0
	Private nQtdItem := 9 
	Private	aVencto  := {}

	    
	Private nPag 	:= 0
	Private nVia 	:= 1
	Private nQtdPg  := 0
	Private lPreview:= .t.
	Private nRowRod := 0
	Private nRowDet := 0
	Private nRowCab := 0
	Private nColRod := 0
	Private nColDet := 0
	Private nColCab := 0
	Private cQuebra := ""	
	Private nColImpr := 0

	
	Private oF09  := TFont():New( "Arial", , -09, .T.,.F.)
	Private oF10  := TFont():New( "Arial", , -10, .T.,.F.)
	Private oF10N := TFont():New( "Arial", , -10, .T.,.T.)
	Private oF12  := TFont():New( "Courier New", , -12, .T.,.F.)
	Private oF12N := TFont():New( "Courier New", , -12, .T.,.T.)	
	Private oF14  := TFont():New( "Arial"      , , -14, .T.,.F.)	
	Private oF14N := TFont():New( "Arial"      , , -14, .T.,.T.)	
	Private oF16  := TFont():New( "Arial"      , , -16, .T.,.F.)
	Private oF16N := TFont():New( "Arial"      , , -16, .T.,.T.)
	Private oF18  := TFont():New( "Arial"      , , -18, .T.,.F.)
	Private oF18N := TFont():New( "Arial"      , , -18, .T.,.T.)

	// Consulta SQL para retornar os dados do cabecalho do Romaneio
	cQuery := "SELECT C5_FILIAL, C5_NUM, C5_EMISSAO, C5_CLIENTE, C5_LOJACLI, A1_NOME"
	cQuery += " ,A1_END, A1_BAIRRO, A1_MUN, A1_EST, A1_CEP, A1_DDD, A1_TEL, A1_TELEX, A1_CGC, A1_INSCR"
	cQuery += " , C5_MENNOTA, C5_CONDPAG, E4_DESCRI, C5_FECENT, C5_FRETE"
	cQuery += " FROM "+ RetSqlName("SC5")+ " SC5"                          
	cQuery += " INNER JOIN "+ RetSqlName("SA1")+ " SA1"
	cQuery += " ON A1_FILIAL ='"+ XFILIAL("SA1")+"' AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI" 

	cQuery += " INNER JOIN "+ RetSqlName("SE4")+ " SE4"
	cQuery += " ON E4_FILIAL ='"+ XFILIAL("SE4")+"' AND C5_CONDPAG = E4_CODIGO" 

	cQuery += " WHERE SC5.D_E_L_E_T_ <> '*' AND SA1.D_E_L_E_T_ <> '*' AND SE4.D_E_L_E_T_ <>'*'"
	cQuery += " AND C5_FILIAL = '"+ XFILIAL("SC5") +"'"
	cQuery += " AND C5_NUM ='"+ SC5->C5_NUM +"' "
	
	If select("QRSC5") <> 0
		QRSC5->(DbCloseArea())
	endif
	
	TcQuery cQuery New Alias 'QRSC5'
		
	dbSelectArea("QRSC5")
	If QRSC5->(!EOF()) .and. QRSC5->(!BOF())
		// Criar a consulta dos itens
		cQuery := "SELECT  	C6_ITEM, C6_PRODUTO, C6_DESCRI, C6_UM, C6_QTDVEN
		cQuery += " , C6_PRUNIT,C6_VALDESC, C6_PRCVEN, C6_VALOR, C6_XOBS"
		cQuery += " FROM "+ RetSqlName("SC6")+ " SC6"                          
		cQuery += " WHERE SC6.D_E_L_E_T_ <> '*' "
		cQuery += " AND C6_FILIAL = '"+ XFILIAL("SC6") +"'"
		cQuery += " AND C6_NUM ='"+ SC5->C5_NUM +"' "  
		cQuery += " ORDER BY C6_PRODUTO "
		
		If select("QRSC6") <> 0
			QRSC6->(DbCloseArea())
		endif
		
		TcQuery cQuery New Alias 'QRSC6'

	    nCount := CntRec("QRSC6")
		nQtdPg := CntPag(nCount, nLinPag) 
        
		If nCount == 0
	    	Alert("Não foi encontrado informações para gerar o relatório"+chr(13)+;
	    	      "Verifique os parâmetros informados!") 
	    	Return.f.
		EndIf
		// Calcular o total do pedido
		dbSelectArea("QRSC6")
		dbGoTop()
		While QRSC6->(!Eof())
			nValorTot+= QRSC6->C6_VALOR
			QRSC6->(dbSkip())
		EndDo
		nValorTot+= QRSC5->C5_FRETE
		// Calcular Condicoes de pagamento
		aVencto  := Condicao(nValorTot,QRSC5->C5_CONDPAG,0,STOD(QRSC5->C5_EMISSAO),0)

		// Criar o arquivo
       	lCriar := .t.
       	CriaArq()
       	// Imprimir o cabecalho
       	//ImpCab()
    Else
    	Alert("Não foi encontrado informações para gerar o relatório"+chr(13)+;
    	      "Verifique os parâmetros informados!") 
    	//GravaLog(cQuery)
    	Return.f.
	EndIf
    
	ProcRegua(nCount) // Régua            

	For nY:= 1 to 2
		nVia := nY
       	// Imprimir o cabecalho
       	ImpCab()

		nLinImp := 0    
		QRSC6->(DBGOTOP()) 
		While QRSC6->(!EOF()) 
		    IncProc("Processando relatório...")
		    //If nLinImp > nLinPag+4
		    If nLinImp > (nLinPag + iif(nPag < nQtdPg,4,0))
		    	// Imprimir o cabecalho caso o numero de linhas seja > 35 ou > 31(ultima)
		       	ImpCab()
			EndIf    	
			// Imprimir detalhes                        
			ImpDet()
	
	        If nLinImp == (nLinPag + iif(nPag < nQtdPg,4,0))
	        	// Imprimir o rodape
	        	ImpRod(.F.)
	        EndIf
			QRSC6->(DBSKIP()) 
			If QRSC6->(EOF()) 
				If nLinImp < nLinPag
		       		// Imprimir o rodape
		       		ImpRod(.T.)
		  		Else
			       	ImpCab()
		       		ImpRod(.T.)
				EndIf	  		
			EndIf
		Enddo
	Next
	
	If lCriar
        FecharArq() 
    EndIf 
    //
Return
//----------------------------------------------- quebra da rotina ------------------------------------------------------//
Static Function CriaArq 
		
	If oPrinter == Nil
	     lPreview := .T.
	     oPrinter := FWMSPrinter():New(cNomArq,6,.F.,,.T.)
	     oPrinter:SetPortrait()
	     oPrinter:SetPaperSize(9)
	     oPrinter:SetMargin(60,60,60,60)
	     oPrinter:cPathPDF := cLocArq       
	EndIf       
Return
//----------------------------------------------- quebra da rotina ------------------------------------------------------//
Static Function ImpCab 
	If nVia == 1
		nRowCab := 30
		oPrinter:StartPage()
		nPag++  
    Else 
		nRowCab := nRowRod + 36
    EndIf
	nColCab := 20

	//oPrinter:Box(nRowCab-05,nColCab-10,nRowCab+40,nColCab+530)
	//oPrinter:SayAlign( nRowCab,nColCab,DTOC(DDATABASE) +" - "+ TIME(),oF12,120, , 0, 0 )		
	//oPrinter:SayAlign( nRowCab,nColCab,"O R Ç A M E N T O",oF18N,500, , 0, 2 )		
	oPrinter:SayAlign( nRowCab,nColCab,"PEDIDO DE VENDA",oF18N,500, , 0, 2 )		
	oPrinter:SayAlign( nRowCab,nColCab+450,"Via.: "+ cValToChar(nVia),oF12N,100, , 0, 0 )		
	oPrinter:line(nRowCab+= 20,nColCab-10,nRowCab,550)
	oPrinter:SayAlign( nRowCab,nColCab,    "DOCUMENTO AUXILIAR DE VENDA",oF12,500, , 0, 2 )   
	oPrinter:SayAlign( nRowCab+=13,nColCab,"NÃO É DOCUMENTO FISCAL - NÃO É VÁLIDO COMO GARANTIA DE MERCADORIA",oF12,500, , 0, 2 )
	oPrinter:line(nRowCab+= 20,nColCab-10,nRowCab,550)
	
	//oPrinter:Box(nRowCab+=18,nColCab-10,nRowCab+85,nColCab+530)
	oPrinter:SayAlign( nRowCab,nColCab,    "    DATA : "+ DTOC(DDATABASE) +" - "+ TIME(),oF12,300, , 0, 0 )   
	oPrinter:SayAlign( nRowCab+=00,nColCab+400,"NÚMERO: "+ QRSC5->C5_NUM,oF12N,450, , 0, 0 )
	oPrinter:SayAlign( nRowCab+=13,nColCab,"CLIENTE..: "+ QRSC5->C5_CLIENTE+" - "+ QRSC5->A1_NOME,oF12N,450, , 0, 0 )
	oPrinter:SayAlign( nRowCab+=13,nColCab,"CPF/CNPJ.: "+ IIF(LEN(ALLTRIM(QRSC5->A1_CGC))>=15,TRANSFORM(QRSC5->A1_CGC,"@R 999.999.999/9999-99"),TRANSFORM(QRSC5->A1_CGC,"@R 999.999.999-99")),oF12,200, , 0, 0 )
	oPrinter:SayAlign( nRowCab,nColCab+200," INSC.EST.: "+ QRSC5->A1_INSCR,oF12,200, , 0, 0 )   

	oPrinter:SayAlign( nRowCab+=13,nColCab,"ENDEREÇO.: "+ SUBSTR(QRSC5->A1_END,1,50),oF12,280, , 0, 0 )
	oPrinter:SayAlign( nRowCab,nColCab+280,"BAIRRO: "+ SUBSTR(QRSC5->A1_BAIRRO,1,15),oF12,120, , 0, 0 )   
	oPrinter:SayAlign( nRowCab,nColCab+400,"CIDADE: "+ AllTRIM(QRSC5->A1_MUN)+"-"+QRSC5->A1_EST,oF12,200, , 0, 0 )
	
	//oPrinter:SayAlign( nRowCab+=13,nColCab,"CIDADE...: "+ QRSC5->A1_MUN,oF12,200, , 0, 0 )
	//oPrinter:SayAlign( nRowCab,nColCab+200," ESTADO: "+ QRSC5->A1_EST,oF12,80, , 0, 0 )   
	//oPrinter:SayAlign( nRowCab,nColCab+280," CEP: "+ TRANSFORM(QRSC5->A1_CEP,"@R 99.999-999"),oF12,120, , 0, 0 ) 
	cDDD := StrZero(Val(QRSC5->(A1_DDD)),2)
	If Len(AllTrim(QRSC5->A1_TEL))> 8
		oPrinter:SayAlign( nRowCab+=13,nColCab,"TELEFONE.: "+ TRANSFORM(cDDD+QRSC5->(A1_TEL),"@R (99)99999-9999"),oF12,150, , 0, 0 )
	Else
		oPrinter:SayAlign( nRowCab+=13,nColCab,"TELEFONE.: "+ TRANSFORM(cDDD+QRSC5->(A1_TEL),"@R (99)9999-9999"),oF12,150, , 0, 0 )
	EndIf
	If Len(AllTrim(QRSC5->A1_TELEX))> 8
		oPrinter:SayAlign( nRowCab,nColCab+150," CELULAR: "+ TRANSFORM(cDDD+QRSC5->(A1_TELEX),"@R (99)99999-9999"),oF12,150, , 0, 0 )   
   	Else
		oPrinter:SayAlign( nRowCab,nColCab+150," CELULAR: "+ TRANSFORM(cDDD+QRSC5->(A1_TELEX),"@R (99)9999-9999"),oF12,150, , 0, 0 )   
	EndIf   	
	
	oPrinter:Box(nRowCab+=18,nColCab-10,nRowCab+15,nColCab+530)
	oPrinter:SayAlign( nRowCab+=2,nColCab,"ITEM",oF10N,20, , 0, 0 )		
	oPrinter:SayAlign( nRowCab,nColCab+=25,"CÓDIGO",oF10N,80, , 0, 0 )		
	oPrinter:SayAlign( nRowCab,nColCab+=80,"DESCRIÇÃO",oF10N,220, , 0, 0 )		
	oPrinter:SayAlign( nRowCab,nColCab+=220,"UN",oF10N,15, , 0, 0 )		
	oPrinter:SayAlign( nRowCab,nColCab+=015,"QUANTIDADE",oF10N,60, , 0, 1 )		
	oPrinter:SayAlign( nRowCab,nColCab+=60,"PREÇO",oF10N,60, , 0, 1 )		
	oPrinter:SayAlign( nRowCab,nColCab+=60,"VR. TOTAL",oF10N,60, , 0, 1 )		

	nRowDet := nRowCab +15
	nLinImp := 0

Return
//----------------------------------------------- quebra da rotina ------------------------------------------------------//
Static Function ImpDet  // 39 itens + traco  (linha: 0784 = ultima linha detalhe)

	nColDet := 20
                                                                                         
	//oPrinter:Box(nRowCab+=18,nColCab-10,nRowCab+15,nColCab+530)
	oPrinter:SayAlign( nRowDet+=2,nColDet,QRSC6->C6_ITEM,oF10,20, , 0, 0 )		
	oPrinter:SayAlign( nRowDet,nColDet+=25,QRSC6->C6_PRODUTO,oF10,80, , 0, 0 )		
	oPrinter:SayAlign( nRowDet,nColDet+=80,QRSC6->C6_DESCRI,oF10,220, , 0, 0 )		
	oPrinter:SayAlign( nRowDet,nColDet+=220,QRSC6->C6_UM,oF10,15, , 0, 0 )		
	oPrinter:SayAlign( nRowDet,nColDet+=015,Transform(QRSC6->C6_QTDVEN,"@E 999,999.99"),oF10,60, , 0, 1 )		
	oPrinter:SayAlign( nRowDet,nColDet+=60,Transform(QRSC6->C6_PRCVEN,"@E 999,999.99"),oF10,60, , 0, 1 )		
	oPrinter:SayAlign( nRowDet,nColDet+=60,Transform(QRSC6->C6_VALOR,"@E 999,999.99"),oF10,60, , 0, 1 )		

	If !Empty(Alltrim(QRSC6->C6_XOBS))
    	nColDet := 20
		nRowDet += 12 
		oPrinter:SayAlign( nRowDet,nColDet+=107,QRSC6->C6_XOBS,oF10,420, , 0, 0 )
		nLinImp++
	EndIf
	nRowDet += 12 
	nRowRod := nRowDet
	nLinImp++
Return

//----------------------------------------------- quebra da rotina ------------------------------------------------------//
Static Function ImpRod(lUltPag)
	Local nColImpr, nX
	
	nLinBr := nQtdItem	- nLinImp
	If nLinBr > 0
		nRowRod+= (nLinBr * 12)
	EndIf                      
	
    nColRod := 20
    //nRowRod := 700+26
	//oPrinter:SayAlign( nRowRod,nColDet-10,Replicate("=",96),oF12,800, , 0, 0 )	

	oPrinter:line(nRowRod,nColRod-10,nRowRod,550)
	nColImpr := 1 

	For nX :=1 to Len(aVencto)       
   		If nColImpr == 2
			//nRowRod+=12
   			nColRod:= 300
   			nColImpr := 1 
   			If nX>=1 .and. nX<=2
				oPrinter:SayAlign( nRowRod   ,nColRod-10,"Vencimento"+ " Forma de Pagamento " +"          Valor",oF12N,400, , 0, 0 )	
			EndIf
			oPrinter:SayAlign( nRowRod+12,nColRod-10,DtoC(aVencto[nX,1])+ "  "+Padr(Substr(QRSC5->E4_DESCRI,1,20),22) +Transform(aVencto[nX][2],"@E 999,999.99"),oF12,400, , 0, 0 )	
			nRowRod+= 12
		Else
			nColRod:= 020
   			nColImpr := 2
   			If nX>=1 .and. nX<=2
				oPrinter:SayAlign( nRowRod   ,nColRod-10,"Vencimento"+ " Forma de Pagamento " +"          Valor",oF12N,400, , 0, 0 )	
			EndIf
			oPrinter:SayAlign( nRowRod+12,nColRod-10,DtoC(aVencto[nX,1])+ "  "+Padr(Substr(QRSC5->E4_DESCRI,1,20),22) +Transform(aVencto[nX][2],"@E 999,999.99"),oF12,400, , 0, 0 )	
		EndIf
	Next
	If len(aVencto) == Int(len(aVencto)/2)*2
		// entao é Par
		nLinPg := len(aVencto)/2
	Else
		// impar	
		nLinPg := (len(aVencto)/2)+1
		nRowRod+=16
	EndIf
    nRowRod := nRowRod +((2-nLinPg)*12)

	nColRod:= 020
	nRowRod+=14
	oPrinter:line(nRowRod		 ,nColRod-10,nRowRod,550)

	oPrinter:SayAlign( nRowRod   ,nColRod-10,"Entrega: ",oF12N,80, , 0, 0 )	
	oPrinter:SayAlign( nRowRod+2 ,nColRod+40,DtoC(StoD(QRSC5->C5_FECENT)),oF12,80, , 0, 1 )

	oPrinter:SayAlign( nRowRod   ,nColRod+200,"Vr. Frete:",oF12N,80, , 0, 0 )	
	oPrinter:SayAlign( nRowRod+2 ,nColRod+250,Transform(QRSC5->C5_FRETE,"@E 999,999.99"),oF12,80, , 0, 1 )

	oPrinter:SayAlign( nRowRod   ,nColRod+400,"Valor Pedido:",oF12N,80, , 0, 0 )	
	oPrinter:SayAlign( nRowRod+2 ,nColRod+450,Transform(nValorTot,"@E 999,999.99"),oF12,80, , 0, 1 )

	cTexto:= "Observação: "+ QRSC5->C5_MENNOTA  
	//nChar    := Len(cTexto)
   	cLinExt1 := OemToAnsi(MemoLine(cTexto,070,1))
	cLinExt2 := OemToAnsi(MemoLine(cTexto,070,2))
	oPrinter:SayAlign( nRowRod+=14,nColRod-10,cLinExt1,oF12,800, , 0, 0 )	
	oPrinter:SayAlign( nRowRod+=14,nColRod-10,cLinExt2,oF12,800, , 0, 0 )	
   	
	
	nRowRod+=20
   	oPrinter:SayAlign( nRowRod,nColRod-10,PADC("_____________________________",30),oF12,400, , 0, 2 )	
	oPrinter:SayAlign( nRowRod,nColRod+200,PADC("_____________________________",30),oF12,400, , 0, 2 )	
	nRowRod+=10
	
	oPrinter:SayAlign( nRowRod,nColRod-10,PADC(cUserName,30),oF12,400, , 0, 2 )	
	oPrinter:SayAlign( nRowRod,nColRod+200,PADC("Ass.Cliente",30),oF12,400, , 0, 2 )	

	nRowRod+=10
	oPrinter:SayAlign( nRowRod,010,"Caro cliente, confira sua mercadoria no ato da entrega, pois não aceitamos reclamações posteriores.",oF10,550, , 0, 0 )	
	
	nRowRod+=10
	oPrinter:SayAlign( nRowRod,010,Replicate(" - ",75),oF10,550, , 0, 0 )	

Return
//-----------------------------------------------------(quebra)---------------------------------------------//

Static Function FecharArq
	oPrinter:EndPage()
	If lPreview
	     oPrinter:Preview()
	EndIf                      
	//FreeObj(oPrinter)
	oPrinter := Nil
Return          
//-----------------------------------------------------(quebra)---------------------------------------------//

Static Function CntRec(cAlias)
	Local _cAlias := "'"+ cAlias+"'"
	nRecAlias := 0
	bCount := {|| nRecAlias++ }
	&_cAlias->(dbEval(bCount))

Return(nRecAlias)
//-----------------------------------------------------(quebra)---------------------------------------------//
                                     
Static Function CntPag(_nRec, _nRecPag)
	If Mod(_nRec, _nRecPag)>0
		_nPag := Int(_nRec/ _nRecPag)+1
	Else
		_nPag := Int(_nRec/ _nRecPag)
	EndIf
Return(_nPag)
//-----------------------------------------------------(quebra)---------------------------------------------//

User Function DTEXPED()
	Local aArea     := GetArea()
    Local aPergs  	:= {}
	Local aRet    	:= {}
    
    dbSelectArea("SC5")
    If !Empty(Trim(SC5->C5_NOTA))
        MsgAlert("Este pedido já está faturado! Não será permitido informar data de expedição", "Data de Expedição")
        Return.f.
    EndIf

	aAdd(aPergs, {1, "Data da Expedição"    	, dDataBase,  "",          ".T.", "",    ".T.", 50,  .T.})

    If !ParamBox(aPergs, "Informe os parâmetros",aRet)
		Return.f.
	EndIf

    RecLock("SC5",.F.)
    SC5->C5_XDTEXP := aRet[1]
    MsUnLock()
    
    MsgInfo("Data da Expedição registrada com sucesso!!!", "Data de Expedição")
	RestArea(aArea)
Return
