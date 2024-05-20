.data
 
str1: .asciiz ".data"
str2: .asciiz ".data"


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





