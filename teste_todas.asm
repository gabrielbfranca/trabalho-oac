add    $3 $2 $1
add    $3 $1 10
addi   $3 $1 10
addiu  $3 $1 10
addu   $3 $2 $1
and    $3 $2 $1
andi   $3 $1 10
and    $3 $2 $1
andi   $3 $1 10
beq    $t3 $t3 label
bgez   $3 label
bgezal $3 label
bne    $t3 $t3 label
bltzal $3 label
clo    $1 $3
clz    $1 $3
div    $1 $3
j      label
jal    label
jalr   $3 
jr     $3
lb     $3 4($1)
lhu    $3 4($1)
lui    $3 10
lw     $3 4($1)
mfhi   $1 
mflo   $1
movn   $3 $2 $1 
mul    $3 $2 $1
mult   $3 $3
nor    $3 $2 $1
or     $3 $2 $1
ori    $3 $1 10
sb     $3 4($1)
sll    $3 $1 10
sllv   $3 $2 $1
slt    $3 $2 $1
slti   $3 $1 10 
sltu   $3 $2 $1
sra    $3 $1 10
srav   $3 $2 $1 
srl    $3 $1 10
sub    $3 $2 $1
subu   $3 $2 $1
sw     $3 4($1)
xor    $3 $2 $1
xori   $3 $1 10

label:
