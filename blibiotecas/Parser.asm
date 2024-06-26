.data 
ArrayListTextoEntrada: .word 0x00 0x00 0x00
FileDescriptor: .word 0x00

arquivo: .asciiz "example_saida_simples.asm"

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

.text
.include "fstream.asm"


la $a0 arquivo
jal parser

la $a0 ArrayListTextoEntrada
lw $a0 ($a0)
print_str


li $v0 10
syscall


#.include "readFileBySpace.asm"
#.include "stringManipulation.asm"
###########################################
# Código do parser - coloca todo o texto do arquivo a ser compilado em uma string
# Salva a localização dos labels nesse arquivo
# $a0 - nome do arquivo
parser:
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
getWordInString $s0 $s2
beqz $v1 parser.fim #somente será zero se encontrar caractere nulo

move $a0 $v0 # palavra

AL.FS $s3 $a0
bltz $v0 parser.naoEhOpcode
add $a1 $a1 1
add $s2 $s2 $v1 # caracters lidas
j parser.loop

parser.naoEhOpcode:
jal identificaLabel
beqz $v0 parser.continue
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





###################################################






