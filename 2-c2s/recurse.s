	.file	"recurse.c"
	.option nopic
	.attribute arch, "rv32i2p0_m2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	2
	.globl	recurse
	.type	recurse, @function
recurse:
	addi	sp,sp,-80
	sw	ra,76(sp)
	sw	s0,72(sp)
	addi	s0,sp,80
	sw	a0,-68(s0)
	lw	a5,-68(s0)
	beq	a5,zero,.L4
	lw	a5,-68(s0)
	addi	a5,a5,-1
	mv	a0,a5
	call	recurse
	j	.L1
.L4:
	nop
.L1:
	lw	ra,76(sp)
	lw	s0,72(sp)
	addi	sp,sp,80
	jr	ra
	.size	recurse, .-recurse
	.section	.rodata
	.align	2
.LC0:
	.string	"The size of an int is %lu bytes\n"
	.align	2
.LC1:
	.string	"Please enter a number of iterations: "
	.align	2
.LC2:
	.string	"%d"
	.text
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	li	a1,4
	lui	a5,%hi(.LC0)
	addi	a0,a5,%lo(.LC0)
	call	printf
	lui	a5,%hi(.LC1)
	addi	a0,a5,%lo(.LC1)
	call	printf
	addi	a5,s0,-20
	mv	a1,a5
	lui	a5,%hi(.LC2)
	addi	a0,a5,%lo(.LC2)
	call	__isoc99_scanf
	lw	a5,-20(s0)
	mv	a0,a5
	call	recurse
	li	a5,0
	mv	a0,a5
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	main, .-main
	.ident	"GCC: (g1ea978e3066) 12.1.0"
	.section	.note.GNU-stack,"",@progbits
