//Bibliotecas
#include 'TOTVS.CH' 
#include "Protheus.ch" 
#include "TopConn.ch" 
#INCLUDE "TBICONN.ch" 

/*        
+-----------+------------+----------------+----------------------+-------+------------+
| Programa  | DELSCBLOCK    | Desenvolvedor  | Pedro Sousa       | Data  | 21/03/2025 |
+-----------+------------+----------------+----------------------+-------+------------+
| Descricao |Excluir Solicitações de Compra bloqueada		                            |
+-----------+-------------------------------------------------------------------------+
| Modulos   | Compras                                                                 |
+-----------+-------------------------------------------------------------------------+
| Processos |                                                                         |
+-----------+-------------------------------------------------------------------------+
|                  Modificacoes desde a construcao inicial                            |
+----------+-------------+------------------------------------------------------------+
| DATA     | PROGRAMADOR | MOTIVO                                                     |
+----------+-------------+------------------------------------------------------------+
|21/03/2025| PEDRO EUST. | Solicitação da AKAFLOOR                                    |
+----------+-------------+------------------------------------------------------------+
*/

 
  
User Function c7_xdata() 
  
  Local _cQuery 

  PREPARE ENVIRONMENT EMPRESA "01" FILIAL  "0101"
  
   //Monta o Update
    _cQuery := " UPDATE " + RetSqlName("SC7") + " "
    _cQuery += "     SET C7_XDATA = C7_EMISSAO
    _cQuery += "   WHERE  C7_XDATA <> C7_EMISSAO
    _cQuery += "     AND D_E_L_E_T_ <>'*' AND YEAR(C7_EMISSAO)>=2025 "
  

  TCSQLExec(_cQuery) 
  TcSqlExec("COMMIT") 
  
  ConOut("------------------------------------------") 
  ConOut("Fim do update") 
  ConOut("------------------------------------------") //vou executar via job 

RESET ENVIRONMENT 

Return 
