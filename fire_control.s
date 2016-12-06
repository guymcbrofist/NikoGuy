extinguish:
	sub	$sp, $sp, 4
	sw	$ra, 0($sp)

	lw	$t0, firesstruct
	la	$t1, firesstruct
	add	$t1, $t1, $t0
	lw	$t1, 0($t1)	# Fire coordinates

	lh	$t0, 2($t1)
	lh	$t1, 0($t1)

	mul	$t0, $t0, 30
	add	$a0, $t0, 15	# X coord of fire
	mul	$t1, $t1, 30
	add	$a1, $t1, 15	# Y coord of fire

	jal	movexy

	li	$a0, WATER_RESOURCE
	jal	gather

	#TODO:	add fire extinguishing logic here

	lw	$ra, 0($sp)
	add	$sp, $sp, 4
	jr	$ra

set_fire:
	sub	$sp, $sp, 4
	sw	$ra, 0($sp)

	

	lw	$ra, 0($sp)
	add	$sp, $sp, 4
	jr	$ra

read_board:
	la	$t0, tilearray
	sw	$t0, TILE_SCAN

	la	$t1, plantarray

	li	$t2, 0
rb_loop:
	lw	$t3, 0($t0)
	#read if current tile is growing
	#read if current tile is ours
	#read if tile to the right is growing
	#add current tile and right tile growing and store in right tile
	#read if tile below is growing
	#add current tile and below tile growing and store in below tile
	#read if tile right is ours
	#read if tile below is ours
	#or all three of our tiles
	add	$t2, $t2, 16

	jr	$ra
