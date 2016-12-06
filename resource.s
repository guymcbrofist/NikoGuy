#################
#request_resource
#
#Requests a puzzle for a resource
#There must be no pending puzzles or a solution struct with a solution when this is called
#
#$a0: Resource type requested
#################
request_resource:
	sw	$a0, SET_RESOURCE_TYPE
	la	$a0, puzzlestruct
	sw	$a0, REQUEST_PUZZLE
	li	$t0, 1
	sw	$t0, wait_puzzle
	jr	$ra

#############
#solve_puzzle
#
#Solves the puzzle
#There must be a valid puzzle and a zero solution struct when called
#############
solve_puzzle:
	sub	$sp, $sp, 4
	sw	$ra, 0($sp)

	la	$a0, solutionstruct
	la	$a1, puzzlestruct
	jal	recursive_backtracking
	la	$t0, solutionstruct
	sw	$t0, SUBMIT_SOLUTION
	sw	$0, have_puzzle
	sw	$0, zero_solution

	lw	$ra, 0($sp)
	add	$sp, $sp, 4
	jr	$ra

###############
#clear_solution
#
#Zeroes out the solution struct
###############
clear_solution:
	la	$t1, solutionstruct
	add	$t0, $t1, 328
cs_loop:
	sw	$0, 0($t1)
	add	$t1, $t1, 4
	blt	$t1, $t0, cs_loop
	li	$t0, 1
	sw	$t0, zero_solution
	jr	$ra

#######
#gather
#
#Keeps calling for puzzles and solves them
#Call while moving over more than short distances
#
#Exits when at_dest is set to 1
#
#a0: Resource type to keep gathering
#    0 = water
#    1 = seeds
#    2 = fire starters
#   -1 = cycle through water and seeds
#######
gather:
	sub	$sp, $sp, 8
	sw	$ra, 0($sp)
	sw	$a0, 4($sp)
working:
	lw	$t0, at_dest
	bnez	$t0, g_return
	lw	$t0, have_puzzle
	lw	$t1, zero_solution
	lw	$t2, wait_puzzle
	beqz	$t0, no_puzzle
	beqz	$t2, no_puzzle
	sw	$0, wait_puzzle
	jal	solve_puzzle
	j	working
no_puzzle:
	bnez	$t1, no_solution
	jal	clear_solution
	j	working
no_solution:
	bnez	$t2, working
	lw	$a0, 4($sp)
	bgez	$a0, g_request

	la	$t0, request_pattern	# Handle resource cycling
	lw	$t1, request_count
	add	$t0, $t0, $t1
	lb	$a0, 0($t0)
	add	$t1, $t1, 1
	sw	$t1, request_count
	ble	$t1, 3, g_request
	sw	$0, request_count

g_request:
	jal	request_resource
	j	working
g_return:
	lw	$ra, 0($sp)
	add	$sp, $sp, 8
	jr	$ra

gather_initial:
	sub	$sp, $sp, 4
	sw	$ra, 0($sp)

	li	$t0, 0
	sw	$t0, at_dest
	lw	$t0, TIMER
	add	$t0, $t0, 500000
	sw	$t0, TIMER
	li	$a0, -1
	jal	gather

	lw	$ra, 0($sp)
	add	$sp, $sp, 4
	jr	$ra
