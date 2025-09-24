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

 
  
User Function DELSCBL() 

  
  Local _cQuery 

  PREPARE ENVIRONMENT EMPRESA "01" FILIAL  "0101"
  
   //Monta o Update
    _cQuery := " UPDATE " + RetSqlName("SC1") + " "
    _cQuery += "     SET D_E_L_E_T_ = '*', C1_OBS = 'BLOQUEADO POR SCHEDULE' "
    _cQuery += "   WHERE  C1_APROV = 'B' AND"
    _cQuery += " C1_DATAAPR<=GETDATE()-5 AND REPLACE(C1_DATAAPR,' ','')<>''"
    _cQuery += "     AND D_E_L_E_T_ <> '*' "
  

  TCSQLExec(_cQuery) 
  TcSqlExec("COMMIT") 
  
  ConOut("------------------------------------------") 
  ConOut("Fim do update") 
  ConOut("------------------------------------------") //vou executar via job 

RESET ENVIRONMENT 

Return 
