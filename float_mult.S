.data

##  Your name and ID etc go here
# Name: Tao Wang
# ID: 919143951

#   X   |   Y   |   Answer In Hex |  Answer in Dec | Correct Answer | Error |
# -------------------------------------------------------------------------
#  2.5  |   5.25 |      0x4125    |     13.125     |     13.125     |    0% |
#  1.0  |  -5.0  |      0xC0A0    |     -5.0       |     -5.0       |    0% |
# -5.0  |   3.3  |      0xC183    |    -16.375     |    -16.5       | 0.76% |
# -1.5  | -25.75 |      0x421A    |     38.5       |     38.625     | 2.26% |
#  0.01 |   0.02 |      0x3952    |      0.0002003 |    0.0002      | 0.14% |

X_string: .string "X = "
Y_string: .string "Y = "
result_string: .string "X x Y = "

newln:    .string "\n"

# X and Y are the inputs

X:  .word  0x4020
Y:  .word  0x40A8


# .text means the rest of the stuff is a program or instructions to the computer
.text
.globl main                         # make main available to all project files

main:                               # There should be one main

# Don't Touch this (BEGIN)
# Code to print X_string
    la a1, X_string
    li a0, 4
    ecall 

# Code to print X. The syscall code 34 in register a0, results in printing the number in hexadecimal notation. 
    lw a1, X
    li a0, 34
    ecall 

# Code to print newln
    la a1, newln
    li a0, 4
    ecall 

# Code to print Y_string
la a1, Y_string
    li a0, 4
    ecall 

# Code to print Y. The syscall code 34 in register a0, results in printing the number in hexadecimal notation. 
    lw a1, Y
    li a0, 34
    ecall 
# Code to print newln
    la a1, newln
    li a0, 4
    ecall


###    Pass X in a1,  Pass Y in a2, call the function bfmult and store result in a3
    lw a1, X
    lw a2, Y
    jal x1, bfmult


# Code to print result_string
    la a1, result_string
    li a0, 4
    ecall 

# Code to print result. The syscall code 34 in register a0, results in printing the number in hexadecimal notation. 
    add a1, x0, a3
    li a0, 34
    ecall 
# Code to print newln
    la a1, newln
    li a0, 4
    ecall
    j exit

# Don't touch this (END)

### BEGIN YOUR CODE  (Make sure the result is in register a3, remember X and Y are in a1 and a2)
bfmult:
    # Process X's mantissa
    li x5, 0x7F              #mant1
    and x5, x5, a1
    ori x5, x5, 0x80
    li x28, 0x0              #count1
    Loop1: 
        andi x29, x5, 0x1
        bne x29, x0, end1
        srli x5, x5, 0x1
        addi x28, x28, 0x1
        beq x0, x0, Loop1
    end1:

    # Process Y's Mantissa
    li x6, 0x7F            #mant2
    and x6, x6, a2
    ori x6, x6, 0x80
    li x29, 0              #count2
    Loop2:
        andi x30, x6, 0x1
        bne x30, x0, end2
        srli x6, x6, 0x1
        addi x29, x29, 0x1
        beq x0, x0, Loop2
    end2:

    # Multiplication of Mantissas
    mul x5, x5, x6

    li x31, 0xE
    sub x6, x31, x28  #x6 is normalizer now
    sub x6, x6, x29   #14 - count1 - count2
    li x31, 0x1
    sll x6, x31, x6
    li x31, 0x0       #offset

    and x7, x6, x5
    beq x7, x0, else1
        xor x5, x5, x6
        beq x0, x0, end3
    else1:
        srli x5, x5, 0x1
        xor x5, x5, x6
        addi x31, x31, 0x1
    end3:

    # Shift the Mantissa to Approapriate Position based on float16
    li x6, 0x7          # Compute 7 - 14 + count1 + count2
    li x7, 0xE
    sub x6, x6, x7
    add x6, x6, x28
    add x6, x6, x29
    bge x6, x0, elseif
        li x7, 7
        sub x7, x7, x28
        sub x7, x7, x29
        sra x5, x5, x7
        beq x0, x0, else2
    elseif:
        beq x5, x0, else2
        sll x5, x5, x6
    else2: 

    # Sign Bit
    li x6, 0x1          #x_sign
    slli x6, x6, 0xF
    and x6, x6, a1
    li x7, 0x1          #y_sign
    slli x7, x7, 0xF
    and x7, x7, a2

    # Exponent
    li x28, 0xFF           #x_exp
    slli x28, x28, 0x7
    and x28, x28, a1
    srli x28, x28, 0x7
    li x29, 0xFF           #y_exp
    slli x29, x29, 0x7
    and x29, x29, a2
    srli x29, x29, 0x7
    add x28, x28, x29          #ans_exp
    li x30, 0x7F
    sub x28, x28, x30       
    add x28, x28, x31         #x_exp + y_exp - 127 + offset
    slli x28, x28, 0x7          

    # Final Assembling
    li a3, 0x0
    xor x6, x6, x7
    or a3, a3, x6
    or a3, a3, x28
    or a3, a3, x5
    jr x1

####  END YOUR CODE

# Don't modify anything below this.  It is just to exit the program gracefully.

   la a1, newln
    li a0, 4
    ecall

exit:
    addi a0, zero, 10 
    ecall