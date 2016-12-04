movexy:
	sub	$sp, $sp, 12
	sw	$ra, 0($sp)
	sw	$a0, 4($sp)
	sw	$a1, 8($sp)

	sb	$0, at_dest

	lw	$s0, BOT_X
	lw	$s1, BOT_Y
	sub	$a0, $a0, $s0
	sub	$a1, $a1, $s1
	jal	sb_arctan

	sw	$v0, ANGLE
	li	$t0, 1
	sw	$t0, ANGLE_CONTROL

	lw	$a0, 4($sp)
	lw	$a1, 8($sp)
	sub	$a0, $a0, $s0
	sub	$a1, $a1, $s1
	jal	euclidean_dist

	mul	$v0, $v0, 1000
	lw	$t0, TIMER
	add	$t0, $t0, $v0
	sw	$t0, TIMER

	li	$t0, 10
	sw	$t0, VELOCITY

	lw	$ra, 0($sp)
	add	$sp, $sp, 12

	jr	$ra
