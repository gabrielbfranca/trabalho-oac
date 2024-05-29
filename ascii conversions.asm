.data
teste1: .asciiz "16"
teste2: .asciiz "0x10"
teste3: .asciiz "123456789" 
teste4: .asciiz "0x" # vai retornar 0
teste5: .asciiz "0f" # não é numero
teste6: .asciiz "0xfffffffff" # muito grande
mensagem: .asciiz "oi"

mensagemDeErro1: "Erro número inválido: "

.include "macroStack.asm"

# aqui nesse arquivo:
# decimal é "1" : string de 0-9
# hexa é "f" : string de 0-F
# numero é 1 : int binária


# Funções para checar o tipo de caractere
.macro bid %registrador %label #branch if ASCII decimal
blt %registrador 0x30 naoEh
bgt %registrador 0x39 naoEh
j %label
naoEh:
.end_macro

.macro bind %registrador %label #branch if not ASCII decimal
blt %registrador 0x30 %label
bgt %registrador 0x39 %label
.end_macro

.macro bih %registrador %label #branch if ASCII hexa
blt %registrador 0x30 naoEh
bgt %registrador 0x39 talvez1
j %label
talvez1: blt %registrador 0x41 naoEh #A
bgt %registrador 0x46 talvez2 #F
j %label
talvez2: blt %registrador 0x61 naoEh #a
bgt %registrador 0x66 naoEh #f
j %label
naoEh:
.end_macro

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


# Funções para converter de ASCII para número.
# Não checam se é um numero antes de fazer a operação
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

# Converte a string para um número
# %string é um registrador com um endereço para uma string
# Termina a execução do programa caso tenha algum erro
# Mantem o estado da função que chamou esse macro salvando todos os registradores
.macro asciiToNumber %string
newCompleteStack

add $s0 $zero %string # endereço da string
li $s1 0 # indice da caractere na string
li $v0 0 # retorno

lb $s2 0($t0)
beq $s2 0x00 fim
bne $s2 0x30 decimal

lb $s2 1($t0)
beq $s2 0x00 fim
bne $s2 0x78 decimal # se formos colocar suporte para octal, seria aqui

add $s1 $s1 2
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
add $v0 $v0 $s2
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
add $v0 $v0 $s2
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
clearCompleteStack
.end_macro

.text
la $t0 teste1
asciiToNumber $t0
move $a0 $v0
li $v0 1
syscall
li $a0 0x0a
li $v0 11
syscall

la $t0 teste2
asciiToNumber $t0
move $a0 $v0
li $v0 1
syscall
li $a0 0x0a
li $v0 11
syscall

la $t0 teste3
asciiToNumber $t0
move $a0 $v0
li $v0 1
syscall
li $a0 0x0a
li $v0 11
syscall

la $t0 teste4
asciiToNumber $t0
move $a0 $v0
li $v0 1
syscall
li $a0 0x0a
li $v0 11
syscall

la $t0 teste5
asciiToNumber $t0
move $a0 $v0
li $v0 1
syscall
li $a0 0x0a
li $v0 11
syscall

fim:
li $v0 10
syscall

