.include "fstream.asm"

.data 
file: .asciiz "teste.asm"
file2: .asciiz "ArrayList.asm"
.text

#la $a0 file
#openFile WRITE

#move $a0 $v0
#la $a1 file
#writeToFile
#writeToFile


la $a0 file2
openFile READ

move $a0 $v0
readFile

lw $a0 ($v0)
print_str