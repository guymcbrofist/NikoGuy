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
have_puzzle:	.word 0	# Do we have a puzzle?
wait_puzzle:	.word 0	# Are we waiting on a puzzle?
zero_solution:  .word 1 # Is our solution struct zeroed out?
at_dest:	.word 0	# Are we done moving?
quad_x: 	.word 0	# 
quad_y:		.word 0	# The quadrant we're working in
max_plant:	.word 0	# The count of plants at max growth
request_pattern:.word 0x01000000
request_count:	.word 0
fire_alert:	.word 0 # Is there a fire?

.align 2
tilearray:	.space 1600
puzzlestruct:	.space 4096
solutionstruct: .space 328
plantarray:	.space 800
firesstruct:	.space 101

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
	jal	gather_initial

	#TODO:	finish main loop
main_begin:
	jal	farm_start
	li	$a0, -1
	jal	gather
	jal	plant_farm
main_loop:
	#TODO:	Write fire checking and extinguishing logic
	lw	$t0, firesstruct
	beqz	$t0, main_harvest
	#TODO:	Write this function:
	#jal	extinguish
main_harvest:
	lw	$t0, max_plant	#Get a count of the max grown plants
	beqz	$t0, main_attack
	sw	$0, max_plant
	jal	harvest
	j	main_loop
main_attack:
	#TODO:	Write fire gathering and starting logic
	j	main_loop

	j	main
