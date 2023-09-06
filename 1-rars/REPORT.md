## Answer to Ultimate Q of life
42
## Address of the first character of the Question:
Baseaddress/the label address 0x10010000
## Does this correspond to the start address of the data segment and to the address of label question in the Labels sub-window?
Yes, it does.
## What is the address of the word containing the correct answer?
0x10010054 
## How many bytes have been skipped between the question and the word?
2
## Are there also skipped bytes between the other data items?
Yes, when ever we need word rounding(multiples of 4 here, for storing words).

#EXPLANATIONS
##Can you see where the 4 labels that we declared in the data segment are used and what for?
yes, used to refer to the error messages/messages and to the answer we stored. We load and use the contents of these addresses in the .text segment when ever we need.

## Can you identify where the system calls are used in the above code and what they are supposed to do
The syscalls we used in toqle.s are the ones for PrintString(to print messages), ReadInt to read int input, Exit(to exit the execution)

##Basic inst: ecall, beq, lw
## Pseudo inst: la, li, b,


# Assembling:
## address of 1st inst: 0x00400000
## la - how many basic instructions needed 
2
# Step by step execution
## After reset pc
has the address of label main, i.e the first inst to execute

## 3. after first basic inst
register t1 changes

## 4
yes



# Coding of an advanced version:

tauqlue2.s is the advanced version with a cumulative counter adding up all valid inputs(between +9 to -9) and prompting the user if the value is still less or more than the desired and also with error messages on input outside the desired range.
The program also has inline comments with my rationale 
