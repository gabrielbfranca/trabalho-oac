.data
teste1: .asciiz "16"
teste2: .asciiz "0x10"
teste3: .asciiz "123456789"
teste4: .asciiz "4294967295" #unsigned
teste5: .asciiz "0xffffffff" #unsigned
teste6: .asciiz "0x" # vai retornar 0
teste7: .asciiz "0"
teste8: .asciiz "-1"
teste9: .asciiz "-0x1"
teste10: .asciiz "-0"
teste11: .asciiz "-2147483648"
teste12: .asciiz "-0x80000000"
teste13: .asciiz "-2147483649"
teste14: .asciiz "-0x80000001"
teste15: .asciiz "4294967296" # muito grande
teste16: .asciiz "0x100000000" # muito grande
teste17: .asciiz "0f" # n�o � numero

mensagem: .asciiz "oi"

mensagemDeErro1: "Erro n�mero inv�lido: "

.include "macroStack.asm"

# aqui nesse arquivo:
# decimal � "1" : string de 0-9
# hexa � "f" : string de 0-F
# numero � 1 : int bin�ria


# Fun��es para checar o tipo de caractere

# n�o est� em uso
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

# n�o est� em uso
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


# Fun��es para converter de ASCII para n�mero.
# N�o checam se � um numero antes de fazer a opera��o
.macro dton %registrador #decimal to number
and %registrador %registrador 0x0f
.end_macro

.macro hton %registrador #hexa to number
bgt %registrador 0x40, letra # branch if %registrador � entre a-f ou A-F
dton %registrador
j end
letra: add %registrador %registrador 9
and %registrador %registrador 0x0f
end:
.end_macro

# Converte a string para um n�mero
# %string � um registrador com um endere�o para uma string
# Termina a execu��o do programa caso tenha algum erro
# Mantem o estado da fun��o que chamou esse macro salvando todos os registradores
.macro asciiToNumber %string
newCompleteStack

la $s0 (%string) # endere�o da string
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
mul $v0 $v0 16 # poderia ter usado sll, mas n�o seria t�o trivial detectar overflow
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

.text

# Exemplo de uso:
la $t0 teste1
asciiToNumber $t0

testAsciiToNumber teste1
testAsciiToNumber teste2
testAsciiToNumber teste3
testAsciiToNumberUnsigned teste4
testAsciiToNumberUnsigned teste5
testAsciiToNumber teste6
testAsciiToNumber teste7
testAsciiToNumber teste8
testAsciiToNumber teste9
testAsciiToNumber teste10
testAsciiToNumber teste11
testAsciiToNumber teste12
#Erros:
#testAsciiToNumber teste13
#testAsciiToNumber teste14
#testAsciiToNumber teste15
#testAsciiToNumber teste16
#testAsciiToNumber teste17
#testAsciiToNumber mensagem


fim:
li $v0 10
syscall

