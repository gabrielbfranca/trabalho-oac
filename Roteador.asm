.include "macroStack.asm"
.include "stringManipulation.asm"
.include "readFileBySpace.asm"

.data
lenghtTabela: .word 3

msgErroOpcodeInexistente: .asciiz "Erro Opcode Inexistente"

ladd:  .asciiz "add"
laddi: .asciiz "addi"
lmflo: .asciiz "mflo"
llw: .asciiz "lw"
lbeq: .asciiz "beq"
lj: .asciiz "j"
lsrl: .asciiz "srl"
# esse "l" é necessário pois não pode ter label com nome de instrução

.align 2

tabelaOpcode: .word ladd laddi lmflo llw lbeq lj lsrl
                 # add  addi mflo lw   beq  j    srl
tabela26.31: .byte 0x40 0x44 0x40 0x63 0x44 0x42 0x40 # numero do opcode
tabela21.25: .byte 0x01 0x01 0x40 0x00 0x01 0x00 0x40 # reg, target, literal
tabela16.20: .byte 0x01 0x01 0x40 0x01 0x01 0x00 0x01 # reg, literal
tabela11.15: .byte 0x01 0x02 0x01 0x00 0x00 0x00 0x01 # reg, imediate, offset pc, offset, literal
tabela6.10:  .byte 0x40 0x00 0x40 0x00 0x00 0x00 0x06 # literal, shamt
tabela0.5:   .byte 0x50 0x00 0x52 0x03 0x04 0x05 0x42 # literal

# 0x00 ignora
# 0x01 indentica registrador
# 0x02 indentifica imediato
# 0x03 indentifica offset
# 0x04 indentifica offset pc
# 0x05 indentifica target
# 0x06 indentifica sa
# 0x4  literal

.align 2

tabelaValores: .word tabela26.31 tabela21.25 tabela16.20 tabela11.15 tabela6.10 tabela0.5

                        # add  addi mflo lw   beq  j    srl
quantidadeDeShamt1: .byte 26   26   26   26   26   26   26   # geralmente sempre 26-31
quantidadeDeShamt2: .byte 11   16   21   16   21   21   21   # 21-25
quantidadeDeShamt3: .byte 21   21   16   16   16   16   11   # 16-20
quantidadeDeShamt4: .byte 16    0   11   11   11   11   16   # 11-15
quantidadeDeShamt5: .byte  6    0    6    6    6    6    6   # 6-10
quantidadeDeShamt6: .byte  0    0    0    0    0    0    0   # 0-5

# opcode = 26
# rs = 21
# rt = 16
# rd = 11

.align 2

quantidadeDeShamtTable: .word quantidadeDeShamt1 quantidadeDeShamt2 quantidadeDeShamt3 quantidadeDeShamt4 quantidadeDeShamt5 quantidadeDeShamt6

.align 2

buffer: .space 4  # Adjust size as needed (modify if different)
my_space: .space 18

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


.include "fstream.asm"
.include "iostream.asm"
.include "asciiConversions.asm"

.text 

la $a0 file
openFile READ
move $s1 $v0 # mudar depois

la $a0 saida
openFile WRITE
move $s2 $v0

read_file_to_space(buffer, my_space, $s1)
la $a0 my_space

jal Roteador

li $v0 10
syscall

# $a0 contem a string da instruï¿½ï¿½o
Roteador: 
newCompleteStack

print_str
EOL

li $s0 0 #instruï¿½ï¿½o

lw $t0 lenghtTabela
sll $t0 $t0 2 # multiplica por 4, será util no meio do codigo

la $t2 tabelaOpcode
li $t3 0 # indice da coluna, anda de 4 em 4

# o objetivo aqui ï¿½ descobrir em qual coluna da tabela a string em $a0 estï¿½
# for string in tabelaOpcode do
Roteador.Coluna:
add $t5 $t3 $t2
lw $t5 ($t5) # $t5 tem a string a ser checada
compareStringsReg $t5 $a0
beq $v0 1 Roteador.Linha

add $t3 $t3 4 # soma 4 pois estamos caminhando em words
bgt $t3 $t0 erroOpcodeInexistente
j Roteador.Coluna


###################

Roteador.Linha:
li $t4 0 # indice da linha, anda de 4 em 4
srl $t3 $t3 2 # de word para byte
Roteador.LinhaLoop:
la $t2 tabelaValores
add $t2 $t4 $t2
lw $t2 ($t2)

add $t5 $t3 $t2
lb $a0 ($t5)
beq $a0 0x00 Roteador.Ignora # continua
blt $a0 0x40 Roteador.LerPalavra 
add $v0 $a0 -0x40 # Roteador.literal
j Roteador.Escrever

# ler proxima palavra
Roteador.LerPalavra:
move $t7 $a0
read_file_to_space(buffer, my_space, $s1)
move $a0 $t7
la $a1 my_space

beqal $a0 0x01 Roteador.Registrador
beqal $a0 0x02 Roteador.Imediato
beqal $a0 0x03 Roteador.Offset
beqal $a0 0x04 Roteador.OffsetPc
beqal $a0 0x05 Roteador.Target
beqal $a0 0x06 Roteador.Sa
# a partir desse ponto $v0 possui o valor a adicionar

Roteador.Escrever:
# descobrir posição do valor de $v0
la $t7 quantidadeDeShamtTable
add $t6 $t4 $t7 
lw $t6 ($t6)
add $t6 $t6 $t3
lb $t6 ($t6) # $t6 possui o shift 

sllv $v0 $v0 $t6
add $s0 $s0 $v0 # valor adicionado na instrução

Roteador.Ignora:
add $t4 $t4 4
bgt $t4 20 Roteador.Fim
cleanSpace(my_space)
j Roteador.LinhaLoop

erroOpcodeInexistente:
li $v0 4
la $a0 msgErroOpcodeInexistente
syscall

li $v0 10
syscall # termina o programa


Roteador.Fim:
jal escreverInstrucao
clearCompleteStack
j $ra

escreverInstrucao:
numberToAscii $v0
move $a1 $v0
move $a0 $s2
writeToFile
move $a0 $a1
print_str
jr $ra


Roteador.Registrador:
newArgsStack
print_str registrador
move $a0 $a1
print_str
EOL
clearArgsStack
jr $ra #Roteador.Registrador end

Roteador.Imediato:
jr $ra #Roteador.Imediato end

Roteador.Offset:
jr $ra #Roteador.Offset end

Roteador.OffsetPc:
jr $ra #Roteador.OffsetPc end

Roteador.Target:
jr $ra #Roteador.Target end

Roteador.Sa:
jr $ra #Roteador.Sa end

