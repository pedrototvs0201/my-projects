//Bibliotecas
#include 'TOTVS.CH' 
#include "Protheus.ch" 
#include "TopConn.ch" 
#INCLUDE "TBICONN.ch" 
#include "Fileio.ch"
/*        
+-----------+------------+----------------+----------------------+-------+------------+
| Programa  | SC2CSV     | Desenvolvedor  | Pedro Sousa           | Data | 17/09/2025 |
+-----------+------------+----------------+----------------------+-------+------------+
| Descricao |GERAR TABELA SC2 EM CSV                    	                          |
+-----------+-------------------------------------------------------------------------+
| Modulos   | PRODU�AO                                                                |
+-----------+-------------------------------------------------------------------------+
| Processos |                                                                         |
+-----------+-------------------------------------------------------------------------+
|                  Modificacoes desde a construcao inicial                            |
+----------+-------------+------------------------------------------------------------+
| DATA     | PROGRAMADOR | MOTIVO                                                     |
+----------+-------------+------------------------------------------------------------+
|21/03/2025| PEDRO EUST. | Solicitação da MRBRASIL                                  |
+----------+-------------+------------------------------------------------------------+
*/

 
  
User Function SC2CSV() 

  
    Local _cQuery 
	local nHandle := FCREATE("\ORDEMPRODUCAO.sql")
	Local   _aArea	 := GetArea()
	Local   _aArray  := {}
	Local   nt       := 0


	// Envia E-mail por Tipo de Producao
	

   // Private cCaminho := ""
	//Private mArquivo := ""
	//private cCtt := ""
	//private nCont := 0

	


	//cCaminho := "C:\TOTVS\SA1CSV\"
	//mArquivo := cCaminho+"cliente.csv"

	//ArqTXT := fCreate(mArquivo)
	



  PREPARE ENVIRONMENT EMPRESA "99" FILIAL  "01"



		_aArray  := {}
  
   //Monta o Update
  	xSQL  	:= GetNextAlias()
    _cQuery := " SELECT C2_NUM 'OP',"
	_cQuery += "(SELECT  TOP(1) SC6.C6_CLI FROM " + RetSqlName("SC6") + " SC6 WHERE SC6.C6_NUM=C2_PEDIDO AND C6_FILIAL=C2_FILIAL) 'CodCliente', "
	_cQuery += "(SELECT TOP(1) SC6.C6_CLI FROM " + RetSqlName("SC6") + " SC6 WHERE SC6.C6_NUM=C2_PEDIDO AND C6_FILIAL=C2_FILIAL) 'CodClienteTriangular',"
	_cQuery += "C2_PRODUTO 'Produto',C2_QUANT 'QuantidadePedida', C2_DATPRF 'DataEntrega', C2_OBS 'Obs',C2_PEDIDO 'PedCliente',C2_ITEMPV 'ItemPedCliente'"
	
	 _cQuery += "FROM " + RetSqlName("SC2") + " "
    
	
	_cQuery += "     WHERE D_E_L_E_T_ <> '*' "
  
  _cQuery     := ChangeQuery(_cQuery)
		dbUseArea(.T.,"TOPCONN",tCGenQry(,,_cQuery),xSQL,.T.,.T.)


		While (xSQL)->(!Eof())

			//Colocando os resultados do select no grid,;
			AADD(_aArray,{ALLTRIM(OP),;
				ALLTRIM(CodCliente),;
				ALLTRIM(CodClienteTriangular),;
				ALLTRIM(Produto),;
				ALLTRIM(QuantidadePedida),;
				ALLTRIM(DataEntrega),;
				ALLTRIM(Obs),;
				ALLTRIM(PedCliente),;
				ALLTRIM(ItemPedCliente)})

			( xSQL )->(DbSkip())
  	ENDDO

	DbCloseArea()
		RestArea(_aArea)


  ConOut("------------------------------------------") 
  ConOut("FEITO SELECT") 
  ConOut("------------------------------------------") //vou executar via job 

RESET ENVIRONMENT 
         // Posiciona no fim do arquivo
  //  FWrite(nHandle, _cQuery)
//fclose(nHandle)



		IF Len(_aArray) >= 1
			For nt := 1 to Len(_aArray)
    ConOut("------------------------------------------") 
  

   FWrite(nHandle, "INSERT INTO cliente values ( '"+_aArray[nt][1]+"';'"+_aArray[nt][2]+"';'"+_aArray[nt][3]+"';'"+_aArray[nt][4]+"';'"+_aArray[nt][5]+"';'"+_aArray[nt][6]+"';'"+_aArray[nt][7]+"';'"+_aArray[nt][8]+"';'"+_aArray[nt][9]+"')"+ CRLF)
  ConOut("------------------------------------------")
  		Next
		ENDIF
		fclose(nHandle)
  //vou executar via job 
Return 
