#INCLUDE "TOTVS.CH"
#include 'RPTDEF.CH'
#include 'protheus.ch'
#INCLUDE "TBICONN.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} INTSC2
description ExecAuto para apontamento de producao
@author  Denilson N. Almeida
@since   date
@version 1.0
*/
//-------------------------------------------------------------------

User Function INTSC2()

	Local cDirSrv    as character
	Local lInicio    as logical
	Private cPedido  as character
	Private cOp      as character
	Private cCliente as character
	Private DtEntr   as date
	Private dtIniP   as date
	Private nQuant   as numeric
	Private cProduto as character
	Private nIpi as numeric
	Private cConj as character
	Private cLinha as character
	Private aLinha as array
	Private cSaida as character
	Private cArqS as character
	Private cLinS as character
	Private cError as character
	private nCont := 0
	Private nQtApt := 0
	Private nQtOp := 0

	cSaida := "/trimbox/out/"
	cArqS := cSaida+'pa_faquini.csv'

	ArqTXT := fCreate(cArqS)
	cLinS := ""

	cDirSrv  := "/trimbox/in/"
	//aDirAux  := Directory(cDirSrv+'produtos_faquini.csv',"A")
	lInicio := .t.
	oFile:=FWFileReader():New(cDirSrv+'pa_faquini.csv')
	oFile:Open()

	While (oFile:HasLine())

		//Pegando a linha atual e transformando em array
		cLinha := oFile:GetLine()
		cLinha := strTran(cLinha,";;","; ;")
		aLinha  := StrTokArr(cLinha, ";")

		nQtApt := 0
		nQtOp  := 0

		If !lInicio .and. len(alinha) >2 .and. substr(alinha[1],1,5) != "-----"
			cPedido := alltrim(substr(aLinha[10],1,6))
			//cOP     := alltrim(substr(aLinha[9],1,6))
			//pegar o campo trimbox no cadastro

			DbSelectArea("SC6")
			DbSetOrder(1)
			if DbSeek(xFilial("SC6")+cPedido,.t.)
				DtEntr := SC6->C6_ENTREG //stod(substr(aLinha[14],1,4)+substr(aLinha[14],6,2)+substr(aLinha[14],9,2))
			Endif
			//pegar o campo trimbox no cadastro
			dtIniP := stod(substr(aLinha[13],1,4)+substr(aLinha[13],6,2)+substr(aLinha[13],9,2))
			DbSelectArea("SB1")
			DbsetOrder(14)
			if Dbseek(xFilial("SB1")+aLinha[11],.t.)
				cProduto := alltrim(SB1->B1_COD) //POSICIONE("SB1",,xFilial("SB1")+aLinha[21])
			EndIf
			nQuant := val(aLinha[12])
			cOP    := POSICIONE("SC2",13,xFilial("SC2")+alltrim(substr(aLinha[9],1,6))+alltrim(cProduto),"C2_NUM")
			nQtApt := POSICIONE("SC2",13,xFilial("SC2")+alltrim(substr(aLinha[9],1,6))+alltrim(cProduto),"C2_QUJE")
			nQtOp  := POSICIONE("SC2",13,xFilial("SC2")+alltrim(substr(aLinha[9],1,6))+alltrim(cProduto),"C2_QUANT")
			
			IF nQuant+ nQtApt > nQtOp
				nQtdMaior := Iif(nQuant-(nQtOp - nQtApt)>0,nQuant-(nQtOp - nQtApt),0) //Quantidade maior que a ordem de producao, ajusta para o restante
				nQuant := iff(nQtApt>=nQtOp,0, nQtOp - nQtApt) //Quantidade maior que a ordem de producao, ajusta para o restante
			EndIf	

			SB1->(DbSetOrder(1))
						
			cError := u_Imata250()

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
