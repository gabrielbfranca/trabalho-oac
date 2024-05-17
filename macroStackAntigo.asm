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
sw $a0 8($sp) #($fp)    - $a0
sw $ra 4($sp)  #-4($fp) - antigo $ra
sw $fp ($sp)   #-8($fp) - antigo $fp
               #-12($fp) e em diante: variáveis locais
add $fp $sp 8
.end_macro

# macro clearSimpleStack
# reatribui os valores antigos de $ra e $fp
# limpa o espaço no Stack criado por newSimpleStack 
# os espaços criados depois devem ser limpados manualmente
# usado no fim de funções que chamaram newSimpleStack
.macro clearSimpleStack
lw $ra -4($fp)
lw $fp -8($fp)

add $sp $sp 12
.end_macro


#######################################################################

# macro newArgsStack
# coloca na stack informações para a criação de um novo escopo
# contempla todo o leque de regitradores $a
# usado no começo de funções
.macro newArgsStack
add $sp $sp -24
sw $a0 20($sp) #($fp)    - $a0
sw $a1 16($sp) #-4($fp)  - $a1
sw $a2 12($sp) #-8($fp)  - $a2
sw $a3 8($sp)  #-12($fp) - $a3
sw $ra 4($sp)  #-16($fp) - antigo $ra
sw $fp ($sp)   #-20($fp) - antigo $fp
               #-24($fp) e em diante: variáveis locais
add $fp $sp 20
.end_macro

# macro clearArgsStack
# reatribui os valores antigos de $ra e $fp
# limpa o espaço no Stack criado por newArgsStack 
# os espaços criados depois devem ser limpados manualmente
# usado no fim de funções que chamaram newArgsStack
.macro clearArgsStack
lw $ra -16($fp)
lw $fp -20($fp)

add $sp $sp 24
.end_macro


#######################################################################

# macro newCompleteStack
# salva automaticamente todas as informções de estado de uma função
# incluindo os registradores $s0-$s7, permitindo que eles sejam
# utilizados pela função que pede essa Stack
.macro newCompleteStack
newArgsStack
add $sp $sp -32
# aqui o scopo já é iniciado por newArgsStack, logo 
# podemos usar o $fp para salvar os dados
sw $s0 -24($fp) # -24($fp) - valor de $s0 quando a função foi chamada
sw $s1 -28($fp) # etc
sw $s2 -32($fp)
sw $s3 -36($fp)
sw $s4 -40($fp)
sw $s5 -44($fp)
sw $s6 -48($fp)
sw $s7 -52($fp)
                # -56($fp) e em diante: variáveis locais
.end_macro

# macro clearCompleteStack
# reatribui os valores antigos de $ra e $fp
# limpa o espaço no Stack criado por newCompleteStack 
# os espaços criados depois devem ser limpados manualmente
# usado no fim de funções que chamaram newComleteStack
.macro clearCompleteStack
lw $s0 -24($fp) # recupera os valores antigos dos registradores $s
lw $s1 -28($fp)
lw $s2 -32($fp)
lw $s3 -36($fp)
lw $s4 -40($fp)
lw $s5 -44($fp)
lw $s6 -48($fp)
lw $s7 -52($fp)
add $sp $sp 32
clearArgsStack
.end_macro


#######################################################################
