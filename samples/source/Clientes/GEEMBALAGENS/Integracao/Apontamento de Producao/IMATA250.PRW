#Include 'Protheus.ch'
#include "tbiconn.ch"

User Function IMATA250()

	Local aVetor

	Local dData

	Local nOpc := 3 //-Opção de execução da rotina,
    Local aErroD3 := {}
    Local cErro as character

	lMsErroAuto := .F.

	aVetor := {}

	dData:=dDataBase

	aVetor := { {"D3_OP" ,cOp+"01001" ,NIL},;
		{"D3_COD" ,cProduto ,NIL},;
		{"D3_QUANT" ,nQuant ,NIL},; // {"D3_PARCTOT" , "P" ,NIL},;
		{"D3_TM" ,"010" ,NIL},;
		{"D3_QTMAIOR" , nQuant ,NIL}}

	MSExecAuto({|x, y| mata250(x, y)},aVetor, nOpc )

	If lMsErroAuto
		//CONOUT("Erro")
		//mostraerro()
        aErroD3 := GetAutoGRLog()// GetAutoGRLog()
		cErro := AllToChar(aErroD3)
	Else
		//CONOUT("Incluido com sucesso")
		CONOUT("Incluido com sucesso")
	Endif

return cErro
