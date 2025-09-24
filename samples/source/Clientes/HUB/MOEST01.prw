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
���Descricao � Gatilho para gerar o sequencial do cadastro do produto.   No caso da Braserv foi acresentado ponto entre o grupo e o sequencial  ���
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





    If Len(RTRIM(M->B1_GRUPO)) <> 4



        MsgBox("Utilize o c�digo analitico, c�digo com 4 caracteres!")

        _xCod := "0000"



    Else

// codigo 4 posicoes do grupo +. (ponto) + sequencial gggg.pppp


        cQry := " SELECT  SUBSTR(B1_COD,5,4) SEQ ,ROW_NUMBER() OVER (PARTITION BY B1_GRUPO ORDER BY B1_GRUPO ) C"

        cQry += " FROM " + RetSqlName("SB1")

        cQry += " WHERE B1_FILIAL = '" + xFilial("SB1") + "'"

        cQry += " AND B1_GRUPO = '" + _xGrupo + "'"

        cQry += " AND D_E_L_E_T_ <> '*' "

        cQry += " ORDER BY B1_COD DESC "



        TcQuery cQry New Alias "QRY"



        dbSelectArea("QRY")

        QRY->( dbGoTop() )



        // Se for final de arquivo

        If QRY->( Eof() ) .AND. SUBSTR(M->B1_GRUPO,1,2) != "PA"

            _xCod := _xGrupo + "0001"

          

        ElseIF  QRY->C == 1 .AND. SUBSTR(M->B1_GRUPO,1,2) != "PA"

//            _xCod := _xGrupo + StrZero( ( Val( QRY->SEQ ) + 1 ), 4 )
       //    _xCod := Alltrim(_xGrupo) +"."+ StrZero( ( Val( QRY->SEQ ) + 1 ), 4 ) // especifico Braserv acrescentado ponto
        _xCod := Alltrim(_xGrupo) + StrZero( ( Val( ALLTRIM(QRY->SEQ) ) + 1 ), 4 )

        //ELSEIF QRY->( Eof() ) .AND. SUBSTR(M->B1_GRUPO,1,2) == "PA"
        //_xCod := "0"+SUBSTR(M->B1_GRUPO,3,2) + "00000001"
        //ELSE
        // _xCod := "0"+SUBSTR(M->B1_GRUPO,3,2) + StrZero( ( Val( QRY->SEQ ) + 1 ), 8 )
        Else 
        _xCod :=" "
        Endif



        QRY->( DbCloseArea() )



    Endif



    RestArea( a_AreaB1 )

    RestArea( a_AreaBM )



Return _xCod
