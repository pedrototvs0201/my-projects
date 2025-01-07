#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "totvs.ch"
//------------------------------------------------------------
/*{VSCode} ADV004
Rotina para não permitir dureza inicial maior que final

@author Pedro Eustáquio
@version 000
@since

*/

User Function ADV004()
cTemp := M->ZZB_DURINI
cTemp2 := M->ZZB_DURFIM

IF cTemp2<cTemp .AND. cTemp2>0
Alert("Dureza Final menor que dureza inicial, corrija!")
M->ZZB_DURFIM:= cTemp++

Endif 


Return ctemp
