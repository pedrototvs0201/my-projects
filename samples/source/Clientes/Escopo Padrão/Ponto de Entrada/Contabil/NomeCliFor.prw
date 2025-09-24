User Function CliFor()

    local cRet := ""

    IF !ALLTRIM(M->C5_TIPO)$'D/B'

        cRet := Posicione("SA1",1,xFilial("SA1")+M->(C5_CLIENTE+C5_LOJACLI),"A1_NOME")

    Else
        
        cRet := Posicione("SA2",1,xFilial("SA2")+M->(C5_CLIENTE+C5_LOJACLI),"A2_NOME")
        
    Endif

Return cRet


User Function CliForA()

    local cRet := ""

    IF !ALLTRIM(M->C5_TIPO)$'D/B'

        cRet := Posicione("SA1",1,xFilial("SA1")+M->(C5_CLIENTE+C5_LOJACLI),"A1_NREDUZ")

    Else
        
        cRet := Posicione("SA2",1,xFilial("SA2")+M->(C5_CLIENTE+C5_LOJACLI),"A2_NREDUZ")
        
    Endif
