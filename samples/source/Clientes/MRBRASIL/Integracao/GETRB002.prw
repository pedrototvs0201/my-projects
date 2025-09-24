#INCLUDE "TOTVS.CH"
#include 'RPTDEF.CH'
#include 'protheus.ch'
#INCLUDE "TBICONN.CH"

User Function GETRB002()

//	If Select("SX6") == 0
//		PREPARE ENVIRONMENT EMPRESA '01' FILIAL '0101' MODULO "COM" //TABLES "SD3","SC6","SA1","SA2","SB1","SB2","SF4","SFM"
//	Endif
    GETRB02A()

 //Processa( {|| GETRB01A() }, "Aguarde...", "Copiando Arquivos csv's para Servidor...",.F.)

Return

Static Function GETRB02A()

    Local nAtual := 0

    cDirSrv  := '\trimbox\out\'
    aDirAux  := Directory(cDirSrv+'*.csv')
    //alert(cDirSrv)
    //Percorre os arquivos
    For nAtual := 1 To Len(aDirAux)

    //Pegando o nome do arquivo
    cNomArq := aDirAux[nAtual][1]
     
    //Copia o arquivo da maquina do usuario para o servidor
    CpyS2T( cDirSrv+cNomArq, 'C:\TOTVS\TRIMBOX\AR\' )
    //alert("oi")
    //Apaga o arquivo copiado
    FERASE( cDirSrv+cNomArq )
    
    Next nAtual
    
Return 
