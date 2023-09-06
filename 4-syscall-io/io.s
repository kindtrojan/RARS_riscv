# data section
.data

# messages
enter_char_message:
.asciz "\nPlease enter a character (Q to quit) "
print_char_message:
.asciz "\nThe ascii code of the character you entered is "
bye_message:
.asciz "\nBye!"

# code section
.text

# read character, return read character in a0
getc:
    addi  sp,sp,-4    # allocate stack frame (1 register to preserve = 1*4 = 4 bytes)
    sw    ra,0(sp)    # save ra
    li    a7,12       # syscall code for ReadChar
    ecall
    lw    ra,0(sp)    # restore ra
    addi  sp,sp,4     # deallocate stack frame, restore stack pointer
    ret               # return

# print character in a0
putc:
    addi  sp,sp,-4    # allocate stack frame (1 register to preserve = 1*4 = 4 bytes)
    sw    ra,0(sp)    # save ra
  #  li    a7,11       # syscall code for PrintChar
    li	  a7, 1 #PrintInt  (trying to print the ascii value of the char
    ecall
    lw    ra,0(sp)    # restore ra
    addi  sp,sp,4     # deallocate stack frame, restore stack pointer
    ret               # return

# main function, read a character, print it, goto end if it is a 'Q', else continue
.globl main
main:
    la    a0,enter_char_message  # print message
    li    a7,4                   # syscall code for PrintString
    ecall
    call  getc                   # read character
    mv    s0,a0                  # copy read character in s0
    la    a0,print_char_message  # print message
    li    a7,4                   # syscall code for PrintString
    ecall
    mv    a0,s0                  # copy read character in a0
    call  putc                   # print read character in ascii format (putc modified to use syscall PrintInt, could have created a new function puti 
    li    t0,'Q'                 # 'Q' ASCII code
    bne   a0,t0,main             # loop if read character is not 'Q'
main_end:
    la    a0,bye_message         # print message
    li    a7,4                   # syscall code for PrintString
    ecall
    li    a7,10                  # syscall code for Exit
    ecall
