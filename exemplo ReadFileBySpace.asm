.include "readFileBySpace.asm"

# Example usage (replace "myfile.txt" and modify buffer size if needed)
.data
  buffer: .space 4  # Adjust size as needed (modify if different)
  my_space: .space 18
  filepath:    .asciiz "example_saida.asm"
  quebra: .asciiz "\n"
.text
main:
  # Open the file (replace with your code to open the file and store descriptor)
  # ...
  # reads_file saved file descriptor: $s0
  li    $v0, 13       
  la    $a0, filepath      
  li    $a1, 0        #0: read, 1: write
  li    $a2, 0        # no mode
  syscall             
  move  $s0, $v0      
# end

  # Call the read_file_to_space macro with reserved space and file descriptor
  read_file_to_space(buffer, my_space, $s0)
  print_str(my_space)
  
  cleanSpace(my_space)
  
  read_file_to_space(buffer, my_space, $s0)
  print_str(my_space)
  li $v0 10
  syscall
 
  cleanSpace(my_space)
  
  read_file_to_space(buffer, my_space, $s0)
  print_str(my_space)

  cleanSpace(my_space)
  
  
  read_file_to_space(buffer, my_space, $s0)
  print_str(my_space)

  cleanSpace(my_space)
  
  read_file_to_space(buffer, my_space, $s0)
  print_str(my_space)

  cleanSpace(my_space)
  
  
  read_file_to_space(buffer, my_space, $s0)
  print_str(my_space)

  cleanSpace(my_space)
  
  read_file_to_space(buffer, my_space, $s0)
  print_str(my_space)

  cleanSpace(my_space)
  
  
  read_file_to_space(buffer, my_space, $s0)
  print_str(my_space)

  cleanSpace(my_space)
  
  
  read_file_to_space(buffer, my_space, $s0)
  print_str(my_space)

  cleanSpace(my_space)
  
  
  read_file_to_space(buffer, my_space, $s0)
  print_str(my_space)

  cleanSpace(my_space)
  
  
  read_file_to_space(buffer, my_space, $s0)
  print_str(my_space)

  cleanSpace(my_space)
  
  
  read_file_to_space(buffer, my_space, $s0)
  print_str(my_space)

  cleanSpace(my_space)
  
    read_file_to_space(buffer, my_space, $s0)
  print_str(my_space)

  cleanSpace(my_space)
  
    read_file_to_space(buffer, my_space, $s0)
  print_str(my_space)
 
  cleanSpace(my_space)
  
    read_file_to_space(buffer, my_space, $s0)
  print_str(my_space)

  cleanSpace(my_space)
  
    read_file_to_space(buffer, my_space, $s0)
  print_str(my_space)

  cleanSpace(my_space)
  
    read_file_to_space(buffer, my_space, $s0)
  print_str(my_space)

  cleanSpace(my_space)
  
    read_file_to_space(buffer, my_space, $s0)
  print_str(my_space)

  cleanSpace(my_space)
  
  
  
  # ... (your code after processing the data in reserved space)

  # Close the file (replace with your code to close the file)
  # ...
  close_file:
   
    li   $v0, 16      
    move $a0, $s0      
    syscall

	
		
  li $v0, 10  # syscall code for exit
  syscall