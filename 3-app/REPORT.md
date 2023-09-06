##Data section: Created an error string and another string to ask for data

##Text section:
created a div function in text section.
increase the stack by 32 bytes(-32 to go to lower addresses)
store the return address ra in 28(sp)

#More comments inside the code


##main:

->start with a labelled section to start asking for a positive input
->use syscall codes to ask input and get input 
->if the input is <=0, branch to cerror section, print error and go back t0 asking the input
->call collatz: which decides to run div2 or t3p1 depending on even vs odd.
->call midioutsync using the return value(32 + a0mod64 )
->repeat until we arrive at 1
->exit using syscall code 10


##Personal observation:

Its super awesome, the sounds was too  feeble  I thought my code is broken when i ran it on my laptop.
It was more audible with earphone and it was very cool, even my girl friend liked it.
