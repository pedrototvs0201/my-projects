/*/{Protheus.doc} User Function CliFor
    (long_description)
    @type  Function
    @author André Almeida
    @since 25/08/2022
/*/


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

Return cRet

User Function CliForB()

    local cRet := ""

    IF !ALLTRIM(SF2->F2_TIPO)$'D/B'

        cRet := Posicione("SA1",1,xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA),"A1_NOME")

    Else
        
        cRet := Posicione("SA2",1,xFilial("SA2")+SF2->(F2_CLIENTE+F2_LOJA),"A2_NOME")
        
    Endif

Return cRet


User Function CliForC()

    local cRet := ""

    IF !ALLTRIM(SF2->F2_TIPO)$'D/B'

        cRet := Posicione("SA1",1,xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA),"A1_NREDUZ")

    Else
        
        cRet := Posicione("SA2",1,xFilial("SA2")+SF2->(F2_CLIENTE+F2_LOJA),"A2_NREDUZ")
        
    Endif

Return cRet

User Function CliForD()

    local cRet := ""

    IF !ALLTRIM(M->C5_TIPO)$'D/B'

        cRet := Posicione("SA1",1,xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI),"A1_NOME")

    Else
        
        cRet := Posicione("SA2",1,xFilial("SA2")+SC5->(C5_CLIENTE+C5_LOJACLI),"A2_NOME")
        
    Endif

Return cRet


User Function CliForE()

    local cRet := ""

    IF !ALLTRIM(M->C5_TIPO)$'D/B'

        cRet := Posicione("SA1",1,xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI),"A1_NREDUZ")

    Else
        
        cRet := Posicione("SA2",1,xFilial("SA2")+SC5->(C5_CLIENTE+C5_LOJACLI),"A2_NREDUZ")
        
    Endif

Return cRet
