.data
texto: .asciiz "Expectativa de resultado para fibonacci(25): 75025 \n"
texto1: .asciiz "Expectativa de resultado para fibonacci(20): 6765 \n"

.text
.include "macroStack.asm"

la $a0 texto
li $v0 4 # print string
syscall

la $a0 texto1
li $v0 4 # print string
syscall

li $a0 20 # fibonacci(n)
jal fibonacci

move $a0 $v0 # printando o resultado
li $v0 1 # print integer
syscall

fim : li $v0 10 # exit
syscall


fibonacci:
newSimpleStack
bgt $a0 2 fibonacciIf1
li $v0 1 
clearSimpleStack
jr $ra
fibonacciIf1:
add $sp $sp -8 # cria espaço para duas variáveis
add $a0 $a0 -1 # prepara a primeira chamda
jal fibonacci
sw $v0 -4($fp)

lw $a0 8($fp)
add $a0 $a0 -2
jal fibonacci

lw $t0 -4($fp)
add $v0 $v0 $t0 #retorno

clearSimpleStack
jr $ra



