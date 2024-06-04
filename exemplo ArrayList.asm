.data
teste: .asciiz "Ola bom dia" #11 caracteres
teste2: .asciiz ", Como você vai?" #16 caracteres

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

# uma outra forma de imprimir, mais simples, é usando o print stirng
#
# lembrando $t0 é um ponteiro para ArrayList, que em sua posição ($t0)
# contem o array em si, que será carregado para $a0 para poder ser impresso

li $v0 4
lw $a0 ($t0)
syscall


###########################
# Novos testes
# ArrayList.JoinArrays

.include "iostream.asm"

EOL
EOL

# juntar Lista
la $t1 teste2
AL.JA $t0 $t1

lw $a0 ($t0)
print_str

EOL

#tentando contatenar um array muito grande num array list pequeno
AL.C $t0 1 #criando um Array list de um de capacidade
la $t1 teste

AL.JA $t0 $t1 
lw $a0 ($t0)
print_str

EOL


#Excluir letras

#Texto é Ola bom dia
AL.DA $t0 7 # " "
AL.DA $t0 6 # "m"
AL.DA $t0 5 # "o"
AL.DA $t0 4 # "b"

lw $a0 ($t0) # não é necessário
print_str



fim:
li $v0 10
syscall
