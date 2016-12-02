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
puzzlebit:	.byte 0
at_dest:	.byte 0
quad_bits:	.byte 0

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

	li	$a0, 30
	li	$a1, 30

	jal	movexy

wait:
	j	wait

#goagain:
#	li	$a0, 30
#	li	$a1, 30
#
#	jal	movexy
#
#waitmore:
#	j	waitmore

#	li	$t0, 2
#	sw	$t0, SET_RESOURCE_TYPE
#
#	la	$t0, puzzlestruct
#	sw	$t0, REQUEST_PUZZLE
#	la	$t0, puzzlebit
#
#	lw	$t2, GET_NUM_FIRE_STARTERS
#
#wait:
#	lb	$t1, 0($t0)
#	beq	$t1, 1, solve
#	j	wait
#
#solve:
#	la	$a0, solutionstruct
#	la	$a1, puzzlestruct
#	jal	recursive_backtracking
#
#	la	$t0, solutionstruct
#	sw	$t0, SUBMIT_SOLUTION
#	li	$t1, 0
#	sw	$t1, puzzlebit
#
#readseeds:
#	lw	$t2, GET_NUM_FIRE_STARTERS
#	j	readseeds

	j	main
