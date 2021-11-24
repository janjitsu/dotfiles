#!/bin/bash
# ----------------------------------------------------------------------------
# Gerador e Validador de cnpj em Shell Script (Bash)
#
# Uso: ./cnpj [cnpj]
# Ex.: ./cnpj 552.056.731-09 # pode utilizar assim
# ./cnpj 55205673109 # pode utilizar assim
# ./cnpj # gera um cnpj válido
#
# Autor: Marcos da B.M. Oliveira , http://www.terminalroot.com.br/
# Desde: Dom 27 Out 2013 18:36:16 BRST
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
# limpa todos os caracteres que não for número.
cnpj=$(echo $1 | tr -d -c 0123456789)
##############################################################################
##############################################################################
########## -- SE FOR PRA GERAR cnpj -- ########################################
##############################################################################
##############################################################################
# se não for digitado o parâmetro do cnpj
if [ -z $cnpj ]; then
# gera 3 sequência de 3 caracters, números randômicos.
 for i in {1..3};
  do
   a+=$(($RANDOM%9));
   b+=$(($RANDOM%9));
   c+=$(($RANDOM%9));
  done


# estabelece o valor temporário do cnpj, só pra poder gerar os digitos verificadores.
 cnpj="$a$b$c"
# array pra multiplicar com o 9(do 10 ao 2)primeiros caracteres do cnpj, respectivamente.
mulUm=(10 9 8 7 6 5 4 3 2)
# um loop pra multiplicar caracteres e numeros.Utilizamos nove pois são 9 casas do cnpj
 for digito in {1..9}
  do
    # gera a soma dos números posteriormente multiplicados
    let DigUm+=$(($(echo $cnpj | cut -c$digito) * $(echo ${mulUm[$(($digito-1))]})))

  done

# divide por 11
restUm=$(($DigUm%11))
# gera o primeiro digito subtraindo 11 menos o resto da divisão
primeiroDig=$((11-$restUm))
# caso o resto da divisão seja menor que 2
[ $restUm -lt 2 ] && primeiroDig=0
# atualizamos o valor do cnpj já com um digito descoberto
cnpj="$a$b$c$primeiroDig"
# agora um novo array pra multiplicar com o 10(do 11 ao 2) primeiros caracteres do cnpj, respectivamente.
mulDois=(11 10 9 8 7 6 5 4 3 2)
 for digitonew in {1..10}
  do

    let DigDois+=$(($(echo $cnpj | cut -c$digitonew) * $(echo ${mulDois[$(($digitonew-1))]})))
  done
# também divide por 11
restDois=$(($DigDois%11))
# gera o segundo digito subtraindo 11 menos o resto da divisão
segundoDig=$((11-$restDois))
# caso o resto da divisão seja menor que 2
[ $restDois -lt 2 ] && segundoDig=0
# exibe o cnpj gerado e formatado.
echo -e "\033[1;35mO cnpj gerado é:\033[1;32m $a$b$c$primeiroDig$segundoDig\033[0m"
 # FINALIZA O SCRIPT
 exit 0;
fi
##############################################################################
##############################################################################
# -- SE DIGITAR O PARÂMETRO, MAS A QUANTIDADE DE NÚMEROS SEJA MENOR QUE 11 --
##############################################################################
##############################################################################
# verificamos a quantidade de caracteres
qtde=$(echo $cnpj | wc -c)
# como o wc aumenta mais 1, então precisamos subtrair para chegar a quantidade exata.
total=$(echo $(($qtde-1)))
# se for menos de 11 caracteres
if [ $total != 11 ]; then
 # informa o erro e mostra quantos caracteres têm.
 echo -e "\033[1;31mQuantidade de números diferente de \033[7;31m11\033[0m: Total:\033[1;35m $total\033[0m";

 # finaliza o script
 exit 0;
else
# se passar, continua...daqui pra frente os comentários serão o mesmo da geração do cnpj,
# mas nesse caso pra validar, pois só os dois últimos é que definem o cnpj
##############################################################################
##############################################################################
########## -- SE FOR PRA VALIDAR cnpj -- ########################################
##############################################################################
##############################################################################
mulUm=(10 9 8 7 6 5 4 3 2)
 for digito in {1..9}
  do

    let DigUm+=$(($(echo $cnpj | cut -c$digito) * $(echo ${mulUm[$(($digito-1))]})))
  done

mulDois=(11 10 9 8 7 6 5 4 3 2)
 for digitonew in {1..10}
  do

    let DigDois+=$(($(echo $cnpj | cut -c$digitonew) * $(echo ${mulDois[$(($digitonew-1))]})))
  done
restUm=$(($DigUm%11))
[ $restUm -lt 2 ] && primeiroDig=0
primeiroDig=$((11-$restUm))
restDois=$(($DigDois%11))
[ $restDois -lt 2 ] && segundoDig=0
segundoDig=$((11-$restDois))
 if [ $(echo $cnpj | cut -c10) == $primeiroDig -a $(echo $cnpj | cut -c11) == $segundoDig ]; then
  # se o cnpj for válido.
  echo -e "\033[1;32mcnpj Válido!\033[0m"
 else
  # informa quais seriam os dois últimos se o cnpj estiver incorreto.
  echo -e "\033[1;31mcnpj Inválido.\nOs dois Últimos números deveriam ser:\033[1;32m $primeiroDig$segundoDig\033[0m"
 fi

fi
