<!-- MASTER-ONLY: DO NOT MODIFY THIS FILE

Copyright © Telecom Paris
Copyright © Renaud Pacalet (renaud.pacalet@telecom-paris.fr)

This file must be used under the terms of the CeCILL. This source
file is licensed as described in the file COPYING, which you should
have received as part of this distribution. The terms are also
available at:
http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt
-->

Quick start with RARS, the RISC-V Assembler and Runtime Simulator

---

[TOC]

---

As for any lab do not forget to write a report in [Markdown syntax] in the `REPORT.md` file.
Remember that the written reports and source code are personal work (plagiarism is not accepted).
Do all assignments yourself and try to understand each of them.
You can of course discuss with others, exchange ideas, ask others for help, help others…
It is even warmly recommended, but at the end your report and source code must be your personal work.
They are due the day before the written exam at 23:59.
After this deadline the git repository will become read-only and there will be no possibility any more to add or modify something.

## Set-up

1. Open a terminal, change the working directory to the `ca` clone, check the current status (`USERNAME` represents your username, that is, the name you use to log on Eurecom GNU/Linux desktop computers):

    ```bash
    $ cd ~/Documents/ca
    $ git status
    On branch USERNAME
    Your branch is up to date with 'origin/USERNAME'.
    
    nothing to commit, working tree clean
    ```

1. If the current branch is not your personal branch, switch to your personal branch and check again the current status:

    ```bash
    $ git checkout USERNAME
    $ git status
    …
    ```

1. If your branch is not up to date with `origin/USERNAME` or there is something to commit or the working tree is not clean, add, commit and/or pull until everything is in order.

1. Pull, merge with `origin/master`, change the working directory to this lab's directory and list the directory's content:

    ```bash
    $ git pull
    $ git merge origin/master
    $ cd labs/1-rars
    $ ls
    README.md
    REPORT.md
    tauqlue.s
    ```

   `README.md` is the file you are currently looking at, `REPORT.md` is the empty file in which you will write your lab report and the `tauqlue.s` file is an empty file in which you will write RV32IM assembly code.

## Introduction

In this lab we will have a quick tour of RARS, the RISC-V Assembler and Runtime Simulator.
We will also discover some assembler directives, system calls and do some assembly coding.

There are usually 3 ways to launch an action with RARS:
- Select an entry in a menu.
- Click on an icon.
- Use a keyboard shortcut (shortcuts are indicated near the menu entry with the same effect).

In the following directions we use the menu entries method with the `[M -> E]` syntax to designate the `E` entry of the `M` menu; feel free to use the method you prefer.

## Launch RARS, settings, help

Launch RARS (just type `rars`), open the `Settings` menu and configure it according the following picture:

![RARS settings](../../doc/rars-settings.png)

Open the help window (`[Help -> Help]`) and select its `RISCV` tab.
In the `RISCV` tab you can see several sub-tabs:
- `Basic instructions` lists the RV32IM basic instructions; ignore the `fxxx` floating point instructions, the `csrxxx`, `ebreak`, `fence`, `fence.i`, `uret` and `wsi` instructions, we will not use them.
- `Extended (pseudo) instructions` lists the pseudo instructions that you can also use but that will be translated into basic instructions by the assembler.
- `Directive` lists the assembler directives, that is, commands that you pass to the assembler to alter its behavior but that will not become instructions.
  In this lab we will use `.asciz`, `.word`, `.text` and `.data`; read the corresponding explanations.
- The `Syscalls` sub-tab explains what system calls are, how to use them, and lists all available system calls with their input/output parameters.
  In this lab we will use `PrintString`, `ReadInt` and `Exit`; read the explanations.

Ignore the other sub-tabs, we don't need them for now.

## The Answer to the Ultimate Question of Life, the Universe, and Everything

The goal of this first coding exercise is to design a small application in RV32IM assembly, and simulate it.
We will also simulate it step by step to observe changes in the registers and with breakpoints to understand how RARS can be used for debugging.
The small application will ask the user [The Answer to the Ultimate Question of Life, the Universe, and Everything][TAUQLUE], compare it with the correct one, print a congratulation message and exit if the answer is correct, else print an error message and ask again.

### A note on the way characters and text strings are represented

In the computer system that RARS emulates characters are encoded as numeric values between 0 and 127: the [ASCII code].
Even if 7 bits would be enough, when stored in memory a character occupies one full byte with a 0 as most significant bit.
The 32 first ASCII codes (0 to 31) and the last (127) correspond to control characters; all others codes correspond to printable characters.
To see the correspondence between characters and ASCII codes, switch to your opened terminal and type `man ascii` (use up/down arrows or page up/page down keys to navigate, type `q` when done).

Text strings are sequences of characters and they are encoded as sequences of numeric values between 0 and 127.
Functions and system calls that process a text string stored in memory frequently need to know not only where the string starts (the memory address of its first byte) but also where it stops.
This can be done in different ways:
- by providing also the length,
- by providing also the memory address of the last byte,
- by using a special ASCII code to terminate the string.

When a special ASCII code is used to signal the end of a string it is usually `NUL` (ASCII code 0).
The `PrintString` system call that we will use later to print text strings expects a `NUL` at the end of the string.

### The assembler

The A letter in RARS stands for Assembler.
This is a software that resembles a compiler: it takes the textual assembly source code of our application and produces a binary version of it, ready to be executed by the computer, that we call the _executable_ for short.
On real computer systems the executable is usually stored in a file and it is this file that you invoke by clicking on its icon or by typing its name in the command line interface when you want to execute the application.
In our small simulated RISC-V computer the executable is not stored in a file but the principle is the same.

The executable is a representation of the memory layout; in order to run the application the executable is parsed, _segments_ of it are loaded at specified addresses into the computer's memory, and the computer's program counter is set to the address of the first instruction.
In this lab we will focus on two segments: the data segment that contains our application's data and the code segment that contains its instructions.
**Important**: the code segment is also sometimes called the _text_ segment for historical reasons; do not mix up with text strings.
With RARS by default the data segment starts at address `0x10010000` in memory and the code segment starts at address `0x00400000`.

The assembler can be seen as a kind of dual track recorder where one track would be the data segment and the other would be the code segment.
It parses our source code and progressively adds items to one or the other of the segments until they are complete.
Only one of the two segments can be updated at a time: the _current_ segment; at the beginning of the assembling the current segment is the code segment.
While parsing our source code the assembler manages 2 internal variables, `vcode` (initialized with `0x00400000`) and `vdata` (initialized with `0x10010000`); they are the recording heads of the dual track recorder and they always point to the next available free memory address in their respective segment.
The assembler reads our assembly source code line by line and depending of what was read it can either:
- change the current segment (`.text` and `.data` directives),
- store the current memory address, that is, the current value of `vcode` or `vdata` depending on the current segment, and give it a name for later reuse (label declarations),
- add an item to the current segment and increment the corresponding `vcode` or `vdata` variable accordingly (almost everything else).

### The data segment

Let's start our coding with the data segment.
The following code snippet specifies the layout we want for the memory region that contains our application's data:

```
.data
question:
.asciz "What's the Answer to the Ultimate Question of Life, the Universe, and Everything? "
answer:
.word XX
wrong:
.asciz "Sorry, that's not the answer, but don't panic! Try again.\n"
bye:
.asciz "Congratulations! Remember: don't panic! Bye!\n"
```

#### Explanations

1. `.data`, is an assembler directive.
   It indicates that the assembler shall change the current segment to data and start using the `vdata` variable.

1. `question:` declares a label that we will use elsewhere in the assembly code to refer to the current memory address.
   When it encounters this label declaration the assembler stores the current memory address (the current value of `vdata`) and gives it the name `question`.
   Every time the assembler will encounter again the `question` label it will replace it by the stored address.

1. `.asciz "What's…? "` is another directive.
   It instructs the assembler to add to the data segment the text string between double-quotes, with a final `NUL` character (ASCII code zero, this is what the `z` in `.asciz` means, the `.ascii` directive does almost the same, without the `NUL` character).
   The `question` label declared on the previous line thus represents the memory address of the first character of the string (the `W`); we call this address the _base address_ of the string or just its _address_.
   The string between double quotes, including the final space, is 82 characters long, so after adding the `NUL` character this directive reserves and initializes 83 bytes in the data segment.
   The assembler adds 83 to `vdata` such that it points to the next memory address to populate in the data segment.

1. `.word XX` adds an aligned word (4 bytes, that is, 32 bits) and initializes this word with integer value `XX`.
   As the reserved word must be aligned on a word boundary, if `vdata` is not already a multiple of 4, it is first incremented by 1, 2 or 3 such that it becomes a multiple of 4 (1 to 3 bytes are skipped).
   After adding the word, the assembler adds 4 to `vdata`.
   Similarly as `question:`, `answer:` declares a label that we will use to refer to the word's base address.

1. We then allocate another `NUL`-terminated text string, `Sorry…`, for the error message and we use a third label, `wrong`, to refer to its address.

1. Finally, we allocate a last `NUL`-terminated text string, `Congrat…`, for the congratulation message and we use another label, `bye`, to refer to its address.

#### Assembling

1. In RARS open the `tauqlue.s` empty file (`[File -> Open]`).

1. Copy the code snippet in the `Edit` sub-window and save the file (`[File -> Save]`).

1. Assemble the code (`[Run -> Assemble]`).
   The error message you see in the `Messages` sub-window tells you that `XX` is not a valid initialization value for our `.word` declaration.
   Replace `XX` by the correct [Answer to the Ultimate Question of Life, the Universe, and Everything][TAUQLUE]; hint: it's a 2 digits positive integer value.
   Do not put quotes around the integer value, quotes are used to delimit text strings.
   Save the file and assemble it again.
   If there are errors fix them and assemble again until the operation completes successfully.

1. The assembler translated the assembly source code you wrote and prepared the data segment accordingly.
   Observe the data segment in the `Data Segment` sub-window.
   You can toggle the `ASCII` and `Hexadecimal` radio-buttons to show the data in the most convenient form.
   The computer we simulate is little-endian, however RARS presents the data by groups of 4-bytes, and in the most convenient order for numbers: most significant byte (highest address) on the left and least significant byte (lowest address) on the right.
   Reading your text strings is thus not very easy but you should recognize them if you scan each 4-bytes group right-to-left.

1. What is the address of the first character of the question?

1. Does this correspond to the start address of the data segment and to the address of label `question` in the `Labels` sub-window?

1. What is the address of the word containing the correct answer?

1. How many bytes have been skipped between the question and the word?

1. Are there also skipped bytes between the other data items?

Note the addresses of the word and the 3 text strings, you will need them to understand what comes next.

### The code segment

Let's now add the instructions for our little application.

```
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
```

#### Explanations

The code is commented, use the comments to understand what it does.

1. The code starts with the `.text` directive to indicate the assembler that what follows is instructions, not data any more.
   The assembler stops using and advancing `vdata`, it now uses `vcode`.

1. Can you see where the 4 labels that we declared in the data segment are used and what for?

1. The code adds 3 more labels: `main`, `ask` and `end`.
   The `main` label is special: we declared it as global (`.globl main` directive) and we enabled the `Initialize Program Counter to global 'main' if defined` setting.
   So, the first instruction that RARS will execute is the one which address corresponds to this label; we call this instruction _the entry point_ of the application.

1. The code makes use of system calls; to understand it you will also need to open the `Syscalls` sub-tab of the help window and study `PrintString`, `ReadInt` and `Exit`.

1. Can you identify where the system calls are used in the above code and what they are supposed to do?

1. Among the various instructions can you identify the basic RV32IM instructions and the pseudo instructions (use the `Basic instuctions` and `Extended (pseudo) instructions` sub-tabs of the help window)?

#### Assembling

1. Copy-paste the preceding code snippet after the data segment in the `Edit` sub-window and save the file.

1. Assemble again.
   The assembler translates the assembly source code you wrote and prepares the data and code segments accordingly.
   If there are errors fix them and assemble again until the operation completes successfully.
   The `Execute` tab now shows you a detailed view of the code segment in which each line corresponds to a basic RV32IM instruction:
   - The left column (`Bkpt`) is for breakpoints (back on this later).
   - The `Address` column shows the address in memory of the instruction.
   - The `Code` column shows the instruction encoding in hexadecimal.
   - The `Basic` column shows the human-readable form of the instruction in RV32IM assembly language.
   - The `Source` column shows the source code you wrote with line numbers on the left.

1. What is the address of the first instruction?

1. Note the hexadecimal encoding of the first instruction, convert it in binary.
   Open the [slides of the ISA lecture](https://perso.telecom-paristech.fr/pacalet/CompArch/lectures/ISA/slides.pdf), search the slide that shows the binary encoding of this type of instruction.
   Check that the binary encoding of RARS and of the slide match.

1. This first instruction is not the `la t0, answer` instruction you wrote because this is a pseudo instruction that has been transformed by the assembler into something equivalent but using only basic RV32IM instructions.
   How many basic instructions were needed for the `la t0, answer` pseudo instruction?

1. Try to understand what the basic instructions corresponding to the first pseudo instruction do and why the result is the same as `la t0, answer`.
   Try to execute them mentally, check that the final value in `t0` is the address of the answer word in the data segment.

1. Identify all other (pseudo) instructions in your source code and study how they have been translated.

### Simulation

1. It's time to test this application (`[Run -> Go]`).
   The output messages are sent to the `Run I/O` tab of the bottom RARS sub-window.
   Try a wrong answer, and then the correct one to check that the application works as expected.

#### Step by step execution

1. Reset the simulator (`[Run -> Reset]`).

1. In the `Registers` tab of the right sub-window check that all registers are initialized to zero, except `x2`, alias `sp`, `x3` (`gp`) and the program counter (`pc`).
   Ignore `sp` and `gp` for now.
   Is `pc` initialized with the address of the first instruction to execute?
   Is it the same address as that of label `main`?
   Is it the starting address of the code segment?

1. Analyze again the first basic instruction.
   What registers should change when it will be executed?

1. Execute only the first instruction (`[Run -> Step]`) and observe the changes in the registers.
   What registers changed?
   Are these changes consistent with what you imagined?

1. Continue executing step by step (after executing the `ecall` instruction corresponding to the `ReadInt` syscall do not forget to enter an answer before you execute the next instruction).
   Before executing each instruction try to predict what the effect will be on the registers and check that you predictions were correct after it has been executed.

#### Using breakpoints

1. Let's introduce a bug on purpose in our source code (`Edit` sub-window): replace the correct answer by another one (e.g. swap the 2 digits).

1. Re-assemble (`[Run -> Assemble]`).

1. Run again the application in normal mode and check that even with the correct answer it keeps asking the question.

1. Stop the execution (`[Run -> Stop]`) and reset (`[Run -> Reset]`).

1. Suppose you are not the person who wrote the code and you don't know where this wrong behavior comes from but you'd like to find out using breakpoints.
   In the left column (`Bkpt`) of the `Text segment` of the `Execute` tab check the radio button of the `beq a0, s0, end` instruction.
   We want to stop there because it is the instruction that checks the answer; examining the content of registers `a0` and `s0` before it is executed is thus probably interesting.

1. Run again the application in normal mode, give the correct answer when asked the question.
   The execution pauses at the breakpoint, that is, just before executing the `beq a0, s0, end` instruction.

1. Check the content of registers `a0` and `s0` and "_realize_" that `s0` does not contain the correct answer.

1. Fix the error and save (`[File -> Save]`).

## Coding of an advanced version

We will now modify our small application to add a bit of complexity.

### Specifications

1. The application manages an internal counter with initial value 0.

1. Instead of letting the user enter any number, the application accepts only integer values between -9 and +9.

1. If the entered value is greater than +9 or less than -9 the application discards it.

1. Else, if the value is valid, the application adds it to the internal counter and:

   1. If the value of the internal counter is equal to the correct [Answer to the Ultimate Question of Life, the Universe, and Everything][TAUQLUE] the application prints the congratulation message and exits.

   1. Else the application prints a message indicating whether the current value of the internal counter is less or greater than the correct answer and asks again.

### Coding

1. In RARS save the `tauqlue.s` file under new name `tauqlue2.s` (`[File -> Save as…]`).

1. Code the modifications.
   To reflect the changes modify the message that the application prints when asking.
   Invent the error message that the application prints when the entered value is greater than +9 or less than -9.
   Invent the messages that the application prints when the current value of the internal counter is not yet the correct answer.

1. Re-assemble (`[Run -> Assemble]`) and fix the errors if any.

1. Test your application, use step by step execution and/or breakpoints to debug it.

## Report, add, commit, push

Once you will have written your report do not forget to add, commit and push it in your personal branch.
Add also the `tauqlue.s` and `tauqlue2.s` files.
Example with a `git status` after each action:

```bash
$ cd ~/Documents/ca/labs/1-rars
$ git status
On branch USERNAME
Your branch is up to date with 'origin/USERNAME'.

Changes not staged for commit:
  (use "git add <file>…" to update what will be committed)
  (use "git restore <file>…" to discard changes in working directory)
	modified:   REPORT.md
	modified:   tauqlue.s
	modified:   tauqlue2.s

no changes added to commit (use "git add" and/or "git commit -a")
$ git add REPORT.md tauqlue.s tauqlue2.s
$ git status
On branch USERNAME
Your branch is up to date with 'origin/USERNAME'.

Changes to be committed:
  (use "git restore --staged <file>…" to unstage)
	modified:   REPORT.md
	modified:   tauqlue.s
	modified:   tauqlue2.s

$ git commit -m 'Complete first lab'
$ git status
On branch USERNAME
Your branch is ahead of 'origin/USERNAME' by 1 commit.
  (use "git push" to publish your local commits)

nothing to commit, working tree clean
$ git push
$ git status
On branch USERNAME
Your branch is up to date with 'origin/USERNAME'.

nothing to commit, working tree clean
```

[Markdown syntax]: https://www.markdowntutorial.com/
[TAUQLUE]: https://en.wikipedia.org/wiki/Phrases_from_The_Hitchhiker%27s_Guide_to_the_Galaxy#The_Answer_to_the_Ultimate_Question_of_Life,_the_Universe,_and_Everything_is_42
[ASCII code]: https://en.wikipedia.org/wiki/ASCII

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0: -->
