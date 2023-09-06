- Yes I understand whats happening. with the memory mapped IO based transmit and receive.
- It is stored in receive data register 0xffff0004.

## To improve speed and footprint :
- cut down on loading addresses repeatedly every time we have to poll.
load addresses once(in receive or transmit) and poll from then on until the control registers are set.
reorganized the labels for receive and transmit.
- Also, remove unreachable code blocks.
