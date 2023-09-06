<!-- MASTER-ONLY: DO NOT MODIFY THIS FILE

Copyright © Telecom Paris
Copyright © Renaud Pacalet (renaud.pacalet@telecom-paris.fr)

This file must be used under the terms of the CeCILL. This source
file is licensed as described in the file COPYING, which you should
have received as part of this distribution. The terms are also
available at:
http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt
-->

Polling and memory-mapped IO

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

1. Open a terminal, change the working directory to the `ca` clone, check the current status.
   If the current branch is not your personal branch, switch to your personal branch and check again the current status.
   If your branch is not up to date with the remote or there is something to commit or the working tree is not clean, add, commit and/or pull until everything is in order.

1. Pull, merge with `origin/master`, change the working directory to this lab's directory and list the directory's content.
   `README.md` is the file you are currently looking at, `REPORT.md` is the empty file in which you will write your lab report and the `io.s` file is the RISC-V source code of an application.

## Introduction

In the previous lab we used syscalls to read data from the keyboard and to print data to the console.
In this lab we will experiment another way based on memory mapped IO and polling.
The keyboard is managed using a Receiver device with two interface registers mapped on memory addresses `0xffff0000` and `0xffff0004`.
The console is managed using a Transmitter device with two interface registers mapped on memory addresses `0xffff0008` and `0xffff000c`.

## Launch RARS, settings, help

Launch RARS (just type `rars`), open the `Settings` menu and configure it according the following picture:

![RARS settings](../../doc/rars-settings.png)

## Assignments

1. In the RARS `Tools` menu select `Keyboard and Display MMIO simulator`.
   A new window appears; click its `Help` button and read the 4 first paragraphs.

1. Study the code in `io.s` and try to understand it.

1. Load `io.s` in RARS and assemble it.

1. In the `Keyboard and Display MMIO simulator` window click the `Connect to Program` button.
   Execute the `io.s` application, enter characters and check your understanding.

1. Pause the execution.
   In the `Data Segment` sub-window select the `0xffff0000 (MMIO)` region to observe the Receiver and Transmitter registers.
   Enter a character and continue executing step by step.
   Do you understand what happens?
   What is the ASCII code of the character you typed?
   In which register is it stored?

1. If you continue executing step by step you should see the sending of the character you typed to the transmitter.
   Then, you should enter the `wait_for_trans_2` loop that waits until the transmitter is ready again to receive a character.
   Instead of stepping until it is, set a breakpoint on the first instruction after the loop and let the execution continue.

1. After exiting the `wait_for_trans_2` loop, continue step-by-step, observe the printing of the newline character and the branching to the beginning of the program for the next iteration.

1. Once you are done with your experiments click the `Disconnect from Program` and `Reset` buttons of the `Keyboard and Display MMIO simulator` window.

1. This program could be slightly optimized for speed (number of executed instructions) and footprint (total number of instructions).
   Do you see how?

1. Edit `io.s` to implement your optimizations.
   Assemble `io.s`, click the `Connect to Program` button of the `Keyboard and Display MMIO simulator` window, test your optimized version. 

## Report, add, commit, push

Write your report, add (`REPORT.md` and `io.s`), commit and push in your personal branch.

[Markdown syntax]: https://www.markdowntutorial.com/

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab textwidth=0: -->
