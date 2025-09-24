#INCLUDE "TOTVS.CH"
#include 'RPTDEF.CH'
#include 'protheus.ch'
#INCLUDE "TBICONN.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} INTSC5
description Função utilizada para a leitura do arquivo txt com os pedidos de venda
@author  denilson
@since   date
@version 1.0
*/
//-------------------------------------------------------------------

User Function INTSC5()

	Local cDirSrv    as character
	Local lInicio    as logical
	Private cPedido  as character
	Private cOp      as character
	Private cCliente as character
	Private DtEntr   as date
	Private nQuant   as numeric
	Private cProduto as character
	Private nIpi as numeric
	Private cConj as character
	Private cLinha as character
	Private aLinha as array
	Private aLinha1 as array
	Private cSaida as character
	Private cArqS as character
	Private cLinS as character
	Private cError as character
	Private nPreUn as numeric
	private nCont := 0
	Private cItPed as character

	cProduto := ""
	cCliente := ""	
	aLinha1 := {}

	cSaida := "/trimbox/out/"
	cArqS := cSaida+'pc_faquini.csv'

	ArqTXT := fCreate(cArqS)
	cLinS := ""

	cDirSrv  := "/trimbox/in/"
	//aDirAux  := Directory(cDirSrv+'produtos_faquini.csv',"A")
	lInicio := .t.
	oFile:=FWFileReader():New(cDirSrv+'pc_faquini.csv')
	oFile:Open()
	oFile:=FWFileReader():New(cDirSrv+'pc_faquini.csv')
	oFile:Open()

	While (oFile:HasLine())

		//Pegando a linha atual e transformando em array
		cLinha := oFile:GetLine()
		cLinha := strTran(cLinha,";;","; ;")
		aLinha  := StrTokArr(cLinha, ";")
		ntam := Len(aLinha)
		aSize(aLinha, ntam+1) //inicializando o array aLinha + 1
		//aLinha  := StrTokArr(cLinha, ";", .t.) //separando os campos da linha		
		nQuant := 0
		nPreUn := 0

		If !lInicio .and. len(alinha) >2 .and. substr(alinha[1],1,5) != "-----"
			

			cPedido := alltrim(aLinha[2])
			//cOP     := substr(alltrim(aLinha[9]),1,6) // numero da ordem de producao
			//cItPed  := substr(alltrim(aLinha[8]),7,2) // numero do item do pedido
			//pegar o campo trimbox no cadastro
			DbSelectArea("SA2")
			DbsetOrder(14)
			if Dbseek(xFilial("SA2")+aLinha[1],.t.)
				cFornece := SA2->A2_COD //POSICIONE("SA1",14,xFilial("SA1")+aLinha[10])
			EndIf
			DtEntr := stod(substr(aLinha[34],1,4)+substr(aLinha[34],6,2)+substr(aLinha[34],9,2))
			DtEmiss:= stod(substr(aLinha[9],1,4)+substr(aLinha[9],6,2)+substr(aLinha[9],9,2))
			//pegar o campo trimbox no cadastro

			DbSelectArea("SB1")
			DbsetOrder(14)
			if Dbseek(xFilial("SB1")+aLinha[14],.t.)
				cProduto := SB1->B1_COD //POSICIONE("SB1",,xFilial("SB1")+aLinha[21])
			EndIf
			nQuant := val(aLinha[36])
			nPreUn := val(aLinha[55])
			

			//nPeso := aLinha[12]
			//nPesoB := aLinha[11]
			//cncm := aLinha[15]
			//nIpi := aLinha[13]
			//if aLinha[14] = "NULL"
			//	cConj := ""
			//else
			//	cConj := aLinha[14]
			//EndIf

			cError := U_IMATA650() //u_IMata410()
			//U_IMATA650()
			aAdd(aLinha1, aLinha) //Adicionando a linha no array aLinha1
			
			cLinS := aLinha[1]+";"//id_InClientesFaquini
			cLinS += aLinha[2]+";" //ErroNesteRegistro
			if alltrim(cError) = ""
				cLinS += aLinha[3]+";"
				cLinS += "1"//Estado
			else
				cLinS += cError+";"
				cLinS += "2"//Estado
			EndIf
			/*/cLinS += aLinha[5]+";"
			cLinS += aLinha[6]+";"
			cLinS += aLinha[7]+";"
			cLinS += aLinha[8]+";"
			cLinS += aLinha[9]+";"
			cLinS += aLinha[10]+";"
			cLinS += aLinha[11]+";"
			cLinS += aLinha[12]+";"
			cLinS += aLinha[13]
			/*/
			ncont++

			cLinS += chr(13) + chr(10)

			FWrite(ArqTXT,cLinS)

		else
			lInicio := .f.
		EndIf
	
		aLinha  := {}
	EndDo
	u_IMata410()
	FClose(ArqTxt)

	oFile:Close()

return
