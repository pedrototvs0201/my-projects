#Include "TOTVS.CH"    
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#include "topconn.ch"      

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºPrograma  ³MT103FIM    ºAutor  ³Elisângela Souza  º Data ³  19/06/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Ponto de Entrada no Documento de Entrada para inclusao de º±±
±±º          ³  Informacoes da NF-e de Importacao                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
                     
User Function MT103FIM()

Local nOpcao    := PARAMIXB[1]   // Opção Escolhida pelo usuario no aRotina 
Local nConfirma := PARAMIXB[2]   // Se o usuario confirmou a operação de gravação da NFE

If nOpcao = 3 .And. nConfirma = 1 .And. SA2->A2_EST = 'EX'
//If SA2->A2_EST = 'EX'
	
	aAREA := GETAREA()
	Static oDlg
	Static oButton1
	Static oFolder1
	Static oGet1
	Static oGet2
	Static oGet3
	Static oGet4
	Static oGet5
	Static oGet6
	Static oGet7
	Static oGet8
	Static oGet9
	Static oGet10
	Static oGet11
	Static oGet12
	Static oGet13
	Static oGet14
	Static oGet15
	Static cGet5 	:= SA2->A2_COD
	Static cGet9	:= SA2->A2_COD
	Static cGet10	:= SA2->A2_LOJA
	Static cGet11	:= SA2->A2_LOJA
	Static cGet1 	:= Space(10)
	Static dGet2	:= Date()
	Static cGet3 	:= Space(256)
	Static dGet4 	:= Date()
	Static cGet6 	:= Space(10)
	Static cGet7	:= Space(10)
	Static cGet8	:= Space(10)
	Static nGet7 	:= 0
	Static nGet8 	:= 0
	Static nGet9 	:= 0
	Static nGet10 	:= 0
	Static nGet11	:= 0
	Static aItems1	:= {"0=Declaração de Importação","1=Declaração Simplificada de Importação"} 
	Static aItems2	:= {"0=Executado no País","1=Executado no Exterior, cujo resultado se verifique no País"}  
	Static aItems3	:= {"1=Marítima","2=Fluvial","3=Lacustre","4=Aérea","5=Postal","6=Ferroviária","7=Rodoviária","8=Conduto","9=Meios próprios",;
	                    "10=Entrada/Saída Ficta","11=Courier","12=Handcarry"}
	Static aItems4	:= {"1=Importacao por conta propria","2=Importacao por conta e ordem","3=Importacao por encomenda"}
	Static cItem1	:= Space(1)
	Static cItem2	:= Space(1)
	Static cItem3	:= Space(2)
	Static cItem4	:= Space(1)
	Static cCombo1
	Static cCombo2
	Static cCombo3
	Static cCombo4
	Static oListBox1
	Static cListBox1 :="BA"	
	Static oMultiGet1
	Static cMultiGet1 := ""
	Static oSay1
	Static oSay2
	Static oSay3
	Static oSay4
	Static oSay5
	Static oSay6
	Static oSay7
	Static oSay8
	Static oSay9
	Static oSay10
	Static oSay11
	Static oSay12
	Static oSay13
	Static oSay14
	Static oSay15
	Static oSay16
	Static oSay17
//	Static oTimer1
	
	Define MsDialog oDlg Title Oemtoansi("NF-e Importação") From 000, 000  To 470, 600 Pixel

	@ 011, 001 FOLDER oFolder1 Size 320, 240 Of oDlg ITEMS "D.I.","Impostos","Mensagens"  Pixel

	@ 007, 006 Say   oSay1 PROMPT "D.I.:"     Size 014, 007 OF oFolder1:aDialogs[1] Pixel
	@ 006, 050 MsGet oGet1 Var cGet1 Size 060, 010 OF oFolder1:aDialogs[1] Valid !Empty(Alltrim(cGet1)) Pixel
	@ 007, 120 Say   oSay2 PROMPT "Dt. D.I.:" Size 025, 007 OF oFolder1:aDialogs[1] Pixel
	@ 006, 160 MsGet oGet2 Var dGet2 Size 060, 010 OF oFolder1:aDialogs[1] Valid !Empty(dGet2) Pixel
	
	@ 024, 006 Say      oSay3 PROMPT "Local Desemb:" Size 039, 007 OF oFolder1:aDialogs[1] Pixel
	@ 023, 050 MSGET    oGet3 Var cGet3 Size 141, 010 OF oFolder1:aDialogs[1] Valid !Empty(Alltrim(cGet3)) Pixel
	@ 024, 200 Say      oSay4 PROMPT "UF" Size 010, 007 OF oFolder1:aDialogs[1] Pixel
	@ 023, 215 COMBOBOX oListBox1 Var cListBox1 ITEMS {"AC","AL","AM","AP","BA","CE","DF","ES","GO","MA","MG","MS","MT","PA","PB","PE","PI","PR","RJ","RN","RO","RR","RS","SC","SE","SP","TO","EX"} SIZE 032, 500 OF oFolder1:aDialogs[1] PIXEL
	
	@ 041, 006 Say   oSay5 PROMPT "Dt. Desemb:" Size 039, 007 OF oFolder1:aDialogs[1] Pixel
	@ 040, 050 MSGET oGet4 Var dGet4 Size 060, 010 OF oFolder1:aDialogs[1] Valid !Empty(dGet4) Pixel
	@ 041, 120 Say   oSay6 PROMPT "Exportador:" Size 027, 007 OF oFolder1:aDialogs[1] Pixel
	@ 040, 160 MSGET oGet5 Var cGet5 Size 060, 010 OF oFolder1:aDialogs[1] F3 "SA2" Valid !Empty(cGet5) Pixel
	@ 040, 220 MSGET oGet14 Var cGet10 Size 030, 010 OF oFolder1:aDialogs[1] Valid !Empty(cGet10) Pixel

	@ 058, 006 Say oSay17 PROMPT "Fabricante:" Size 025, 007 OF oFolder1:aDialogs[1] Pixel
	@ 057, 050 MSGET oGet13 VAR cGet9 Size 060, 010 OF oFolder1:aDialogs[1] F3 "SA2" Valid !Empty(cGet9) Pixel
	@ 057, 110 MSGET oGet15 Var cGet11 Size 030, 010 OF oFolder1:aDialogs[1] Valid !Empty(cGet11) Pixel
 /*especifico itf
	@ 075, 006 Say oSay15 PROMPT "ABS:" Size 025, 007 OF oFolder1:aDialogs[1] Pixel
	@ 074, 050 MSGET oGet11 Var cGet7 Size 060, 010 OF oFolder1:aDialogs[1]  Valid !Empty(Alltrim(cGet7)) Pixel
	@ 075, 120 Say oSay16 PROMPT "ITF:" Size 027, 007 OF oFolder1:aDialogs[1] Pixel
	@ 074, 160 MSGET oGet12 Var cGet8 Size 060, 010 OF oFolder1:aDialogs[1]  Valid !Empty(Alltrim(cGet8)) Pixel
*/
	cCombo1 := aItems1[1]
    oCombo1 := TComboBox():New(093,006,{|cItem1|if(PCount()>0,cCombo1:=cItem1,cCombo1)},aItems1,160,015,oFolder1:aDialogs[1],,,,,,.T.,,,,,,,,,'cCombo1',"Tp.Doc.Imp",1)

	cCombo2 := aItems2[1]
    oCombo2 := TComboBox():New(121,006,{|cItem2|if(PCount()>0,cCombo2:=cItem2,cCombo2)},aItems2,160,015,oFolder1:aDialogs[1],,,,,,.T.,,,,,,,,,'cCombo2',"Local Serv",1)

	cCombo3 := aItems3[1]
    oCombo3 := TComboBox():New(149,006,{|cItem3|if(PCount()>0,cCombo3:=cItem3,cCombo3)},aItems3,160,015,oFolder1:aDialogs[1],,,,,,.T.,,,,,,,,,'cCombo3',"Via Transp",1)

	cCombo4 := aItems4[1]
    oCombo4 := TComboBox():New(177,006,{|cItem4|if(PCount()>0,cCombo4:=cItem4,cCombo4)},aItems4,160,015,oFolder1:aDialogs[1],,,,,,.T.,,,,,,,,,'cCombo4',"Forma Import",1)

	@ 006, 006 Say oSay9 PROMPT "Siscomex:" SIZE 025, 007 OF oFolder1:aDialogs[2] Pixel
	@ 005, 050 MSGET oGet8 Var nGet8 SIZE 060, 010 OF oFolder1:aDialogs[2] Picture "@E 999,999,999.99" Pixel
	@ 006, 120 SAY oSay10 PROMPT "Armazenagem:" SIZE 036, 007 OF oFolder1:aDialogs[2] Pixel
	@ 005, 160 MSGET oGet9 VAR nGet9 SIZE 060, 010 OF oFolder1:aDialogs[2] Picture "@E 999,999,999.99" Pixel
	@ 021, 006 SAY oSay8 PROMPT "Imp. Import.:" SIZE 034, 007 OF oFolder1:aDialogs[2] Pixel
	@ 020, 050 MSGET oGet7 VAR nGet7 SIZE 060, 010 OF oFolder1:aDialogs[2] Picture "@E 999,999,999.99"  Pixel
	@ 036, 006 SAY oSay13 PROMPT "Dolar:" SIZE 025, 007 OF oFolder1:aDialogs[2] Pixel
	@ 035, 050 MSGET oGet10 VAR nGet10 SIZE 060, 010 OF oFolder1:aDialogs[2] Picture "@E 999.9999" Pixel
	@ 036, 120 SAY oSay14 PROMPT "Euro:" SIZE 025, 007 OF oFolder1:aDialogs[2] Pixel
	@ 035, 160 MSGET oGet11 VAR nGet11 SIZE 060, 010 OF oFolder1:aDialogs[2] Picture "@E 999.9999" Pixel
/*especifico itf
	@ 051, 006 Say oSay7 PROMPT "Container:" Size 025, 007 OF oFolder1:aDialogs[2] Pixel
	@ 050, 050 MSGET oGet6 VAR cGet6 Size 060, 010 OF oFolder1:aDialogs[2] Pixel
*/
	@ 005, 003 GET oMultiGet1 VAR cMultiGet1 OF oFolder1:aDialogs[3] MULTILINE Size 232, 170 Pixel
 	@ 180, 006 SAY oSay11 PROMPT "Dica: Para quebrar Linhas, insira o caractere # ao final da linha." SIZE 229, 007 OF oFolder1:aDialogs[3] Pixel
	@ 210, 210 BUTTON oButton1 PROMPT "Gravar" SIZE 037, 012 OF oDlg Action Gravar() Pixel
	//DEFINE TIMER oTimer1 INTERVAL 0 OF oDlg
	@ 000, 000 SAY oSay12 PROMPT "                                                       Nota Fiscal Eletrônica de Importação" Size 250, 007 OF oDlg Pixel
      
	Activate MsDialog oDlg Centered
Return

Endif

//*********************************************************************************************

Static Function Gravar()

Local cString := ""
/*especifico itf
If !Empty(cGet7)
	cString += " ABS: " + cGet7
Endif

If !Empty(cGet8)
	cString += " ITF: " + cGet8
Endif

If !Empty(cGet6)
	cString += " Container: " + cGet6
Endif
*/

If nGet8 > 0
	cString += " Sisx: " + AllTrim(Str(nGet8,14,2))
Endif

If nGet9 > 0
	cString += " Armaz.: " + AllTrim(Str(nGet9,14,2))
Endif

If nGet7 > 0
	cString += " II: " + AllTrim(Str(nGet7,14,2))
Endif

If nGet10 > 0
	cString += " Tx Dolar: " + AllTrim(Str(nGet10,7,4))
Endif

If nGet11 > 0
	cString += " Tx Euro: " + AllTrim(Str(nGet11,7,4))
Endif

_xPis  := 0
_XCof  := 0
                                    
DbSelectArea("SD1")
SD1->( DbSetOrder(1) )                    
SD1->( DbSeek(SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,.T.))
While SD1->( !Eof() ) .And. SD1->D1_FILIAL = SF1->F1_FILIAL  .And. SD1->D1_DOC  = SF1->F1_DOC .And. SD1->D1_SERIE = SF1->F1_SERIE .And.;
                           SD1->D1_FORNECE = SF1->F1_FORNECE .And. SD1->D1_LOJA = SF1->F1_LOJA
	DbSelectArea("CD5")
	RecLock("CD5",.T.)
		CD5->CD5_FILIAL := xFilial("CD5")
		CD5->CD5_DOC 	:= SF1->F1_DOC
		CD5->CD5_SERIE	:= SF1->F1_SERIE
		CD5->CD5_SDOC	:= SF1->F1_SERIE
		CD5->CD5_ESPEC 	:= SF1->F1_ESPECIE
		CD5->CD5_FORNEC	:= SF1->F1_FORNECE
		CD5->CD5_LOJA 	:= SF1->F1_LOJA
		CD5->CD5_ITEM	:= SD1->D1_ITEM
		CD5->CD5_TPIMP 	:= cCombo1
		CD5->CD5_DOCIMP	:= cGet1
		CD5->CD5_LOCAL	:= cCombo2
		CD5->CD5_LOCDES	:= Upper(Alltrim(cGet3))
 		CD5->CD5_UFDES	:= cListBox1
		CD5->CD5_DTDES	:= dGet4
		CD5->CD5_CODEXP	:= cGet5
		CD5->CD5_LOJEXP	:= cGet10
		CD5->CD5_NDI	:= cGet1
		CD5->CD5_DTDI	:= dGet2
		//criar os dois campos abaixo
		CD5->CD5_NADIC	:= SD1->D1_FSADIC //C - 3 -@!
		CD5->CD5_SQADIC	:= SD1->D1_FSSADI //C - 3 -999
		//FIM
		CD5->CD5_CODFAB	:= cGet9
		CD5->CD5_LOJFAB	:= cGet11
		CD5->CD5_VTRANS := cCombo3
		CD5->CD5_INTERM	:= cCombo4
		CD5->CD5_BSPIS  := SD1->D1_BASIMP6
		CD5->CD5_ALPIS  := SD1->D1_ALQIMP6
		CD5->CD5_VLPIS  := SD1->D1_VALIMP6
		CD5->CD5_BSCOF  := SD1->D1_BASIMP5
		CD5->CD5_ALCOF  := SD1->D1_ALQIMP5
		CD5->CD5_VLCOF	:= SD1->D1_VALIMP5
		CD5->CD5_CNPJAE	:= SM0->M0_CGC
		/*especifico itf
		CD5->CD5_ITABS	:= SF1->F1_ITFABS
		CD5->CD5_ITNITF	:= SF1->F1_ITFNITF
        */

/*		CD5->CD5_ACDRAW
		CD5->CD5_BCIMP
		CD5->CD5_VLRII	:= 
		CD5->CD5_VAFRMM   */
	MsUnLock()
                     
	_xPis  += SD1->D1_VALIMP6
	_xCof  += SD1->D1_VALIMP5

	SD1->( DbSkip() )
Enddo

If _xPis > 0
	cString += " PIS: " + AllTrim(Str(_xPis,14,2))
Endif

If _xCof > 0
	cString += " COFINS: " + AllTrim(Str(_xCof,14,2))
Endif

cString += " " + cMultiGet1


DbSelectArea("SF1")
RecLock("SF1",.F.)
	Replace SF1->F1_FSMEMO  With AllTrim(cString) //criar campo memo - Obs NFe
MsUnLock()

/*especifico itf
c_UpdTit := " UPDATE " + RetSqlName("SE2") + " "
c_UpdTit += " SET E2_ITFNITF   = '" + AllTrim(cGet8) + "' "
c_UpdTit += " FROM " + RetSqlName("SE2") + " SE2 "
c_UpdTit += " WHERE SE2.D_E_L_E_T_ <> '*' "
c_UpdTit += " AND E2_NUM     = '" + SF1->F1_DOC     + "' "
c_UpdTit += " AND E2_PREFIXO = '" + SF1->F1_SERIE   + "' "
c_UpdTit += " AND E2_FORNECE = '" + SF1->F1_FORNECE + "' "
c_UpdTit += " AND E2_LOJA    = '" + SF1->F1_LOJA    + "' " 
n_RetSQL := TCSQLExec(c_UpdTit)

If n_RetSQL <> 0
	AVISO(SM0->M0_NOMECOM,'Falha na Atualização ('+STR(n_RetSQL,4)+') : '+TcSqlError(),{"Ok"},3,"Atenção")
Endif
*/	
Close(oDlg)

Return()

/*
If Empty(cGet1) .Or. Empty(cGet3) .Or. Empty(cListBox1)

Endif
  */
