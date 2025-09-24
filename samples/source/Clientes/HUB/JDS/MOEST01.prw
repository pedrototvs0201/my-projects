#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"    
#INCLUDE "protheus.ch"
#INCLUDE "totvs.ch"

/*/
�����������������������������������������������������������������������������
���Programa  � MOCEST01 � Autor � Elis�ngela Souza   � Data �  22/05/18   ���
���Ajustado  � Welington Junior                      � Data �  28/08/18   ���
�� Ajustado  � Bruno Bouzas/ Francisco Rezende       � Data �  01/10/19   ���
�������������������������������������������������������������������������͹��
���Descricao � Gatilho para gerar o sequencial do cadastro do produto.    ���
�������������������������������������������������������������������������͹��
���Uso       � Geral                                                      ���
�����������������������������������������������������������������������������
/*/

User Function MOEST01()

 

       // (4)Grupo + (4)|Sequencial

       Local _xCod         := ""

       Local _xGrupo       := M->B1_GRUPO

       Local a_AreaB1      := SB1->(GetArea())

       Local a_AreaBM      := SBM->(GetArea())

       //Local c_Alias       := GetNextAlias()

 

       If Len(RTRIM(M->B1_GRUPO)) <> 4

 

             MsgBox("Utilize o c�digo analitico, c�digo com 4 caracteres!")

             _xCod := "0000"

 

       Else

 

             cQry := " SELECT TOP 1 SUBSTRING(B1_COD,5,4) SEQ "

             cQry += " FROM " + RetSqlName("SB1")

             cQry += " WHERE B1_FILIAL = '" + xFilial("SB1") + "'"

             cQry += " AND B1_GRUPO = '" + _xGrupo + "'"

             cQry += " AND D_E_L_E_T_ <> '*' "

             cQry += " ORDER BY B1_COD DESC "

 

             TcQuery cQry New Alias "QRY"

 

             dbSelectArea("QRY")

             QRY->( dbGoTop() )

 

             // Se for final de arquivo

             If QRY->( Eof() )

                    _xCod := _xGrupo + "0001"

             Else

                    _xCod := _xGrupo + StrZero( ( Val( QRY->SEQ ) + 1 ), 4 )

             Endif

 

             QRY->( DbCloseArea() )

 

       Endif

 

       RestArea( a_AreaB1 )

       RestArea( a_AreaBM )

 

Return _xCod
