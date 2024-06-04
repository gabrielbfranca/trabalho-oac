.include "fstream.asm"

.data 
file: .asciiz "teste.asm"
.text

la $a0 file
openFile WRITE

move $a0 $v0
la $a1 file
writeToFile
writeToFile