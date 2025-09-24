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


User Function OLDINTSA1()

	Private cCaminho := ""
	Private mArquivo := ""
	private cCtt := ""
	private nCont := 0

    
	cCaminho := "/trimbox/out/"
	mArquivo := cCaminho+"cliente.csv"

	ArqTXT := fCreate(marquivo)
	

	If select("TEMP") > 0
		TEMP->(dbCloseArea())
	Endif

	BeginSql alias "TEMP"

        select
        A1_NREDUZ,
        A1_XTCLIEN,
        A1_COD,
        A1_XTOTMAX,
        A1_XTOTMIN,
        A1_XPRIORI,
        A1_NOME,
        A1_XLAUDO ,
        A1_XEMLAUD
        FROM %table:SA1% A1  		                                
		WHERE A1.A1_XINTTRI = "2"
		AND A1.%notDel%
		
	EndSql

	DbSelectArea("TEMP")
	DbGoTop()

	cLinha := ""

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
			cLinha += alltrim(TEMP->A1_NREDUZ)+";"       //cliente
            cLinha += ALLTRIM(transform(TEMP->A1_XTOTMAX,"@E 999")) + ";"//tolerancia max
			cLinha += ALLTRIM(transform(TEMP->A1_XTOTMIN,"@E 999")) + ";"            //tolerancia min
			cLinha += alltrim(TEMP->A1_XPRIORI) + ";"            //Preferencial
			cLinha += "0;"//cliente_fornecedor
            cLinha += alltrim(substr(TEMP->A1_NOME,1,99)) + ";"            //Razao social
			cLinha += alltrim(TEMP->A1_XLAUDO)+";"                  //laudo
			cLinha += alltrim(substr(TEMP->A1_XEMLAUD,1,50))//email laudo

			TEMP->(DBSKIP())
			ncont++
		

		cLinha += chr(13) + chr(10)


		FWrite(ArqTXT,cLinha)
        
	EndDo


	FClose(ArqTxt)


Return

