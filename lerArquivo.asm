.data
fileDescriptor: .word 0x00000000
entrada: .space 4096
nomeDaEntrada: .asciiz "example_saida.asm"

gambiarra: .space 2 #o nomeDaEntrada termina numa word de 2 bytes, por isso é preciso 
#adicionar esse espaçamento de 2 bytes para que as proximas entradas estejam alinhadas na memória

linha: .space 256

palavra1: .space 32
palavra2: .space 32
palavra3: .space 32
palavra4: .space 32
palavra5: .space 32
palavra6: .space 32
palavraList: .word palavra1, palavra2, palavra3, palavra4, palavra5, palavra6

lerTextoErro1.text: .asciiz "Erro lerTexto1 - texto muito grande"
lerTextoErro2.text: .asciiz "Erro lerTexto2 - erro na leitura do arquivo"

.text

jal abreTexto

move $a0, $v0
jal lerTexto


#li $s7, 6 #para pegar outra linha
la $a0, entrada
la $a1, linha
jal proximaLinha








la $t0, linha
li $v0, 11 #print char

loop: lw $t1, ($t0)
li $t7, 4
move $a0, $t1
jal printChar
add $t0, $t0, 4
bne $t1, 0, loop


fim: li $v0, 10
syscall #fim

# ============================================================== #

abreTexto: #sem entradas
li   $v0, 13
la   $a0, nomeDaEntrada
li   $a1, 0        
li   $a2, 0 
syscall
la $t0, fileDescriptor
sw $v0, ($t0) #v0 recebe fileDescriptor
jr $ra

# ------------------------------------------------------------- #

lerTexto: #a0 - fileDescriptor
la $t0, entrada
#ler arquivo e colocar em texto
li $v0, 14
move $a1, $t0
li $a2, 4096
syscall #v0 recebe o número de caracteres lidas
#bgt $v0, 4096, lerTextoErro1 # TODO: precisamos criar logica para caso o arquivo ultrapasse o limite de caracteres
blt $v0, 0, lerTextoErro2
jr $ra

lerTextoErro1: la $a0 lerTextoErro1.text
li $v0, 4 #print string
syscall
j fim
lerTextoErro2: la $a0 lerTextoErro2.text
li $v0, 4 #print string
syscall
j fim


# ---------------------------------------------------------- #

proximaLinha:
add $sp, $sp, -12
sw $a0, 8($sp)
sw $ra, 4($sp)
sw $fp, ($sp)
add $fp, $sp, 8

la $t5, linha
add $sp, $sp, -4 #ponteiro da linha
sw $t5, ($sp)
move $t4, $zero #indice para cada 4 caracteres na linha
move $t3, $zero #indice de qual caractere dentro do bloco de 32 bits * 8

li $t0, 4
div $s7, $t0
mflo $t7 #quociente
mfhi $t6 #resto

sll $t7, $t7, 2 #multiplica por 4
add $t7, $t7, $a0 

sll $t6, $t6, 3 #multiplica por 8

proximaLinhaLoop2:
lw $t0, ($t7) #palavra
proximaLinhaLoop1:
add $s7, $s7, 1
srlv $t1, $t0, $t6
and $t1, $t1, 0x00ff
beq $t1, 0x000a, interromperProximaLinha

#salva caractere
lw $t5, -12($fp) #ponteiro da linha
add $t2, $t4, $t5
lw $t5, ($t2)
sllv $t1, $t1, $t3
xor $t5, $t5, $t1 #add
sw $t5, ($t2)
add $t3, $t3, 8
bne $t3, 32, proximaLinhaIf1
add $t4, $t4, 4
move $t3, $zero
proximaLinhaIf1:

add $t6, $t6, 8
bne $t6, 32, proximaLinhaLoop1
move $t6, $zero
add $t7, $t7, 4
j proximaLinhaLoop2


interromperProximaLinha:
add $sp, $sp, 4 #ponteiro da linha

lw $ra, -4($fp)
lw $fp, -8($fp)
add $sp, $sp, 12
jr $ra


# ------------------------------------------------------- #

separarPalavras:
add $sp, $sp, -16
sw $a0, 12($sp)
sw $a1, 8($sp)
sw $ra, 4($sp)
sw $fp, ($sp)

add $fp, $sp, 12
	
move $t7, $a0
move $t6, $a1

move $t5, $zero #indice da caractere na linha
move $t4, $zero #indice da palavra na lista de palavras

separarPalavraLoop1:
add $t1, $t7, $t5
lw $t0, ($t1)
separarPalavraLoop2:
and $t0, 0x00ff
beq $t0, 



lw $ra, -8($fp)
lw $fp, -12($fp)

jr $ra

# ----------------------------------------------------- #




printChar: syscall
srl $a0, $a0, 8
add $t7, $t7, -1
bne $t7, 0, printChar
jr $ra
