## inside getc function: Removed the syscall part and instead checking the receiver control register for bit set and reading from receiver data register.

did the same as above for putc function.


## added a print_string method.
Which gets a char from the address in reg8ister a0, and calls putc if the char read is not null, in a loop.
Uses a saved register to save the address of the string(current address being read) 

changed all the printstr syscalls to use this print_string function.

## d2i 
Take the ascii values of '0' and '9' for reference and check the values received lie in between these two and reduce the ascii value of '0' from our digit to get the value of our digit

## geti:
 call getc in loop and keep storing the received digits in a register, by multiplying the previously received digits by 10 and adding the newly received value to it.

## puti: 
print the remainder by diving with 10, using putc (add ascii of '0' to it to get ascii of the number).
      divide by 10 and  store the value and loop over it again.

## Remarks: I
 made a small error somewhere and somehow i am printing only the last digit, need some more debugging
