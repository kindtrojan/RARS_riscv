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
	ret
	.size	recurse, .-recurse
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"The size of an int is %lu bytes\n"
	.align	2
.LC1:
	.string	"Please enter a number of iterations: "
	.align	2
.LC2:
	.string	"%d"
	.section	.text.startup,"ax",@progbits
	.align	2
	.globl	main
	.type	main, @function
main:
	lui	a0,%hi(.LC0)
	addi	sp,sp,-32
	li	a1,4
	addi	a0,a0,%lo(.LC0)
	sw	ra,28(sp)
	call	printf
	lui	a0,%hi(.LC1)
	addi	a0,a0,%lo(.LC1)
	call	printf
	lui	a0,%hi(.LC2)
	addi	a1,sp,12
	addi	a0,a0,%lo(.LC2)
	call	__isoc99_scanf
	lw	ra,28(sp)
	li	a0,0
	addi	sp,sp,32
	jr	ra
	.size	main, .-main
	.ident	"GCC: (g1ea978e3066) 12.1.0"
	.section	.note.GNU-stack,"",@progbits
