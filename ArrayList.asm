#########################################################################################
# ArrayList � uma lista de 3 informa��es:
# Em 0(*) cont�m um ponteiro para o array em si
# Em 4(*) cont�m a capacidade desse array
# Em 8(*) cont�m o tamanho atual do array
#
# Para ler o ArrayList primeiro obtenha o ponteiro para o array em 0(*)
# Depois leia normalmente como qualquer outro array;
#
# Para adicionar uma caractere ao array, chame ArrayList.AppendByte com o endere�o
# do ArrayList (n�o do array) e informe o byte que deseja inserir ao final da lista;
# ArrayList.AppendByte ir� expandir automaticamente o array caso ele n�o tenha espa�o
# Essa opera��o pode mudar o valor de 0(*), lembre de obter ele de novo sempre que
# quiser ler o array ap�s uma opera��o de ArrayList.AppendByte
#
# Para editar um byte, primeiro obtenha o ponteiro para o array em 0(*)
# Depois edite normalmente
# Cuidado: editar um byte fora do tamanho do array n�o � recomendado
# Caso o byte que deseja editar esteja al�m da capacidade, uma exess�o ser� lan�ada
# Caso o byte esteja entre o tamanho e a capacidade, a ArrayList n�o vai ter
# a informa��o que esse byte deve ser mantido, ent�o, quando ArrayList.AppendByte
# for chamado, esse byte pode ser sobreescrito
#
# Todas as fun��es de ArrayList n�o alteram o estado da fun��o
# que chamou alguma delas


# Cria um ArrayList com 8 de capacidade
# Coloca no %regRetorno um ponteiro para um ArrayList
.macro ArrayList.Create %regRetorno
ArrayList.Create %regRetorno 8
.end_macro

# Cria uma ArrayList com um tamanho definido em %capacidade
# %regRetorno vai ser o registrador que obtem o ArrayList
.macro ArrayList.Create %regRetorno %capacidade
add $sp $sp -16 # salva os registradores para n�o alterar o estado
sw $t0 8($sp)
sw $v0 4($sp)  # das fun��es que chamarem essa
sw $a0 0($sp)

li $v0 9 #alocar bytes
li $a0 12 #alocar 3 words
syscall
move $t0 $v0 # ponteiro para ArrayList
add $a0 $zero %capacidade #aloca 1 byte a mais para garantir que o array termine em um
add $a0 $a0 1             #caracter nulo
li $v0 9
syscall
sw $v0   0($t0)   # 0(%regRetorno) endere�o do array em si
sw $a0   4($t0)   # 4(%regRetorno) capacidade do array
sw $zero 8($t0) # 8(%regRetorno) tamanho do array

sw $t0 12($sp) # gambiarra para permitir que $t0, $v0 e $a0
# sejam usados para receber o endere�o de retorno

lw $t0 8($sp) # restaura o valor antigo dos registradores
lw $v0 4($sp)
lw $a0 0($sp)
lw %regRetorno 12($sp)
add $sp $sp 16
.end_macro

##################################################
# Adiciona um %Byte ao final do array em ArrayList
.macro ArrayList.AppendByte %ArrayList %Byte
add $sp $sp -36
sw $v0 32($sp)
sw $a0 28($sp)
sw $t0 20($sp)

add $t0 $zero %Byte # dessa forma Byte pode ser tanto
sw $t0 24($sp) # imediato quanto registrador

lw $t0 20($sp)
sw $t1 16($sp)
sw $t2 12($sp)
sw $t3 8($sp)
sw $t4 4($sp)
sw $t5 0($sp)
########
move $t0 %ArrayList
lw $t1 0($t0) # endere�o do array
lw $t2 4($t0) # capacidade do array
lw $t3 8($t0) # tamanho do array

beq $t2 $t3 ExpandArray
add $t1 $t1 $t3
lw $t5 24($sp)
sb $t5 ($t1) # salva o byte
j fim
ExpandArray:
sll $t2 $t2 1 # duplicar o tamanho
move $a0 $t2
add $a0 $a0 1 # 1 a mais do que a capacidade para que o array termine em caracter nulo
li $v0 9
syscall
move $t4 $v0

sw $t4 0($t0)
sw $t2 4($t0)

move $t5 $zero # $t5 � um indice
loop: 
lb $t2 ($t1) # copia todos os bytes da lista antiga
sb $t2 ($t4) # para a lista nova
add $t1 $t1 1
add $t4 $t4 1
add $t5 $t5 1
blt $t5 $t3 loop

lw $t5 24($sp)
sb $t5 ($t4)

fim:
add $t3 $t3 1
sw $t3 8($t0)

sw $v0 32($sp)
sw $a0 28($sp)
lw $t0 20($sp)
lw $t1 16($sp)
lw $t2 12($sp)
lw $t3 8($sp)
lw $t4 4($sp)
lw $t5 0($sp)
add $sp $sp 36
.end_macro


# Shortcuts
.macro AL.C %regRetorno
ArrayList.Create %regRetorno 8
.end_macro
.macro AL.C %regRetorno %capacidade
ArrayList.Create %regRetorno %capacidade
.end_macro
.macro AL.AB %ArrayList %Byte
ArrayList.AppendByte %ArrayList %Byte
.end_macro

