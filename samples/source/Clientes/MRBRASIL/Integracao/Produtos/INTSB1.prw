#INCLUDE "TOTVS.CH"
#include 'RPTDEF.CH'
#include 'protheus.ch'
#INCLUDE "TBICONN.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} INTSB1
description
@author  author
@since   date
@version version
*/
//-------------------------------------------------------------------


User Function INTSB1()

	Local cDirSrv as character
	Local lInicio as logical
	Private cProduto as character
	Private cDesPro as character
	Private cCliente as character
	Private nPeso as numeric
	Private nPesoB as numeric
	Private cncm as character
	Private nIpi as numeric
	Private cConj as character
	Private cLinha as character
	Private aLinha as array
	Private cSaida as character
	Private cArqS as character
	Private cLinS as character
	Private cError as character
	Private cCodTrim as character
	private nCont := 0
	
	cSaida := "/trimbox/out/"
	cArqS := cSaida+'produtos_faquini.csv'

	ArqTXT := fCreate(cArqS)
	cLinS := ""
	
	cDirSrv  := "/trimbox/in/"
	//aDirAux  := Directory(cDirSrv+'produtos_faquini.csv',"A")
	lInicio := .t.
	oFile:=FWFileReader():New(cDirSrv+'produtos_faquini.csv')
	oFile:Open()

	While (oFile:HasLine())

		//Pegando a linha atual e transformando em array
		cLinha := oFile:GetLine()
		cLinha := strTran(cLinha,";;","; ;")
		aLinha  := StrTokArr(cLinha, ";")
		If !lInicio .and. len(alinha) >2 .and. substr(aLinha[1],1,5) != "-----"
			cProduto := alltrim(padl(aLinha[8],6,'0'))
			cCodTrim := aLinha[8]
			cDesPro := alltrim(aLinha[9])
			cCliente := padl(aLinha[10],6,'0')
			nPeso := aLinha[12]
			nPesoB := aLinha[11]
			cncm := aLinha[15]
			if aLinha[13] = "NULL"
			nIpi := 0
			else
			cIpi := aLinha[13]
			nIpi := val(cIpi)
			EndIf
			if aLinha[14] = "NULL"
				cConj := ""
			else
				cConj := aLinha[14]
			EndIf

			cError := u_m010IncRa()

			cLinS := aLinha[1]+";"//id_InClientesFaquini
			cLinS += aLinha[2]+";" //ErroNesteRegistro
			if alltrim(cError) = ""
				cLinS += aLinha[3]+";"
				cLinS += "1"//Estado
			else
				cLinS += cError+";"
				cLinS += "2"//Estado
			EndIf
			/*/
			cLinS += aLinha[5]+";"
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

	FClose(ArqTxt)

	oFile:Close()

return
