.data
# Prompt string for archive names
prompt_msg: .asciiz "digite o nome do arquivo: "
prompt_out_filename_data: .asciiz "digite o nome do arquivo para saída de data: "
prompt_out_filename_text: .asciiz "digite o nome do arquivo para saída de text: "

# Buffer size (larger for longer names)
buffer_in: .space 128
buffer_data_out: .space 128
buffer_text_out: .space 128
breakline: .asciiz "\n"
.text
.macro replace_newline_with_null (%str)
    # $a0 = address of the string
    # $t0 = temporary register for current character
    # $t1 = temporary register for address offset
    
    la   $a0, %str      # Load the address of the string into $a0
    li   $t1, 0          # Initialize the offset to 0

replace_loop:
    lb   $t0, 0($a0)     # Load the byte at the current address
    beq  $t0, 0, end_replace # If the byte is 0 (null terminator), end the loop
    beq  $t0, 10, replace   # If the byte is 10 (\n), replace it
    addi $a0, $a0, 1     # Increment the address to the next character
    j    replace_loop    # Jump back to the start of the loop

replace:
    li   $t0, 0          # Load the null terminator value into $t0
    sb   $t0, 0($a0)     # Store the null terminator at the current address
    j    end_replace     # Jump to the end of the loop

end_replace:
.end_macro

.macro print_str (%str)

	.text
	li $v0, 4
	la $a0, %str
	syscall
	.end_macro
############ CLI ##################
  # Print prompt
  la $a0, prompt_msg
  li $v0, 4
  syscall

  # Read user input into buffer
  la $a0, buffer_in
  li $v0, 8
  li $a1, 128
  syscall
  replace_newline_with_null (buffer_in)
  #print_str (breakline)
   # Print prompt
  la $a0, prompt_out_filename_data
  li $v0, 4
  syscall
  
  # Read user input into buffer
  la $a0, buffer_data_out
  li $v0, 8
  li $a1, 128
  syscall
  replace_newline_with_null (buffer_data_out)
   # Print prompt
  la $a0, prompt_out_filename_text
  li $v0, 4
  syscall
  
  # Read user input into buffer
  la $a0, buffer_text_out
  li $v0, 8
  li $a1, 128
  syscall
  replace_newline_with_null (buffer_text_out)
 
##############################################  
  

	print_str (buffer_in)
	print_str (buffer_in)
	print_str (buffer_data_out)
	print_str (buffer_text_out)

