clo $3 $1
add $t0 $t0 $t1
addi $t0 $t0 -0x7fff
addi $t1 $t2 10
Label: mflo $t3
lw $t0 ($t0)
beq $t4 $t4 Label
j Label
srl $t0 $t0 4
