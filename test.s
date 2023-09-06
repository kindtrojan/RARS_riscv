# Polling-based IO (simple) example

.text
.globl main
main:

wait_for_rcv:
    # initialize CPU registers with addresses of receiver interface registers
    li    t0,0xffff0000               # t0 <- 0xffff_0000 (address of receiver control register)
    li    t1,0xffff0004               # t1 <- 0xffff_0004 (address of receiver data register)
    lw    t2,0(t0)                    # t2 <- value of receiver control register
    andi  t2,t2,1                     # mask all bits except LSB
    beq   t2,zero,wait_for_rcv        # loop if LSB unset (no character from receiver)
    lw    a0,0(t1)                    # store received character in a0

wait_for_trans_1:
    # initialize CPU registers with addresses of transmitter interface registers
    li    t0,0xffff0008               # t0 <- 0xffff_0008 (address of transmitter control register)
    li    t1,0xffff000c               # t1 <- 0xffff_000c (address of transmitter data register)
    lw    t2,0(t0)                    # t2 <- value of transmitter control register
    andi  t2,t2,1                     # mask all bits except LSB
    beq   zero,t2,wait_for_trans_1    # loop if LSB unset (transmitter busy)
    sw    a0,0(t1)                    # send character received from receiver to transmitter

wait_for_trans_2:
    lw    t2,0(t0)                    # t2 <- value of transmitter control register
    andi  t2,t2,1                     # mask all bits except LSB
    beq   zero,t2,wait_for_trans_2    # loop if LSB unset (transmitter busy)
    li    t3,10                       # ASCII code of newline
    sw    t3,0(t1)                    # send newline character to transmitter

    b     wait_for_rcv                # go to wait_for_rcv (infinite loop)
