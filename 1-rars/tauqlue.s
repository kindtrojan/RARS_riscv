.data
question:
.asciz "What's the Answer to the Ultimate Question of Life, the Universe, and Everything? "
answer:
.word 42
wrong:
.asciz "Sorry, that's not the answer, but don't panic! Try again.\n"
bye:
.asciz "Congratulations! Remember: don't panic! Bye!\n"

.text              # what follows goes in code segment
.globl main        # main is a global label
main:              # label main is the RARS entry point by default
  la t0, answer    # store address of answer in register t0
  lw s0, 0(t0)     # load answer in register s0
ask:               # label
  la a0, question  # store address of question in a0
  li a7, 4         # store value 4 in a7 (index of PrintString syscall)
  ecall            # syscall
  li a7, 5         # store value 5 in a7 (index of ReadInt syscall)
  ecall            # syscall
  beq a0, s0, end  # if correct answer goto end
  la a0, wrong     # store address of error message in a0
  li a7, 4         # store value 4 in a7 (index of PrintString syscall)
  ecall            # syscall
  b ask            # goto ask
end:               # label
  la a0, bye       # store address of congratulation message in a0
  li a7, 4         # store value 4 in a7 (index of PrintString syscall)
  ecall            # syscall
  li a7, 10        # store value 10 in a7 (index of Exit syscall)
  ecall            # syscall
