	#INCLUDE "TOTVS.CH"
#include 'RPTDEF.CH'
#include 'protheus.ch'
#INCLUDE "TBICONN.CH"

    User Function IntPro()
    Local cDirSrv as character
	Local aDirAux as array


	If Select("SX6") == 0
		PREPARE ENVIRONMENT EMPRESA '01' FILIAL '0101'
	Endif

	cDirSrv  := "/trimbox/out/"
	aDirAux  := Directory(cDirSrv+'produtos_faquini.csv',"A")
	
    if len(aDirAux ) > 0
		RESET ENVIRONMENT
		return
	endIf
   
    U_INTSB1()
	
    RESET ENVIRONMENT

return
