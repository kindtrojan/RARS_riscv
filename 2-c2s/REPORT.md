## Look at the abssub function in the abssub.s produced assembly code.

Try to answer the following questions.

  

#### What is the size of the stack it uses?

48 bytes

#### What is the stack used for?

To store and restore saved register, local variable etc.

#### What registers are saved on the stack at the beginning and restored from the stack at the end?

s0

#### Two registers are used to manage the stack and to access its content, which ones?

sp and s0

#### What are they used for?

They achieve the same goal: sp to access from the bottom(by adding offset), s0 to do the reverse.

#### Are there input parameters in this function and, if yes, in what registers are they passed?

yes, in a0 and a1

#### Are there output results and, if yes, in what registers are they passed?

yes, in a0

#### Try to understand the code.

#### Does it look correct?

Yes

#### Do you think the code could be optimized?

Yes, there are few redundant sw and lw operations(back to back) which could be avoided.



----------------

## Look at the `main` function in the `abssub.s` produced assembly code:
    
   ### Answer the same questions as for the `abssub` function
  

#### What is the size of the stack it uses?

16 bytes

#### What is the stack used for?

To store and restore saved register s0 and return address ra

#### What registers are saved on the stack at the beginning and restored from the stack at the end?

s0, ra

#### Two registers are used to manage the stack and to access its content, which ones?

I think only sp is being used

#### What are they used for?

to access the stack contents

#### Are there input parameters in this function and, if yes, in what registers are they passed?

No- void

#### Are there output results and, if yes, in what registers are they passed?

yes, in a0, a return code of 0

#### Try to understand the code.

#### Does it look correct?

Yes

#### Do you think the code could be optimized?

Yes, there are few redundant instructions(storing in a register , then copying it to other) which could be clubbed. 

#### Do you see where the `main` function calls the `abssub` function?
using a remote subroutine call (call	absSub)
####  Do you think the compiler uses a kind of calling convention similar to the one we studied during the lectures?
Yeah, uses an extended/pseudo instruction which clubs multiple basic instructions
#### Try to summarize the strategy that the compiler uses to call functions:
        -   What is done in the caller before the function is called?
        store the arguments in the a0/a1 registers, store the return address ra on stack if this function is not main function and has to return somewhere else later.
        -   What is done at the beginning of the callee?
        Preamble: give some space on the stack by reducing the stackpointer, store the saved registers we want saved(maybe ra too, if we have to call another function), read inputs from input arg registers
        -   What is done at the end of the callee?
        POSTAMBLE: clear the stack and free up the space. restore ra and other saved regs before that and save appropriate return values in a0
        -   What is done in the caller after returning from the callee?
        nothing, caller probably acts on the return value from the callee 
        -   What registers are preserved by the callee and what registers are not?
        callee preserves all saved regs(ABI) and maybe ra(if the callee is to act as a caller later).

-------------

### Do you think the conventions used by the compiler and seen during the lectures would work with recursive functions? Why? If yes, do you think there is a limit to the number of recursions? Why?

Yeah, should work fine with conventions the compiler uses and what we saw in lectures as this is standard caller calling callee (except the callee inturn acts as a caller and calls itself as a callee again and again in a loop)

There will be a limit on the number of recursions, because the stack can only grow so much and will reach its limit if the recursion is too much, making it run into other memory sections(heap)

### Can you explain what happens with a large enough number of iterations? What is the approximate maximum size of the stack on your host PC?
there will be a segmentation fault as the stack will try to grow into heap.

the number of recursions it could take is approx 104700.
I compiled it and checked the generated assembly code, it is creating a stack of 80 bytes. so, according to this its 104700*80 bytes
However, it is saving ra and s0(4+4 bytes) and then needs space for 10 integer array.(10*4).. so, it should only need about 48 bytes,. according to this , the stack size is 104700*48 bytes

## Optimization:
#### Look at the produced assembly code in `abssub.o3.s`:
-   Do you think the compiler did a good optimization job?
	yes, redundant instructions are removed and it is even bypassing the static call to abssub
-   Do you think the code could be further optimized?
 No
## Adaptation for RARS:
removed the printf call and used a syscall of printInt(li a7, 1 +  ecall)
at the end of main, doing an exit Syscall (li a7, 10 + ecall)

## Assembly:
Datasegment: it contains the .string - %d\n
Text segment: auipc and jalr are used to achieve the pseudo "call"
