
#INCLUDE "topconn.ch"
#INCLUDE "totvs.ch"

//------------------------------------------------------------
/*{VSCode} ADV003
Rotina para não permitir dureza inicial maior que final

@author Pedro Eustáquio
@version 000
@since

*/

User Function ADV003()
cTemp := M->ZZB_DURINI
cTemp2 := M->ZZB_DURFIM

IF cTemp2<cTemp
Alert("Dureza Final menor que dureza inicial, corrija!")
M->ZZB_DURFIM:= cTemp++

Endif 


Return ctemp2
