add $t0 $t0 $t1
addi $t1 $t2 10
mflo $t3
lw $t0 ($t0)
beq $t4 $t4 Label
j Label
srl $t0 $t0 4