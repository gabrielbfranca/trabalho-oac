.text
.globl main

main:
    li $v0, 4
    la $a0, msg1
    syscall

    li $v0, 8
    la $a0, string1
    li $a1, 99
    syscall

    li $v0, 4
    la $a0, msg2
    syscall

    li $v0, 8
    la $a0, string2
    li $a1, 99
    syscall

    lb $t5, endline

    # compare each bit
    la $t1, string1
    la $t2, string2

    loop:
    # load the characters 
        lb $t3, 0($t1)
        lb $t4, 0($t2)
    # check if equal, if not stop loop, if equal, then continue 
        sub $t6, $t3, $t4

        beq $t6, $zero, continueEqual
        j end_loop

    continueEqual:
    # if t3 or t4 == '\n' stop loop
        beq $t3, $t5, end_loop
    # continue again, by incrementing both address by one
        addi $t1, $t1, 1
        addi $t2, $t2, 1
        j loop

    end_loop:

        beq $t6, $zero, same

        notSame:
        li $v0, 4
        la $a0, msg4
        syscall

        j printRes
        
        same:
            li $v0, 4
            la $a0, msg3
            syscall

    printRes:
        li $v0, 1
        move $a0, $t6
        syscall
        li $v0, 4
        la $a0, endline
        syscall

exit:
    li $v0, 10
    syscall


.data

msg1: .asciiz "Enter string-1: "
msg2: .asciiz "Enter string-2: "
msg3: .asciiz "Same\n"
msg4: .asciiz "Not Same\n"
endline: .asciiz "\n"
string1: .space 100
string2: .space 100