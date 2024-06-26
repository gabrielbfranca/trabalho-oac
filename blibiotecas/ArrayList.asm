#########################################################################################
# ArrayList é uma lista de 3 informações:
# Em 0(*) contém um ponteiro para o array em si
# Em 4(*) contém a capacidade desse array
# Em 8(*) contém o tamanho atual do array
#
# Para ler o ArrayList primeiro obtenha o ponteiro para o array em 0(*)
# Depois leia normalmente como qualquer outro array;
#
# Para adicionar uma caractere ao array, chame ArrayList.AppendByte com o endereço
# do ArrayList (não do array) e informe o byte que deseja inserir ao final da lista;
# ArrayList.AppendByte irá expandir automaticamente o array caso ele não tenha espaço
# Essa operação pode mudar o valor de 0(*), lembre de obter ele de novo sempre que
# quiser ler o array após uma operação de ArrayList.AppendByte
#
# Para editar um byte, primeiro obtenha o ponteiro para o array em 0(*)
# Depois edite normalmente
# Cuidado: editar um byte fora do tamanho do array não é recomendado
# Caso o byte que deseja editar esteja além da capacidade, uma exessão será lançada
# Caso o byte esteja entre o tamanho e a capacidade, a ArrayList não vai ter
# a informação que esse byte deve ser mantido, então, quando ArrayList.AppendByte
# for chamado, esse byte pode ser sobreescrito
#
# Todas as funções de ArrayList não alteram o estado da função
# que chamou alguma delas


# Cria um ArrayList com 16 de capacidade
# Coloca no %regRetorno um ponteiro para um ArrayList
.macro ArrayList.Create %regRetorno
ArrayList.Create %regRetorno 16
.end_macro

# Cria uma ArrayList com um tamanho definido em %capacidade
# %regRetorno vai ser o registrador que obtem o ArrayList
.macro ArrayList.Create %regRetorno %capacidade
add $sp $sp -16 # salva os registradores para não alterar o estado
sw $t0 8($sp)
sw $v0 4($sp)  # das funções que chamarem essa
sw $a0 0($sp)

li $v0 9 #alocar bytes
li $a0 12 #alocar 3 words
syscall
move $t0 $v0 # ponteiro para ArrayList
add $a0 $zero %capacidade #aloca 4 byte a mais para garantir que o array termine em uma
add $a0 $a0 4             #word nula
li $v0 9                  # nota: talvez um caracter já seja bom o suficiente, mas vai saber
syscall
sw $v0   0($t0)   # 0(%regRetorno) endereço do array em si
sw $a0   4($t0)   # 4(%regRetorno) capacidade do array
sw $zero 8($t0) # 8(%regRetorno) tamanho do array

sw $t0 12($sp) # gambiarra para permitir que $t0, $v0 e $a0
# sejam usados para receber o endereço de retorno

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
lw $t1 0($t0) # endereço do array
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
add $a0 $a0 4 # 4 a mais para que o array termine em uma word nula
li $v0 9
syscall
move $t4 $v0

sw $t4 0($t0)
sw $t2 4($t0)

move $t5 $zero # $t5 é um indice
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

lw $v0 32($sp)
lw $a0 28($sp)
lw $t0 20($sp)
lw $t1 16($sp)
lw $t2 12($sp)
lw $t3 8($sp)
lw $t4 4($sp)
lw $t5 0($sp)
add $sp $sp 36
.end_macro

.include "macroStack.asm"

##################################################
# Adiciona uma %Word ao final do array em ArrayList
.macro ArrayList.AppendWord %ArrayList %Word
newCompleteStack
add $sp $sp -4
sw %Word -4($fp)

move $s0 %ArrayList

add $s3 $fp -4
li $s2 0
loop:
add $s1 $s2 $s3
lb $s1 ($s1)
ArrayList.AppendByte $s0 $s1
add $s2 $s2 1
blt $s2 4 loop

clearCompleteStack
.end_macro

##################################################
# Deleta o byte na posição %Index e junta a lista
.macro ArrayList.DeleteAt %ArrayList %Index
.data
mensagemErroIndex: .asciiz "ArrayList: index especificado não faz parte do array"
.align 2
.text
newCompleteStack # ArrayList.DeleteAt %ArrayList %Index
add $sp $sp -4
sw %ArrayList -4($fp)
add $s1 $zero %Index # truque para permitir que %index seja tanto imediato quanto registrador
lw $s0 -4($fp)
#  $s1 - index

lw $s2 8($s0) # tamanho atual do array

bge $s1 $s2 erroIndex
blt $s1 0 erroIndex

add $s2 $s2 1
add $s3 $s1 1 # indice
lw $s6 ($s0) # array
loop:
add $s5 $s6 $s3 # $s5 endereço do byte sendo lido
lb $s4 ($s5) # byte a ser escrito
add $s5 $s5 -1 # endereço para salvar
sb $s4 ($s5)
add $s3 $s3 1
blt $s3 $s2 loop

j fim

erroIndex:
li $v0 4
la $a0 mensagemErroIndex
syscall
li $v0 10
syscall

fim:
add $s2 $s2 -2
sw $s2 8($s0)
clearCompleteStack
.end_macro

##################################################
# Deleta o byte na posição %Index e junta a lista
.macro ArrayList.FastDeleteAt %ArrayList %Index
.data
mensagemErroIndex: .asciiz "ArrayList: index especificado não faz parte do array"
.align 2
.text
# ArrayList.DeleteAt %ArrayList %Index
add $sp $sp -4
sw %ArrayList -4($fp)
add $t1 $zero %Index # truque para permitir que %index seja tanto imediato quanto registrador
lw $t0 -4($fp)
#  $s1 - index

lw $t2 8($t0) # tamanho atual do array

bge $t1 $t2 erroIndex
blt $t1 0 erroIndex

add $t2 $t2 1
add $t3 $t1 1 # indice
lw $t6 ($t0) # array
loop:
add $t5 $t6 $t3 # $s5 endereço do byte sendo lido
lb $t4 ($t5) # byte a ser escrito
add $t5 $t5 -1 # endereço para salvar
sb $t4 ($t5)
add $t3 $t3 1
blt $t3 $t2 loop

j fim

erroIndex:
li $v0 4
la $a0 mensagemErroIndex
syscall
li $v0 10
syscall

fim:
add $t2 $t2 -2
sw $t2 8($t0)
.end_macro

##################################################
# Deleta o byte na posição %Index e junta a lista
.macro ArrayList.DeleteRange %ArrayList %Start %Number
newArgsStack
add $sp $sp -4
sw %ArrayList ($sp)
add $a1 %Start $zero
lw $a0 ($sp)

add $a2 %Number $zero
loop:
ArrayList.FastDeleteAt $a0 $a1
add $a2 $a2 -1
bgtz $a2 loop

clearArgsStack
.end_macro

##################################################
# Junta o %Array no final de %ArrayList, %Array permance inalterado
.macro ArrayList.JoinArrays %ArrayList %Array
newCompleteStack # ArrayList.JoinArrays %ArrayList %Array
add $sp $sp -8
sw %ArrayList -4($fp)
sw %Array -8($fp)
lw $s0 -4($fp)
lw $s1 -8($fp)

li $s2 0 # index
loop:
add $s3 $s2 $s1
lb $s4 ($s3)
beq $s4 0x00 fim
ArrayList.AppendByte $s0 $s4
add $s2 $s2 1
j loop

fim:
clearCompleteStack
.end_macro

##################################################
# Deleta o ultimo byte do array
.macro ArrayList.DeleteLast %ArrayList
newArgsStack
move $a0 %ArrayList
lw $a1 ($a0) # array
lw $a2 8($a0) # tamanho do array

add $a2 $a2 -1 # reduzindo em um o tamanho do array
sb $a2 8($a0)

add $a3 $a1 $a2 # posição da caractere a ser deletada
li $a0 0
sb $a0 ($a3)

clearArgsStack
.end_macro


.include "iostream.asm"
.include "stringManipulation.asm"

#############################################
# Usado em listas de string*
# $v0 recebe o index da string, negativo se não tiver presente
.macro ArrayList.FindString %ArrayList %String
.data
.align 2
mensagemErro: "Erro palavra desconhecida: "
.text 
newCompleteStack
add $sp $sp -4
sw %ArrayList ($sp)
move $a1 %String
lw $a0 ($sp)
li $v0 0
lw $s0 ($a0)
lw $s1 8($a0) # index

loop:
add $s1 $s1 -4
add $s2 $s1 $s0
lw $s2 ($s2)
fastCompareStringsReg $s2 $a1
beq $v0 1 achou 
bgtz $s1 loop
li $s2 -1
#print_str mensagemErro
#move $a0 $a1
#print_str
#li $v0 10
#syscall

achou:
move $v0 $s2
clearCompleteStack
.end_macro

##################################################
# Adiciona um %Byte ao final do array em ArrayList
# cerca de 1.8x vezes mais rapido quando não há expansão
# +4x mais rapido quando há expansão
# não salva os registradores $t, $a nem $v
.macro ArrayList.FastAppendByte %ArrayList %Byte
add $sp $sp -4
sw %ArrayList ($sp)
add $t6 $zero %Byte # dessa forma Byte pode ser tanto imediato quanto registrador
lw $t0 ($sp)

########
lw $t1 0($t0) # endereço do array
lw $t2 4($t0) # capacidade do array
lw $t3 8($t0) # tamanho do array

beq $t2 $t3 ExpandArray
j fim
ExpandArray:
sll $t2 $t2 1 # duplicar o capacidade
move $a0 $t2
add $a0 $a0 4 # 4 a mais do que a capacidade para que o array termine em word nulo
li $v0 9
syscall
move $t4 $v0

sw $t4 0($t0)
sw $t2 4($t0)

move $t5 $zero # $t5 é um indice
loop: 
lw $t2 ($t1) # copia todos os bytes da lista antiga
sw $t2 ($t4) # para a lista nova
add $t1 $t1 4
add $t4 $t4 4
add $t5 $t5 4
blt $t5 $t3 loop

lw $t1 0($t0)

fim:
add $t1 $t1 $t3
sb $t6 ($t1) # salva o byte

add $t3 $t3 1
sw $t3 8($t0) # atualiza capacidade

add $sp $sp 4
.end_macro

##################################################
# Adiciona uma %Word ao final do array em ArrayList
# copiado do codigo FastAppendByte, adaptado para conseguir manipular words
.macro ArrayList.FastAppendWord %ArrayList %Word
add $sp $sp -4
sw %ArrayList ($sp)
add $t6 $zero %Word # dessa forma Word pode ser tanto imediato quanto registrador
lw $t0 ($sp)

########
lw $t1 0($t0) # endereço do array
lw $t2 4($t0) # capacidade do array
lw $t3 8($t0) # tamanho do array

beq $t2 $t3 ExpandArray
j fim
ExpandArray:
sll $t2 $t2 1 # duplicar o capacidade
move $a0 $t2
add $a0 $a0 4 # 4 a mais do que a capacidade para que o array termine em word nulo
li $v0 9
syscall
move $t4 $v0

sw $t4 0($t0)
sw $t2 4($t0)

move $t5 $zero # $t5 é um indice
loop: 
lw $t2 ($t1) # copia todos os bytes da lista antiga
sw $t2 ($t4) # para a lista nova
add $t1 $t1 4
add $t4 $t4 4
add $t5 $t5 4
blt $t5 $t3 loop

lw $t1 0($t0)

fim:
add $t1 $t1 $t3
sw $t6 ($t1) # salva a word

add $t3 $t3 4
sw $t3 8($t0) # atualiza capacidade

add $sp $sp 4
.end_macro

##################################################
# Junta o %Array no final de %ArrayList, %Array permance inalterado
.macro ArrayList.FastJoinArrays %ArrayList %_Array
add $sp $sp -4
sw %ArrayList ($sp)
move $t7 %_Array # Array
lw $t8 ($sp) # ArrayList

li $t9 0 # not index
loop:
lw $t9 ($t7)
beq $t9 0x00000000 fim
ArrayList.FastAppendWord $t8 $t9
add $t7 $t7 4
j loop

fim:
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
.macro AL.AW %ArrayList %Word
ArrayList.AppendWord %ArrayList %Word
.end_macro
.macro AL.DA %ArrayList %_Index # delete byte
ArrayList.DeleteAt %ArrayList %_Index
.end_macro
.macro AL.JA %ArrayList %_Array
ArrayList.JoinArrays %ArrayList %_Array
.end_macro
.macro AL.FJA %ArrayList %_Array
ArrayList.FastJoinArrays %ArrayList %_Array
.end_macro
.macro AL.DL %ArrayList # delete byte
ArrayList.DeleteLast %ArrayList
.end_macro
.macro AL.FS %ArrayList %String
ArrayList.FindString %ArrayList %String
.end_macro
