.data
prompt_msg: .asciiz "digite o nome do arquivo: "
prompt_out_filename_data: .asciiz "digite o nome do arquivo para saída de data: "
prompt_out_filename_text: .asciiz "digite o nome do arquivo para saída de text: "

# Buffer size (larger for longer names)
buffer_in: .space 128
buffer_data_out: .space 128
buffer_text_out: .space 128
.text
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
   # Print prompt
  la $a0, prompt_out_filename_data
  li $v0, 4
  syscall
  
  # Read user input into buffer
  la $a0, buffer_data_out
  li $v0, 8
  li $a1, 128
  syscall
 
   # Print prompt
  la $a0, prompt_out_filename_text
  li $v0, 4
  syscall
  
  # Read user input into buffer
  la $a0, buffer_text_out
  li $v0, 8
  li $a1, 128
  syscall
 
##############################################  
