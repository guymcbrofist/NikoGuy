fire_handler:	
	lw	$a0, GET_FIRE_LOC
	and $t1, $a0, 0xffff		#to get the x and y locations
	srl $a0, $a0, 16
	and $t0, $a0, 0xffff

	mul $a0, $a0, 30	#a0 = (x % 10) * 30
	add $a0, $a0, 15	#a0 = ((x % 10) * 30) + 15, x_pixel

	mul $a1, $a1, 30	#a1 = ((y % 10) * 30)
	add $a1, $a1, 15	#a1 = ((y % 10) * 30) + 15, y_pixel

	jal movexy 		#move towards that location.

	li $t0, 1
	sw $t0, PUT_OUT_FIRE	#put out the fire

	jr $ra			#do we need to update the tile array here??
	
