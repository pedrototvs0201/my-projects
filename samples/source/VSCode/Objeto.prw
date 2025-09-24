#include "msobject.ch"
#include "msobject.ch"
#include "totvs.framework.treports.integratedprovider.th"
   
namespace totvs.framework.smartiew
  
@totvsFrameworkTReportsIntegratedProvider(active=.T., team="Framework", name="Produtos com Imagens", country="ALL")
//-------------------------------------------------------------------
/*{Protheus.doc} imageBusinessObject
Classe para criação do Objeto de Negócio
  
@author Vanessa Ruama
@since 17/03/2025
@version 1.0
*/
//------------------------------------------------------------------- 
class imageBusinessObject from totvs.framework.treports.integratedprovider.IntegratedProvider
    data aFields as array
    data cLogo as character
    data cDefaultImg as character
 
    public method new() as object
    public method getData() as object
    public method getSchema() as object
endclass
   
//-------------------------------------------------------------------
/*{Protheus.doc} new
Método de instância da classe
  
@return object: self
  
@author Vanessa Ruama
@since 17/03/2025
@version 1.0
*/
//------------------------------------------------------------------- 
method new() class imageBusinessObject
_Super:new()
//Define a Área
self:appendArea("Framework")
  
//Define o nome do Objeto de Negócio
self:setDisplayName("Produtos com Imagens")
  
//Define a descrição do Objeto de Negócio
self:setDescription("Produtos com Imagens")
 
self:aFields := {"B1_FILIAL", "B1_COD", "B1_DESC", "B1_TIPO", "B1_BITMAP"}
 
self:cLogo := u_getImage(.T.)
self:cDefaultImg := u_getImage(.F., "produto_default.jpg") //Utilizado caso o produto não tenha imagem
 
return self
 
//-------------------------------------------------------------------
/*{Protheus.doc} getData
Retorna os dados do objeto de negócio
  
@param nPage, numérico, indica a página atual do relatório
@param oFilter, objeto, contém o filtro do TReports
  
@return object: self:oData
  
@author Vanessa Ruama
@since 17/03/2025
@version 1.0
*/
//------------------------------------------------------------------- 
method getData(nPage as numeric, oFilter) as object class imageBusinessObject
local cQuery as character
local cAlias as character
local nSkip as numeric
local nCount as numeric
local nX as numeric
local jItems as json
local aPDFields as array
local lUseParams as logical
local cDirExport as character
local cImage as character
local oImgRepo as object
local aFile as array
local oExec as object
    
nCount := 0
cQuery := "SELECT " + self:getSQLFields(,,,.T.) + "FROM " + RetSQLName("SB1") + " WHERE D_E_L_E_T_ = ' '"
lUseParams := .T.
cDirExport := "\spool\" //local onde a imagem será extraída
oImgRepo := FWBmpRep():New()
  
//Os filtros serão setados na interface do novo TReports
if oFilter:hasFilter()
    cQuery += " AND " + oFilter:getSQLExpression()
endif
  
jParams := oFilter:getParameters() //metodo para retorno do json dos parâmetros
u_setDefaultParams(@jParams)
//Faz a parametrização na query
cQuery += "AND B1_COD BETWEEN ? AND ?"
  
oExec := FwExecStatement():New(ChangeQuery(cQuery))
oExec:setString(1, jParams['01'][1])
oExec:setString(2, jParams['02'][1])
 
cAlias := oExec:OpenAlias()
    
if nPage == 1
    (cAlias)->(dbGoTop())
else
    //Encontra a quantidade de itens que irá pular de acordo com a página atual
    nSkip := ((nPage - 1) * self:getPageSize())   
    
    (cAlias)->(dbSkip(nSkip))
endif
    
//Verifica se precisa fazer o tratamento para LGPD
aPDFields := FwProtectedDataUtil():UsrAccessPDField(__cUserID, self:aFields)
lObfuscated := len( aPDFields ) != Len(self:aFields)
aAllFields := self:getStructFields()
  
while !(cAlias)->(Eof())
    jItems := JsonObject():new()
   
    for nX := 1 To Len(aAllFields)
        cId := aAllFields[nX]:getName()
        cRealName := aAllFields[nX]:getRealName()
        if lObfuscated .and. aScan(aPDFields, cRealName) == 0
            jItems[cId] := FwProtectedDataUtil():ValueAsteriskToAnonymize((cAlias)->&(cRealName))
        else
            if aAllFields[nX]:getType() == "date"
                jItems[cId] := totvs.framework.treports.date.stringToTimeStamp((cAlias)->&(cRealName))
            elseif cRealName == "B1_BITMAP"
                cImage := AllTrim((cAlias)->&(cRealName))
 
                //Usa o FWBmpRep e o Directory apenas se não souber a extensão dos arquivos, se souber é possível utilizar a RepExtract
                if !empty(cImage) .and. oImgRepo:Extract(cImage, cDirExport + cImage , .F.)
                    aFile := Directory(cDirExport + cImage + ".*")
 
                    if len(aFile) > 0
                        jItems[cId] := u_getImage(.F., cDirExport + aFile[1][1])
                    endif
 
                    //Opcional apagar ou não
                    FErase(cDirExport + aFile[1][1])
 
                    FwFreeArray(aFile)
                else
                    jItems[cId] := self:cDefaultImg
                endif
 
            elseif cRealName == "Logo"
                jItems[cId] := self:cLogo
            else
                jItems[cId] := (cAlias)->&(cRealName)
            endif
        endif
    next nX
 
    oImgRepo:CloseRepository()
 
   
    self:oData:appendData(jItems)
   
    (cAlias)->(DBSkip())
    nCount++
    
    //Sai do loop quando chegar no tamanho de itens da página
    if nCount == self:getPageSize()
      exit
    endif
enddo
    
//Se não for o último registro indica que terá próxima página
self:setHasNext(!(cAlias)->(Eof()))
    
(cAlias)->(DBCloseArea())
 
FwFreeObj(oImgRepo)
FwFreeObj(oExec)
FwFreeObj(jItems)
FwFreeObj(jParams)
FwFreeArray(aPDFields)
FwFreeArray(aAllFields)
 
return self:oData
   
//-------------------------------------------------------------------
/*{Protheus.doc} getSchema
Retorna a estrutura dos campos
  
@return object: self:oSchema
  
@author Vanessa Ruama
@since 02/03/2023
@version 1.0
*/
//-------------------------------------------------------------------
method getSchema() as object class imageBusinessObject
  
self:aliasToSchema("SB1", self:aFields)
 
//Adiciona o logo da empresa
self:addProperty("Logo", "Logo", "string", "Logo da empresa","Logo")
 
//Adiciona os parâmetros
self:addParameter("01"  , "Produto de", "string", .F.,,,.T.,"SB1",,,,{"      "})
self:addParameter("02"  , "Produto até", "string", .F.,,,.T.,"SB1",,,,{"ZZZZZZ"})
 
return self:oSchema
 
//-------------------------------------------------------------------
/*{Protheus.doc} setDefaultParams
Seta os valores padrões do parâmetros caso estejam vazios
   
@param jParam json: Parâmetros recebidos
  
@author Vanessa Ruama
@since 17/03/2025
@version 1.0
*/
//-------------------------------------------------------------------
user function setDefaultParams(jParams)
if empty(jParams['01'][1])
    jParams['01'][1] := "      "
elseif empty(jParams['02'][1])
    jParams['02'][1] := "ZZZZZZ"
endif
return
 
//-------------------------------------------------------------------
/*{Protheus.doc} getImage
Retorna a imagem em base64
   
@param lIsLogo logical: Indica se a imagem a ser retornada é o logo
@param cImage character: Nome da imagem que será convertida
 
@return cImageBase64, character: Imagem convertida em base64
  
@author Vanessa Ruama
@since 17/03/2025
@version 1.0
*/
//-------------------------------------------------------------------
user function getImage(lIsLogo as logical, cImage as character)
local cImageBase64 as character
local lFile as logical
local oFile as object
 
cImageBase64 := ""
 
if lIsLogo
    cImage := FWGetImgLogo()
 
    if empty(cImage)
        cImage := "logo-totvs-h-brown.png"
    endif
endif
 
lFile := File(cImage)
 
if !lFile
    Resource2File(cImage, cImage)
    lFile := File(cImage)
endif
 
if lFile
    oFile := FWFileReader():new(cImage)
    oFile:open()
    cImageBase64 := Encode64(oFile:FullRead())
    oFile:close()
    FWFreeVar(@oFile)
endif
 
return cImageBase64
