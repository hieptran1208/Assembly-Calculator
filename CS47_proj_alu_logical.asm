.include "./cs47_proj_macro.asm"

.text
.globl au_logical
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_logical
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################


au_logical:
# TBD: Complete it 
	# Store frame
	addi	$sp, $sp, -60
	sw	$fp, 60($sp)
	sw	$ra, 56($sp)
	sw	$a0, 52($sp)
	sw	$a1, 48($sp)
	sw	$a2, 44($sp)		# the result of the operation 	t0 = S
	sw	$a3, 40($sp)
	sw	$s0, 36($sp)		# position 0-31 		t2 = I
	sw	$s1, 32($sp)		# Carry bit 			t3 = C
	sw	$s2, 28($sp)			# A
	sw	$s3, 24($sp)			# B
	sw	$s4, 20($sp)			# A xor B
	sw	$s5, 16($sp)			# AB
	sw	$s6, 12($sp)			# C(A xor B)
	sw	$s7, 8($sp)			# value of Y = (C xor A xor B)
	addi	$fp, $sp, 60

	# Body
	
	
	beq 	$a2, '+', addition
	beq	$a2, '-', substraction
	beq	$a2, '*', multiplication
	beq	$a2, '/', division
	
		
addition: 
	li	$a2, 0x00000000
	extract_nth_bit($t3, $a2, $zero)
	j	add_sub_logic
	
substraction:
	li	$a2, 0xffffffff
	extract_nth_bit($t3, $a2, $zero)
	not 	$a1, $a1
	j	add_sub_logic

add_sub_logic:
	li	$t2, 0x0			# index
	li	$t0, 0x0			# result

	
add_loop:	
	extract_nth_bit($t4, $a0, $t2)
	extract_nth_bit($t5, $a1, $t2)
	# Value of Y
	xor	$t6, $t4, $t5
	xor	$t9, $t3, $t6
	insert_to_nth_bit($t0, $t2, $t9, $s0)
	# Value of C-out
	and 	$t7, $t4, $t5
	and	$t8, $t3, $t6
	or	$t3, $t7, $t8

	add	$t2, $t2, 1
	blt	$t2, 32, add_loop
	j	end


multiplication:
	# make a0 contain hi and lo (2 registers with lo is a0 and hi is a3)
	li	$a3, 0			# hi in multiplicand.
	li	$t0, 0			# lo
	li	$t1, 0			# hi
	li	$t2, 0			# index
	li	$t3, 0			# carry bit
	li	$t4, 0			# index for the add loop
	li	$s7, 31			
mul_loop:
	extract_nth_bit($t6, $a1, $zero)
	beq	$t6, 0, shift		# the bit is 0, we shift, otherwise we add
	move	$t5, $t0
additionMul_LO: 			# add the lo multiplicand register and the lo result register
	extract_nth_bit($s2, $a0, $t4)
	extract_nth_bit($s3, $t5, $t4)
	# Value of Y
	xor	$s4, $s3, $s2
	xor	$t9, $t3, $s4
	insert_to_nth_bit($t0, $t4, $t9, $s0)
	
	# Value of C-out
	and 	$s5, $s2, $s3
	and	$s6, $t3, $s4
	or	$t3, $s5, $s6
	
	addi	$t4, $t4, 1
	
	blt	$t4, 32, additionMul_LO
	
	li	$t4, 0
	move	$t6, $t1
additionMul_Hi: 			# add the hi multiplicand register and the hi result register
	extract_nth_bit($s2, $a3, $t4)
	extract_nth_bit($s3, $t6, $t4)
	# Value of Y
	xor	$s4, $s3, $s2
	xor	$t9, $t3, $s4
	insert_to_nth_bit($t1, $t4, $t9, $s0)
	
	# Value of C-out
	and 	$s5, $s2, $s3
	and	$s6, $t3, $s4
	or	$t3, $s5, $s6
	
	addi	$t4, $t4, 1
	
	blt	$t4, 32, additionMul_Hi

	
shift:
	extract_nth_bit($t8, $a0, $s7)		# extract the MSB and move it to hi register
	insert_to_nth_bit($a3, $zero, $t8, $s0)	# insert that bit to hi register
	sll	$a0, $a0, 1
	sll	$a3, $a3, 1
	srl	$a1, $a1, 1

	addi	$t2, $t2, 1
	blt	$t2, 32, mul_loop
	j end
	
twos_compliment:
	# the idea to get a 2's compliment number is invert and add 1 to it
	not	$a0, $a0
	li	$a1, 1
	
	#save the results onto the stack
	addi	$sp, $sp, -20
	sw	$fp, 20($sp)
	sw	$ra, 16($sp)
	sw	$t0, 12($sp)
	sw	$t1, 8($sp)
	addi	$fp, $sp, 16
	
	li	$t0, 0	# index
	li	$v0, 0	# sum
	li	$t1, 0	# carry bit
	jal	add_loop	# add the invert and 1
	
	# restore the stack and get the result in v0
	lw	$fp, 20($sp)
	lw	$ra, 16($sp)
	lw	$t0, 12($sp)
	lw	$t1, 8($sp)
	addi	$sp, $sp, 16
	jr	$ra


twos_compliment_if_neg:
	bltz	$a0, twos_compliment
	# save the result in v0
	move	$v0, $a0
	jr	$ra
			

division:
	li	$s7, 0			# index = 1
	move	$s1, $a0		# dvnd put in s1
	move	$s2, $a1		# dvsr put in s2
	li	$s3, 0			# remainder set to 0

div_loop:	
	li	$s4, 31
	sll	$s3, $s3, 1		# move remainder 1 to the left.
	extract_nth_bit($s5, $s1, $s4)
	insert_to_nth_bit($s3, $zero, $s5, $s6)
	
	sll	$s1, $s1, 1
	move	$a0, $s3	# save the remainder and the quotient
	move	$a1, $s2
	
	la	$t0, 0		# index = 0
	li	$v1, 0		# carry bit = 0
	li	$v0, 0		# sum = 0
	jal	add_loop	# S = v0, S = R - D
	
	bltz	$v0, increase_index	# v0 < 0, increment the index
	move	$s3, $v0
	li	$t0, 1
	insert_to_nth_bit($s1, $zero, $t0, $v1)		# q[0] = 1
	
increase_index:
	addi	$s7, $s7, 1
	beq	$s7, 32, end_division
	j	div_loop
	
end_division:
	# store the value of dvnd and dvsr onto the stack
	move	$v0, $s1
	lw	$fp, 20($sp)
	lw	$ra, 16($sp)
	lw	$a0, 12($sp)
	lw	$a1, 8($sp)
	addi	$sp, $sp, 20
	
	move	$s6, $a0
	move	$s7, $a1
	
	li	$t8, 31
	extract_nth_bit($t1,$a0, $t8)	# take out the 2 31st bits to compare
	extract_nth_bit($t2, $a1, $t8)
	xor	$t6, $t1, $t2		#if xor is 1, it is negative
	beqz	$t6, positive_div
	
	move	$a0, $s1		# return quotient to a0
	jal	twos_compliment
	move	$s1, $v0		# temp to store the 2's compliment
	move	$a0, $s3		# remainder to a0
	extract_nth_bit($t1, $s7, $t8)	
	bgtz	$t1, skip_secondtwos	
	
	jal	twos_compliment
	la	$v1, ($v0)
	la	$v0, ($s1)
	j end
	
skip_secondtwos:
	la	$v0, ($s1)
	la	$v1, ($s3)
	j end

positive_div:
	la	$s5, ($v0)
	la	$v1, ($s3)
	
	li	$t8, 31
	extract_nth_bit($t1, $s7, $t8)
	beqz	$t1, end
	la	$a0, ($v1)
	jal twos_compliment
	la	$v1, ($v0)
	la	$v0, ($s5)
	
end:
	move	$v0, $t0
	move	$v1, $t1
	# Restore frame
	lw	$fp, 60($sp)
	lw	$ra, 56($sp)
	lw	$a0, 52($sp)
	lw	$a1, 48($sp)
	lw	$a2, 44($sp)		
	lw	$a3, 40($sp)
	lw	$s0, 36($sp)		
	lw	$s1, 32($sp)		
	lw	$s2, 28($sp)			
	lw	$s3, 24($sp)			
	lw	$s4, 20($sp)			
	lw	$s5, 16($sp)			
	lw	$s6, 12($sp)			
	lw	$s7, 8($sp)	
	addi	$sp, $sp, 60
	jr 	$ra
	

