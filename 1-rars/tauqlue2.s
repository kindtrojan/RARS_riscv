.data
question:
.asciz "What's the Answer to the Ultimate Question of Life, the Universe, and Everything? "
answer:
.word 42
badinputlowerlimit:
.word -9
badinputhigherlimit:
.word 9
wrong:
.asciz "Sorry, that's not the answer, but don't panic! Try again.\n"
bye:
.asciz "Congratulations! Remember: don't panic! Bye!\n"
dlesser:
.asciz "Its less! add more \n"
dgreater:
.asciz "Its more! reduce \n"
dbadinputlower:
.asciz "Input in less that -9, bad input, discarding! \n"
dbadinputupper:
.asciz "Input is higher than 9, bad input, discarding! \n"
dbadinput:
.asciz "Input should be between -9 and +9, discarding bad input! \n"

.text              # what follows goes in code segment
.globl main        # main is a global label
main:              # label main is the RARS entry point by default
  la t0, answer    # store address of answer in register t0
  lw s0, 0(t0)     # load answer in register s0
  add s1, zero, zero  #initialize s1 counter with zero
  
  la t0, badinputlowerlimit
  lw s2, 0(t0)
  
  la t0, badinputhigherlimit
  lw s3, 0(t0)
ask:               # label
  la a0, question  # store address of question in a0
  li a7, 4         # store value 4 in a7 (index of PrintString syscall)
  ecall            # syscall
  li a7, 5         # store value 5 in a7 (index of ReadInt syscall)
  ecall            # syscall
  blt a0, s2, cbadinput #if received input less than the value in s2 (badinputlowerlimit), branch to cbadinput
  bgt a0, s3, cbadinput #if received input greater than the value in s3 (badinputupperlimit), branch to cbadinput
  add s1, s1, a0
  beq s1, s0, end  # if correct answer goto end
  #jump to less if less
  blt s1, s0, clesser
  #jump to greater if greater
  bge s1, s0, cgreater

  
  
  la a0, wrong     # store address of error message in a0
  li a7, 4         # store value 4 in a7 (index of PrintString syscall)
  ecall            # syscall
  b ask            # goto ask
cbadinput:	   #code to display the error message for a bad input
  la a0, dbadinput
  li a7, 4
  ecall
  b ask 
clesser:           #branch code to display the message that the cumulative sum is lesser than the magic number we want.
  la a0, dlesser
  li a7, 4
  ecall
  b ask
cgreater:          #branch code to display the message that the cumulative sum is greater than the magic number we want.
  la a0, dgreater
  li a7, 4
  ecall
  b ask
end:               # label
  la a0, bye       # store address of congratulation message in a0
  li a7, 4         # store value 4 in a7 (index of PrintString syscall)
  ecall            # syscall
  li a7, 10        # store value 10 in a7 (index of Exit syscall)
  ecall            # syscall
