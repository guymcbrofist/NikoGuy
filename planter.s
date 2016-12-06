.text

###########
#farm_start
#
#Sends the SpimBOT somewhere to start farming
#Tries to pick a corner of the map farthest away from other bot
###########
farm_start:
	sub	$sp, $sp, 4
	sw	$ra, 0($sp)
	
	lw	$t0, OTHER_BOT_X
	lw	$t1, OTHER_BOT_Y

	slti	$t0, $t0, 150	#give us other bot's coords to work with
	slti	$t1, $t1, 150

	xor	$t0, $t0, 1	#gives us our desired quadrant
	xor	$t1, $t1, 1
	sw	$t0, quad_x
	sw	$t1, quad_y
	li	$t2, 210
	li	$t3, 255
	
	mul	$a0, $t0, $t2	#desired_x*(210) to get pixel
	mul	$a1, $t1, $t2	#same with y coord.
	sub	$a0, $t3, $a0	#s4 = 255 - (desired_x * 210)
	sub	$a1, $t3, $a1	#s5 = 255 - (desired_y * 210)

	jal	movexy

	lw	$ra, 0($sp)
	add	$sp, $sp, 4
	jr	$ra

###########
#plant_farm
#
#Farm planting routine
#
###########
plant_farm:
	sub	$sp, $sp, 4
	sw	$ra, 0($sp)

	li	$a0, 1
	jal	plant_cross

	lw	$s0, quad_x
	lw	$s1, quad_y

	sub	$s0, $0, $s0
	or	$s0, $s0, 1		#determine which direction to go in, bit tricks. Has -1 or 1.
	#sub	$s1, $0, $s1
	#or	$s1, $s1, 1

	lw	$a0, BOT_X
	lw	$a1, BOT_Y
	mul	$t0, $s0, 60
	sub	$a0, $a0, $t0
	jal	movexy

	li	$a0, -1
	jal	gather

	li	$a0, 1
	jal	plant_cross
	
pf_return:	
	lw	$ra, 0($sp)
	add	$sp, $sp, 4
	jr	$ra

############
#plant_cross
#
#Tells the SpimBOT to plant in a cross pattern
#
#a0: Whether SpimBOT should water the center of the cross or not
#     0: don't water
#    !0: water
############
plant_cross:
	sub	$sp, $sp, 8
	sw	$ra, 0($sp)
	sw	$a0, 4($sp)

	lw	$a0, BOT_X
	lw	$a1, BOT_Y
	jal	check_tile
	bnez	$v0, move_up	#if x.state == 0, go check seeds and plant
	jal	plant_seed
	
move_up:
	sub	$a1, $a1, 30
	jal	check_tile
	bnez	$v0, move_down_right
	jal	movexy		#move up
up_loop:
	lw	$t0, at_dest
	beqz	$t0, up_loop
	lw	$a0, BOT_X
	lw	$a1, BOT_Y
	jal	plant_seed
	
move_down_right:
	addi	$a0, $a0, 30
	addi	$a1, $a1, 30
	jal	check_tile
	bnez	$v0, move_down_left
	jal	movexy
dr_loop:
	lw	$t0, at_dest
	beqz	$t0, dr_loop
	lw	$a0, BOT_X
	lw	$a1, BOT_Y
	jal	plant_seed

move_down_left:
	sub	$a0, $a0, 30
	addi	$a1, $a1, 30
	jal	check_tile
	bnez	$v0, move_up_left
	jal	movexy
dl_loop:
	lw	$t0, at_dest
	beqz	$t0, dl_loop
	lw	$a0, BOT_X
	lw	$a1, BOT_Y
	jal	plant_seed

move_up_left:
	sub	$a0, $a0, 30
	sub	$a1, $a1, 30
	jal	check_tile
	bnez	$v0, move_right
	jal	movexy
ul_loop:
	lw	$t0, at_dest
	beqz	$t0, ul_loop
	lw	$a0, BOT_X
	lw	$a1, BOT_Y
	jal	plant_seed

move_right:
	addi	$a0, $a0, 30
	jal	movexy
right_loop:
	lw	$t0, at_dest
	lw	$a0, BOT_X
	lw	$a1, BOT_Y
	beqz	$t0, right_loop

	lw	$a0, 4($sp)
	beqz	$a0, pc_return
	li	$t0, 10		# Crop watering time!
	sw	$t0, WATER_TILE 
pc_return:
	lw	$ra, 0($sp)
	add	$sp, $sp, 8
	jr	$ra

###########
#plant_seed
###########
plant_seed:
	sw	$0, SEED_TILE

	la	$t0, tilearray
	sw	$t0, TILE_SCAN
	jr	$ra
	



