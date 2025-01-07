/*
Funçao       :  <<Calculadora>>()
Parametros   :  <<Parametros>> - <<Descricao dos Parametros>>
Retorno      :  <<Retorno>> - <<Descricao do retorno>>
Objetivos    :  <<Listar os objetivos da funcao>>
Autor        :  <<Pedro Eustaquio>>
Data/Hora    :  <<2024/08/29>> - <<15:03>>
Revisao      :  <<Descricao de possiveis revisoes na funcao>>
Obs.         :  <<obcervacoes importantes>>
*/

/*
Tipos de variaveis
Local -  Visivel apenas no fonte
Private - Pode ser usada na função e nas proximas
Public - Visivel em todos funções


*/


User Function testeA()

local num1, num2, ntotal

num1:= 10
num2:= 20
ntotal:=0

atotal:= num1 + num2
mtotal:= num1 * num2
stotal:= num1 - num2
dtotal:= num1 / num2

iif(atotal>=50,testeB(),testec())




return 

Static function testeB()
Alert("rodou function teste B e o resultado é"+cvaltoChar(num1))
return

Static function testec()
Alert("rodou function teste c e o resultado é"+cvaltoChar(num1))
return
  