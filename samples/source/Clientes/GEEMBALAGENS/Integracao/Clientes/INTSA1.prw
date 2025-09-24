#INCLUDE "TOTVS.CH"
#include 'RPTDEF.CH'
#include 'protheus.ch'
#INCLUDE "TBICONN.CH"
#DEFINE crlf chr(13) + chr(10)

//|-----------------------------------------------------------------------------|
//| Programa  | intsa1      | Autor(s)| Denilson Almeida    | Data | 30/04/2020 |
//|-----------------------------------------------------------------------------|
//| Descrição | Geração de arquivo .csv com a lista dos funcionários com redução|
//|-----------------------------------------------------------------------------|
//|                             Últimas Alterações                              |
//|-----------------------------------------------------------------------------|
//| DATA       | ANALISTA          | DETALHAMENTO                               |
//|------------|-------------------|--------------------------------------------|
//|            |                   |                                            |
//|-----------------------------------------------------------------------------|


User Function INTSA1()

	Local cDirSrv as character
	Local lInicio as logical

	Private cCliente as character
	Private	cCNPJ    as character
	Private	cRSocial as character
	Private	cTipo    as character 
	Private	cEnd     as character
	Private	cNFant   as character
	Private	cBairro  as character
	Private	cTCli    as character
	Private	cUF      as character
	Private	cCep     as character
	Private	cMun     as character
	Private	cDDD     as character
	Private	cTel     as character
	Private	cCont    as character
	Private	cIE      as character
	Private	cPais    as character
	Private	cCompl   as character
	Private	cEmail   as character
	Private	nTolmi   as numeric
	Private	nTolmx   as numeric
	Private	cLaudo   as character
	Private	cELaud   as character
	Private	cPrio    as character
	Private	cVend    as character
	Private	nPcom    as numeric
	Private cCodTrim as character
	Private cIBGE    as character
	
	private nCont := 0
	
	cSaida := "/trimbox/out/"
	cArqS := cSaida+'cliente.csv'

	ArqTXT := fCreate(cArqS)
	cLinS := ""
	
	cDirSrv  := "/trimbox/in/"
	//aDirAux  := Directory(cDirSrv+'produtos_faquini.csv',"A")
	lInicio := .t.
	oFile:=FWFileReader():New(cDirSrv+'clientes_faquini.csv')
	oFile:Open()

	While (oFile:HasLine())

		//Pegando a linha atual e transformando em array
		cLinha := oFile:GetLine()
		cLinha := strTran(cLinha,";;","; ;")
		aLinha  := StrTokArr(cLinha, ";")
		If !lInicio .and. len(alinha) >2 .and. substr(alinha[1],1,5) != "-----"
			cCliente := alltrim(padl(aLinha[8],6,'0'))
			cCodTrim := alltrim(alinha[8])
			cCNPJ := alltrim(aLinha[10])
			cRSocial := alltrim(aLinha[9])
			cTipo := aLinha[11]
			cEnd := aLinha[12]
			if aLinha[9] = "NULL"
			cNFant := substring(aLinha[9],1,19)
			else
			cNFant := aLinha[9]
			EndIf
			cBairro := aLinha[13]
			cTCli := aLinha[14]
			cUF := aLinha[15]
			cIBGE := aLinha[16]
			cIBGE := substr(cIBGE,3,5)
			cCep := aLinha[17]
			cMun := aLinha[18]
			if aLinha[19] = "NULL"
				cDDD := ""
			else
				cDDD := aLinha[19]
			EndIf
			cTel := aLinha[20]
			cCont := aLinha[21]
			cIE := aLinha[22]
			if aLinha[23] = "Brasil"
			cPais := '105'
			else
			cPais := ""
			EndIf
			If aLinha[24] = "NULL"
			cCompl := ""
			else
			cCompl := aLinha[24]
			EndIf
			If aLinha[25] = "NULL"
			cEmail := ""
			else
			cEmail := aLinha[25]
			EndIf
			//if Type(&(aLinha[26])) == "N"  
			//nTolmi := aLinha[26]
			//else
			nTolmi := 10//aLinha[26]
			//EndIf
			//if Type(&(aLinha[27])) == "N
			//nTolmx := aLinha[27]
			//else
			nTolmx := 10//aLinha[27]
			//EndIf
			cLaudo := ""//aLinha[29]
			If aLinha[29] = "NULL"
			cELaud := ""
			else
			cELaud := ""//aLinha[30]
			EndIf
			cPrio := "0"//aLinha[31]
			If aLinha[31] = "NULL"
			cVend := ""
			else
			cVend := ""//aLinha[32]
			EndIf
			nPcom := 0//aLinha[33]
			
			cError := u_GECRMA980()

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
			cLinS += aLinha[13]+";"
			cLinS += aLinha[14]+";"
			cLinS += aLinha[15]+";"
			cLinS += aLinha[16]+";"
			cLinS += aLinha[17]+";"
			cLinS += aLinha[18]+";"
			cLinS += aLinha[19]+";"
			cLinS += aLinha[20]+";"
			cLinS += aLinha[21]+";"
			cLinS += aLinha[22]+";"
			cLinS += aLinha[23]+";"
			cLinS += aLinha[24]+";"
			cLinS += aLinha[25]+";"
			cLinS += aLinha[26]+";"
			cLinS += aLinha[27]+";"
			cLinS += aLinha[28]+";"
			cLinS += aLinha[29]+";"
			cLinS += aLinha[30]+";"
			cLinS += aLinha[31]+";"
			cLinS += aLinha[32]+";"
			cLinS += aLinha[33]
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

Return

