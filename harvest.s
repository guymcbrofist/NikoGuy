harvest:	
	sub	$sp, $sp, 4
	sw	$ra, 0($sp)
	
	#TODO:	Write loop that finds max grown tiles
hrvst_scan_begin:
	la	$t0, tilearray
	sw	$t0, TILE_SCAN
	li	$t1, 0
hrvst_scan:
	lw	$t2, 4($t0)
	bnez	$t2, hrvst_scan_bad_tile
	lw	$t2, 8($t0)
	blt	$t2, 512, hrvst_scan_bad_tile
	j	hrvst_scan_done
hrvst_scan_bad_tile:
	add	$t0, $t0, 16
	add	$t1, $t1, 1
	blt	$t1, 100, hrvst_scan
	j	hrvst_return
hrvst_scan_done:
	li	$t0, 10
	div	$t1, $t0
	mfhi	$t1
	mflo	$t2

	mul	$t1, $t1, 30
	add	$a0, $t1, 15	# X pixel coord of plant

	mul	$t2, $t2, 30
	add	$a1, $t2, 15	# Y pixel coord of plant

	jal	movexy

	li	$a0, -1
	jal	gather

	sw	$0, HARVEST_TILE	#harvest

	#no checking for seed number here, we take care of that
	#in the main file
	sw	$0, SEED_TILE 	#plant

	li	$t0, 10		#water
	sw	$t0, WATER_TILE
	j	hrvst_scan_begin

hrvst_return:
	lw $ra, 0($sp)
	add $sp, $sp, 4

	jr $ra
	
