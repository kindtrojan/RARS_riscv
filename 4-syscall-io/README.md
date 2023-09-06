<!-- MASTER-ONLY: DO NOT MODIFY THIS FILE

Copyright © Telecom Paris
Copyright © Renaud Pacalet (renaud.pacalet@telecom-paris.fr)

This file must be used under the terms of the CeCILL. This source
file is licensed as described in the file COPYING, which you should
have received as part of this distribution. The terms are also
available at:
http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt
-->

Syscall-based IO

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
    $ cd labs/4-syscall-io
    $ ls
    README.md
    REPORT.md
    io.s
    ```

   `README.md` is the file you are currently looking at, `REPORT.md` is the empty file in which you will write your lab report and the `io.s` file is the RISC-V source code of an application.

## Introduction

In this lab we will work with software functions to read data from the keyboard and to print data to the console.
We will simulate them using the RARS simulator, debug them if needed, and observe the internals of the simulated RISC-V processor during execution.

The application that we will work on is a loop that:

1. Print a message asking to enter a character.
1. Read a character from the keyboard.
1. Print another message followed by the entered character.
1. Print a good bye message and exit if the entered character was a `Q`.
1. Else, go back to 1.

In this first version we will use the RARS syscalls to read and print characters and to print messages.

## Launch RARS, settings, help

Launch RARS (just type `rars`), open the `Settings` menu and configure it according the following picture:

![RARS settings](../../doc/rars-settings.png)

Also open the help window (`[Help -> Help]`), you will need it.

## Assignments

1. Open the `io.s` file with your favourite editor, study the code and try to understand it.
   In order to understand what the various syscalls are doing and how they are called, you will need the `Syscalls` tab of the help window of RARS.

1. Load the `io.s` source file, assemble it and simulate.
   After entering (and displaying) several characters pause and start executing step-by-step.
   After stepping over the `ReadChar` syscall do not forget to enter a character.
   Before each step, try to understand what instruction will be executed and what its effect should be.
   Cross-check your guessing by looking at the content of the registers (including the Program Counter - PC) before and after the step.

1. Edit `io.s` and modify the code to print the ASCII code of the entered character instead of the character itself.
   Also change the `print_char_message` accordingly.
   Test your modification.

1. Use your application to find the ASCII codes of characters `#`, `u` and `$`.

## Report, add, commit, push

Write your report, add (`REPORT.md` and `io.s`), commit and push in your personal branch.

[Markdown syntax]: https://www.markdowntutorial.com/

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab textwidth=0: -->
