.data
dask:
.asciz "Please input a positive integer:\n"

derror:
.asciz "Entered input is not a positive integer.\n"



.text
.global main
.align 2
div2:
	addi sp, sp, -32
	sw ra, 28(sp)
	#li t1, 2
	#div a0, a0, t1
	srai a0, a0, 1 #shift right by 1(divide by 2) and store in a0  (this 1 instruction does what the two above does)
	lw ra, 28(sp)
	addi sp, sp, 32
	jr ra

t3p1:
	addi sp,sp, -32
	sw ra, 28(sp)
	slli t0, a0, 1   #shift left by 1, doubles it
	add a0, a0, t0   #x + 2x = 3x. triple it
	addi a0, a0, 1   #3x + 1
	lw ra, 28(sp)
	addi sp, sp , 32 #reduce the stack
	jr ra

collatz:
	addi sp, sp, -32
	sw ra, 28(sp)

	andi t0, a0, 1  #check if ones digit is 1(odd)
	beqz t0, ceven
#Odd
	call t3p1
	b cend
ceven:
	call div2
cend:
	lw ra, 28(sp)
	addi sp, sp, 32
	jr ra
		
main:
cask: #label to ask for positive integer
  la a0, dask
  li a7, 4   #call printString
  ecall
  li a7, 5   # syscall scanf, value will be in a0
  ecall    
  blez a0, cerror  #if input is less than or equal to zero : Jump to cerror label to print error and circle back to ask.  

  li s1, 1 #to compare return of collatz (1 is the last in the series, it keeps repeating after that)
#  mv s0, a0   
series:
#  jal div2   # jmp to div2, and save ra in ra
  jal collatz #call collatz with value in a0
  #return value will also be in a0, print and keep calling collatz if its not 1 yet
  mv s0, a0 #save the current val in s0
  
  li a7, 1   # printInt a0 val(returned from collatz)
  ecall
  #print new line
  li a0, 10
  li a7, 11
  ecall
  
  #play music
  #a0 already stored in s0, do 32+(a0 mod64)
#  mv a0, s0 #restore s0
  andi a0,s0,64 #Modulo by 64
  addi a0,a0,32 #add 32

  li a1 125 # 125 milli
  li a2 0 #piano 0-7
  li a3, 32 # a quarter of max, roughly
  li a7, 33 #MidiOutSync too play sounds
  ecall 
  
  #restore a0 from s0
  mv a0, s0
#  jal t3p1
#  li a7, 1
#  ecall
  bne a0, s1, series  #loop if result is not 1 yet
  li a7, 10  # Exit syscall
  ecall
cerror: #print error message and ask for a good input again.
  la a0, derror
  li a7, 4
  ecall
  b cask
  
  
  
