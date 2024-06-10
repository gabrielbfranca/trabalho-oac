# arquivos importados:
# iostream.asm
# stringManipulation.asm
# macroStack.asm
# ArrayList.asm
# readFileBySpace.asm
# fstream.asm
# asciiConversions.asm

.data
arquivo: .asciiz "example_saida_simples.asm"
.align 3
arquivoSaida: .asciiz "teste.asm"
my_space: .space 16
.text

# abrir arquivo de saída
la $a0 arquivoSaida
jal openFile.func.write
move $s2 $v0 # file descriptor do arquivo de saida

la $a0 arquivo
jal Parser # usando intrução jal -> Jump target word address beyond 26-bit range

la $a0 ArrayListTextoEntrada
lw $a0 ($a0)
#jal print
move $s0 $a0 # texto de entrada

li $s1 0 # numero da chars lidas
loop:
move $a0 $s0
move $a1 $s1
jal getWordInString.Func
beqz $v1 fim
add  $s1 $s1 $v1
move $a2 $s2
move $a1 $s1
move $a0 $v0
jal Roteador
move $s1 $v1
j loop


fim:
li $v0 10
syscall



################################################################
################################################################
################################################################
# Arquivos importados

################################################################
# iostream.asm

.macro print_str
li $v0 4
syscall
.end_macro

.macro print_str %label
add $sp $sp -4
sw $a0 ($sp)

la $a0 %label
print_str

lw $a0 ($sp)
add $sp $sp 4
.end_macro

.macro print_EOL
add $sp $sp -4
sw $a0 ($sp)

li $a0 0x0a
li $v0 11
syscall

lw $a0 ($sp)
add $sp $sp 4
.end_macro

.macro print_SPACE
add $sp $sp -4
sw $a0 ($sp)

li $a0 0x20
li $v0 11
syscall

lw $a0 ($sp)
add $sp $sp 4
.end_macro

.eqv EOL print_EOL
.eqv SPACE print_SPACE

################################################################
# stringManipulation.asm
.data
 
str1: .asciiz ".data"
str2: .asciiz ".data"
str3:
.asciiz "00000001 : "
str4:
.asciiz "00000003;"
result:
.space 18

.text

# end
# Se for igual $v0 obtém 1, se não 0
.macro compareStringsReg %str1 %str2 
 addi $sp, $sp, -20
 sw $ra, 20($sp)
 sw $t1, 16($sp) 
 sw $t2, 12($sp)
 sw $t3, 8($sp)
 sw $t4, 4($sp)
 sw $t6, 0($sp)
 
 la $t1, (%str1)
 la $t2, (%str2)

loop:
  # Load characters from strings
  lb $t3, 0($t1)
  lb $t4, 0($t2)
  
    # Check if characters are equal
  sub $t6, $t3, $t4
  

  # Check for end of strings (newline character)
  beq $t3, 0, end_loop  # 10 is the ASCII code for newline 0 is code for null
  beq $t4, 0, end_loop
  
  beq $t6, $zero, continueEqual


  # Characters not equal, exit loop
  j end_loop

continueEqual:
  # Both characters are equal, increment pointers
  addi $t1, $t1, 1
  addi $t2, $t2, 1
  j loop

end_loop:
  # Check if characters were equal until the end
  beq $t6, $zero, same  # Move 1 to result register

  # Characters not the same, move 0 to result register
  li $v0, 0
  j exit
  
same:
  # Characters are the same, move 1 to result register
  li $v0, 1
exit:
	
 	lw $ra, 20($sp)
 	lw $t1, 16($sp) 
 	lw $t2, 12($sp)
 	lw $t3, 8($sp)
 	lw $t4, 4($sp)
 	lw $t6, 0($sp)
 	addi $sp, $sp, 20
 	
.end_macro

# Se for igual $v0 obtém 1, se não 0
.macro fastCompareStringsReg %str1 %str2
add $sp $sp -4
sw %str1 ($sp)
move $t1 %str2
lw $t2 ($sp)

loop:
  # Load characters from strings
  lw $t3, 0($t1)
  lw $t4, 0($t2)
  
  # Check if characters are equal
  sub $t0, $t3, $t4
  

  # Check for end of strings (newline character)
  beq $t3, 0x00, end_loop  # 10 is the ASCII code for newline 0 is code for null
  beq $t4, 0x00, end_loop
  
  beq $t0, $zero, continueEqual


  # Characters not equal, exit loop
  j end_loop

continueEqual:
  # Both characters are equal, increment pointers
  addi $t1, $t1, 4
  addi $t2, $t2, 4
  j loop

end_loop:
  # Check if characters were equal until the end
  beq $t0, $zero, same  # Move 1 to result register

  # Characters not the same, move 0 to result register
  li $v0, 0
  j exit
  
same:
  # Characters are the same, move 1 to result register
  li $v0, 1
exit:
 addi $sp, $sp, 4
.end_macro

.macro stringInList %str %array
add $sp $sp -4
sw %str ($sp)
move $t6 %Array
lw $t7 ($sp)

loop:
lw $t8 ($t6)
fastCompareStringsReg $t7 $t8
beq $v0 1 stringInList.Fim
add $t6 $t6 4
beq $t6 0x00 stringInList.Fim
j loop:

stringInList.Fim:
.end_macro

.macro compareStringsLabel (%str1, %str2)
add $sp $sp -8
sw $t0 4($sp)
sw $t1 0($sp)
la $t0 %str1
la $t1 %str2
compareStringsReg $t0 $t1
lw $t0 4($sp)
lw $t1 0($sp)
add $sp $sp 8
.end_macro

.macro compare_strings (%str1, %str2, %result_reg)
 addi $sp, $sp, -20
 sw $ra, 20($sp)
 sw $t1, 16($sp) 
 sw $t2, 12($sp)
 sw $t3, 8($sp)
 sw $t4, 4($sp)
 sw $t6, 0($sp)
 
 la $t1, %str1
 la $t2, %str2

loop:
  # Load characters from strings
  lb $t3, 0($t1)
  lb $t4, 0($t2)
  
    # Check if characters are equal
  sub $t6, $t3, $t4
  

  # Check for end of strings (newline character)
  beq $t3, 0, end_loop  # 10 is the ASCII code for newline 0 is code for null
  beq $t4, 0, end_loop
  
  beq $t6, $zero, continueEqual


  # Characters not equal, exit loop
  j end_loop

continueEqual:
  # Both characters are equal, increment pointers
  addi $t1, $t1, 1
  addi $t2, $t2, 1
  j loop

end_loop:
  # Check if characters were equal until the end
  beq $t6, $zero, same  # Move 1 to result register

  # Characters not the same, move 0 to result register
  li %result_reg, 0
  j exit
  
same:
  # Characters are the same, move 1 to result register
  li %result_reg, 1
exit:
	
 	lw $ra, 20($sp)
 	lw $t1, 16($sp) 
 	lw $t2, 12($sp)
 	lw $t3, 8($sp)
 	lw $t4, 4($sp)
 	lw $t6, 0($sp)
 	addi $sp, $sp, 20
.end_macro


.macro concatenateString(%str1, %str2, %result) #result é um espaço
.text
# Copy first string to result buffer

addi $sp, $sp, -24
 sw $ra, 24($sp)
 sw $a0, 20($sp) 
 sw $a1, 16($sp)
 sw $v0, 12($sp)
 sw $t0, 8($sp)
 sw $t1, 4($sp)
 sw $t2, 0($sp)
 
 
la $a0, %str1
la $a1, %result
jal strcopier
nop

# Concatenate second string on result buffer
la $a0, %str2
or $a1, $v0, $zero
jal strcopier
nop
j finish
nop

# String copier function
strcopier:
or $t0, $a0, $zero # Source
or $t1, $a1, $zero # Destination

loop:
lb $t2, 0($t0)
beq $t2, $zero, end
addiu $t0, $t0, 1
sb $t2, 0($t1)
addiu $t1, $t1, 1
b loop
nop

end:
or $v0, $t1, $zero # Return last position on result buffer
jr $ra
nop

finish:
	
 	lw $ra, 24($sp)
 	lw $a0, 20($sp) 
 	lw $a1, 16($sp)
 	lw $v0, 12($sp)
 	lw $t0, 8($sp)
	lw $t1, 4($sp)
	lw $t2, 0($sp)
	addi $sp, $sp, 24
.end_macro


.macro cleanSpace(%space) # not functional

	addi $sp, $sp, -12
 	sw $ra, 12($sp)
 	sw $t0, 8($sp)
 	sw $t1, 4($sp)
 	sw $t2, 0($sp)
 
	la $t0, %space  # Load address of my_buffer
	li $t1, 0          # Load value to write (zero)
	addi $t2, $t0, 18   # Calculate end address (10 bytes)

	loop:
	  sb $t1, 0($t0)    # Store zero at current address
	  addi $t0, $t0, 1   # Increment address
	  blt $t0, $t2, loop  # Loop until end address reached

 	lw $ra, 12($sp)
 	lw $t0, 8($sp)
 	lw $t1, 4($sp)
 	lw $t2, 0($sp)
 	addi $sp, $sp, 12
.end_macro




#concatenateString(str1, str2, result)
#print_str (result)
#cleanSpace(result)


################################################################
# macroStack.asm

# Macros para facilitar a criação e o fim de escopos alocando e desalocando espaço na Stack
# 
# baseado em https://lisha.ufsc.br/teaching/sys/stack.pdf
#
#

# macro newSimpleStack
# coloca na stack informações para a criação de um novo escopo
# atribui o minimo de espaços possiveis
# usado no começo de funções
.macro newSimpleStack
add $sp $sp -12
sw $a0 8($sp)  #8($fp) - $a0
sw $ra 4($sp)  #4($fp) - antigo $ra
sw $fp 0($sp)  #0($fp) - antigo $fp
move $fp $sp
               #-4($fp)
               #-8($fp)
               #etc - variáveis locais
.end_macro

# macro clearSimpleStack
# reatribui os valores antigos de $ra, $fp e $a0
# limpa o espaço no Stack criado por newSimpleStack 
# os espaços criados depois são limpados automaticamente
# usado no fim de funções que chamaram newSimpleStack
.macro clearSimpleStack
move $sp $fp
lw $a0 8($sp)
lw $ra 4($sp)
lw $fp 0($sp)

add $sp $sp 12
.end_macro


#######################################################################

# macro newArgsStack
# coloca na stack informações para a criação de um novo escopo
# contempla todo o leque de regitradores $a
# usado no começo de funções
.macro newArgsStack
add $sp $sp -12
# aqui o scopo já é iniciado parcilmente por newSimpleStack
sw $a3 8($sp)  #20($fp) - $a3
sw $a2 4($sp)  #16($fp) - $a2
sw $a1 0($sp)  #12($fp) - $a1
newSimpleStack #8($fp)  - $a0
               #4($fp)  - antigo $ra
               #0($fp)  - antigo $fp

               #-4($fp)
               #-8($fp)
               #etc     - variáveis locais
.end_macro

# macro clearArgsStack
# reatribui os valores antigos de $ra, $fp e registradores $a
# limpa o espaço no Stack criado por newArgsStack 
# os espaços criados depois são limpados automaticamente
# usado no fim de funções que chamaram newArgsStack
.macro clearArgsStack
clearSimpleStack
lw $a3 8($sp) # recupera os valores dos registradores $a
lw $a2 4($sp)
lw $a1 0($sp)

add $sp $sp 12
.end_macro


#######################################################################

# macro newCompleteStack
# salva automaticamente todas as informções de estado de uma função
# incluindo os registradores $s0-$s7, permitindo que eles sejam
# utilizados pela função que pede essa Stack
# Nota - comparado com SimpleStack, CompleteStack usa 2,3 mais instruções
.macro newCompleteStack

add $sp $sp -32
# aqui o scopo já é iniciado parcilmente por newArgsStack
sw $s7 28($sp) #52($fp) - $s7 antigo
sw $s6 24($sp) #48($fp) - $s6
sw $s5 20($sp) #44($fp) - $s5
sw $s4 16($sp) #40($fp) - $s4
sw $s3 12($sp) #36($fp) - $s3
sw $s2 8($sp)  #32($fp) - $s2
sw $s1 4($sp)  #28($fp) - $s1
sw $s0 0($sp)  #24($fp) - $s0
newArgsStack   #20($fp) - $a3
               #16($fp) - $a2
               #12($fp) - $a1
               #8($fp)  - $a0
               #4($fp)  - antigo $ra
               #0($fp)  - antigo $fp
              
               #-4($fp)
               #-8($fp)
               #etc     - variáveis locais
.end_macro

# macro clearCompleteStack
# reatribui os valores antigos de $ra, $fp, $a, e $s
# limpa o espaço no Stack criado por newCompleteStack 
# os espaços criados depois são limpados automaticamente
# usado no fim de funções que chamaram newComleteStack
.macro clearCompleteStack
clearArgsStack
lw $s7 28($sp) # recupera os valores antigos dos registradores $s
lw $s6 24($sp)
lw $s5 20($sp)
lw $s4 16($sp)
lw $s3 12($sp)
lw $s2 8($sp)
lw $s1 4($sp)
lw $s0 0($sp)
add $sp $sp 32
.end_macro


#######################################################################

# macro newBiggerStack
# salva automaticamente todas as informções de estado de uma função,
# até os registradores temporários
# incluindo os registradores $t0-$t9, permitindo que eles sejam
# utilizados pela função que pede essa Stack
.macro newBiggerStack
add $sp $sp -40
# aqui o scopo já é iniciado parcilmente por newArgsStack
sw $t9 36($sp)   #92($fp) - $t9 antigo
sw $t8 32($sp)   #88($fp) - $t8
sw $t7 28($sp)   #84($fp) - $t7
sw $t6 24($sp)   #80($fp) - $t6
sw $t5 20($sp)   #76($fp) - $t5
sw $t4 16($sp)   #72($fp) - $t4
sw $t3 12($sp)   #68($fp) - $t3
sw $t2 8($sp)    #64($fp) - $t2
sw $t1 4($sp)    #60($fp) - $t1
sw $t0 0($sp)    #56($fp) - $t0 ####
newCompleteStack #52($fp) - $s7 
                 #48($fp) - $s6
                 #44($fp) - $s5
                 #40($fp) - $s4
                 #36($fp) - $s3
                 #32($fp) - $s2
                 #28($fp) - $s1
                 #24($fp) - $s0 ####
                 #20($fp) - $a3 
                 #16($fp) - $a2
                 #12($fp) - $a1
                 #8($fp)  - $a0
                 #4($fp)  - antigo $ra
                 #0($fp)  - antigo $fp
             
                 #-4($fp)
                 #-8($fp)
                 #etc     - variáveis locais
.end_macro

# macro clearBiggerStack
# reatribui os valores antigos de $ra, $fp, $a, $s e $t
# limpa o espaço no Stack criado por newBiggerStack 
# os espaços criados depois são limpados automaticamente
# usado no fim de funções que chamaram newBiggerStack
.macro clearBiggerStack
clearArgsStack
lw $t9 36($sp) # recupera os valores antigos dos registradores $t
lw $t8 32($sp)
lw $t7 28($sp) 
lw $t6 24($sp)
lw $t5 20($sp)
lw $t4 16($sp)
lw $t3 12($sp)
lw $t2 8($sp)
lw $t1 4($sp)
lw $t0 0($sp)
add $sp $sp 32
.end_macro


################################################################
# ArrayList.asm


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

#.include "macroStack.asm"

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


#.include "iostream.asm"
#.include "stringManipulation.asm"

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
li $s1 -1
#print_str mensagemErro
#move $a0 $a1
#print_str
#li $v0 10
#syscall

achou:
move $v0 $s1
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


################################################################
# readFileBySpace.asm

.macro parse_word(%space,%file_descriptor)
.data
buffer:   .space  4

.text

readc: # usa arquivo : $s0, retorna caracter em: $v0 
	li $v0,14
	move $a0,$s0  # aponta pro ponteiro no arquivo
  	la $a1,buffer 
  	li $a2,1        
  	syscall
  	beq $v0, $0, finish # eof
  	lb $v0,buffer # le um byte armazenado em buffer
.end_macro


.macro read_file_to_space (%buffer,%space, %file_descriptor)
  .data
  
  error_message: .asciiz "Error in parser: not enough space"
.text
add $sp $sp -16
sw $t0 12($sp)
sw $t1 8($sp)
sw $t2 4($sp)
sw $t3 0($sp)

la $t2, %space
la $t3, %buffer
loop:
  # Read a character from the file
  li $v0, 14      # syscall code for read
  move $a0, %file_descriptor  # use provided file descriptor
  la $a1, %buffer   # load address of buffer
  li $a2, 1        # read 1 byte

  syscall        # perform read syscall

  # Check for end of file (EOF)
  beq $v0, -1, finish  # branch on error or EOF

  # Check for space character
  lb $t0, %buffer   # load byte from buffer
  beqz $t0, finish   # branch if null terminator (EOF)
  #bne $t0, 32, not_space
  #bne $t0, 10, not_space 
  beq $t0, 44, loop # ignores ,
  bge $t0, 33, not_space
  # Character is a space (less than 10), terminate loop
  j finish

not_space:
  # Character is not a space, append it to the reserved space
  lb $t1, 0($t2)  # load current byte from reserved space
  beqz $t1, append  # branch if space is available in reserved space

  # Handle full reserved space (e.g., print error message)
  li $v0, 1    # syscall code for print string
  la $a0, error_message  # load error message address
  syscall
  j finish      # jump to finish

append:
  # Append the character to the reserved space
  sb $t0, 0($t2)  # store byte in reserved space
  addi $t2, $t2, 1  # move to next byte in reserved space

  j loop        # continue reading the file

finish:
lw $t0 12($sp)
lw $t1 8($sp)
lw $t2 4($sp)
lw $t3 0($sp)
add $sp $sp 16
.end_macro


#.include "ArrayList.asm"
#.include "macroStack.asm"
# $v0 string
# $v1 char lidas
.macro getWordInString %string %index
newCompleteStack
add $sp $sp -4
sw %string ($sp)
add $s3 $zero %index # index
add $s4 $zero %index
lw $s0 ($sp) #string
AL.C $s1 8

loop:
add $s2 $s3 $s0
lb $s2 ($s2)
beq $s2 0x20 fim
beq $s2 0x0a fim
beq $s2 0x00 fim2
ArrayList.FastAppendByte $s1 $s2
add $s3 $s3 1
j loop

fim2:
add $s3 $s3 -1 
fim:
lw $v0 ($s1)
add $v1 $s3 1
sub $v1 $v1 $s4
clearCompleteStack
.end_macro

.macro getArrayListInString %string %index
newCompleteStack
add $sp $sp -4
sw %string ($sp)
add $s3 $zero %index # index
add $s4 $zero %index
lw $s0 ($sp) #string
AL.C $s1 8

loop:
add $s2 $s3 $s0
lb $s2 ($s2)
beq $s2 0x20 fim
beq $s2 0x0a fim
beq $s2 0x00 fim2
ArrayList.FastAppendByte $s1 $s2
add $s3 $s3 1
j loop

fim2:
add $s3 $s3 -1 
fim:
move $v0 $s1
add $v1 $s3 1
sub $v1 $v1 $s4
clearCompleteStack
.end_macro



.macro cleanSpace(%space) # not functional

	addi $sp, $sp, -12
 	sw $ra, 12($sp)
 	sw $t0, 8($sp)
 	sw $t1, 4($sp)
 	sw $t2, 0($sp)
 
	la $t0, %space  # Load address of my_buffer
	li $t1, 0          # Load value to write (zero)
	addi $t2, $t0, 18   # Calculate end address (10 bytes)

	loop:
	  sb $t1, 0($t0)    # Store zero at current address
	  addi $t0, $t0, 1   # Increment address
	  blt $t0, $t2, loop  # Loop until end address reached

 	lw $ra, 12($sp)
 	lw $t0, 8($sp)
 	lw $t1, 4($sp)
 	lw $t2, 0($sp)
 	addi $sp, $sp, 12
.end_macro

.macro cleanSpace2 %space %size # not functional

	addi $sp, $sp, -12
 	sw $ra, 12($sp)
 	sw $t0, 8($sp)
 	sw $t1, 4($sp)
 	sw $t2, 0($sp)
 
	la $t0, %space  # Load address of my_buffer
	li $t1, 0          # Load value to write (zero)
	addi $t2, $t0, %size   # Calculate end address (10 bytes)

	loop:
	  sw $t1, ($t0)    # Store zero at current address
	  addi $t0, $t0, 4   # Increment address
	  blt $t0, $t2, loop  # Loop until end address reached

 	lw $ra, 12($sp)
 	lw $t0, 8($sp)
 	lw $t1, 4($sp)
 	lw $t2, 0($sp)
 	addi $sp, $sp, 12
.end_macro

################################################################
# fstream.asm

.eqv READ 0
.eqv WRITE 1

###################################################
# $a0 - nome do arquivo
# $v0 - file descriptorS
.macro openFile %flag # 0: read, 1: write
.data 
mensagemErro: .asciiz "Erro na abertura do arquivo: "
.text
li $v0 13
li $a1 %flag
syscall
bge $v0 0 fim
print_str mensagemErro
print_str
li $v0 10
syscall

fim:
.end_macro

openFile.func.read:
openFile READ
jr $ra

openFile.func.write:
openFile WRITE
jr $ra

####################################################
# $a0 - file_descriptor
# $a1 - string
.macro writeToFile
.data
  error_message: .asciiz "Error writing to file."
.text
  # Get string length (excluding null terminator)
  addi $sp, $sp, -12
  sw $t2, 8($sp)
  sw $t1, 4($sp)
  sw $t0, 0($sp)
  
  move $t2 $a1
  li $t0, 0  # counter for string length
loop:
    lb $t1, 0($t2)  # load byte from string address
    beqz $t1, done_strlen  # branch if null terminator found
    addi $t2, $t2, 1  # move to next character
    addi $t0, $t0, 1  # increment counter
    j loop
  done_strlen:

  # Write the string to the file
  li $v0, 15    # syscall code for write
  move $a2, $t0  # string length (excluding null terminator)
  syscall

  # Check if write was successful
  
  bne $v0, -1, finish
write_error:
  # Handle error (e.g., print message)
  li $v0, 4    # syscall code for print string
  la $a0, error_message  # load error message address
  syscall
  li $v0, 10
  syscall

finish:
  	sw $t2, 8($sp)
  	lw $t1, 4($sp)
  	lw $t0, 0($sp)
  	addi $sp, $sp, 12
.end_macro

#.include "ArrayList.asm"
#.include "iostream.asm"
#.include "readFileBySpace.asm"
#################################
# $a0 - file descriptor
# $v0 - ArrayList com todo o texto do arquivo
# $v1 - tamanho do texto
.macro readFile
.data 
.align 2
space: .space 512
.space 4
mensagemDeErro: .asciiz "Erro na leitura do arquivo"
.text
newCompleteStack
li $v1 0
AL.C $s0 512
move $s3 $a0
readFile.loop:
li $v0 14
move $a0 $s3
la $a1 space
li $a2 512
syscall
bltz $v0 erro
beq $v0 0 fim
add $v1 $v1 $v0
AL.FJA $s0 $a1
cleanSpace2 space 512
j readFile.loop

erro:
print_str mensagemDeErro
li $v0 10 
syscall


fim:
move $v0 $s0
clearCompleteStack
.end_macro

###################################################################################
# asciiConversions.asm

.data
mensagemDeErro1: "Erro número inválido: "

# .include "macroStack.asm" arquivo que usa desse precisa incluir macroStack.asm
# .include "stringManipulation.asm" arquivo que usa desse precisa incluir stringManipulation.asm

# aqui nesse arquivo:
# decimal é "1" : string de 0-9
# hexa é "f" : string de 0-F
# numero é 1 : int binário


# Funções para checar o tipo de caractere

# não está em uso
# .macro bid %registrador %label #branch if ASCII decimal
# blt %registrador 0x30 naoEh
# bgt %registrador 0x39 naoEh
# j %label
# naoEh:
# end_macro

.macro bind %registrador %label #branch if not ASCII decimal
blt %registrador 0x30 %label
bgt %registrador 0x39 %label
.end_macro

# não está em uso
# .macro bih %registrador %label #branch if ASCII hexa
# blt %registrador 0x30 naoEh
# bgt %registrador 0x39 talvez1
# j %label
# talvez1: blt %registrador 0x41 naoEh #A
# bgt %registrador 0x46 talvez2 #F
# j %label
# talvez2: blt %registrador 0x61 naoEh #a
# bgt %registrador 0x66 naoEh #f
# j %label
# naoEh:
# .end_macro

.macro binh %registrador %label #branch if not ASCII hexa
blt %registrador 0x30 %label
bgt %registrador 0x39 talvez1
j Eh
talvez1: blt %registrador 0x41 %label #A
bgt %registrador 0x46 talvez2 #F
j Eh
talvez2: blt %registrador 0x61 %label #a
bgt %registrador 0x66 %label #f
# j Eh
Eh:
.end_macro


# Funções para converter ASCII para numero.
# não checam se é um numero antes de fazer a operação
.macro dton %registrador #decimal to number
and %registrador %registrador 0x0f
.end_macro

.macro hton %registrador #hexa to number
bgt %registrador 0x40, letra # branch if %registrador é entre a-f ou A-F
dton %registrador
j end
letra: add %registrador %registrador 9
and %registrador %registrador 0x0f
end:
.end_macro

##########################################################################################

# Converte a string para um número
# %string é um registrador com um endereço para uma string
# Termina a execução do programa caso tenha algum erro
# Mantem o estado da função que chamou esse macro salvando todos os registradores
.macro asciiToNumber %string
newCompleteStack

la $s0 (%string) # endereço da string
li $s1 0 # indice da caractere na string
li $v0 0 # retorno
li $s4 0 # positivo

comecar:
add $s7 $s0 $s1
lb $s2 ($s7)
beq $s2 0x00 fim

bne $s2 0x2d positivo # -
beq $s4 0x8000 erro
lui $s4 0x8000
add $s1 $s1 1
j comecar

positivo:
bne $s2 0x30 decimal
# 0
add $s1 $s1 1
add $s7 $s0 $s1
lb $s2 ($s7)
beq $s2 0x00 fim
bne $s2 0x78 decimal # se formos colocar suporte para octal, seria aqui

add $s1 $s1 1
hexa:
add $s7 $s0 $s1
lb $s2 ($s7)
beq $s2 0x00 fim
binh $s2 erro
#executa logica se for
mul $v0 $v0 16 # poderia ter usado sll, mas não seria tão trivial detectar overflow
mfhi $s3 # detectar se o numero seja muito grande
bgtz $s3, erro
hton $s2
addu $s5 $v0 $s2
bgtu $v0 $s5 erro
move $v0 $s5
add $s1 $s1 1
j hexa

decimal:
add $s7 $s0 $s1
lb $s2 ($s7)
beq $s2 0x00 fim
bind $s2 erro
#executa logica se for
mul $v0 $v0 10
mfhi $s3 # detectar se o numero seja muito grande
bgtz $s3, erro
dton $s2
addu $s5 $v0 $s2
bgtu $v0 $s5 erro
move $v0 $s5
add $s1 $s1 1
j decimal



erro: li $v0 4
la $a0 mensagemDeErro1
syscall
la $a0 ($s0) # string
syscall

li $v0 10 # exit
syscall

fim: 
bne $s4 0x80000000 continue 
bgtu $v0 $s4 erro
subu $v0 $zero $v0
continue:
clearCompleteStack
.end_macro

##########################################################################################

# Convete o número no registrador para uma string ascii com o número hexadecimal correspondente
# %registrador contem o registrador que possui o número a ser convertido
# v0 recebe o endereço da string 
.macro numberToAscii %registrador
.data
saida: .space 9
.text
newCompleteStack

move $s0 %registrador # numero para ser convertido
li $s1 7 # indice
la $v0 saida

loop:
and $s2 $s0 0xf #seleciona os bits
bgt $s2 9 letras
li $s3 0x0030

save:
add $s3 $s3 $s2
add $s4 $v0 $s1
sb $s3 ($s4)
add $s1 $s1 -1
srl $s0 $s0 4
bge $s1 0 loop
j fim

letras:
li $s3 0x0060
add $s2 $s2 -9
j save

fim:
# v0 tem o endereço da stirng
clearCompleteStack
.end_macro

##########################################################################################

# Macros apenas para ajudar nos testes
.macro testAsciiToNumber %label
la $t0 %label
asciiToNumber $t0
move $a0 $v0
li $v0 1
syscall
li $a0 0x0a
li $v0 11
syscall
.end_macro

.macro testAsciiToNumberUnsigned %label
la $t0 %label
asciiToNumber $t0
move $a0 $v0
li $v0 36
syscall
li $a0 0x0a
li $v0 11
syscall
.end_macro


####################################################################################################################
####################################################################################################################
####################################################################################################################
# funções

.align 2
.text
###########################################
# Código do parser - coloca todo o texto do arquivo a ser compilado em uma string
# Salva a localização dos labels nesse arquivo
# $a0 - nome do arquivo
Parser:
.data
parser.msgErro: .asciiz "Erro - tal palavra não é reconhecida:"
.text
newCompleteStack
# $a0 tem o nome do arquivo
openFile READ
move $a0 $v0
move $s7 $v1 # numero de chars lidas
la $t0 FileDescriptor
sw $a0 ($t0)

readFile
move $s1 $v1
la $s4 ArrayListTextoEntrada
lw $s0 0($v0) #array
lw $t1 4($v0) #capacidade
lw $t2 8($v0) #tamanho

sw $s0 0($s4)
sw $t1 4($s4)
sw $t2 8($s4)

# prepara para armazenar os labels
jal iniciarLabels
li $s2 0 #index
la $s3 AL.opcodes
li $a1 0x00100000 # endereço da instrução
parser.loop:
getArrayListInString $s0 $s2
beqz $v1 parser.fim #somente será zero se encontrar caractere nulo
move $s5 $v0
lw $a0 ($v0) # palavra

AL.FS $s3 $a0
bltz $v0 parser.naoEhOpcode
add $a1 $a1 1
add $s2 $s2 $v1 # caracters lidas
j parser.loop

parser.naoEhOpcode:
jal identificaLabel
beqz $v0 parser.continue
AL.DL $s5
lw $a0 ($s5)
jal adicionarLabel
ArrayList.DeleteRange $s4 $s2 $v1
j parser.loop

parser.continue:
add $s2 $s2 $v1 # caracters lidas
j parser.loop


parser.erroNaoEhLabel: # nao faz sentido
print_str parser.msgErro
print_str
EOL

li $v0 10
syscall

parser.fim:
clearCompleteStack
jr $ra


#################################################
# Lógica dos labels
#
.data
.align 2
ArrayListDeLabels.Nomes: .word 0x00 0x00 0x00
ArrayListDeLabels.Enderecos: .word 0x00 0x00 0x00

.text

# Inicializa as listas dinamicas de Labels. 
iniciarLabels:
newCompleteStack
la $s0 ArrayListDeLabels.Nomes
AL.C $s1       # cria array list
lw $s2 ($s1)   # pega todos os valores da ArrayList
lw $s3 4($s1)
lw $s4 8($s1)
sw $s2 ($s0)   # salva eles na localização de ArrayListDeLabels
sw $s3 4($s0)
sw $s4 8($s0)

la $s0 ArrayListDeLabels.Enderecos
AL.C $s1       # cria array list
lw $s2 ($s1)   # pega todos os valores da ArrayList
lw $s3 4($s1)
lw $s4 8($s1)
sw $s2 ($s0)   # salva eles na localização de ArrayListDeLabels
sw $s3 4($s0)
sw $s4 8($s0)

clearCompleteStack
jr $ra


# $a0 é uma string*
# $v0 recebe se é ou não
identificaLabel:
li $t0 0 # index
li $v0 0
li $t3 0 # penultimo byte lido

identificaLabel.loop:
move $t3 $t2

add $t1 $a0 $t0
lb $t2 ($t1)

add $t0 $t0 1
beq $t2 0x00 identificaLabel.parou
beq $t2 0x20 identificaLabel.parou
beq $t2 0x0A identificaLabel.parou
j identificaLabel.loop

identificaLabel.parou:
bne $t3 0x3a identificaLabel.nao # 3a = ":"
li $v0 1
identificaLabel.nao:
jr $ra


# $a0 é uma string*
# $a1 é o endereço
adicionarLabel:
newArgsStack
la $a2 ArrayListDeLabels.Nomes
AL.AW $a2 $a0
la $a2 ArrayListDeLabels.Enderecos
AL.AW $a2 $a1
clearArgsStack
jr $ra

# $a0 string
print:
print_str
jr $ra

######################################################
# registradores reservados: 			     #	
#    file descriptor para arquivo de entrada: $s0    #
#    file descriptor para arquivo texto : $s1	     #
#    file descriptor para arquivo data : $s2	     #
######################################################
.data
filepath:    .asciiz "example_saida.asm"
text:   .asciiz "data.mif"     
data:   .asciiz "text.mif"

palavra1: .space 32
palavra2: .space 32
palavra3: .space 32
palavra4: .space 32
palavra5: .space 32
palavra6: .space 32

data_header: .asciiz "DEPTH = 16384;\nWIDTH = 32;\nADDRESS_RADIX = HEX;\nDATA_RADIX = HEX;\nCONTENT\nBEGIN\n\n"
text_header: .asciiz "DEPTH = 4096;\nWIDTH = 32;\nADDRESS_RADIX = HEX;\nDATA_RADIX = HEX;\nCONTENT\nBEGIN\n\n"
separador:  .asciiz " : "
quebralinha:  .asciiz "\n"
error:    .asciiz "valor nao reconhecido"
data_word: .asciiz ".data"

buffer:   .space  4
everything: .space 100


##########################################################################
# Parser
##########################################################################
.data 
ArrayListTextoEntrada: .word 0x00 0x00 0x00
FileDescriptor: .word 0x00

.align 2

.data
.align 2
ladd:    .asciiz "add\0\0\0"    
.align 2
laddi:   .asciiz "addi\0\0\0"   
.align 2
laddiu:  .asciiz "addiu\0\0\0"  
.align 2
laddu:   .asciiz "addu\0\0\0"   
.align 2
land:    .asciiz "and\0\0\0"    
.align 2
landi:   .asciiz "andi\0\0\0"   
.align 2
lbeq:    .asciiz "beq\0\0\0"    
.align 2
lbgez:   .asciiz "bgez\0\0\0"   
.align 2
lbgezal: .asciiz "bgezal\0\0\0" 
.align 2
lbltzal: .asciiz "bltzal\0\0\0" 
.align 2
lbne:    .asciiz "bne\0\0\0"    
.align 2
lclo:    .asciiz "clo\0\0\0"    
.align 2
lclz:    .asciiz "clz\0\0\0"    
.align 2
ldiv:    .asciiz "div\0\0\0"    
.align 2
lj:      .asciiz "j\0\0\0"      
.align 2
ljal:    .asciiz "jal\0\0\0"    
.align 2
ljalr:   .asciiz "jalr\0\0\0"   
.align 2
ljr:     .asciiz "jr\0\0\0"     
.align 2
llb:     .asciiz "lb\0\0\0"     
.align 2
llhu:    .asciiz "lhu\0\0\0"    
.align 2
llui:    .asciiz "lui\0\0\0"    
.align 2
llw:     .asciiz "lw\0\0\0"     
.align 2
lmfhi:   .asciiz "mfhi\0\0\0"   
.align 2
lmflo:   .asciiz "mflo\0\0\0"   
.align 2
lmovn:   .asciiz "movn\0\0\0"   
.align 2
lmul:    .asciiz "mul\0\0\0"    
.align 2
lmult:   .asciiz "mult\0\0\0"   
.align 2
lnor:    .asciiz "nor\0\0\0"    
.align 2
lor:     .asciiz "or\0\0\0"     
.align 2
lori:    .asciiz "ori\0\0\0"    
.align 2
lsb:     .asciiz "sb\0\0\0"     
.align 2
lsll:    .asciiz "sll\0\0\0"    
.align 2
lsllv:   .asciiz "sllv\0\0\0"   
.align 2
lslt:    .asciiz "slt\0\0\0"    
.align 2
lslti:   .asciiz "slti\0\0\0"   
.align 2
lsltu:   .asciiz "sltu\0\0\0"   
.align 2
lsra:    .asciiz "sra\0\0\0"    
.align 2
lsrav:   .asciiz "srav\0\0\0"   
.align 2
lsrl:    .asciiz "srl\0\0\0"    
.align 2
lsub:    .asciiz "sub\0\0\0"    
.align 2
lsubu:   .asciiz "subu\0\0\0"   
.align 2
lsw:     .asciiz "sw\0\0\0"     
.align 2
lxor:    .asciiz "xor\0\0\0"    
.align 2
lxori:   .asciiz "xori\0\0\0"   
.align 2

.align 2

opcodes: .word ladd laddi laddiu laddu land landi lbeq lbgez lbgezal lbltzal 
.word lbne lclo lclz ldiv lj ljal ljalr ljr llb llhu 
.word llui llw lmfhi lmflo lmovn lmul lmult lnor lor lori
.word lsb lsll lsllv lslt lslti lsltu lsra lsrav lsrl lsub
.word lsubu lsw lxor lxori
.space 4

AL.opcodes: .word opcodes 176 176
.align 2


################################################################################
################################################################################
################################################################################
# Roteador.asm
#.include "macroStack.asm"
#.include "stringManipulation.asm"
#.include "readFileBySpace.asm"

.data
lenghtTabela: .word 44

msgErroOpcodeInexistente: .asciiz "Erro Opcode Inexistente - "

.align 2

.eqv tabelaOpcode opcodes
                 # add  addi addiu addu and  andi beq  bgez bgezal bltzal bne  clo  clz  div  j    jal  jalr jr   lb   lhu  lui  lw   mfhi mflo movn mul  mult nor  or   ori  sb   sll  sllv slt  slti sltu sra  srav srl  sub  subu sw   xor  xori
tabela26.31: .byte 0x40 0x48 0x49  0x40 0x40 0x4c 0x44 0x41 0x41   0x41   0x45 0x5c 0x5c 0x40 0x42 0x43 0x40 0x40 0x60 0x65 0x4f 0x63 0x40 0x40 0x40 0x5c 0x40 0x40 0x40 0x4d 0x68 0x40 0x40 0x40 0x4a 0x40 0x40 0x40 0x40 0x40 0x40 0x6b 0x40 0x4e
tabela21.25: .byte 0x01 0x01 0x01  0x01 0x01 0x01 0x01 0x01 0x01   0x01   0x01 0x01 0x01 0x01 0x05 0x05 0x01 0x01 0x01 0x01 0x01 0x01 0x40 0x40 0x01 0x01 0x01 0x01 0x01 0x01 0x01 0x40 0x01 0x01 0x01 0x01 0x40 0x01 0x40 0x01 0x01 0x01 0x01 0x01 
tabela16.20: .byte 0x01 0x01 0x01  0x01 0x01 0x01 0x01 0x41 0x51   0x50   0x01 0x40 0x40 0x01 0x00 0x00 0x40 0x40 0x03 0x03 0x40 0x03 0x40 0x40 0x01 0x01 0x01 0x01 0x01 0x01 0x01 0x01 0x01 0x01 0x01 0x01 0x01 0x01 0x01 0x01 0x01 0x01 0x01 0x01 
tabela11.15: .byte 0x01 0x02 0x02  0x01 0x01 0x02 0x04 0x04 0x04   0x04   0x04 0x01 0x01 0x40 0x00 0x00 0x40 0x40 0x00 0x00 0x02 0x00 0x01 0x01 0x01 0x01 0x40 0x01 0x01 0x02 0x03 0x01 0x01 0x01 0x02 0x01 0x01 0x01 0x01 0x01 0x01 0x03 0x01 0x02 
tabela6.10:  .byte 0x40 0x00 0x00  0x40 0x40 0x00 0x00 0x00 0x00   0x00   0x00 0x40 0x40 0x40 0x00 0x00 0x40 0x40 0x00 0x00 0x00 0x00 0x40 0x40 0x40 0x40 0x40 0x40 0x40 0x00 0x00 0x06 0x40 0x40 0x00 0x40 0x06 0x04 0x06 0x40 0x40 0x00 0x40 0x00 
tabela0.5:   .byte 0x60 0x00 0x00  0x61 0x64 0x00 0x00 0x00 0x00   0x00   0x00 0x61 0x60 0x5a 0x00 0x00 0x49 0x48 0x00 0x00 0x00 0x00 0x50 0x52 0x4b 0x42 0x58 0x67 0x65 0x00 0x00 0x40 0x44 0x6a 0x00 0x6b 0x43 0x47 0x42 0x62 0x63 0x00 0x66 0x00 # literal

# numero do opcode
# reg, target, literal
# reg, literal
# reg, imediate, offset pc, offset, literal
# literal, shamt
# literal

# 0x00 ignora
# 0x01 indentica registrador
# 0x02 indentifica imediato
# 0x03 indentifica offset
# 0x04 indentifica offset pc
# 0x05 indentifica target
# 0x06 indentifica sa
# 0x4  literal

.align 2

.eqv rs 21
.eqv rt 16
.eqv rd 11
.eqv imm 0
.eqv off 0

tabelaValores: .word tabela26.31 tabela21.25 tabela16.20 tabela11.15 tabela6.10 tabela0.5

                      #   add  addi addiu addu and  andi beq  bgez bgezal bltzal bne  clo  clz  div  j    jal  jalr jr   lb   lhu  lui  lw   mfhi mflo movn mul  mult nor  or   ori  sb   sll  sllv slt  slti sltu sra  srav srl  sub  subu sw   xor  xori
quantidadeDeShamt1: .byte 26   26   26    26   26   26   26   26   26     26     26   26   26   26   26   26   26   26   26   26   26   26   26   26   26   26   26   26   26   26   26   26   26   26   26   26   26   26   26   26   26   26   26   26   # geralmente sempre 26-31
quantidadeDeShamt2: .byte rd   rt   rt    rd   rd   rt   rs   rs   21     21     21   11   21   21    0    0   21   21   16   16   16   16   21   21   21   21   21   21   21   21   21   21   21   21   21   21   21   21   21   21   21   21   21   21   # 21-25
quantidadeDeShamt3: .byte rs   rs   rs    rs   rs   rs   rt   rt    0      0     16   21   21   16   16   16   16   11    0    0   11    0   16   16   11   11   11   11   11   11   11   11   11   11   11   11   11   11   11   11   11   11   11   11   11   # 16-20
quantidadeDeShamt4: .byte rt    0    0    rt   rt   imm  off  off  11     11      0   11   11   11   11   11   11   16   11   11    0   11   11   11   16   16   16   16   16   16   16   16   16   16   16   16   16   16   16   16   16   16   16   16   # 11-15
quantidadeDeShamt5: .byte  6    6    6     6    6    6    6    6    6      6      6    6    6    6    6    6    6    6    6    6    6    6    6    6    6    6    6    6    6    6    6    6    6    6    6    6    6    6    6    6    6    6    6    6   # 6-10
quantidadeDeShamt6: .byte  0    0    0     0    0    0    0    0    0      0      0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0   # 0-5

# opcode = 26

# offset = 0

.align 2

quantidadeDeShamtTable: .word quantidadeDeShamt1 quantidadeDeShamt2 quantidadeDeShamt3 quantidadeDeShamt4 quantidadeDeShamt5 quantidadeDeShamt6

.align 2

file: .asciiz "example_saida_simples.asm"
saida: .asciiz "teste2.asm"

registrador: .asciiz "registrador!\n"
imediato: .asciiz "imdeidato!\n"



###################
.text
###################


.macro literal %reg
and %reg %reg 0x7f
.end_macro

.macro beqal %reg %regOuIme %label # branch if equal and link
bne %reg %regOuIme fim
jal %label
fim:
.end_macro

.macro bgeal %reg %regOuIme %label # branch if greater of equal and link
blt %reg %regOuIme fim
jal %label
fim:
.end_macro


#.include "fstream.asm"
#.include "iostream.asm"
#.include "asciiConversions.asm"

.text 

# $a0 contem a string da instrução
# $a1 contem o index dessa string no array
# $a2 contem o file descriptor do arquivo de saida .text
Roteador:
newCompleteStack
move $s1 $a1
move $s2 $a2

EOL
print_str
SPACE

li $s0 0 #instrução

lw $t0 lenghtTabela
sll $t0 $t0 2 # multiplica por 4, será util no meio do codigo

la $t2 tabelaOpcode
li $s3 0 # indice da coluna, anda de 4 em 4

# o objetivo aqui é descobrir em qual coluna da tabela a string em $a0 está
# for string in tabelaOpcode do
Roteador.Coluna:
add $t5 $s3 $t2
lw $t5 ($t5) # $t5 tem a string a ser checada
compareStringsReg $t5 $a0
beq $v0 1 Roteador.Linha

add $s3 $s3 4 # soma 4 pois estamos caminhando em words
bgt $s3 $t0 erroOpcodeInexistente
j Roteador.Coluna


###################

Roteador.Linha:
li $s4 0 # indice da linha, anda de 4 em 4
srl $s3 $s3 2 # de word para byte
Roteador.LinhaLoop:
la $t2 tabelaValores
add $t2 $s4 $t2
lw $t2 ($t2)

add $t5 $s3 $t2
lb $a1 ($t5)
beq $a1 0x00 Roteador.Ignora # continua
blt $a1 0x40 Roteador.LerPalavra 
add $v0 $a1 -0x40 # Roteador.literal
j Roteador.Escrever

# ler proxima palavra
Roteador.LerPalavra:
move $t6 $v0
lw $t7 ArrayListTextoEntrada
getWordInString $t7 $s1 # t7 livre
move $a0 $v0
print_str
add $s1 $s1 $v1
move $v0 $t6 # t6 livre

beqal $a1 0x01 Roteador.Registrador
beqal $a1 0x02 Roteador.Imediato
beqal $a1 0x03 Roteador.Offset
beqal $a1 0x04 Roteador.OffsetPc
beqal $a1 0x05 Roteador.Target
beqal $a1 0x06 Roteador.Sa
# a partir desse ponto $v0 possui o valor a adicionar

Roteador.Escrever:
# descobrir posição do valor de $v0
la $t7 quantidadeDeShamtTable
add $t6 $s4 $t7 
lw $t6 ($t6)
add $t6 $t6 $s3
lb $t6 ($t6) # $t6 possui o shift 

sllv $v0 $v0 $t6
add $s0 $s0 $v0 # valor adicionado na instrução

Roteador.Ignora:
add $s4 $s4 4
bgt $s4 20 Roteador.Fim
j Roteador.LinhaLoop

erroOpcodeInexistente:
print_str msgErroOpcodeInexistente
print_str

li $v0 10
syscall # termina o programa


Roteador.Fim:
move $a0 $s0
jal escreverInstrucao
move $v1 $s1
clearCompleteStack
jr $ra

escreverInstrucao:
numberToAscii $a0
move $a1 $v0 # string
move $a0 $s2 # file descriptor
writeToFile
.data
space: .asciiz "\n"
.text
la $a1 space
writeToFile
move $a0 $a1 #?
#print_str
jr $ra


# $a0 - string que representa o registrador a ser decodificado
# $a1 - nao mexer
# $v0 - valor equivalente
Roteador.Registrador:
newArgsStack
#print_str registrador
#print_str
#EOL
li $v0 0
clearArgsStack
jr $ra #Roteador.Registrador end

Roteador.Imediato:
li $v0 0
jr $ra #Roteador.Imediato end

Roteador.Offset:
li $v0 0
jr $ra #Roteador.Offset end

Roteador.OffsetPc:
li $v0 0
jr $ra #Roteador.OffsetPc end

Roteador.Target:
la $t0 ArrayListDeLabels.Nomes
AL.FS $t0 $a0 # v0 tem o index da palavra
lw $t0 ArrayListDeLabels.Enderecos
sll $v0 $v0 2
add $t0 $t0 $v0
lw $v0 ($t0)
jr $ra #Roteador.Target end

Roteador.Sa:
li $v0 0
jr $ra #Roteador.Sa end


# $a0 - string
# $a1 - index
getWordInString.Func:
getWordInString $a0 $a1
jr $ra

