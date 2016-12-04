.text

at_start:
	sub $sp, $sp, 36
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	sw $s0, 12($sp)
	sw $s1, 16($sp)
	sw $s2, 20($sp)
	sw $s3, 24($sp)
	sw $s4, 28($sp)
	sw $s5, 32($sp)

	
	jal initial_gather	#write for how much initial resource we want.
	lw $s0, OTHER_BOT_X
	lw $s1, OTHER_BOT_Y

	slti $s0, $s0, 150	#give us other bot's coords to work with
	slti $s1, $s1, 150
	sll $s1, $s1, 1
	or $s1, $s1, $s0
	sw $s1, quad_bits
	
	not $s0, $s0		#gives us our desired coords			
	not $s1, $s1		#s0, s1
	li $s2, 210
	li $s3, 255
	
	mul $s4, $s0, $s2	#desired_x*(210) to get pixel
	mul $s5, $s1, $s2	#same with y coord.
	sub $s4, $s3, $s4	#s4 = 255 - (desired_x * 210)
	sub $s5, $s3, $s5	#s5 = 255 - (desired_y * 210)

	move $a0, $s4
	move $a1, $s5
	jal movexy

check_bit_start:
	lb $t2, at_dest
	bne $t2, 0, check_bit_start

	
planting:
	jal plant_cross

planting_horizOnly:
	move $t0, $s0
	sub $t0, 0, $t0
	or $t0, $t0, 1		#determine which direction to go in, masking the bit. Has -1 or 1.

	mul $t0, $t0, 60
	add $a0, $s4, $t0
	move $a1, $s5
	jal movexy

check_bit_horizOnly:
	lb $t2, at_dest
	bne $t2, 0, check_bit_horizOnly

	jal plant_cross

planting_vertHoriz:
	move $t0, $s0
	sub $t0, 0, $t0
	or $t0, $t0, 1

	mul $t0, $t0, 30	#want to move horizontally 1 tile.

	move $t1, $s1
	sub $t1, 0 $t1
	or $t1, $t1, 1

	mul $t1, $t1, 60	#want to move vertically 2 tiles.

	add $a0, $s4, $t0
	add $a1, $s5, $t1
	jal movexy

check_bit_vertHoriz:
	lb $t2, at_dest
	bne $t2, 0, check_bit_vertHoriz

	jal plant_cross

planting_horizOnly:
	move $t0, $s0
	sub $t0, 0, $t0
	or $t0, $t0, 1		#determine which direction to go in, masking the bit. Has -1 or 1.

	mul $t0, $t0, 60
	add $a0, $s4, $t0
	move $a1, $s5
	jal movexy

check_bit_horizOnly:
	lb $t2, at_dest
	bne $t2, 0, check_bit_horizOnly

Finished_Planting:	
	sub $sp, $sp, 36
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	sw $s0, 12($sp)
	sw $s1, 16($sp)
	sw $s2, 20($sp)
	sw $s3, 24($sp)
	sw $s4, 28($sp)
	sw $s5, 32($sp)
	jr $ra

	
plant_cross:
check_tile:
	move $a0, $s4
	move $a1, $s5
	jal check_tile
	beq $v0, 0, move_up	#if x.state == 0, go check seeds and plant
	jal plant_seed
	
move_up:
	subi $a1, $s5, 30
	move $a0, $s4
	jal movexy		#move up

check_bitUp:
	lb $t2, at_dest
	bne $t2, 0, check_bitUp

	move $a0, $s4
	move $a1, $s5
	jal check_tile
	beq $v0, 0, move_down_right
	jal plant_seed
	
move_down_right:
	addi $a0, $s4, 30
	addi $a1, $s5, 30
	jal movexy

check_bitdR:
	lb $t2, at_dest
	bne $t2, 0, check_bitdR

	move $a0, $s4
	move $a1, $s5
	jal check_tile
	beq $v0, 0, move_down_left
	jal plant_seed

move_down_left:
	subi $a0, $s4, 30
	addi $a1, $s5, 30
	jal movexy

check_bitdL:
	lb $t2, at_dest
	bne $t2, 0, check_bitdL

	move $a0, $s4
	move $a1, $s5
	jal check_tile
	beq $v0, 0, move_up_left
	jal plant_seed

move_up_left:
	subi $a0, $s4, 30
	subi $a1, $s5, 30
	jal movexy

check_bitLeft:
	lb $t2, at_dest
	bne $t2, 0, check_bitLeft

	move $a0, $s4
	move $a1, $s5
	jal check_tile
	beq $v0, 0, move_right
	jal plant_seed

move_right:
	addi $a0, $s4, 30
	move $a1, $s5
	jal movexy

check_bitRight:
	lb $t2, at_dest
	bne $t2, 0, check_bitRight

water:
	li $t0, 10
	sw $t0, WATER_TILE 
	#j planting_horizOnly
	jr $ra
	
		
plant_seed:
	sw $0, SEED_TILE

	la $t0, tilearray
	sw $t0, TILE_SCAN
	jr $ra
	



