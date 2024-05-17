# Macros para facilitar a cria��o e o fim de escopos alocando e desalocando espa�o na Stack
# 
# baseado em https://lisha.ufsc.br/teaching/sys/stack.pdf
#
#

# macro newSimpleStack
# coloca na stack informa��es para a cria��o de um novo escopo
# atribui o minimo de espa�os possiveis
# usado no come�o de fun��es
.macro newSimpleStack
add $sp $sp -12
sw $a0 8($sp)  #8($fp) - $a0
sw $ra 4($sp)  #4($fp) - antigo $ra
sw $fp 0($sp)  #0($fp) - antigo $fp
move $fp $sp
               #-4($fp)
               #-8($fp)
               #etc - vari�veis locais
.end_macro

# macro clearSimpleStack
# reatribui os valores antigos de $ra, $fp e $a0
# limpa o espa�o no Stack criado por newSimpleStack 
# os espa�os criados depois s�o limpados automaticamente
# usado no fim de fun��es que chamaram newSimpleStack
.macro clearSimpleStack
move $sp $fp
lw $a0 8($sp)
lw $ra 4($sp)
lw $fp 0($sp)

add $sp $sp 12
.end_macro


#######################################################################

# macro newArgsStack
# coloca na stack informa��es para a cria��o de um novo escopo
# contempla todo o leque de regitradores $a
# usado no come�o de fun��es
.macro newArgsStack
add $sp $sp -12
# aqui o scopo j� � iniciado parcilmente por newSimpleStack
sw $a3 8($sp)  #20($fp) - $a3
sw $a2 4($sp)  #16($fp) - $a2
sw $a1 0($sp)  #12($fp) - $a1
newSimpleStack #8($fp)  - $a0
               #4($fp)  - antigo $ra
               #0($fp)  - antigo $fp

               #-4($fp)
               #-8($fp)
               #etc     - vari�veis locais
.end_macro

# macro clearArgsStack
# reatribui os valores antigos de $ra, $fp e registradores $a
# limpa o espa�o no Stack criado por newArgsStack 
# os espa�os criados depois s�o limpados automaticamente
# usado no fim de fun��es que chamaram newArgsStack
.macro clearArgsStack
clearSimpleStack
sw $a3 8($sp) # recupera os valores dos registradores $a
sw $a2 4($sp)
sw $a1 0($sp)

add $sp $sp 12
.end_macro


#######################################################################

# macro newCompleteStack
# salva automaticamente todas as inform��es de estado de uma fun��o
# incluindo os registradores $s0-$s7, permitindo que eles sejam
# utilizados pela fun��o que pede essa Stack
# Nota - comparado com SimpleStack, CompleteStack usa 2,3 mais instru��es
.macro newCompleteStack

add $sp $sp -32
# aqui o scopo j� � iniciado parcilmente por newArgsStack
sw $s7 28($sp) #52($fp) - $s7
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
               #etc     - vari�veis locais
.end_macro

# macro clearCompleteStack
# reatribui os valores antigos de $ra, $fp, $a, e $s
# limpa o espa�o no Stack criado por newCompleteStack 
# os espa�os criados depois s�o limpados automaticamente
# usado no fim de fun��es que chamaram newComleteStack
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
