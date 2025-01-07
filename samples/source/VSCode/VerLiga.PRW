#Include "Totvs.ch"
#Include "FWMVCDef.ch"

USER FUNCTION VerLiga()

Local cCodigoLiga := M->B1_XCODLIG

//Exemplo colocando na validação do campo:

  
 
If ExistCPO("ZZA", cCodigoLiga )
    
Else
    M->B1_XCODLIG:='9999'
    MsgStop("Liga não existe", "Atenção")
    

EndIf
RETURN
