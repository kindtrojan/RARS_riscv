	.file	"abssub.c"
	.option nopic
	.attribute arch, "rv32i2p0_m2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.section	.rodata
	.align	2
.LC0:
	.string	"%d\n"
	.text
	.align	2
	.globl	printInt
	.type	printInt, @function
printInt:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	sw	a0,-20(s0)
	lw	a1,-20(s0)
	#lui	a5,%hi(.LC0)
	#addi	a0,a5,%lo(.LC0)
	li  a7, 1   #since RARS doesnt know printf
	ecall #try calling printInt syscall, that prints contents of a0
	#call	printf
	nop
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	printInt, .-printInt
	.align	2
	.globl	absSub
	.type	absSub, @function
absSub:
	addi	sp,sp,-48
	sw	s0,44(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	sw	a1,-40(s0)
	lw	a4,-40(s0)
	lw	a5,-36(s0)
	sub	a5,a4,a5
	sw	a5,-20(s0)
	lw	a5,-20(s0)
	bge	a5,zero,.L3
	lw	a5,-20(s0)
	neg	a5,a5
	sw	a5,-20(s0)
.L3:
	lw	a5,-20(s0)
	mv	a0,a5
	lw	s0,44(sp)
	addi	sp,sp,48
	jr	ra
	.size	absSub, .-absSub
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	addi	s0,sp,16
	li	a1,46
	li	a0,17
	call	absSub
	mv	a5,a0
	mv	a0,a5
	call	printInt
	li	a5,0
	mv	a0,a5
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	#jr	ra  #return to caller, skipping as there is not caller here
	li a7, 10 #exit syscall
	ecall
	.size	main, .-main
	.ident	"GCC: (g1ea978e3066) 12.1.0"
	.section	.note.GNU-stack,"",@progbits
