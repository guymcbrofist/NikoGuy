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
puzzlebit:	.word 0
at_dest:	.word 0
quad_bits:	.word 0

.align 2
tilearray:	.space 1600
puzzlestruct:	.space 4096
solutionstruct: .space 328

.text
main:
	# go wild
	# the world is your oyster :)
	li	$t0, REQUEST_PUZZLE_INT_MASK
	or	$t0, $t0, 1
	or	$t0, $t0, ON_FIRE_MASK
	or	$t0, $t0, TIMER_MASK
	or	$t0, $t0, MAX_GROWTH_INT_MASK
	mtc0	$t0, $12

	li	$a0, 15
	li	$a1, 15
	jal	movexy

	li	$a0, SEED_RESOURCE
	jal	request_resource

loop:
	lb	$t2, puzzlebit
	bnez	$t2, go
	j	loop

go:
	jal	solve_puzzle
	jal	clear_solution
	lb	$t0, at_dest
	bnez	$t0, leave
	li	$a0, SEED_RESOURCE
	jal	request_resource
	j	loop
leave:
	li	$a0, 255
	li	$a1, 255
	jal	movexy

loop2:
	j	loop2

	j	main

request_resource:
	sw	$a0, SET_RESOURCE_TYPE
	la	$a0, puzzlestruct
	sw	$a0, REQUEST_PUZZLE
	jr	$ra

solve_puzzle:
	sub	$sp, $sp, 4
	sw	$ra, 0($sp)

	la	$a0, solutionstruct
	la	$a1, puzzlestruct
	jal	recursive_backtracking
	la	$t0, solutionstruct
	sw	$t0, SUBMIT_SOLUTION
	sw	$0, puzzlebit

	lw	$ra, 0($sp)
	add	$sp, $sp, 4
	jr	$ra

clear_solution:
	la	$t1, solutionstruct
	add	$t0, $t1, 328
cs_loop:
	sw	$0, 0($t1)
	add	$t1, $t1, 4
	blt	$t1, $t0, cs_loop
	jr	$ra

look_at_enemy:
	lh	$t0, OTHER_BOT_X
	lh	$t1, OTHER_BOT_Y
	jr	$ra
