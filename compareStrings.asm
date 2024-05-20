.data
palavra1: .space 100  
str1: .asciiz ".data"

palavra2: .space 100
str2: .asciiz ".data"


.text


# tentando simetrizar

la $t0, str1        # Load address of str1 (source string)
la $t1, palavra1    # Load address of palavra1 (destination)

loop:
  # Load character from source string
  lb $t2, 0($t0)

  # Check for null terminator (end of string)
  beq $t2, 0, end_copy  # If null terminator, end loop

  # Copy character to destination string
  sb $t2, 0($t1)

  # Increment source and destination addresses
  addi $t0, $t0, 1
  addi $t1, $t1, 1

  # Jump back to loop for next character
  j loop
end_copy:
# end
.macro compare_strings (%str1, %str2, %result_reg)

   
 la $t1, %str1
 la $t2, %str2

loop:
  # Load characters from strings
  lb $t3, 0($t1)
  lb $t4, 0($t2)

  # Check for end of strings (newline character)
  beq $t3, 10, end_loop  # 10 is the ASCII code for newline
  beq $t4, 10, end_loop

  # Check if characters are equal
  sub $t6, $t3, $t4
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
.end_macro

main:


  # Call the macro for comparison, provide a register for result
  # se for igual $t0 = 1, se for diferente $t0 = 0
  
  compare_strings (palavra1, palavra2, $t0)





