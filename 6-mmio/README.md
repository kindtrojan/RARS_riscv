<!-- MASTER-ONLY: DO NOT MODIFY THIS FILE

Copyright © Telecom Paris
Copyright © Renaud Pacalet (renaud.pacalet@telecom-paris.fr)

This file must be used under the terms of the CeCILL. This source
file is licensed as described in the file COPYING, which you should
have received as part of this distribution. The terms are also
available at:
http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt
-->

Memory-mapped IO

---

[TOC]

---

## Set-up

1. Open a terminal, change the working directory to the `ca` clone, check the current status.
   If the current branch is not your personal branch, switch to your personal branch and check again the current status.
   If your branch is not up to date with the remote or there is something to commit or the working tree is not clean, add, commit and/or pull until everything is in order.

1. Pull, merge with `origin/master`, change the working directory to this lab's directory and list the directory's content.
   `README.md` is the file you are currently looking at, `REPORT.md` is the empty file in which you will write your lab report.

## Introduction

In this lab we will combine what we saw during the two previous labs.
We will code functions to read data from the keyboard and to print data to the console using memory memory mapped Inputs / Outputs (I/O) and polling.
Our functions will replace the sycalls used in the initial version of our `io.s` toy application.
Make sure you understood the procedure call convention (the ILP32 Application Binary Interface) and beware your saved/unsaved CPU registers.

## Launch RARS, settings, help

Launch RARS (just type `rars`), open the `Settings` menu and configure it according the following picture:

![RARS settings](../../doc/rars-settings.png)

## Assignments

1. Copy the `io.s` initial version of our toy application:

    ```bash
	$ cp ../4-syscall-io/io.s .
    ```

1. Edit `io.s` and rewrite the code of the `getc` function to use memory mapped I/O and polling, instead of a syscall.

1. Load `io.s` in RARS, assemble, launch the `Keyboard and Display MMIO simulator` tool, connect it to the program and simulate `io.s`.
   Remember that the characters are now entered in the keyboard part of the `Keyboard and Display MMIO simulator` tool.
   Debug if needed and verify that your new `getc` function behaves as expected.
   When done with your experiments click the `Disconnect from Program` and `Reset` buttons of the `Keyboard and Display MMIO simulator` window.

1. Edit again `io.s` and rewrite the code of the `putc` function to use memory mapped I/O and polling, instead of syscalls.

1. Assemble, launch the `Keyboard and Display MMIO simulator` tool, connect it to the program and simulate.
   Debug if needed and verify that your new `putc` function behaves as expected.
   Remember that the characters are now entered and printed in the `Keyboard and Display MMIO simulator` tool.
   When done with your experiments click the `Disconnect from Program` and `Reset` buttons of the `Keyboard and Display MMIO simulator` window.

1. Add a `print_string` function that prints the NUL-terminated character string stored in memory at the address contained in register `a0` using the new `putc` function to print each character, instead of a syscall.
   Hint: use a loop to print characters one-by-one until you reach the NUL character.

1. Replace all `PrintString` syscalls by a call to the `print_string` function.

1. Assemble, launch the `Keyboard and Display MMIO simulator` tool, connect it to the program and simulate.
   Debug if needed and verify that your `print_string` function behaves as expected.
   When done with your experiments click the `Disconnect from Program` and `Reset` buttons of the `Keyboard and Display MMIO simulator` window.

1. Add a new `d2i` function that takes the ASCII code of a digit character (`'0'` to `'9'`) in register `a0`, converts it to a decimal integer between 0 and 9 and returns it in register `a0`.
   Return also an error code in register `a1`:
    * 0: no error
    * 1: not-a-digit error

   Remember that the ASCII code of character `x` can be represented in your assembly source code with literal `'x'` and that the ASCII codes of the digit characters are consecutive, `'0'` being the smallest and `'9'` being the largest.

1. Add a new `geti` function that reads a multi-digits unsigned integer using the `getc` and `d2i` functions instead of the `ReadInt` syscall.
   The reading ends when a newline character (ASCII code `'\n'`) is entered.
   As for `d2i`, return an error code in `a1`:
    * 0: no error
    * 1: not-a-digit error
    * 2: overflow (the unsigned integer does not fit on 32 bits)

   Hints:
    * Store the current value of the read integer in a saved register (do not forget to initialize it).
    * Use a loop to read digits one-by-one.
    * After each digit read update the current value of the integer by multiplying the old value by 10 and adding the read digit.
    * Detect overflows by comparing the result of each arithmetic operation with the old value.

1. Add a new `puti` function that prints the unsigned integer in register `a0` using the `putc` function instead of the `PrintInt` syscall.
   Hint: instead of a loop use recursion (let `puti` call itself); bevare your saved/unsaved registers.

1. Modify the `main` function such that it asks for an integer instead of a character, prints it, and exits if the entered integer was 0.
   In the data segment update the existing text messages to reflect the changes.
   Add new text messages for the error situations (not-a-digit or overflow); on not-a-digit or overflow errors print meaningful error messages and ask again for a new integer.

1. Simulate `io.s` with RARS, debug if needed and verify that it behaves as expected.

## Report, add, commit, push

Write your report, add (`REPORT.md` and `io.s`), commit and push in your personal branch.

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab textwidth=0: -->
