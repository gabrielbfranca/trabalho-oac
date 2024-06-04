.data
mensagemDeErro1: "Erro número inválido: "

.include "macroStack.asm"
.include "stringManipulation.asm"

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
saida: .space 8
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
