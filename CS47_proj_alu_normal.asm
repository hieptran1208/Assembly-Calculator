.include "./cs47_proj_macro.asm"
.text
.globl au_normal
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_normal
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_normal:
# TBD: Complete it

	# Store frame
	addi	$sp, $sp, -24
	sw	$fp, 24($sp)
	sw	$ra, 20($sp)
	sw	$a0, 16($sp)
	sw	$a1, 12($sp)
	sw	$a2, 8($sp)
	addi	$fp, $sp, 24
	
	# Body
	beq 	$a2, '+', addition
	beq	$a2, '-', substraction
	beq	$a2, '*', multiplication
	beq	$a2, '/', division
	
addition:
	add 	$t0, $a0, $a1
	j	end
substraction:
	sub	$t0, $a0, $a1
	j 	end
multiplication:
	mul	$t0, $a0, $a1
	mfhi	$t1
	j	end
division:
	div	$a0, $a1
	mflo	$t0
	mfhi	$t1
	j	end
	
end:
	move	$v0, $t0
	move	$v1, $t1
	
	# Restore frame
	lw	$fp, 24($sp)
	lw	$ra, 20($sp)
	lw	$a0, 16($sp)
	lw	$a1, 12($sp)
	lw	$a2, 8($sp)
	addi	$sp, $sp, 24
	jr	$ra
