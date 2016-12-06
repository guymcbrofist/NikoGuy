# syscall constants
PRINT_STRING = 4
PRINT_CHAR   = 11
PRINT_INT    = 1

# debug constants
PRINT_INT_ADDR   = 0xffff0080
PRINT_FLOAT_ADDR = 0xffff0084
PRINT_HEX_ADDR   = 0xffff0088

# spimbot constants
VELOCITY       = 0xffff0010
ANGLE          = 0xffff0014
ANGLE_CONTROL  = 0xffff0018
BOT_X          = 0xffff0020
BOT_Y          = 0xffff0024
OTHER_BOT_X    = 0xffff00a0
OTHER_BOT_Y    = 0xffff00a4
TIMER          = 0xffff001c
SCORES_REQUEST = 0xffff1018

TILE_SCAN       = 0xffff0024
SEED_TILE       = 0xffff0054
WATER_TILE      = 0xffff002c
MAX_GROWTH_TILE = 0xffff0030
HARVEST_TILE    = 0xffff0020
BURN_TILE       = 0xffff0058
GET_FIRE_LOC    = 0xffff0028
PUT_OUT_FIRE    = 0xffff0040

GET_NUM_WATER_DROPS   = 0xffff0044
GET_NUM_SEEDS         = 0xffff0048
GET_NUM_FIRE_STARTERS = 0xffff004c
SET_RESOURCE_TYPE     = 0xffff00dc
REQUEST_PUZZLE        = 0xffff00d0
SUBMIT_SOLUTION       = 0xffff00d4

WATER_RESOURCE        = 0
SEED_RESOURCE         = 1
FIRE_RESOURCE         = 2

# interrupt constants
BONK_MASK               = 0x1000
BONK_ACK                = 0xffff0060
TIMER_MASK              = 0x8000
TIMER_ACK               = 0xffff006c
ON_FIRE_MASK            = 0x400
ON_FIRE_ACK             = 0xffff0050
MAX_GROWTH_ACK          = 0xffff005c
MAX_GROWTH_INT_MASK     = 0x2000
REQUEST_PUZZLE_ACK      = 0xffff00d8
REQUEST_PUZZLE_INT_MASK = 0x800

.data
# data things go here
have_puzzle:	.word 0
wait_puzzle:	.word 0
zero_solution:  .word 1
at_dest:	.word 0
quad_x: 	.word 0
quad_y:		.word 0

.align 2
tilearray:	.space 1600
puzzlestruct:	.space 4096
solutionstruct: .space 328

.text
#####
#main
#
#Schedules the SpimBOT
#####
main:
	# go wild
	# the world is your oyster :)
	li	$t0, REQUEST_PUZZLE_INT_MASK
	or	$t0, $t0, 1
	or	$t0, $t0, ON_FIRE_MASK
	or	$t0, $t0, TIMER_MASK
	or	$t0, $t0, MAX_GROWTH_INT_MASK
	mtc0	$t0, $12

	#TODO:	Write this function
	#jal	gather_initial

	jal	farm_start

	li	$a0, SEED_RESOURCE
	jal	gather

	jal	plant_farm
loop:
	j	loop

	j	main

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
	jal	request_resource
	j	working
g_return:
	lw	$ra, 0($sp)
	add	$sp, $sp, 8
	jr	$ra
