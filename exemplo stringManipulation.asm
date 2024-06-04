.include "stringManipulation.asm"
  
      # Call the macro for comparison, provide a register for result
  # se for igual $s0 = 1, se for diferente $s0 = 0
main:
  #copy_string_to_space(str1, espaco1)
  #copy_string_to_space(str2, espaco2)  
  compareStringsLabel (str1, str2)

# concat strings and clear
##################################################