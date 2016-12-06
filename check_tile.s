.text

###########
#check_tile
#
#Checks the growing status of the given tile
#If a coordinate out of range of the board is passed in, returns 1 (growing, leave it alone)
#
#a0: x-coordinate
#a1: y-coordinate
###########
check_tile:
	slt	$t0, $a0, $0
	slt	$t1, $a1, $0
	or	$t0, $t0, $t1
	li	$t2, 300
	slt	$t1, $t2, $a0
	or	$t0, $t0, $t1
	slt	$t1, $t2, $a1
	or	$t0, $t0, $t1
	beqz	$t0, valid_tile
	li	$v0, 1
	j	ct_return
valid_tile:
	div	$t0, $a0, 30
	div	$t1, $a1, 30
	
	mul	$t1, $t1, 10	#y_tile*10 since it is columns
	add	$t1, $t1, $t0	#to get tile number, add previous statment and x_tile
	mul	$t1, $t1, 16	#16 is tileStruct size
	la	$t2, tilearray
	add	$t2, $t2, $t1 
	lw	$v0, 0($t2)	#current_tile.state
ct_return:
	jr	$ra
