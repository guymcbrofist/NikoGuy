.text

check_tile:	
	div $t5, $a0, 30
	mflo $t5, $t5		#get x_tile
	div $t6, $a1, 30
	mflo $t6, $t6		#get y_tile
	
	mul $t0, $t6, 10	#y_tile*10 since it is columns
	add $t1, $t0, $t5	#to get tile number, add previous statment and x_tile
	mul $t1, $t1, 16	#16 is tileStruct size
	lw $t2, tilearray
	add $t2, $t2, t1 
	lw $t2, 0($t2)		#current_tile.state
	#bne $t2, 0, plant_seed	#if x.state == 0, go check seeds and plant


	move $v0, $t2
	jr $ra
