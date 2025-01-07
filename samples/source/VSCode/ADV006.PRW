#INCLUDE "Protheus.ch"



 /*/{Protheus.doc} ADV006
    Relatório de Ligas com norma e materiais
    @type  Function
    @author Pedro Henrique Eustaquio
      @version 1.0
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
user Function ADV006()

//variaveis
public oReport
public  cPerg   :="GRUPO01   " //filtro de perguntas e parametros


Pergunte(cPerg, .T.)// tela que abre para perguntar sobre os filtros, se for .F. nao abrirá
oReport:=Estrutura(cPerg)// Ele é responsavel por receber a estrutura do relatório, iremos criar uma function logo abaixo
oReport:PrintDialog()
   
Return 

Static Function Estrutura(cPerg) // function de estrutura (recebendo as perguntas)

Local oReport // recebera a variavel
Local oSecao1liga // cabeçalho do relatorio
Local oSecao2Produto // dados de materiais da liga
Local cTitulo := 'Ligas e Estrutura' // titulo do relatorio

oReport := TReport():New('ADV006',cTitulo, cPerg, {|oReport| PrintReport(oReport)})
// função com 4 campos:
// nome da função, função com titulo do relatorio, as perguntas, e a função que organizará os dados

oReport:SetLandscape()// modo paisagem no relatório, se quiser retrato é só nao colocar
//SEÇÃO COM INFORMAÇÕES DO CADASTRO DA LIGA------------------------------------------------------


oSecao1liga := TRSection():New(oReport, 'Liga')  // pegando informações da tabela pai, Liga

TRCell(): New(oSecao1liga, 'ZZA_COD','' , 'Cod. da Liga:','',TamSX3('ZZA_COD')[1]) // Receber dados e suas colunas o padrão é:

// Variavel local, nome do campo não do SQL mas renomeado, tabela, cabeçalho , picture do campo,tamanho do campo 
TRCell(): New(oSecao1liga, 'ZZA_DESC', , 'Descrição da Liga:','',TamSX3('ZZA_DESC')[1])
TRCell(): New(oSecao1liga, 'ZZA_DESCNR', , 'Descrição da Norma:','',TamSX3('ZZA_DESCNR')[1])

//SEÇÃO COM INFORMAÇÕES DO CADASTRO DA MATERIA PRIMA DA LIGA------------------------------------------------------
oSecao2Produto := TRSection(): New(oReport, 'Produtos')  // pegando informações da tabela filho, produtos da liga

TRCell(): New(oSecao2Produto, 'ZZC_ITEM', , 'Item:','',TamSX3('ZZC_ITEM')[1])
TRCell(): New(oSecao2Produto, 'ZZC_PROD', , 'Cod. do Produto:','',TamSX3('ZZC_PROD')[1]) // Receber dados e suas colunas o padrão é:
// Variavel local, nome do campo não do SQL mas renomeado, tabela, cabeçalho , picture do campo,tamanho do campo 
TRCell(): New(oSecao2Produto, 'ZZC_DESCPR', , 'Descrição do Produto:','',TamSX3('ZZC_DESCPR')[1])
TRCell(): New(oSecao2Produto, 'ZZC_UM', , 'UM','',TamSX3('ZZC_UM')[1])
TRCell(): New(oSecao2Produto, 'ZZC_QUANT', , 'Quant:','',TamSX3('ZZC_QUANT')[1])

return oReport


Static Function PrintReport(oReport)

Local oSecao1liga   := oReport:Section(1) // criando a seção da tabela pai 
Local oSecao2Produto:= oReport:Section(2) // criando a seção da tabela filho 

Local cAliasLg      := GetNextAlias() // variaveis que vão receber as consultas SQL, é 1 alias para cada seção
Local cAliasPL      := GetNextAlias() // variaveis que vão receber as consultas SQL , é 1 alias para cada seção

Local numeroRegs         := 0 // responsavel por contar os registros do relatório

BeginSql Alias cAliasLg  //Criar a Query SQL

select ZZA_COD, 
       ZZA_DESC,
       ZZA_DESCNR 
from %Table:ZZA% AS ZZA 
WHERE ZZA.%NotDel% // para poder filtrar os que não foram excluidos
AND A1_FILIAL=%xFilial:ZZA% // para pegar de qualquer filial
AND ZZA_COD BETWHEEN %Exp: MV_PAR01% AND  %Exp: MV_PAR02% // coloquei as variaveis para receber os parametros de filtros

 EndSql // encerro a consulta SQL

Count To numeroRegs // conto quantos registros para que caso tenha registro, entrar na função de  imprimir o relatório

If numeroRegs>0  // se for maior que zero gerar o relatório
(cAliasLg)->(DbGoTop())
while (cAliasLg)->(!Eof())// estamos fazendo um while para que pare somente ao final dos registros com a formula (!Eof)

oSecao1liga:init() // iniciando a seção com o init

oSecao1liga:Cell('ZZA_COD'):SetValue( Alltrim ((cAliasLg)->ZZA_COD)) 
// em ZZA_COD deve ser o
//mesmo nome que informamos em TRCell linha 44, 
//SetValue é referente que ele recebera esse valor, 
//Alltrim ele remove os espaços vazios tanto a direita quanto a esquerda
//cAlias é referente a function que consultei o SQL
// ZZA_COD é o nome do campo dentro de begin sql

oSecao1liga:Cell('ZZA_DESC'):SetValue( Alltrim ((cAliasLg)->ZZA_DESC)) 
oSecao1liga:Cell('ZZA_DESCNR'):SetValue( Alltrim ((cAliasLg)->ZZA_DESCNR)) 

oSecao1liga:PrintLine() // Vai imprimir o retorno da seção da liga 
oSecao1liga:ThinLine()// vai manter os dados impressos todos em 1 linha

BeginSql Alias cAliasPL  //Criar a Query SQL

SELECT ZZC_ITEM,
       ZZC_PROD,
       ZZC_QUANT,
       ZZC_UM, 
       ZZC_DESCPR 
       FROM %Table:ZZC% AS ZZC
WHERE ZZC.%NotDel% 
and ZZC_FILIAL=%xFilial:ZZC%
AND ZZC_COD = %Exp:(cAliasLg)->ZZA_DESC% // aqui estou trazendo um filtro diferente, somente dos materiais do cabeçalho, diferente de todo o filtro

 EndSql // encerro a consulta SQL
numeroRegs:=0

Count To numeroRegs // conto quantos registros para que caso tenha registro, entrar na função de  imprimir o relatório

If numeroRegs>0  // se for maior que zero gerar o relatório
(cAliasPL)->(DbGoTop())
while (cAliasPL)->(!Eof())// estamos fazendo um while para que pare somente ao final dos registros com a formula (!Eof)

oSecao2Produto:init() // iniciando a seção com o init

oSecao2Produto:Cell('ZZC_ITEM'):SetValue( Alltrim ((cAliasPL)->ZZC_ITEM)) 
oSecao2Produto:Cell('ZZC_PROD'):SetValue( Alltrim ((cAliasPL)->ZZC_PROD)) 
// em ZZA_COD deve ser o
//mesmo nome que informamos em TRCell linha 44, 
//SetValue é referente que ele recebera esse valor, 
//Alltrim ele remove os espaços vazios tanto a direita quanto a esquerda
//cAlias é referente a function que consultei o SQL
// ZZA_COD é o nome do campo dentro de begin sql

oSecao2Produto:Cell('ZZC_QUANT'):SetValue(  (cAliasPL)->ZZC_QUANT) // Para campos de Quantidade e valores não usa o alltrim
oSecao2Produto:Cell('ZZC_UM'):SetValue( Alltrim ((cAliasPL)->ZZC_UM)) 
oSecao2Produto:Cell('ZZC_DESCPR'):SetValue(  (cAliasPL)->ZZC_DESCPR) // Para campos de Quantidade e valores não usa o alltrim

oSecao2Produto:PrintLine() // Vai imprimir o retorno da seção da liga 
(cAliasPL)->(DbSkip())
 
endDo 

oSecao2Produto:Finish()//encerrando a seção de produto
oReport:SkipLine(1)//Salta 1 linha do final da ultima linha
endIf
oSecao1liga:Finish() // enderrando a seção da liga
oReport:SkipLine(2)
endDo
endIf(cAliasLg)->(DbCloseArea())







Return oReport





