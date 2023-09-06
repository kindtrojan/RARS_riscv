<!-- MASTER-ONLY: DO NOT MODIFY THIS FILE

Copyright © Telecom Paris
Copyright © Renaud Pacalet (renaud.pacalet@telecom-paris.fr)

This file must be used under the terms of the CeCILL. This source
file is licensed as described in the file COPYING, which you should
have received as part of this distribution. The terms are also
available at:
http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt
-->

Assembly coding and debug of a custom application, the ILP32 ABI

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
    $ cd labs/3-app
    $ ls
    README.md
    REPORT.md
    collatz.s
    ```

   `README.md` is the file you are currently looking at, `REPORT.md` is the empty file in which you will write your lab report and the `collatz.s` file is an empty file in which you will write RV32IM assembly code.

1. Source the `/packages/LabSoC/bin/ca_functions` script to define the `rars` and `c2rv` bash functions:

    ```bash
    $ source /packages/LabSoC/bin/ca_functions
    ```

   Remember that these definitions are for the current terminal only.
   If you open a new terminal source the script again.

## Introduction

In this lab we will code in RISC-V assembly a complete application, debug it and run it.
Our main goal is to become familiar with the coding conventions (ABI) that we saw in [the ISA lecture], see slide 16, and as the C compiler uses.

**Important**: Always reserve enough space on the stack to save the _saved_ registers that you use and restore them before returning.
Even if we don't need it for simple functions, always reserve at least 32 bytes on the stack and save at least `ra` on it; it is a small overhead and if we later modify a function to call other functions we will avoid the infamous _wrong return address_ bug.
Remember that the stack grows towards low addresses.
Use `sp` as your stack pointer.

Feel free to also use `fp` (alias `x2`, alias `s0`) as frame pointer, like the C compiler does, but you do not have to, you can also access the content of the stack with only `sp`, as you wish.

Our application will ask the user to enter a positive integer value and it will compute the [Collatz series] starting from there, until it reaches value 1.
In the Collatz series each element $`e_{i+1}`$ depends on the previous element $`e_i`$ according the following simple rules:

- If $`e_i`$ is even, $`e_{i+1}=e_i/2`$.
- Else $`e_{i+1}=3\times e_i+1`$.

Example: if we start from $`e_1=7`$ the series is 7, 22, 11, 34, 17, 52, 26, 13, 40, 20, 10, 5, 16, 8, 4, 2, 1, 4, 2, 1...
As we can see on this example if the series reaches value 4 it cycles infinitely through 4, 2 and 1.

There is an interesting conjecture about this series: whatever the starting element the series always ends in the 4-2-1 cycle.
Many brilliant mathematicians tried to prove or disprove it but up to now nobody knows if it is true, false or undecidable.

## Launch RARS, settings, help

Launch RARS (just type `rars`), open the `Settings` menu and configure it according the following picture:

![RARS settings](../../doc/rars-settings.png)

Also open the help window (`[Help -> Help]`), you will need it.

## Coding of a divide-by-two function

1. Switch to the data segment (`.data`) and add a NUL-terminated string (`.asciz`) containing a message that asks for a positive integer.
   Add another NUL-terminated string containing an error message to print if the integer is not positive.
   Do not forget to declare a label for each.

1. Switch to the code segment (`.text`) and code a `div2` function that takes an integer parameter and returns its half (rounding towards $`-\infty`$).

1. Declare the `main` label as global (directive `.globl main`).
   Code a `main` function that asks the user to enter a positive integer.
   Use your two messages to communicate with the user, keep asking until the entered integer is positive.
   Call `div2` on it, print the result and stop with the `Exit` syscall.
   Use the `PrintString`, `ReadInt`, `PrintInt` and `Exit` syscalls.

1. Assemble, test and debug with various inputs.
   Fix bugs until it works.

## Coding of a times-3-plus-1 function

1. Add a `t3p1` function that takes an integer parameter and returns 3 times its value plus 1.
   Do not handle overflows, we will ignore them in this lab.

1. Modify your `main` function such that it also computes and prints the `t3p1` result for the entered integer.
   Use the `PrintChar` syscall to print a newline (`'\n'`) character between the `div2` and `t3p1` results.

1. Assemble, test and debug with various inputs.
   Fix bugs until it works.

## Coding of a Collatz function

1. Add a `collatz` function that takes an integer parameter, passes it to `div2` if it is even, else to `t3p1`, and returns the result.

1. Modify your `main` function such that it:
   - Computes the Collatz series starting from the entered positive integer.
   - Prints each element (including the starting one) followed by a newline character.
   - Stops with the `Exit` syscall after 1 has been reached.

1. Assemble, test and debug with various inputs (127 is a nice starting value with a long series until 1).
   Fix bugs until it works.

## Play the Collatz symphony

The `MidiOutSync` syscall allows to play music with RARS.
Open the help window and read the description of the MIDI output near the bottom.

1. Modify your `main` function such that after printing each value $`e_i`$ it plays a sound which pitch depends on $`e_i`$.
   Reasonable choices for the other parameters are:
   - Pitch: $`32 + (e_i \mod 64)`$
   - Duration: 125 milliseconds
   - Instrument: a piano
   - Volume: a quarter of the maximum

1. Assemble, test and debug with various inputs.
   Use your headphones if your computer has no speaker.
   Fix bugs until it works.

1. **Important**: save your `collatz.s`.
   Even if you decide to do some more experiments with the MIDI output, use a different source file.
   At the end of the lab `collatz.s` shall reflect the exact above specifications.

## Optional bonus

If you wish you can experiment with the MIDI output, try variants of the application where the duration, instrument and volume also depend on the current value.
You can also try the `MidiOut` and `Sleep` syscalls to generate overlapping notes instead of the consecutive ones that `MidiOutSync` offers.

## Report, add, commit, push

Write your report.
Add-commit-push your report and your `collatz.s` source file in your personal branch.
Add also your variants if you have interesting ones.

[Markdown syntax]: https://www.markdowntutorial.com/
[Collatz series]: https://en.wikipedia.org/wiki/Collatz_conjecture
[the ISA lecture]: https://perso.telecom-paristech.fr/pacalet/CompArch/lectures/ISA/slides.pdf

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0: -->
