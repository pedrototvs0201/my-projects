#INCLUDE "TOTVS.CH"
#include 'RPTDEF.CH'
#include 'protheus.ch'
#INCLUDE "TBICONN.CH"
#DEFINE crlf chr(13) + chr(10)

//|-----------------------------------------------------------------------------|
//| Programa  | intsa1      | Autor(s)| Denilson Almeida    | Data | 30/04/2020 |
//|-----------------------------------------------------------------------------|
//| Descrição | Geração de arquivo .csv com a lista dos funcionários com redução|
//|-----------------------------------------------------------------------------|
//|                             Últimas Alterações                              |
//|-----------------------------------------------------------------------------|
//| DATA       | ANALISTA          | DETALHAMENTO                               |
//|------------|-------------------|--------------------------------------------|
//|            |                   |                                            |
//|-----------------------------------------------------------------------------|



User Function INTSA1L()

	Private cCaminho := ""
	Private mArquivo := ""
	private cCtt := ""
	private nCont := 0

	

	cCaminho := "/trimbox/out/"
	mArquivo := cCaminho+"clienteLoja.csv"

	ArqTXT := fCreate(marquivo)


	If select("TEMP") > 0
		TEMP->(dbCloseArea())
	Endif

	BeginSql alias "TEMP"

        select        
        A1_XTCLIEN,
        A1_COD,
		A1_END,
		A1_BAIRRO, 
        A1_EST,
		A1_COD_MUN,
		A1_CEP,
		A1_MUN,
		A1_CGC,
		A1_PESSOA,
		A1_INSCR,
		A1_LOJA       
        FROM %table:SA1% A1  		                                
		WHERE A1.A1_XINTTRI = "2"
		AND A1.%notDel%
		
	EndSql

	DbSelectArea("TEMP")
	DbGoTop()


	while TEMP->(!Eof())

		cLinha := ";"//id_InClientesFaquini
		cLinha += ";" //ErroNesteRegistro
		cLinha += cValtochar(val(TEMP->A1_XTCLIEN))+";" //OrdemGeracaoRegistro
		cLinha += ";"//Estado
		cLinha += ";"//DescEstado
		cLinha += ";"//datacriacao
		cLinha += ";"//substr(dtos(date()),1,4)+"-"+substr(dtos(date()),5,2)+"-"+substr(dtos(date()),7,2)+" "+time()+".000;"//DataProcessamentoRegistro
		cLinha += alltrim(TEMP->A1_XTCLIEN)+';'        //Codigo Cliente
		cLinha += alltrim(TEMP->A1_COD)+";"                   //Codigo ERP
		cLinha += alltrim(TEMP->A1_END)+";"       //Endereco
		cLinha += ALLTRIM(TEMP->A1_BAIRRO) + ";"//Bairro,
		cLinha += ALLTRIM(TEMP->A1_MUN) + ";"            //Municipio,
		cLinha += alltrim(TEMP->A1_EST) + ";"            // UF,
		cLinha += alltrim(TEMP->A1_CEP)+";"//CEP,
		cLinha += If(TEMP->A1_PESSOA = 'J','1','0') + ";"            //TipoCliente,
		cLinha += alltrim(TEMP->A1_CGC)+";"                  //CNPJ,
		cLinha += alltrim(TEMP->A1_INSCR)+";"//   IE,
		cLinha += alltrim(POSICIONE("SX5",1,XFILIAL("SX5")+"ZZ"+TEMP->A1_EST,"X5_DESCRI"))+alltrim(TEMP->A1_COD_MUN)// CodIbge

		TEMP->(DBSKIP())
		ncont++


		cLinha += chr(13) + chr(10)


		FWrite(ArqTXT,cLinha)

	EndDo


	FClose(ArqTxt)

	TEMP->(DbGoTop())

	While TEMP->(!Eof())

		DbSelectArea("SA1")
		DbSetOrder(1)
		If DbSeek(xFilial("SA1")+TEMP->A1_COD+TEMP->A1_LOJA,.T.)

			Reclock("SA1")
						
			Replace A1_XINTTRI with "1"

			MsUnLock()

		ENDif

		TEMP->(Dbskip())

	EndDo


Return
