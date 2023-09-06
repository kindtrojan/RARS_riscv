# data section
.data
kstack:
.space 1024

.text
.globl exception_handler
exception_handler:

  csrrw zero,uscratch,sp #save register sp in uscratch
  la sp,kstack #set sp to kstack
  #save registers
  sw t0,0(sp)
  sw t1,4(sp)
  sw t2,8(sp)
  sw t3,12(sp)
  sw a0,16(sp)
  sw a7,20(sp)



#csrrsi  a0,uepc,zero   # atomic a0 <- uepc <- uepc OR zero
     # print 6 CSRs

  li a7,34
  csrrs a0,ustatus,zero
  ecall

  li a7,34
  csrrs a0,uie,zero
  ecall

  li a7,34
  csrrs a0,utvec,zero
  ecall
	
  li a7,34
  csrrs a0,uscratch,zero
  ecall


  li a7,34
  csrrs a0,uepc,zero
  ecall


  li a7,34
  csrrs a0,ucause,zero
  ecall

end:
# restore registers saved on k stack
  lw t0,0(sp)
  lw t1,4(sp)
  lw t2,8(sp)
  lw t3,12(sp)
  lw a0,16(sp)
  lw a7,20(sp)
# restore sp
  csrrs sp,uscratch,zero
  # return
  uret


  