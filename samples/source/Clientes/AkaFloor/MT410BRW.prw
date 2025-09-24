/*
+-----------------------------------------------------------------------+
¦Programa  ¦MT410BRW ¦                              ¦ Data ¦27.05.2022  ¦
+----------+------------------------------------------------------------¦
¦Descriçào ¦Programa para criar botão no browse de pedidos.             ¦
+-----------------------------------------------------------------------+
*/
#include "TOTVS.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"

#Define OldLace RGB(128,128,128)
#Define Cinza   RGB(220,220,220)


User Function MT410BRW()
    AAdd( aRotina, { 'Packing List' , 'U_AKAPACK()' , 0, 6 } )

Return

//********************
User Function AKAPACK(cFilDef,cPedDef,lPreview)
    //********************
    Local cDirLocal := "c:\packing_list\"


    Default cFilDef := SC5->C5_FILIAL
    Default cPedDef := SC5->C5_NUM
    Default lPreview:= .t.

    Private cStartPath :=   AllTrim(GetSrvProfString("StartPath","\"))
    Private cImag001    :=  cStartPath+"akapack.png"
    Private oCrNew25N   :=  TFont():New('Courier new',,25,,.T.,,,,,.F.,.F.)
    Private oCrNew15N   :=  TFont():New('Courier new',,15,,.T.,,,,,.F.,.F.)
    Private oCrNew11N   :=  TFont():New('Courier new',,11,,.T.,,,,,.F.,.F.)
    Private oCrNew11    :=  TFont():New('Courier new',,11,,.F.,,,,,.F.,.F.)

    Private nLin := 0
    Private nTamLin := 10
    Private nBorda := 2

    Private oBrush1 := TBrush():New( ,OldLace)
    Private oBrush2 := TBrush():New( ,Cinza)

    Private lAdjustToLegacy := .F.
    Private lDisableSetup  := .T.

    Private cTRBPed   := ""
    Private nTotItem  := 0
    Private nTotM2    := 0
    Private nTotDesc  := 0
    Private nValFrete := 0
    Private cDescCP := ""
    Private oPrinter := Nil

    //cArq := "Pedido_"+ Alltrim(cNumPed)+".rel"
    cArq := "PL_"+ Alltrim(cPedDef)+".pdf"
    If lPreview
        oPrinter := FWMSPrinter():New(cArq, IMP_PDF, lAdjustToLegacy,   , lDisableSetup)
    Else
        oPrinter := FWMSPrinter():New(cArq, IMP_PDF, lAdjustToLegacy,   , lDisableSetup, .F., , , .T., .T., , .F.)
    EndIf
    oPrinter:SetResolution(72)
    oPrinter:SetPortrait()
    oPrinter:SetPaperSize(DMPAPER_A4)
    oPrinter:SetMargin(20,20,20,20)
    //oPrinter:cPathPDF := "c:\directory\"
    oPrinter:cPathPDF := cDirLocal
    //Verifica se existe o diretório, caso não existe irá tentar criar, caso negativo irá informar o usuário do problema
    If !ExistDir(cDirLocal)
        If MakeDir(cDirLocal) <> 0
            MsgAlert("O diretório não foi encontrado, contacte o departamento de TI! " + cValToChar( FError() ) )
        EndIf
    Else
        If File(cDirLocal+cArq)
            FErase(cDirLocal+cArq)
        EndIf
    EndIf

    BuscDados(cFilDef,cPedDef)

    If (cTRBPed)->(Eof())
        MsgAlert("Não a dados para ser exibidos")
        Return
    EndIf

    ImpLogo()
    Impboxemp()
    ImpBoxCli()
    ImpBoxNF()
    ImpCabDet()
    ImpItmDet()

    (cTRBPed)->(dbCloseArea())

    If lPreview
        oPrinter:Preview()
    Else
        oPrinter:Print()
    EndIf

Return

Static Function BuscDados(cFilDef,cPedDef)

    Local cQuery := ""


    Local cQuery := ""

    cQuery += " SELECT "
    cQuery += "   C5_FILIAL, C5_NUM, A1_NOME, A1_CGC, A1_RG, A1_INSCR, A1_END, A1_DDD, A1_BAIRRO, A1_MUN, A1_EST, A1_CONTATO, A1_TEL, C5_CONDPAG, "
    cQuery += "   A1_EMAIL, A1_CEP, C5_MENNOTA, C6_QTDVEN, C6_UM, C6_DESCRI, C6_UNSVEN, C6_SEGUM, C6_PRCVEN, C6_VALOR, C5_FRETE, C5_EMISSAO, "
    cQuery += "   C6_DESCONT, C6_VALDESC, F4_TEXTO, "
    cQuery += "   COALESCE(D2_EMISSAO, '') AS SD2_EMISSAO, COALESCE(D2_DOC, '') AS SD2_DOC, "
    cQuery += "   BE_XESPESS, BE_XLARGUR, BE_XEMBALA, BE_XM2CX, "
    cQuery += "   C6_LOCALIZ, C6_LOTECTL, C6_UNSVEN, "
    cQuery += "   C5_TRANSP, C5_PESOL, C5_PBRUTO, C5_VOLUME1, C5_ESPECI1, "
    cQuery += "   D2_LOCALIZ, D2_LOTECTL "
    cQuery += " FROM " + RetSQLName("SC5")
    cQuery += "   INNER JOIN " + RetSQLName("SC6") + " ON C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM "
    cQuery += "   INNER JOIN " + RetSQLName("SA1") + " ON C5_CLIENTE = A1_COD AND C5_LOJACLI = A1_LOJA "
    cQuery += "   INNER JOIN " + RetSQLName("SF4") + " ON F4_CODIGO = C6_TES AND F4_FILIAL = C6_FILIAL AND " + RetSQLName("SF4") + ".D_E_L_E_T_ = '' "
    cQuery += "   LEFT JOIN " + RetSQLName("SD2") + " ON C6_FILIAL = D2_FILIAL AND C6_NUM = D2_PEDIDO AND C6_ITEM = D2_ITEMPV AND " + RetSQLName("SD2") + ".D_E_L_E_T_ = '' "
    cQuery += "   LEFT JOIN " + RetSQLName("SBE") + " ON BE_FILIAL = C6_FILIAL AND BE_CODPRO = C6_PRODUTO AND BE_LOCALIZ = C6_LOCALIZ AND " + RetSQLName("SBE") + ".D_E_L_E_T_ = '' "
    cQuery += " WHERE " + RetSQLName("SC5") + ".D_E_L_E_T_ = '' "
    cQuery += "   AND " + RetSQLName("SC6") + ".D_E_L_E_T_ = '' "
    cQuery += "   AND C5_FILIAL = '" + cFilDef + "' "
    cQuery += "   AND C5_NUM = '" + cPedDef + "'"

Return cQuery

//***********************
Static Function ImpLogo()
    //***********************

    oPrinter:StartPage()
    oPrinter:SayBitMap(0010,0080,cImag001,440,100)

    nLin := 110
    oPrinter:SayAlign(nLin,0,"PACKING LIST",oCrNew25N,570,10, CLR_BLACK,2,2)

    nLin += nTamLin
    nLin += nTamLin
    nLin += nTamLin

    cSay := "PEDIDO: "+(cTRBPed)->C5_NUM
    oPrinter:SayAlign(nLin,20,cSay,oCrNew15N,570,10, CLR_BLACK,0,0)

    nLin += nTamLin
    nLin += nTamLin
    nLin += nTamLin
Return

Static Function Impboxemp()
    //*************************

    oPrinter:Box(nLin,10,nLin+50,570)
    oPrinter:SayAlign(nLin,20,"AKAFLOOR INDUSTRIAL LTDA",oCrNew11N,250,10, CLR_BLACK,0,2)
    oPrinter:SayAlign(nLin,420,"DATA: "+DTOC(stod((cTRBPed)->C5_EMISSAO)),oCrNew11N,250,10, CLR_BLACK,0,2)
    nLin += nTamLin
    oPrinter:SayAlign(nLin,20,"Rua Dr Kleber Vasques Filgueiras - 140 - Matozinhos",oCrNew11N,306,10, CLR_BLACK,0,2)
    nLin += nTamLin
    oPrinter:SayAlign(nLin,20,"Sao Joao del Rei - MG - CEP: 36305-030 - Tel: 32-3371-1000",oCrNew11N,348,10, CLR_BLACK,0,2)
    nLin += nTamLin
    oPrinter:SayAlign(nLin,20,"CNPJ:19.550.599-0001/65 IE: 625.229.818.00.59",oCrNew11N,270,10, CLR_BLACK,0,2)
    nLin += nTamLin
    nLin += nTamLin
    nLin += nTamLin

Return


Static Function ImpBoxCli()
    //*************************

    oPrinter:Box(nLin,10,nLin+60,570)
    oPrinter:SayAlign(nLin,20,(cTRBPed)->A1_NOME,oCrNew11N,470,10, CLR_BLACK,0,2)

    nLin += nTamLin

    If Len(AllTrim((cTRBPed)->A1_CGC)) == 11
        oPrinter:SayAlign(nLin,20,TRANSFORM((cTRBPed)->A1_CGC,"@R 999.999.999-99"),oCrNew11N,270,10, CLR_BLACK,0,2)
    Else
        oPrinter:SayAlign(nLin,20,TRANSFORM((cTRBPed)->A1_CGC,"@R 99.999.999.9999/99"),oCrNew11N,270,10, CLR_BLACK,0,2)
    EndIf

    nLin += nTamLin

    oPrinter:SayAlign(nLin,20,AllTrim((cTRBPed)->A1_END)+" - "+AllTrim((cTRBPed)->A1_BAIRRO),oCrNew11N,570,10, CLR_BLACK,0,2)

    nLin += nTamLin

    oPrinter:SayAlign(nLin,20,AllTrim((cTRBPed)->A1_MUN)+" - "+AllTrim((cTRBPed)->A1_EST),oCrNew11N,570,10, CLR_BLACK,0,2)

    nLin += nTamLin

    oPrinter:SayAlign(nLin,20,"("+ALLTRIM((cTRBPed)->A1_DDD)+")"+Alltrim((cTRBPed)->A1_TEL),oCrNew11N,270,10, CLR_BLACK,0,2)

    nLin += nTamLin
    nLin += nTamLin
    nLin += nTamLin

Return

Static Function ImpBoxNF()
    //*************************

    oPrinter:Box(nLin,10,nLin+40,570)
    oPrinter:SayAlign(nLin,20,"NATUREZA:",oCrNew11N,54,10, CLR_BLACK,0,2)//oPrinter:Say(0898,20,"Cliente: ",oArial20,,0)
    oPrinter:SayAlign(nLin,70,SUBSTR((cTRBPed)->F4_TEXTO,1,35),oCrNew11N,270,10, CLR_BLACK,0,2)//oPrinter:Say(0898,0301,"MADEL COMERCIO DE MADEIRAS E FERRAGENS LTDA",oArial20,,0)

    cNomTra := POSICIONE("SA4",1,XFILIAL("SA4")+(cTRBPed)->C5_TRANSP,"A4_NOME")
    oPrinter:SayAlign(nLin,280,"TRANSP.:",oCrNew11N,50,10, CLR_BLACK,0,2)//oPrinter:Say(0898,20,"Cliente: ",oArial20,,0)
    oPrinter:SayAlign(nLin,330,cNomTra,oCrNew11N,270,10, CLR_BLACK,0,2)//oPrinter:Say(0898,0301,"MADEL COMERCIO DE MADEIRAS E FERRAGENS LTDA",oArial20,,0)

    nLin += nTamLin

    cEmissao := (cTRBPed)->SD2_EMISSAO
    cDtEmis  := IIF(!Empty(cEmissao), RIGHT(cEmissao,2)+"/"+SUBSTR(cEmissao,5,2)+"/"+LEFT (cEmissao,4),"")
    cDoc     := (cTRBPed)->SD2_DOC

    oPrinter:SayAlign(nLin,20,"SAÍDA:",oCrNew11N,54,10, CLR_BLACK,0,2)
    oPrinter:SayAlign(nLin,70,cDtEmis,oCrNew11N,270,10, CLR_BLACK,0,2)

    oPrinter:SayAlign(nLin,280,"VOLUME:",oCrNew11N,40,10, CLR_BLACK,0,2)
    oPrinter:SayAlign(nLin,320,TRANSFORM((cTRBPed)->C5_VOLUME1,"@E 999,999")+" "+ALLTRIM((cTRBPed)->C5_ESPECI1),oCrNew11N,100,10, CLR_BLACK,0,2)

    nLin += nTamLin

    oPrinter:SayAlign(nLin,20,"NF-E:",oCrNew11N,54,10, CLR_BLACK,0,2)
    oPrinter:SayAlign(nLin,70,cDoc,oCrNew11N,270,10, CLR_BLACK,0,2)

    oPrinter:SayAlign(nLin,280,"PESO BRUTO:",oCrNew11N,60,10, CLR_BLACK,0,2)
    oPrinter:SayAlign(nLin,340,TRANSFORM((cTRBPed)->C5_PBRUTO,"@E 999,999.999"),oCrNew11N,100,10, CLR_BLACK,0,2)

    oPrinter:SayAlign(nLin,440,"PESO LÍQUI:",oCrNew11N,60,10, CLR_BLACK,0,2)
    oPrinter:SayAlign(nLin,500,TRANSFORM((cTRBPed)->C5_PESOL,"@E 999,999.999"),oCrNew11N,100,10, CLR_BLACK,0,2)

    nLin += nTamLin
    nLin += nTamLin
    nLin += nTamLin


Return

Static Function Impcabdet()
    //*************************

    nLin += nTamLin


    /*/{Protheus.doc}
    @author Gustavo Lima
    @since 17/04/2025
    PS: foi criado o campo lote para ser exibido no packlist,
    puxando os valor da tabela SC6 e campo C6_loteCTL
    /*/


    oPrinter:Fillrect( {nLin, 10, nLin+20, 73 }, oBrush1, "-2")
    oPrinter:SayAlign(nLin+2, -8,"LOTE",oCrNew11N,65,10, CLR_BLACK,2,2)

    oPrinter:Fillrect( {nLin, 74, nLin+20, 131 }, oBrush1, "-2")
    oPrinter:SayAlign(nLin+2,77,"PALLET",oCrNew11N,126,10, CLR_BLACK,0,2)

    oPrinter:Fillrect( {nLin, 132, nLin+20, 262 }, oBrush1, "-2")
    oPrinter:SayAlign(nLin+2,135,"DESCRIÇÃO",oCrNew11N,60,10, CLR_BLACK,0,2)

    oPrinter:Fillrect( {nLin, 263, nLin+20, 323 }, oBrush1, "-2")
    oPrinter:SayAlign(nLin+2,266,"ESPESSURA",oCrNew11N,50,10, CLR_BLACK,0,2)

    oPrinter:Fillrect( {nLin, 324, nLin+20, 384}, oBrush1, "-2")
    oPrinter:SayAlign(nLin+2,327,"LARGURA",oCrNew11N,50,10, CLR_BLACK,0,2)

    oPrinter:Fillrect( {nLin, 385, nLin+20, 445 }, oBrush1, "-2")
    oPrinter:SayAlign(nLin+2,388,"EMBALADO",oCrNew11N,50,10, CLR_BLACK,0,2)

    oPrinter:Fillrect( {nLin, 446, nLin+20, 506 }, oBrush1, "-2")
    oPrinter:SayAlign(nLin+2,449,"M2/KG",oCrNew11N,50,10, CLR_BLACK,2,2)

    oPrinter:Fillrect( {nLin, 507, nLin+20, 570 }, oBrush1, "-2")
    oPrinter:SayAlign(nLin+2,510,"QTD CAIXA",oCrNew11N,60,10, CLR_BLACK,2,2)

    nLin+= nTamLin
    nLin+= nTamLin
    nLin+= nBorda

return

Static Function ImpItmDet()
    //*************************

    Local cDescri := ""
    Local i       := 0
    Local nQtdLin := 0

    While (cTRBPed)->(!Eof())

        //Verifica quebra de página
        If nLin > 808
            ImpLogo() // 828 / 190
            ImpCabDet() // 190 / 222
        Endif

        cDescri := AllTrim((cTRBPed)->C6_DESCRI)

        nQtdLin := mlcount(cDescri,30)

        oPrinter:Fillrect( {nLin+2, 010, nLin+nTamLin+(nQtdLin*nTamLin), 073 }, oBrush2, "-2")
        oPrinter:Fillrect( {nLin+2, 074, nLin+nTamLin+(nQtdLin*nTamLin), 131 }, oBrush2, "-2")
        oPrinter:Fillrect( {nLin+2, 132, nLin+nTamLin+(nQtdLin*nTamLin), 262 }, oBrush2, "-2")
        oPrinter:Fillrect( {nLin+2, 263, nLin+nTamLin+(nQtdLin*nTamLin), 323 }, oBrush2, "-2")
        oPrinter:Fillrect( {nLin+2, 324, nLin+nTamLin+(nQtdLin*nTamLin), 384 }, oBrush2, "-2")
        oPrinter:Fillrect( {nLin+2, 385, nLin+nTamLin+(nQtdLin*nTamLin), 445 }, oBrush2, "-2")
        oPrinter:Fillrect( {nLin+2, 446, nLin+nTamLin+(nQtdLin*nTamLin), 506 }, oBrush2, "-2")
        oPrinter:Fillrect( {nLin+2, 507, nLin+nTamLin+(nQtdLin*nTamLin), 570 }, oBrush2, "-2")

        cDtEmbal  := IIF(AllTrim((cTRBPed)->C6_UM) == "M2", (RIGHT((cTRBPed)->BE_XEMBALA,2)+"/"+SUBSTR((cTRBPed)->BE_XEMBALA,5,2)+"/"+LEFT ((cTRBPed)->BE_XEMBALA,4)),"")
        nCx       := IIF(!Empty((cTRBPed)->C6_SEGUM), (cTRBPed)->C6_UNSVEN, "")
        cCxEsp    := IIF(AllTrim((cTRBPed)->C6_UM) == "M2", cValToChar((cTRBPed)->BE_XESPESS), "")
        cCxLarg   := IIF(AllTrim((cTRBPed)->C6_UM) == "M2", cValToChar((cTRBPed)->BE_XLARGUR), "")


        /*/{Protheus.doc}
           @author Otavio Belchior
           @since 30/05/2025
           PS: Tentativa de ajustar o packing list para pegar os campos de lote e local
        /*/

        // Função para buscar o LOTE com prioridade
        Static Function GetLoteFinal()
            Local cLote := ""

            If !Empty((cTRBPed)->C6_LOTECTL)
                cLote := (cTRBPed)->C6_LOTECTL
            ElseIf !Empty((cTRBPed)->D2_LOTECTL)
                cLote := (cTRBPed)->D2_LOTECTL
            ElseIf !Empty((cTRBPed)->BE_XLOTE)
                cLote := (cTRBPed)->BE_XLOTE
            EndIf

        Return cLote

        // Função para buscar LOCAL com prioridade
        Static Function GetLocalFinal()
            Local aCampos := {"C6_LOCALIZ", "D2_LOCALIZ"}
            Local cLocal := ""

            For Each cCampo In aCampos
                If !Empty((cTRBPed)->&cCampo)
                    cLocal := (cTRBPed)->&cCampo
                    Exit
                EndIf
            Next

        Return cLocal


        Local cLote := GetLoteFinal()
        Local cLocal := GetLocalFinal()

        oPrinter:SayAlign(nLin+2, 15, cLote, oCrNew11, 55, nQtdLin*nTamLin*2, CLR_BLACK, 0, 2)
        oPrinter:SayAlign(nLin+2, 77, cLocal, oCrNew11, 55, nQtdLin*nTamLin*2, CLR_BLACK, 0, 2)

        oPrinter:SayAlign(nLin+2,266,cCxEsp,oCrNew11,55,nQtdLin*nTamLin*2,CLR_BLACK,0,2)
        oPrinter:SayAlign(nLin+2,327,cCxLarg,oCrNew11,55,nQtdLin*nTamLin*2,CLR_BLACK,0,2)
        oPrinter:SayAlign(nLin+2,388,cDtEmbal,oCrNew11,55,nQtdLin*nTamLin*2,CLR_BLACK,0,2)
        oPrinter:SayAlign(nLin+2,449,cValToChar((cTRBPed)->C6_QTDVEN),oCrNew11,55,nQtdLin*nTamLin*2,CLR_BLACK,2,2)
        oPrinter:SayAlign(nLin+2,510,cValToChar(nCX),oCrNew11,55,nQtdLin*nTamLin*2,CLR_BLACK,2,2)


        For i := 1 to nQtdLin
            oPrinter:SayAlign(nLin+2,135,memoline(cDescri,25,i),oCrNew11,150,10, CLR_BLACK,0,2)
            nLin += nTamLin
        Next

        nLin += nTamLin
        nLin += 1

        (cTRBPed)->(dbSkip())

    EndDo

    nLin += nTamLin
    nLin += nTamLin

return


