max_growth_interrupt:
	jal 	harvester
	sw 	$a1, MAX_GROWTH_ACK
	j	interrupt_dispatch
	
harvester:	
	sub $sp, $sp, 12
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	
	lw $t0, MAX_GROWTH_TILE
	div $t0, $t0, 10
	mfhi $a0		#mag_growth_tile % 10 = x-coord
	mflo $a1		#max_growth_tile / 10 = y-coord

	mul $a0, $a0, 30
	add $a0, $a0, 15	#obtain x pixel

	mul $a1, $a1, 30
	add $a1, $a1, 15	#obtain y pixel

	jal movexy

check_bit:
	lb $t1, at_dest
	bne $t1, 0, check_bit

conquer:
	sw $0, HARVEST_TILE	#harvest

	#no checking for seed number here, we take care of taht
	#in the main file
	sw $0, SEED_TILE 	#plant

	li $t0, 10		#water
	sw $t0, WATER_TILE

	sub $sp, $sp, 12
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)

	jr $ra
	
