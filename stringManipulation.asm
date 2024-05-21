.data
 
str1: .asciiz ".data"
str2: .asciiz ".data"
str1:
.asciiz "00000001 : "
str2:
.asciiz "00000003;"
result:
.space 18

.text

# end
.macro compare_strings (%str1, %str2, %result_reg)
 addi $sp, $sp, -20
 sw $ra, 20($sp)
 sw $t1, 16($sp) 
 sw $t2, 12($sp)
 sw $t3, 8($sp)
 sw $t4, 4($sp)
 sw $t6, 0($sp)
 
 la $t1, %str1
 la $t2, %str2

loop:
  # Load characters from strings
  lb $t3, 0($t1)
  lb $t4, 0($t2)
  
    # Check if characters are equal
  sub $t6, $t3, $t4
  

  # Check for end of strings (newline character)
  beq $t3, 0, end_loop  # 10 is the ASCII code for newline 0 is code for null
  beq $t4, 0, end_loop
  
  beq $t6, $zero, continueEqual


  # Characters not equal, exit loop
  j end_loop

continueEqual:
  # Both characters are equal, increment pointers
  addi $t1, $t1, 1
  addi $t2, $t2, 1
  j loop

end_loop:
  # Check if characters were equal until the end
  beq $t6, $zero, same  # Move 1 to result register

  # Characters not the same, move 0 to result register
  li %result_reg, 0
  j exit
  
same:
  # Characters are the same, move 1 to result register
  li %result_reg, 1
exit:
	
 	lw $ra, 20($sp)
 	lw $t1, 16($sp) 
 	lw $t2, 12($sp)
 	lw $t3, 8($sp)
 	lw $t4, 4($sp)
 	lw $t6, 0($sp)
 	addi $sp, $sp, 20
.end_macro
  # Call the macro for comparison, provide a register for result
  # se for igual $s0 = 1, se for diferente $s0 = 0
main:
  #copy_string_to_space(str1, espaco1)
  #copy_string_to_space(str2, espaco2)  
  compare_strings (str1, str2, $s3)

# concat strings and clear
##################################################

.macro concatenateString(%str1, %str2, %result) #result é um espaço
.text
# Copy first string to result buffer

addi $sp, $sp, -24
 sw $ra, 24($sp)
 sw $a0, 20($sp) 
 sw $a1, 16($sp)
 sw $v0, 12($sp)
 sw $t0, 8($sp)
 sw $t1, 4($sp)
 sw $t2, 0($sp)
 
 
la $a0, %str1
la $a1, %result
jal strcopier
nop

# Concatenate second string on result buffer
la $a0, %str2
or $a1, $v0, $zero
jal strcopier
nop
j finish
nop

# String copier function
strcopier:
or $t0, $a0, $zero # Source
or $t1, $a1, $zero # Destination

loop:
lb $t2, 0($t0)
beq $t2, $zero, end
addiu $t0, $t0, 1
sb $t2, 0($t1)
addiu $t1, $t1, 1
b loop
nop

end:
or $v0, $t1, $zero # Return last position on result buffer
jr $ra
nop

finish:
	
 	lw $ra, 24($sp)
 	lw $a0, 20($sp) 
 	lw $a1, 16($sp)
 	lw $v0, 12($sp)
 	lw $t0, 8($sp)
	lw $t1, 4($sp)
	lw $t2, 0($sp)
	addi $sp, $sp, 24
.end_macro

.macro print_str (%str)
	.text
	li $v0, 4
	la $a0, %str
	syscall
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

concatenateString(str1, str2, result)
print_str (result)
cleanSpace(result)




