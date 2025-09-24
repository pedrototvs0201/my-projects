#INCLUDE "TOTVS.CH"
#Include "PROTHEUS.CH"

/*/{Protheus.doc} User Function COPIXML
    (Função utilizada para transportar os XML dá máquina do usuário para a pasta \xml\IN dentro do RootPath do servidor)
    @type  Function
    @author André Almeida
    @since 01/09/2020
    /*/
    
User Function COPIXML()

    Processa( {|| U_copxml2() }, "Aguarde...", "Copiando Arquivos XML's para Servidor...",.F.)

Return

User Function copxml2()

    Local nAtual := 0

    cDirSrv  := 'C:\XMLS\'
    aDirAux  := Directory(cDirSrv+'*.XML')

    //Percorre os arquivos
    For nAtual := 1 To Len(aDirAux)

    //Pegando o nome do arquivo
    cNomArq := aDirAux[nAtual][1]
     
    //Copia o arquivo da maquina do usuario para o servidor
    CpyT2S( cDirSrv+cNomArq, "\importadorxml\inn" )

    //Apaga o arquivo copiado
    FERASE( cDirSrv+cNomArq )
    
    Next nAtual
    
Return 
