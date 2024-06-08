.eqv READ 0
.eqv WRITE 1

###################################################
# $a0 - nome do arquivo
# $v0 - file descriptorS
.macro openFile %flag # 0: read, 1: write
.data 
mensagemErro: .asciiz "Erro na abertura do arquivo: "
.text
li $v0 13
li $a1 %flag
syscall
bge $v0 0 fim
print_str mensagemErro
print_str
li $v0 10
syscall

fim:
.end_macro

####################################################
# $a0 - file_descriptor
# $a1 - string
.macro writeToFile
.data
  error_message: .asciiz "Error writing to file."
.text
  # Get string length (excluding null terminator)
  addi $sp, $sp, -12
  sw $t2, 8($sp)
  sw $t1, 4($sp)
  sw $t0, 0($sp)
  
  move $t2 $a1
  li $t0, 0  # counter for string length
loop:
    lb $t1, 0($t2)  # load byte from string address
    beqz $t1, done_strlen  # branch if null terminator found
    addi $t2, $t2, 1  # move to next character
    addi $t0, $t0, 1  # increment counter
    j loop
  done_strlen:

  # Write the string to the file
  li $v0, 15    # syscall code for write
  move $a2, $t0  # string length (excluding null terminator)
  syscall

  # Check if write was successful
  
  bne $v0, -1, finish
write_error:
  # Handle error (e.g., print message)
  li $v0, 4    # syscall code for print string
  la $a0, error_message  # load error message address
  syscall
  li $v0, 10
  syscall

finish:
  	sw $t2, 8($sp)
  	lw $t1, 4($sp)
  	lw $t0, 0($sp)
  	addi $sp, $sp, 12
.end_macro

.include "ArrayList.asm"
#.include "iostream.asm"
.include "readFileBySpace.asm"
#################################
# $a0 - file descriptor
# $v0 - ArrayList com todo o texto do arquivo
# $v1 - tamanho do texto
.macro readFile
.data 
.align 2
space: .space 512
.space 4
mensagemDeErro: .asciiz "Erro na leitura do arquivo"
.text
newCompleteStack
li $v1 0
AL.C $s0 512
move $s3 $a0
readFile.loop:
li $v0 14
move $a0 $s3
la $a1 space
li $a2 512
syscall
bltz $v0 erro
beq $v0 0 fim
add $v1 $v1 $v0
AL.FJA $s0 $a1
cleanSpace2 space 512
j readFile.loop

erro:
print_str mensagemDeErro
li $v0 10 
syscall


fim:
move $v0 $s0
clearCompleteStack
.end_macro




