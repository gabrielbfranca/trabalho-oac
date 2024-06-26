.macro print_str
li $v0 4
syscall
.end_macro

.macro print_str %label
add $sp $sp -4
sw $a0 ($sp)

la $a0 %label
print_str

lw $a0 ($sp)
add $sp $sp 4
.end_macro

.macro print_EOL
add $sp $sp -4
sw $a0 ($sp)

li $a0 0x0a
li $v0 11
syscall

lw $a0 ($sp)
add $sp $sp 4
.end_macro

.eqv EOL print_EOL