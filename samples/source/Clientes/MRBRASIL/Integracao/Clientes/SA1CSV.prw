//Bibliotecas
#include 'TOTVS.CH' 
#include "Protheus.ch" 
#include "TopConn.ch" 
#INCLUDE "TBICONN.ch" 
#include "Fileio.ch"
/*        
+-----------+------------+----------------+----------------------+-------+------------+
| Programa  | OUTSA1    | Desenvolvedor  | Pedro Sousa           | Data  | 17/09/2025 |
+-----------+------------+----------------+----------------------+-------+------------+
| Descricao |GERAR TABELA SA1 EM CSV                    	                          |
+-----------+-------------------------------------------------------------------------+
| Modulos   | FATURAMENTO                                                             |
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

 
  
User Function SA1CSV() 

  
    Local _cQuery 
	local nHandle := FCREATE("\CLIENTE.sql")
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
    _cQuery := " SELECT A1_COD 'CodCliente', A1_NOME 'RazaoSocial',"
	_cQuery += " CASE A1_PESSOA WHEN 'J' THEN '1' WHEN 'F' THEN '2' ELSE '0' END 'TipoPessoa', "
	_cQuery += "A1_NREDUZ 'Cliente',A1_VEND 'CodRepresentante', (select top(1)A3_NOME FROM "+RetSqlName("SA3")+" WHERE A3_COD = A1_VEND AND A1_FILIAL=A3_FILIAL) 'NomeRepresentante',"
	_cQuery += "A1_CGC 'CNPJ',A1_INSCR 'IE', A1_END 'Endereco', A1_BAIRRO 'Bairro', A1_CEP 'CEP', A1_MUN 'Municipio',"
	 _cQuery += "A1_EST'UF',A1_CONTATO 'Contato',   A1_EMAIL 'Email',"
	_cQuery += "A1_EMAIL 'Email', concat(A1_DDD,' ',A1_TEL) 'Telefone', A1_COD_MUN 'CodMunicipio'"
	 _cQuery += "FROM " + RetSqlName("SA1") + " "
    
	
	_cQuery += "     WHERE D_E_L_E_T_ <> '*' "
  
  _cQuery     := ChangeQuery(_cQuery)
		dbUseArea(.T.,"TOPCONN",tCGenQry(,,_cQuery),xSQL,.T.,.T.)


		While (xSQL)->(!Eof())

			//Colocando os resultados do select no grid,;
			AADD(_aArray,{ALLTRIM(CodCliente),;
				ALLTRIM(TipoPessoa),;
				ALLTRIM(RazaoSocial),;
				ALLTRIM(Cliente),;
				ALLTRIM(CodRepresentante),;
				ALLTRIM(NomeRepresentante),;
				ALLTRIM(CNPJ),;
				ALLTRIM(IE),;
				ALLTRIM(Endereco),;
				ALLTRIM(Bairro),;
				ALLTRIM(CEP),;
				ALLTRIM(Municipio),;
				ALLTRIM(UF),;
				ALLTRIM(Contato),;	
				ALLTRIM(Telefone),;			
				ALLTRIM(CodMunicipio)})

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
  ConOut(_aArray[nt][1],_aArray[nt][2],_aArray[nt][3])

   FWrite(nHandle, "INSERT INTO cliente values ( '"+_aArray[nt][1]+"';'"+_aArray[nt][2]+"';'"+_aArray[nt][3]+"';'"+_aArray[nt][4]+"';'"+_aArray[nt][5]+"';'"+_aArray[nt][6]+"';'"+_aArray[nt][7]+"';'"+_aArray[nt][8]+"';'"+_aArray[nt][9]+"';'"+_aArray[nt][10]+"';'"+_aArray[nt][11]+"';'"+_aArray[nt][12]+"';'"+_aArray[nt][13]+"';'"+_aArray[nt][14]+"';'"+_aArray[nt][15]+"';'"+_aArray[nt][16]+"')"+ CRLF)
  ConOut("------------------------------------------")
  		Next
		ENDIF
		fclose(nHandle)
  //vou executar via job 
Return 
