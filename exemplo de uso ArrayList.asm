.data
teste: .asciiz "Ola bom dia" #11 caracteres

.text
.include "ArrayList.asm"

# Comentário: quando criamos o array, ele possui uma capacidade inicial de 8 bytes
# O texto que que queremos colocar no array tem 11 caracteres, 11 bytes
# Ao usar o ArrayList.AppendByte, a lista se espande automaticamente
# 
# Experimentem colocar como valor inicial de tamanho da lista qualquer outro valor maior que zero

AL.C $t0 8

lw $t7 ($t0) # obtém o endereço do array, isso não é necessário para colocar dados

li $t1 0
la $t2 teste
loop:
add $t3 $t2 $t1
lb $t4 ($t3)
AL.AB $t0 $t4 #salva o byte na lista
add $t1 $t1 1
blt $t1 11 loop

# a partir desse ponto, o array de ArrayList possui o texto em teste:
# o valor de $t7 não reflete mais o array certo, já que ele foi trocado por um maior

li $t1 0
lw $t7 ($t0) # aqui o $t7 recebe o valor atualizado do array
li $v0 11 # print char
loop2:
add $t3 $t7 $t1
lb $a0 ($t3)
syscall
add $t1 $t1 1
blt $t1 11 loop2
