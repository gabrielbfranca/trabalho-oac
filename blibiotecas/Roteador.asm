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
                 # add  addi addiu addu and  andi beq  bgez bgezal bltzal bne  clo  clz  div  j    jal  jalr jr   lb   lhu  lui  lw   mfhi mflo movn mul  mult nor  or   ori  sb   sll  sllv slt  slti sltu sra  srav srl  sub  subu sw   xor  xori
tabela26.31: .byte 0x40 0x44 0x45  0x40 0x40 0x46 0x44 0x41 0x41   0x41   0x45 0x5c 0x5c 0x40 0x42 0x43 0x40 0x40 0x60 0x65 0x4f 0x63 0x40 0x40 0x40 0x5c 0x40 0x40 0x40 0x4d 0x68 0x40 0x40 0x40 0x4a 0x40 0x40 0x40 0x40 0x40 0x40 0x6b 0x40 0x4e
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

# $a0 contem a string da instrução
# $a1 contem o index dessa string no array
Roteador: 
newCompleteStack
move $s1 $a1 

print_str
EOL

li $s0 0 #instrução

lw $t0 lenghtTabela
sll $t0 $t0 2 # multiplica por 4, será util no meio do codigo

la $t2 tabelaOpcode
li $s3 0 # indice da coluna, anda de 4 em 4

# o objetivo aqui ï¿½ descobrir em qual coluna da tabela a string em $a0 estï¿½
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


# $a0 - string que representa o registrador a ser decodificado
# $a1 - nao mexer
# $v0 - valor equivalente
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
la $t0 ArrayListDeLabels.Nomes
AL.FS $t0 $a0 # v0 tem o index da palavra
lw $t0 ArrayListDeLabels.Enderecos
add $t0 $t0 $v0
lw $v0 ($t0)
jr $ra #Roteador.Target end

Roteador.Sa:
jr $ra #Roteador.Sa end

