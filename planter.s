.text

at_start:
	sub $sp, $sp, 24
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	sw $s0, 12($sp)
	sw $s1, 16($sp)
	sw $s2, 20($sp)
	sw $s3, 24($sp)

	
	jal initial_gather	#write for how much initial resource we want.
	lw $s0, OTHER_BOT_X
	lw $s1, OTHER_BOT_Y

	slti $s0, $s0, 150	#give us other bot's coords to work with
	slti $s1, $s1, 150
	sll $s1, $s1, 1
	or $s1, $s1, $s0
	sw $s1, quad_bits
	
	not $s0, $s0		#gives us our desired coords
	not $s1, $s1
	li $s2, 270
	li $s3, 285
	
	mul $s0, $s0, $s2	#desired_x*(270) to get pixel
	mul $s1, $s0, $s1	#same with y coord.
	sub $s0, $s3, $s2
	sub $s1, $s3, $s2	#285 - (desired_y * 270)


planting:
	
