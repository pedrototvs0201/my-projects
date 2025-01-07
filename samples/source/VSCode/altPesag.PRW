
static function altPesag()

    Local oDlg
    Local aH      := {}
    local nI
    Local cV      := 'AlwaysTrue'
    local aCpos   := {} 
    local aRet    := {}
    local aCampos := {'ZZD_QTDPES', 'ZZD_SOLVEN', 'ZZD_PRCDIL', 'ZZD_QTDDIL'}

    aAdd(aCpos, {"ZZD_COMPO"}) 
    aAdd(aCpos, {"ZZD_DSCOMP"}) 
    aAdd(aCpos, {"ZZD_PERCEN"})
    aAdd(aCpos, {"ZZD_QTDCPO"})
    aAdd(aCpos, {"ZZD_QTDPES"})
    aAdd(aCpos, {"ZZD_SOLVEN"})
    aAdd(aCpos, {"ZZD_PRCDIL"})
    aAdd(aCpos, {"ZZD_QTDDIL"})

    For nI := 1 to len(aCpos)
        Posicione("SX3",2,aCpos[nI,1],"")
        SX3->(AADD(aH,{Trim(X3Titulo()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,"",X3_TIPO,"","" }))
    Next nI

    Define MsDialog oDlg From 0,0 to 294,1000 Pixel Title "Informe o Peso"
    oBrw := MsNewGetDados():New(0,0,200,500,3,cV,cV,,aCampos,0,9999999,cV,cV,cV,oDlg,aH,aDados)

  // @ 130,001 Button "OK" Size 40,15 of oDlg Pixel Action (aRet:=tudoOK(oBrw), oDlg:End())
   // @ 130,045 Button "Pesar" Size 40,15 of oDlg Pixel Action (aRet:=buscaPeso(oBrw))

    Activate MsDialog oDlg Centered

return aRet
