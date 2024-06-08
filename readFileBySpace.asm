.macro parse_word(%space,%file_descriptor)
.data
buffer:   .space  4
.text

readc: # usa arquivo : $s0, retorna caracter em: $v0 
	li $v0,14
	move $a0,$s0  # aponta pro ponteiro no arquivo
  	la $a1,buffer 
  	li $a2,1        
  	syscall
  	beq $v0, $0, finish # eof
  	lb $v0,buffer # le um byte armazenado em buffer
.end_macro


.macro read_file_to_space (%buffer,%space, %file_descriptor)
  .data
  
  error_message: .asciiz "Error in parser: not enough space"
.text
add $sp $sp -16
sw $t0 12($sp)
sw $t1 8($sp)
sw $t2 4($sp)
sw $t3 0($sp)

la $t2, %space
la $t3, %buffer
loop:
  # Read a character from the file
  li $v0, 14      # syscall code for read
  move $a0, %file_descriptor  # use provided file descriptor
  la $a1, %buffer   # load address of buffer
  li $a2, 1        # read 1 byte

  syscall        # perform read syscall

  # Check for end of file (EOF)
  beq $v0, -1, finish  # branch on error or EOF

  # Check for space character
  lb $t0, %buffer   # load byte from buffer
  beqz $t0, finish   # branch if null terminator (EOF)
  #bne $t0, 32, not_space
  #bne $t0, 10, not_space 
  beq $t0, 44, loop # ignores ,
  bge $t0, 33, not_space
  # Character is a space (less than 10), terminate loop
  j finish

not_space:
  # Character is not a space, append it to the reserved space
  lb $t1, 0($t2)  # load current byte from reserved space
  beqz $t1, append  # branch if space is available in reserved space

  # Handle full reserved space (e.g., print error message)
  li $v0, 1    # syscall code for print string
  la $a0, error_message  # load error message address
  syscall
  j finish      # jump to finish

append:
  # Append the character to the reserved space
  sb $t0, 0($t2)  # store byte in reserved space
  addi $t2, $t2, 1  # move to next byte in reserved space

  j loop        # continue reading the file

finish:
lw $t0 12($sp)
lw $t1 8($sp)
lw $t2 4($sp)
lw $t3 0($sp)
add $sp $sp 16
.end_macro


#.include "ArrayList.asm"
#.include "macroStack.asm"
# $v0 string
# $v1 char lidas
.macro getWordInString %string %index
newCompleteStack
add $sp $sp -4
sw %string ($sp)
add $s3 $zero %index # index
add $s4 $zero %index
lw $s0 ($sp) #string
AL.C $s1 8

loop:
add $s2 $s3 $s0
lb $s2 ($s2)
beq $s2 0x20 fim
beq $s2 0x0a fim
beq $s2 0x00 fim2
ArrayList.FastAppendByte $s1 $s2
add $s3 $s3 1
j loop

fim2:
add $s3 $s3 -1 
fim:
lw $v0 ($s1)
add $v1 $s3 1
sub $v1 $v1 $s4
clearCompleteStack
.end_macro



.macro cleanSpace(%space) # not functional

	addi $sp, $sp, -12
 	sw $ra, 12($sp)
 	sw $t0, 8($sp)
 	sw $t1, 4($sp)
 	sw $t2, 0($sp)
 
	la $t0, %space  # Load address of my_buffer
	li $t1, 0          # Load value to write (zero)
	addi $t2, $t0, 18   # Calculate end address (10 bytes)

	loop:
	  sb $t1, 0($t0)    # Store zero at current address
	  addi $t0, $t0, 1   # Increment address
	  blt $t0, $t2, loop  # Loop until end address reached

 	lw $ra, 12($sp)
 	lw $t0, 8($sp)
 	lw $t1, 4($sp)
 	lw $t2, 0($sp)
 	addi $sp, $sp, 12
.end_macro

.macro cleanSpace2 %space %size # not functional

	addi $sp, $sp, -12
 	sw $ra, 12($sp)
 	sw $t0, 8($sp)
 	sw $t1, 4($sp)
 	sw $t2, 0($sp)
 
	la $t0, %space  # Load address of my_buffer
	li $t1, 0          # Load value to write (zero)
	addi $t2, $t0, %size   # Calculate end address (10 bytes)

	loop:
	  sw $t1, ($t0)    # Store zero at current address
	  addi $t0, $t0, 4   # Increment address
	  blt $t0, $t2, loop  # Loop until end address reached

 	lw $ra, 12($sp)
 	lw $t0, 8($sp)
 	lw $t1, 4($sp)
 	lw $t2, 0($sp)
 	addi $sp, $sp, 12
.end_macro


