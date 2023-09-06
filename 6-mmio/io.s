# data section
.data

# messages
enter_char_message:
.asciz "\nPlease enter a character (Q to quit) "
print_char_message:
.asciz "\nThe ascii code of the character you entered is "
enter_int_message:
.asciz "\nPlease enter an integer ending with newline and 0 to quit "
not_a_digit_message:
.asciz "\nThe entered character is not a digit!\n"
overflow_message:
.asciz "\nThe entered integer overflowed on 32 bits!\n"
print_int_message:
.asciz "\nYou entered integer "
bye_message:
.asciz "\nBye!"

#symbols
.eqv KCTRL 0xffff0000 #keyboard control register
.eqv KDATA 0xffff0004 #keyboard data register
.eqv DCTRL 0xffff0008 #display control register
.eqv DDATA 0xffff000c #display data register
.eqv OVERR 2          # error code for overflow
.eqv NDERR 1          # error code for not-a-digit
.eqv NOERR 0          # error code for no error
.eqv OVFMAX   4294967296  # max value
# code section
.text

# read character, return read character in a0
getc:
    addi  sp,sp,-4    # allocate stack frame (1 register to preserve = 1*4 = 4 bytes)
    sw    ra,0(sp)    # save ra
    li    t0,0xffff0000               # t0 <- 0xffff_0000 (address of receiver control register)
    li    t1,0xffff0004               # t1 <- 0xffff_0004 (address of receiver data register) 
getc_poll:
    lw    t2,0(t0)           # t2 <- value of receiver control register
    andi  t2,t2,1            # mask all bits except LSB
    beq   t2,zero,getc_poll  # loop if LSB unset.
    lw    a0,0(t1)           # store received character in a0
    lw    ra,0(sp)           # restore ra
    addi  sp,sp,4            # deallocate stack frame, restore stack pointer
    ret                      # return
#   li    a7,12       # syscall code for ReadChar
#   ecall
#    lw    ra,0(sp)    # restore ra
#    addi  sp,sp,4     # deallocate stack frame, restore stack pointer
#    ret               # return

# print character in a0
putc:
    addi  sp,sp,-4    # allocate stack frame (1 register to preserve = 1*4 = 4 bytes)
    sw    ra,0(sp)    # save ra
    # initialize CPU registers with addresses of transmitter interface registers
    li    t0,0xffff0008               # t0 <- 0xffff_0008 (address of transmitter control register)
    li    t1,0xffff000c               # t1 <- 0xffff_000c (address of transmitter data register)
putc_poll:
    lw    t2,0(t0)           # t2 <- value of transmitter control register
    andi  t2,t2,1            # mask all bits except LSB
    beq   zero,t2,putc_poll  # loop if LSB unset (transmitter busy)
    sw    a0,0(t1)           # send character
    lw    ra,0(sp)           # restore ra
    addi  sp,sp,4            # deallocate stack frame, restore stack pointer
    ret                      # return

  #  li    a7,11       # syscall code for PrintChar
 #   li	  a7, 1 #PrintInt  (trying to print the ascii value of the char
 #   ecall
 #   lw    ra,0(sp)    # restore ra
 #   addi  sp,sp,4     # deallocate stack frame, restore stack pointer
 #   ret               # return
 

# print NUL-terminated string stored in memory at address in a0
# Function to print a string char by char present at address in a0 until we hit '\0'
print_string:
    #PREAMBLE
    addi  sp,sp,-8
    sw ra,4(sp)
    sw s0, 0(sp)
    mv s0, a0 #store the address of the string in s0, so that it wont be lost in our program  
    #a0 has the address of the string
#    get the next char
get_next_char:
    lbu a0, 0(s0) #read s0+t3 character (i.e: t3-th character from s0 address)
    beq a0, zero, print_string_end #if '\0' null char is reached, return
    #call putc otherwise
    call putc
#    andi a1, a1, TOERR
    bnez  a1, print_string_end  #return if the error code is not 0
    mv a0, s0
    #increase t0 by 1, for next char
    addi s0, a0, 1
    mv a0, s0
    b get_next_char #loop printing chars
print_string_end:
    #POSTAMBLE
    lw    ra,4(sp)    # restore ra
    lw    s0, 0(sp)
    addi  sp,sp,8 
    ret 
    
# d2i: convert the ascii in a0 to int
# a1(error) =1 if it is not a digit, else 0
d2i:
	addi  sp,sp,-4	  # allocate stack frame (1 register to preserve = 1*4 = 4 bytes)
	sw ra,0(sp)	  # save ra
	li t0,'9'         # ASCII character '9'
	li t1, '0'  #ascii of 0
        blt t0,a0,d2i_end  # if t0 <  ascii of 9, goto d2i_not_a_digit
     #   li t0,'0
        blt a0,t1,d2i_not_a_digit  # if a0 < the ascii of 0, goto d2i_not_a_digit
        sub a0,a0,t1       # get the difference between the ascii of 0 and our digit (the digit's value in decimal)
        li  a1,NOERR       # a1 <- no error code
	b d2i_end
d2i_not_a_digit:
	li a1,NDERR
d2i_end:
	lw ra,0(sp)	  # restore ra
	addi  sp,sp,4	  # deallocate stack frame, restore stack pointer
	ret   # return

# read integer -> a0
# error code -> a1:
# returns OVERR, NDERR, NOERR error codes
geti:
    addi  sp,sp,-12         # allocate stack frame (3 registers to preserve = 3*4 = 12 bytes)
    sw    ra,0(sp)          # save ra
    sw    s0,4(sp)          # save s0
    sw    s1,8(sp)          # save s1
    
    li    s0,0              # sum register(total number)
    li    s1,10             # multiply with 10 and new line value
    li    t2,OVFMAX  
geti_loop:
    call  getc              # get character
    beq   a0,s1,geti_ok     # if character is newline goto geti_ok
    call  d2i               # convert chara to int
    bne   a1,zero,geti_end  # goto geti_end and carry on the error from d2i
    
    mul   t0,s0,s1         # s0 * 10 (mult prev value with 10)
    bgtu  t0,t2,geti_ovf   # if t0 > t2 goto geti_ovf (overflow)
    add   s0,t0,a0         # t0 + a0 (add the new digit in ones place)   
    b  geti_loop         # while loop
geti_ovf:
    li  a1,OVERR          # a1 <- overflow error code
    b geti_end
geti_ok:
    mv    a0,s0            # a0 <- s0 (entered integer)
    li    a1,NOERR         # a1 <- no error code
    #postamble
geti_end:
    lw    ra,0(sp)         # ra from stack
    lw    s0,4(sp)         # s0 saved on stack
    lw    s1,8(sp)         #  s1 from stack
    addi  sp,sp,12         # deallocate stack frame, restore stack pointer
    ret                     # return

# print the number
puti:
#preamble
    addi  sp,sp,-8          # allocate stack frame
    sw    ra,0(sp)          # save ra
    sw    s0,4(sp)          # save s0
    li    t0,10             # store 10
    
    rem   s0,a0,t0          # ones digit
    div   a0,a0,t0          # devide by 10
    beq   a0,zero,puti_end # no more digits to print
    call  puti              # loop
puti_end:
    addi  a0,s0,48         # 48 is ascii code of '0'
    call  putc              # print char(of digit)
    #postamble
    lw    ra,0(sp)          # restore ra
    lw    s0,4(sp)          # restore s0
    addi  sp,sp,8           # deallocate stack frame, restore stack pointer
    ret                     # return

### main function, read a character, print it, goto end if it is a 'Q', else continue -> old

#read an integer, print it, goto end if '0' , else continue
.globl main
main:
    la    a0,enter_int_message  # print message
#    li    a7,4                   # syscall code for PrintString
    call print_string
#    ecall
#    call  getc                   # read character
    call geti #read int
#    mv    s0,a0                  # copy read character in s0
#    la    a0,print_char_message  # print message
#    li    a7,4                   # syscall code for PrintString
#    ecall

    andi  t0,a1,NDERR            # test error code
    bne   t0,zero,main_not_a_d
    andi  t0,a1,OVERR            # test error code
    bne   t0,zero,main_overf

#    mv    a0,s0                  # copy read character in a0
    mv s0, a0                    #copy the read char in s0 to reuse a0
    
    la a0, print_int_message     #print int message from .data
    call print_string
    
    mv a0, s0 #restore a0 from s0
#    call  putc                   # print read character
    call puti    #print the read char digit by digit
    li a0, 10 #new line ascii
    call putc  #print new line
#    li    t0,'Q'                 # 'Q' ASCII code
    bne   s0,zero,main        #loop if its not zero  
    b main_end  
main_not_a_d:
    la    a0,not_a_digit_message
    call  print_string
    b    main
main_overf:
    la   a0,overflow_message
    call print_string
    b    main

main_end:
    la    a0,bye_message         # print message
#    li    a7,4                   # syscall code for PrintString
#    ecall
    call print_string  
    li    a7,10                  # syscall code for Exit
    ecall
