<!-- MASTER-ONLY: DO NOT MODIFY THIS FILE

Copyright © Telecom Paris
Copyright © Renaud Pacalet (renaud.pacalet@telecom-paris.fr)

This file must be used under the terms of the CeCILL. This source
file is licensed as described in the file COPYING, which you should
have received as part of this distribution. The terms are also
available at:
http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt
-->

Memory-mapped IO, polling with time-out, timer interrupts

---

[TOC]

---

## Set-up

1. Open a terminal, change the working directory to the `ca` clone, check the current status.
   If the current branch is not your personal branch, switch to your personal branch and check again the current status.
   If your branch is not up to date with the remote or there is something to commit or the working tree is not clean, add, commit and/or pull until everything is in order.

1. Pull, merge with `origin/master`, change the working directory to this lab's directory and list the directory's content.
   `README.md` is the file you are currently looking at, `REPORT.md` is the empty file in which you will write your lab report, `exception_handler.s` is an empty file in which you will code an _Exception Handler_, `.io.s` is a starting point in case your last version of our toy application is not working yet.

## Introduction

In the previous lab we designed a simple application where the user interface was based on memory mapped IO and polling.
One of the drawbacks of this polling-based version is that our `getc` and `putc` routines are blocking.
In case the event they expect never happens, they never exit their polling loop and the CPU is 100% loaded by this loop.
We will enhance the application to avoid this drawback: these 2 functions will watch a time-out flag and, when the flag is asserted, they will return an error code instead of looping forever.
It is a timer and its interrupts that will assert the time-out flag if the user waits more than 5 seconds before entering the next character or if the display is not ready to receive the next character to print after 5 seconds.
This will not only solve the polling issue but also be a first introduction to interrupts and exceptions handling.

In this lab we will use several numeric constants like memory addresses or error codes.
The `.eqv` assembler directive is especially useful in such cases.
It is a kind of equivalent of the `#define` pre-processor macro of the C langage.
It allows to give a name to a literal and use the name instead of the literal in the code.
This reduces the risk of errors and makes it very easy to change the value of a constant: only one line of code must be changed.
Example: `.eqv TIME 0xffff018` declares name `TIME` as an equivalent of literal `0xffff018`.
With this declaration we can now write `li t0,TIME` to assign value `0xffff018` to register `t0`.

Recommendation: if one of the RARS companion tools does not work as expected reset the simulator, disconnect all tools, reset all tools, reconnect the tools and run the program again.

## Launch RARS, settings

Launch RARS (just type `rars`), open the `Settings` menu and configure it according the following picture:

![RARS settings](../../doc/rars-settings.png)

## Assignments

1. Copy your last version of our toy application:

    ```bash
	$ cp ../6-mmio/io.s .
    ```

   Alternately, if yours is not working yet, you can use the provided one:

    ```bash
	$ cp .io.s io.s
    ```

   If you decide to do so, please do not copy blindly: study the provided code, try to understand it, compare with yours and analyze the differences.

### The time-out flag

1. Edit the `io.s` source file.
   In the data section add a declaration for a 32-bits word that we will use for the time-out flag, with a global label for easy reference:

    ```
    # data section
    .data
    ...
    # time-out flag
    .globl time_out
    time_out:
    .word 0

    # code section
    .text
    ...
    ```

1. Add a `set_timer` function that takes a delay in milliseconds in register `a0` but does nothing and returns.
   Later we will modify it to initialize a timer.

1. At the beginning of `getc` and `putc` functions call `set_timer` with parameter 5000 (5 seconds) and reset the time-out flag.

1. Modify the polling loops of `getc` and `putc` such that they watch the time-out flag and return error code 4 in `a1` if the value of the time-out flag is not 0.

1. Adapt the code of the `print_string`, `geti` and `puti` functions such that they handle this new error code and return it to their own caller functions, still in `a1`.
   For all functions check that they return value 0 in `a1` if there is no error.

1. Adapt the code of the `main` function such that it prints a dedicated error message and exits if there is a time-out error.
   Of course, do not check for another time-out error while printing the dedicated error message.
   Do you understand why we use values 1, 2 and 4 for the error codes, and not 1, 2 and 3?

1. Assemble with RARS, launch the `Keyboard and Display MMIO simulator` tool, connect it to the program, simulate, debug if needed and verify that it behaves as expected.
   As we have no way yet to set the time-out flag during the simulation we are not be able to really test the time-out feature; the new version shall behave as the original one.

### The timer tool

RARS has another companion tool, the `Timer Tool` that emulates a hardware timer.
Its current 32-bits value (`time`) represents the number of milliseconds since the timer started.
It is a read-only Memory-Mapped IO (MMIO) mapped at address `0xffff0018`.
The timer counts as soon as the `Timer Tool` is launched, connected to the running program, and the `Play` button is pressed.
Note: `time` is in fact a 64-bits value and the upper half is mapped at address `0xffff001c` but, as `$2^{32}-1$` milliseconds equals about 50 days, we will never need the upper part (unless the lab lasts more than 50 days).

1. Launch the `Timer Tool`, connect it to the running program, start the timer, wait a few seconds and pause it.

1. In the `Data Segment` sub-window of RARS select the `0xffff0000 (MMIO)` memory region and look at the current value of `time`.

1. Does it correspond to the current time of the `Timer Tool` window?

1. Modify the `io.s` code such that it prints not only the entered integer but also the time at which it was entered:

    ```
    You entered integer 123 at 4135 milliseconds.
    ```

1. Assemble with RARS, launch the `Keyboard and Display MMIO simulator` and `Timer Tool` tools, connect them to the program, start the timer, simulate, debug if needed and verify that the application behaves as expected.

### Exceptions, interrupts, Control and Status Registers

Exceptions and interrupts are ways to signal a computer that something requires attention.
Exception is a term mainly used for events that are synchronous with the running application, like trying to execute an invalid instruction, dividing by zero, trying to access memory at an unaligned or illegal access, etc.
Interrupt is a term mainly used for asynchronous events that can occur any time, like a hardware timer reaching a limit, a keystroke on a keyboard, etc.
When an exception or an interrupt is raised the hardware automatically saves some context information in dedicated registers, stops executing the current application and jumps to a software component called the _exception handler_ (even if it also handles interrupts).
That is, it sets the Program Counter (PC) to the address of the first instruction of the exception handler.
The exception handler investigates about the event and takes the appropriate measures to deal with it before returning to the interrupted application with the `uret` instruction.

Exceptions and interrupts are other examples of mandatory hardware support for OS.
In order to let the OS preempt any running process a hardware timer can be configured to periodically raise an interrupt.

With the RISC-V architecture and the RARS tool a set of dedicated registers is used to handle exceptions and interrupts: the Control and Status Registers (CSR).
In RARS the CSR are visible in the _Control and Status_ tab of the _Registers_ sub-window.
The CSR we are interested in are:

- `ustatus`: status information, its bit 0 (LSB) serves as a global interrupt enable, if it is 0 all interrupts are ignored.
  When an exception or an interrupt occurs the hardware copies bit 0 to bit 4 and clears bit 0 before jumping to the exception handler.
  This way the exception handler cannot be itself interrupted by a new interrupt.
  This allows to design simpler non-reentrant interrupt handlers (but nested exceptions shall be considered).
  Before returning, the `uret` instruction restores the global interrupt enable by copying back bit 4 to bit 0.
- `uie`: specific interrupt enable flags, bit 4 is the timer interrupt enable, if it is 0 timer interrupts are ignored.
- `utvec`: base address of the exception handler.
  The `uret` instruction jumps at `utvec`.
- `uscratch`: general purpose register, as we will see it is essential for the design of exception handlers.
- `uepc`: PC of current instruction when exception or interrupt occurs.
  When an exception or an interrupt occurs the hardware copies the PC of the current instruction to `uepc`.
  The `uret` instruction sets back the PC to `uepc`.
- `ucause`: cause of exception or interrupt, bit 31 (MSB) is an interrupt flag set to 1 for interrupts, 0 for exceptions; bits 30 down to 0 are the numeric code of the exception or interrupt.

Several dedicated instructions are used to read or update the CSR.

1. In the RARS _Help_ window look at the `csrxxx` instructions and read the explanation (`fcsr` is just an example, any CSR name can be used).
   These instructions are atomic: they all perform several actions but it is guaranteed that nothing else can happen between these actions.
   Atomic actions are another example of mandatory hardware support for OS.
   Look also at the `uret` instruction that returns from the exception handler (just like the `ret` pseudo-instruction returns from a function).
   If the explanation is not clear search Internet.

1. Modify again your application to copy `time` to the `uscratch` CSR when printing the entered integer and the current time.

1. Assemble with RARS, launch the `Keyboard and Display MMIO simulator` and `Timer Tool` tools, connect them to the program, start the timer, simulate, debug if needed and observe the value changes of `uscratch` during execution (you must pause the execution of your program to refresh the display of the CSR values in the _Registers_ sub-window).

### First exception handler, numeric code of timer interrupt

The `Timer Tool` implements a second MMIO: `timecmp`, for _TIME CoMPare_, a 32-bits value.
While `time` is read-only `timecmp` can be read or written at address `0xffff0020`.
An interrupt is raised as soon as `time` becomes greater than or equal `timecmp`.
Note: like `time`, `timecmp` is in fact a 64-bits value and the upper 32-bits are mapped at address `0xffff0024`; for the same reason as for `time` we will not need it.
Note: if `timecmp` is set to a value less than `time` the interrupt will never be raised, unless we wait until the timer wraps around its upper bound (that is, with a 64-bits timer, about 580 million years).

A hardware timer is an example of mandatory hardware support for Operating Systems (OS); without a timer it would be very difficult or impossible to implement a full-fledge multi-task preemptive OS.
An application could run forever and never let the OS schedule other applications.

In this part we will design a simple exception handler and use it to discover the numeric code of the timer interrupt.
Exception handlers are very special software components, usually part of the Operating System (OS).
One of their most challenging aspects is that they cannot modify **any** general purpose register, including non-saved registers like `t0`, `t1`, etc.
If an exception handler modifies a general purpose register, say `t0`, and the running application is using it when it is interrupted, things will go wrong when the application resumes after the exception handler finished its job.
But how can we design an exception handler without modifying any general purpose register?

We could try to allocate a stack frame by subtracting some value from `sp`, save all registers we want to use in the stack frame, restore them at the end and restore `sp` by adding what was subtracted, a bit like we do for regular functions.
But this is not allowed neither because the exception could have been caused by an unaligned bogus `sp` value.
If the target processor does not support data unaligned accesses we would encounter the same exception again on the first register save.
And even if `sp` is properly aligned it could also be wrong, due to the same coding error that caused the exception, and our stack frame could overwrite useful data.

This is where `uscratch`, a free extra general purpose register enters the picture; we will use it, plus a dedicated _kernel_ stack.

1. Open the empty assembly source file named `exception_handler.s` and add a 1KiB software stack in the data segment, labeled `kstack` (_k_ for _kernel_):

    ```
    # data section
    .data
    kstack:
    .space 1024
    ```

1. Add a code segment starting with a `exception_handler` global label:

    ```
    .text
    .globl exception_handler
    exception_handler:
    ```

1. Use the `csrrw` instruction to save register `sp` in `uscratch`.

1. Set `sp` to `kstack` and use it to save `t0`, `t1`, `t2`, `t3`, `a0` and `a7` in the kernel stack.
   We will try to use only these registers in our exception handler.
   If we need more we will save and restore them too.

1. Code also the end of the exception handler where you restore these same registers from the kernel stack, restore `sp` from `uscratch` and call `uret`.

1. Between the introduction and conclusion of your exception handler print the content of the 6 CSR we are interested in, in hexadecimal, using the `PrintIntHex` syscall (code 34).
   Be careful: you can use only the registers you saved in `kstack`.
   Be careful: in order to preserve the content of the CSR you cannot use the `csrrw` instruction to read them; use `csrrsi` instead:

    ```
    csrrsi  a0,uepc,zero   # atomic a0 <- uepc <- uepc OR zero
    ```

1. Save the file, in the _Settings_ menu of RARS select _Exception Handler..._ and declare `exception_handler.s` as the exception handler to use for all assemble operations.

Edit `io.s` to:

1. Add instructions to the `set_timer` function such that it reads `time`, adds `a0` to it, stores the result in `timecmp` and enables timer interrupts.

Add instructions at the beginning of the `main` function to:

1. Store the address of the exception handler in `utvec`.

1. Enable all interrupts in `ustatus`.

1. Call `set_timer` with a 5000 milliseconds (5 seconds) delay.

1. Assemble with RARS, launch the `Keyboard and Display MMIO simulator` and `Timer Tool` tools, connect them to the program, start the execution of the application but do not enter an integer.
   Instead, start the timer and wait 5 seconds.
   Your exception handler should execute and the values of the CSR should be printed.
   If not, debug and fix errors until you see the 6 CSR values.
   Try to explain these values.
   What instruction was currently executing when the timer interrupt occurred?
   What is the timer interrupt code?
   How do you know this was an interrupt and not an exception with the same code?

### Using timer interrupts to set the time-out flag

Edit `exception_handler.s` to:

1. Comment out the printing of the CSR values.

1. Add instructions such that, if the event that caused the execution of the exception handler is a timer interrupt, the time-out flag is set to 1 and timer interrupts are disabled.
   We can say that this part of the exception handler is the _timer Interrupt Service Routine_ (_timer ISR_) because it is the part that specifically manages timer interrupts.

Edit `io.s` to:

1. Comment out the call of `set_timer` at the beginning of the `main` function.

Now, normally, if you wait more than 5 seconds while the application is waiting for a character input (`getc`) or a character output (`putc`), the time-out flag should be set by the exception handler, the `getc` or `putc` function should exit its polling loop and return error code 4.
This should allow us to test the time-out flag.

1. Assemble with RARS, launch the `Keyboard and Display MMIO simulator` and `Timer Tool` tools, connect them to the program, start the execution of the application, start the timer and enter integers when asked, without delay.
   The behavior shall be the same as before.
   Wait more than 5 seconds before entering the next character and check that this time-out situation is properly caught.
   If not, debug and fix errors until the behavior is the expected one.

1. Bonus question: at the beginning of the `getc` and `putc` functions of our application we call `set_timer` with parameter 5000 (5 seconds) and reset the time-out flag, in this order.
   This order is important; do you know why?

## Conclusion

Even with a time-out, polling suffers another drawback by putting load on the CPU: repeatedly reading an interface register until something useful happens is not very efficient.
It may be acceptable if the polling is fast and done at a low frequency (e.g. it takes one micro-second every minute) or if it can be done only when there is nothing more important to do (e.g. check for new emails).
But this is not always the case.
For unpredictable events requiring a reasonably fast reaction like keystrokes, the polling should probably be done every millisecond or so.

Indeed, polling is about as efficient as repeatedly stopping the preparation of the diner, going to the front door and opening it to check if the expected visitors arrived.
Preparing the diner until the door bell rings seems much better.
This is what interrupts are: the door bells of computer systems.
A better option than polling is thus to configure the system such that, when the expected event occurs, the device raises an interrupt, forcing the CPU to execute the exception handler.

Indeed, the `Keyboard and Display MMIO simulator` tool raises an interrupt when it receives a new character or the console display is ready to receive a new character to print.
We could thus use these interrupts to completely avoid the rather inefficient polling.
This would be beneficial if we had something better to do than looping while waiting for the user to enter a new character.

As a bonus try to imagine a new version of our application where:

* The complete functionality is distributed among the ISR of the keyboard, display and timer.
* The `main` routine does something completely different, like, for instance, search for a counter-example to the Collatz conjecture.

## Report, add, commit, push

Write your report, add (`REPORT.md` and `io.s`), commit and push in your personal branch.

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab textwidth=0: -->
