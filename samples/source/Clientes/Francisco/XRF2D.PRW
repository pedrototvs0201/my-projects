#INCLUDE "TOTVS.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} XRF2D
Consulta dados tributários F2D com base no D1_IDTRIB ou D2_IDTRIB

@param _cOper  - Operação: "E" (Entrada/SD1) ou "S" (Saída/SD2)
@param _cImp   - Código do imposto
@param _cTpRet - Tipo de retorno:
                "1" - F2D_TRIB (Código do tributo F2D)
                "2" - F2B_TRIB (Código do tributo F2B)
                "3" - F2D_BASE (Base de cálculo)
                "4" - F27_REDBAS (Redução da base)
                "5" - F2D_ALIQ (Alíquota)
                "6" - F2D_VALOR (Valor do tributo)
                "7" - CJ2_INCIDE (Código de incidência)
                "8" - CJ2_INCIDE_DESC (Descrição da incidência)
                "9" - CJ2_CST (Código de situação tributária)

@return String - Campo solicitado ou "" se não encontrado

@example
// Retorna o código do tributo F2D para uma entrada
_cTributo := XRF2D("E", "ICMS", "1")

// Retorna a redução da base para uma saída
_cRedBase := XRF2D("S", "ICMS", "4")

// Retorna a alíquota para uma entrada
_cAliq := XRF2D("E", "ICMS", "5")

@author [Nome do Autor]
@since [Data]
@version 1.0
/*/
//-------------------------------------------------------------------
User Function XRF2D(_cOper, _cImp, _cTpRet)
    Local _cIdTrib := ""
    Local _cResult := ""
    
    If _cOper == "E"
        _cIdTrib := SD1->D1_IDTRIB
    ElseIf _cOper == "S"
        _cIdTrib := SD2->D2_IDTRIB
    Else
        Return ""
    EndIf
 
    _cResult := ConsF2D(_cIdTrib, _cImp, _cTpRet)
     
Return _cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} ConsF2D
Função estática para consulta dos dados F2D

@param _cIdTrib - ID Tributário
@param _cImp    - Código do imposto
@param _cTpRet  - Tipo de retorno

@return Array com os dados da consulta

@author [Nome do Autor]
@since [Data]
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ConsF2D(_cIdTrib, _cImp, _cTpRet)
    Local _cQuery   := ""
    Local _cAlias   := GetNextAlias()
    Local _cResult  := ""
    
    _cQuery := "SELECT "
    _cQuery += "    F2D.F2D_TRIB, "
    _cQuery += "    F2B.F2B_TRIB, "
    _cQuery += "    F2D.F2D_BASE, "
    _cQuery += "    F27.F27_REDBAS, "
    _cQuery += "    F2D.F2D_ALIQ, "
    _cQuery += "    F2D.F2D_VALOR, "
    _cQuery += "    CJ2.CJ2_INCIDE, "
    _cQuery += "    CASE CJ2.CJ2_INCIDE "
    _cQuery += "        WHEN '1' THEN 'T' "
    _cQuery += "        WHEN '2' THEN 'I' "
    _cQuery += "        WHEN '3' THEN 'O' "
    _cQuery += "        WHEN '4' THEN 'TI' "
    _cQuery += "        WHEN '5' THEN 'TO' "
    _cQuery += "        WHEN '6' THEN 'IO' "
    _cQuery += "        WHEN '7' THEN 'TIO' "
    _cQuery += "        ELSE CJ2.CJ2_INCIDE "
    _cQuery += "    END AS CJ2_INCIDE_DESC, "
    _cQuery += "    CJ2.CJ2_CST "
    _cQuery += "FROM " + RetSqlName("F2D") + "  F2D (NOLOCK) "
    _cQuery += "INNER JOIN " + RetSqlName("F2B") + " F2B (NOLOCK) "
    _cQuery += "    ON  F2B.F2B_FILIAL = F2D.F2D_FILIAL "
    _cQuery += "    AND F2B.F2B_ID     = F2D.F2D_IDCAD "
    _cQuery += "    AND F2B.D_E_L_E_T_ = '' "
    _cQuery += "INNER JOIN " + RetSqlName("CJ2") + "  CJ2 (NOLOCK) "
    _cQuery += "    ON  CJ2.CJ2_FILIAL  = F2B.F2B_FILIAL "
    _cQuery += "    AND CJ2.CJ2_CODIGO  = F2B.F2B_CODESC "
    _cQuery += "    AND CJ2.CJ2_ALTERA  = '2' "
    _cQuery += "    AND CJ2.R_E_C_D_E_L_ = 0 "
    _cQuery += "INNER JOIN " + RetSqlName("F27") + "  F27 (NOLOCK) "
    _cQuery += "    ON   F27.F27_CODIGO = F2B.F2B_RBASE "
    _cQuery += "    AND F27.F27_ALTERA = '2' "
    _cQuery += "    AND F27.D_E_L_E_T_ = '' "
    _cQuery += "WHERE "
    _cQuery += "    F2D.F2D_IDREL  = '" + _cIdTrib + "' "
    _cQuery += "    AND F2D.D_E_L_E_T_ = '' "
    
    _cQuery := ChangeQuery(_cQuery)
    
    DbUseArea(.T., "TOPCONN", TcGenQry(,, _cQuery), _cAlias, .F., .T.)
    
    If (_cAlias)->(Eof())
        (_cAlias)->(DbCloseArea())
        Return ""
    EndIf
    
    Do Case
        Case _cTpRet == 1
            _cResult := (_cAlias)->F2D_TRIB
        Case _cTpRet == 2
            _cResult := (_cAlias)->F2B_TRIB
        Case _cTpRet == 3
            _cResult := (_cAlias)->F2D_BASE
        Case _cTpRet == 4
            _cResult := (_cAlias)->F27_REDBAS
        Case _cTpRet == 5
            _cResult := (_cAlias)->F2D_ALIQ
        Case _cTpRet == 6
            _cResult := (_cAlias)->F2D_VALOR
        Case _cTpRet == 7
            _cResult := (_cAlias)->CJ2_INCIDE
        Case _cTpRet == 8
            _cResult := (_cAlias)->CJ2_INCIDE_DESC
        Case _cTpRet == 9
            _cResult := (_cAlias)->CJ2_CST
        Otherwise
            _cResult := ""
    EndCase
    
    (_cAlias)->(DbCloseArea())
    
Return _cResult
