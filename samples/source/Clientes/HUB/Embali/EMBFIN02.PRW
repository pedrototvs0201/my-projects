#Include 'Protheus.ch'
#Include 'Protheus.ch'
#INCLUDE 'TOPCONN.CH'

User Function EMBFIN02()

	Local oReport := nil
	Local cPerg:= Padr("EMBFIN02",10)

	//gero a pergunta	          
	Pergunte(cPerg)
	
	oReport := RptDef(cPerg)
	oReport:PrintDialog()

Return

Static Function RptDef(cNome)
	Local oReport := Nil
	Local oSection1:= Nil
	Local oSection2:= Nil
	Local oBreak
	Local oFunction
	
//	lPrevisao := IIF(mv_par02>dDataBase,.T.,.F.)
	
	/*Sintaxe: TReport():New(cNome,cTitulo,cPerguntas,bBlocoCodigo,cDescricao,LandScape)*/
	oReport := TReport():New(cNome,"Extrato Bancário - Unificado",cNome,{|oReport| ReportPrint(oReport)},"Extrato Bancário - Unificado",.T.)
	
	oSection1:= TRSection():New(oReport, "BANCOS", {"TRBBNC"}, , .F., .T.)
	TRCell():New(oSection1,"A6_NOME"  	    ,"TRBBNC","NOME"		,"@!",30)
	TRCell():New(oSection1,"A6_COD"		    ,"TRBBNC","BANCO"  		,"@!",10)
	TRCell():New(oSection1,"A6_AGENCIA"		,"TRBBNC","AGENCIA"  	,"@!",15)
	TRCell():New(oSection1,"A6_NUMCON"		,"TRBBNC","CONTA"  		,"@!",15)
	
	TRCell():New(oSection1,"DATA"			,"TTRBNC","DATA UL.MOV"		,""  ,10)
	
	TRCell():New(oSection1,"SALDO_INI"		,"TTRBNC","SALDO INICIAL"   ,"@E 9,999,999.99"/*@E 9.999.999,00*/  ,12)
	TRCell():New(oSection1,"VALOR_DEB"		,"TTRBNC","LIQUIDAÇÕES"	    ,"@E 9,999,999.99"  ,12)//DEB CC
	TRCell():New(oSection1,"VALOR_DEP"		,"TTRBNC","DEPÓSITO"		,"@E 9,999,999.99"  ,12)
	TRCell():New(oSection1,"SAIDAS"			,"TTRBNC","SAÍDAS"	    	,"@E 9,999,999.99"  ,12)
	TRCell():New(oSection1,"SALDO_ATU"		,"TTRBNC","SALDO ATUAL"		,"@E 9,999,999.99"/*@E 9.999.999,00*/  ,12)
	TRCell():New(oSection1,"DIVERGENCIAS"	,"TTRBNC","DIVERGENCIAS"	,"@E 9,999,999.99"/*@E 9.999.999,00*/  ,12)

//TOTALIZADOR PADRÃO - SE FOR ATIVAR, DEVE SER DESATIVADO O PERSONALIZADO!!!
/*		
	TRFunction():New(oSection1:Cell("SALDO_ATU"),NIL,"SUM",,,,,.F.,.T.)
	TRFunction():New(oSection1:Cell("VALOR_DEB"),NIL,"SUM",,,,,.F.,.T.)
	TRFunction():New(oSection1:Cell("VALOR_DEP"),NIL,"SUM",,,,,.F.,.T.)
	
	oReport:SetTotalInLine(.T.)
*/       
//Quebra  por seção
//	oSection1:SetPageBreak(.T.)
//	oSection1:SetTotalText(" ")				
Return(oReport)

Static Function ReportPrint(oReport)
	Local oSection1 := oReport:Section(1) 
	Local cQuery1   := ""
	Local cQuery2   := ""
	
	Local nSaldoIni :=0
	Local nValDeb   :=0
	Local nValDep   :=0  
	Local nValSaidas:=0
	Local nSaldoAtu :=0
	Local nResul1   :=0
	Local nResul2   :=0
	
	Local nTSaldoIni:=0
	Local nTValDeb  :=0
	Local nTValDep  :=0
	Local nTValSaida:=0
	Local nTSaldoAtu:=0
	Local nTResultad:=0
	
	Local bPrint    := {|| oReport:ThinLine(),oSection1:Printline(),oReport:ThinLine()}
	
	Local dDataAtual:= mv_par01
	Local dDataAnter:= mv_par01
	Local cSaida 	:= IIF(mv_par04 = 1,"SAIDAS","SAIDAS_NO_TF")

 // cQuery1:=	"exec [dbo].[sp_FluxoDeCaixa] '1'"
 
 	//20190918 - Anderson Davyd - Data de bloqueio adicionada na stored: AND A6_DTBLOQ <= @Parm_Data
 	cQuery1:=	"exec [dbo].[sp_FluxoDeCaixa] '1','"+DTOS(dDataAtual)+"'"
 	
	//Se o alias estiver aberto, irei fechar, isso ajuda a evitar erros
	IF Select("TRBBNC") > 0
		DbSelectArea("TRBBNC")
		TRBBNC->(DbCloseArea())
	ENDIF
	
	//crio o novo alias
	TcQuery cQuery1 NEW ALIAS "TRBBNC"	
	
	dbSelectArea("TRBBNC")
//	TRBBNC->(dbGoTop())

//	IndRegua("TRBBNC", IndexKey(), "BANCO+AGENCIA+CONTA", , , "Selecionando Registros...")
	oReport:SetMeter(TRBBNC->(LastRec()))	
	
	//inicializo a primeira seção
	oSection1:Init()

	oReport:IncMeter()

WHILE dDataAtual <= mv_par02 .AND. dDataAtual <= dDataBase
IF !(cValToChar(Dow(dDataAtual)) $ '1,7')//Sábados e Domingos
    dDataAnter:= DaySub(dDataAtual,1)
    
    While cValToChar(Dow(dDataAnter)) $ '1,7'
    	dDataAnter:= DaySub(dDataAnter,1)
    ENDDO
    
	nSaldoIni :=0
	nValDeb   :=0
	nValDep   :=0	
	nSaldoAtu :=0
	nResul1   :=0
	nResul2   :=0
	
	nValSaidas :=0

//	Alert(DTOC(dDataAtual))
	TRBBNC->(dbGoTop())
	
	While TRBBNC->(!Eof())
		
		If oReport:Cancel()
			Exit
		EndIf
					
		IncProc("Carregando Data "+DTOC(dDataAtual))	
		
		//imprimo a primeira seção				
		oSection1:Cell("BANCO"):SetValue(TRBBNC->BANCO)
		oSection1:Cell("AGENCIA"):SetValue(TRBBNC->AGENCIA)
		oSection1:Cell("CONTA"):SetValue(TRBBNC->CONTA)
		oSection1:Cell("NOME"):SetValue(TRBBNC->NOME)
			
		  cQuery2:=	"exec [dbo].[sp_FluxoDeCaixa] '2','"+ DTOS(dDataAtual) + "','"+;
		   												  TRIM(TRBBNC->BANCO) +"','"+;
		   												  TRIM(TRBBNC->AGENCIA) +"','"+;
		   												  TRIM(TRBBNC->CONTA) +"','"+;
		   												  DTOS(dDataAnter)+"'"

			//Se o alias estiver aberto, irei fechar, isso ajuda a evitar erros
			IF Select("TRBBNC2") > 0
				DbSelectArea("TRBBNC2")
				TRBBNC2->(DbCloseArea())
			ENDIF
			
			//crio o novo alias
		  TcQuery cQuery2 NEW ALIAS "TRBBNC2"
		  
		  dbSelectArea("TRBBNC2")
		  TRBBNC2->(dbGoTop())
		
		nResul1:=TRBBNC2->(SALDO_INI+VALOR_DEB+VALOR_DEP-&cSaida-SALDO_ATU)
		
		oSection1:Cell("DATA"):SetValue(STOD(TRBBNC2->DATA))
		oSection1:Cell("SALDO_INI"):SetValue(TRBBNC2->SALDO_INI)
		oSection1:Cell("VALOR_DEB"):SetValue(TRBBNC2->VALOR_DEB)
		oSection1:Cell("VALOR_DEP"):SetValue(TRBBNC2->VALOR_DEP)
		oSection1:Cell("SAIDAS"):SetValue(TRBBNC2->&cSaida)
		oSection1:Cell("SALDO_ATU"):SetValue(TRBBNC2->SALDO_ATU)
		oSection1:Cell("DIVERGENCIAS"):SetValue(nResul1)
	
		IIF (mv_par03 != 1,oSection1:Printline(),nil)
		//TOTALIZADOR (FORMATO REGISTRO)
		nSaldoIni  += TRBBNC2->SALDO_INI 
		nValDeb    += TRBBNC2->VALOR_DEB
		nValDep    += TRBBNC2->VALOR_DEP	
		nValSaidas += TRBBNC2->&cSaida
		nSaldoAtu  += TRBBNC2->SALDO_ATU
		nResul2    += nResul1
			
		TRBBNC2->(dbclosearea())
		TRBBNC->(dbSkip())
	
	ENDDO
	    nTSaldoIni += nSaldoIni
		nTValDeb   += nValDeb
		nTValDep   += nValDep
		nTValSaida += nValSaidas
		nTSaldoAtu += nSaldoAtu
		nTResultad += nResul2
		
	//TOTALIZADOR (FORMATO REGISTRO)			
	    oSection1:Cell("NOME"):SetValue("TOTAL - "+DTOC(dDataAtual))
		oSection1:Cell("BANCO"):SetValue("-")
		oSection1:Cell("AGENCIA"):SetValue("-")
		oSection1:Cell("CONTA"):SetValue("-")
		oSection1:Cell("DATA"):SetValue("")
		oSection1:Cell("SALDO_INI"):SetValue(nSaldoIni)
		oSection1:Cell("VALOR_DEB"):SetValue(nValDeb)
		oSection1:Cell("VALOR_DEP"):SetValue(nValDep)
		oSection1:Cell("SAIDAS"):SetValue(nValSaidas)
		oSection1:Cell("SALDO_ATU"):SetValue(nSaldoAtu)
		oSection1:Cell("DIVERGENCIAS"):SetValue(nResul2)

		Eval(bPrint)
		
ENDIF

dDataAtual:=DaySum(dDataAtual,1)
ENDDO	

	//TOTALIZADOR (FORMATO REGISTRO)
		oReport:FatLine( )		
		oSection1:Cell("NOME"):SetValue("TOTAL - "+DTOC(mv_par01)+" >"+DTOC(mv_par02))
		oSection1:Cell("BANCO"):SetValue("-")
		oSection1:Cell("AGENCIA"):SetValue("-")
		oSection1:Cell("CONTA"):SetValue("-")
		oSection1:Cell("DATA"):SetValue("-")
		oSection1:Cell("SALDO_INI"):SetValue(nSaldoIni)/*0*//*nTSaldoAtu*/
		oSection1:Cell("VALOR_DEB"):SetValue(nTValDeb)
		oSection1:Cell("VALOR_DEP"):SetValue(nTValDep)
		oSection1:Cell("SAIDAS"):SetValue(nTValSaidas)
		oSection1:Cell("SALDO_ATU"):SetValue(nSaldoAtu)/*0*//*nTSaldoAtu*/
		oSection1:Cell("DIVERGENCIAS"):SetValue(nTResultad)
		
		TRBBNC->(dbclosearea())
		Eval(bPrint)

	oReport:EndPage()
	oSection1:Finish()

Return
