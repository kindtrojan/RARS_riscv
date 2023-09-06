## Q) do you understand why errors 1,2,4 and not 1,2,3?
A) because we are doing an AND of the received error code with the .enq values and then we compare with zero to see if the errors are set.
if we use 3, then it its binary is 11.. which doesnt give a zero when did an AND with 2(10) and also error code 1(01).
so, 4 (100) is safer as it has no bits in common with the other two error codes.

## I used the io.s provided:
 because my io.s from lab 6 was not ready by the time we started lab7, I did try to change the functions to my functions from lab6, and got so many errors
issues faced : make sure your registers are saved before any function calls and when returning , inputs in a0 were overwritten by mistake.


