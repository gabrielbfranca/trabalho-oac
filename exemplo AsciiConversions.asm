.data 
teste1: .asciiz "16"
teste2: .asciiz "0x10"
teste3: .asciiz "123456789"
teste4: .asciiz "4294967295" #unsigned
teste5: .asciiz "0xffffffff" #unsigned
teste6: .asciiz "0x" # vai retornar 0
teste7: .asciiz "0"
teste8: .asciiz "-1"
teste9: .asciiz "-0x1"
teste10: .asciiz "-0"
teste11: .asciiz "-2147483648"
teste12: .asciiz "-0x80000000"
teste13: .asciiz "-2147483649"
teste14: .asciiz "-0x80000001"
teste15: .asciiz "4294967296" # muito grande
teste16: .asciiz "0x100000000" # muito grande
teste17: .asciiz "0f" # não é numero

mensagem: .asciiz "oi"

.include "asciiConversions.asm"

.text

# Exemplo de uso:
la $t0 teste1
asciiToNumber $t0

testAsciiToNumber teste1
testAsciiToNumber teste2
testAsciiToNumber teste3
testAsciiToNumberUnsigned teste4
testAsciiToNumberUnsigned teste5
testAsciiToNumber teste6
testAsciiToNumber teste7
testAsciiToNumber teste8
testAsciiToNumber teste9
testAsciiToNumber teste10
testAsciiToNumber teste11
testAsciiToNumber teste12
#Erros:
#testAsciiToNumber teste13
#testAsciiToNumber teste14
#testAsciiToNumber teste15
#testAsciiToNumber teste16
#testAsciiToNumber teste17
#testAsciiToNumber mensagem

li $a0 0xffffffff
numberToAscii $a0
move $a0 $v0
li $v0 4
syscall
print_EOL

li $a0 0x10101010
numberToAscii $a0
move $a0 $v0
li $v0 4
syscall
print_EOL

li $a0 1024
numberToAscii $a0
move $a0 $v0
li $v0 4
syscall
print_EOL

li $a0 0
numberToAscii $a0
move $a0 $v0
li $v0 4
syscall
print_EOL



fim:
li $v0 10
syscall
