######################################################
# registradores reservados: 			     #	
#    file descriptor para arquivo de entrada: $s0    #
#    file descriptor para arquivo texto : $s1	     #
#    file descriptor para arquivo data : $s2	     #
######################################################
.data
filepath:    .asciiz "example_saida.asm"
text:   .asciiz "data.mif"     
data:   .asciiz "text.mif"

palavra1: .space 32
palavra2: .space 32
palavra3: .space 32
palavra4: .space 32
palavra5: .space 32
palavra6: .space 32

data_header: .asciiz "DEPTH = 16384;\nWIDTH = 32;\nADDRESS_RADIX = HEX;\nDATA_RADIX = HEX;\nCONTENT\nBEGIN\n\n"
text_header: .asciiz "DEPTH = 4096;\nWIDTH = 32;\nADDRESS_RADIX = HEX;\nDATA_RADIX = HEX;\nCONTENT\nBEGIN\n\n"
separador:  .asciiz " : "
quebralinha:  .asciiz "\n"
error:    .asciiz "valor nao reconhecido"
data_word: .asciiz ".data"

buffer:   .space  4
everything: .space 100
.text
# reads_file saved file descriptor: $s0
  li    $v0, 13       
  la    $a0, filepath      
  li    $a1, 0        #0: read, 1: write
  li    $a2, 0        # no mode
  syscall             
  move  $s0, $v0      
# end
# creates_file_text saved file descriptor: $s1
  li   $v0, 13       
  la   $a0, text 
  li   $a1, 1        #0: read, 1: write
  li   $a2, 0        
  syscall           
  move $s1, $v0   
#end  
 # creates_file_data saved file descriptor: $s2
  li   $v0, 13       
  la   $a0, data 
  li   $a1, 1        # 0: read, 1: write
  li   $a2, 0       
  syscall            # open a file (file descriptor returned in $v0)
  move $s2, $v0
 #end      

parse_words:
  jal readc      #le primeiro caracter
  #bne $v0, 46, catch # checa se existe ponto
  j parse_words
	

readc: # usa arquivo : $s0, retorna caracter em: $v0 
	li $v0,14
	move $a0,$s0  # aponta pro ponteiro no arquivo
  	la $a1,buffer 
  	li $a2,1        
  	syscall
  	beq $v0, $0, finish # eof
  	lb $v0,buffer # le um byte armazenado em buffer
  	jr $ra
  	
 
finish: # ends reading
  close_file:
   
    li   $v0, 16      
    move $a0, $s0      
    syscall
  close_text: # finish writing "text"

    li   $v0, 16       
    move $a0, $s1      
    syscall            

  close_data: # finish writing "data"
   
    li   $v0, 16      
    move $a0, $s2      
    syscall              
end: # ends program
    
    li    $v0, 10
    syscall

catch: # catch errors
  li    $v0, 4      
  la    $a0, error  
  syscall
  j end

