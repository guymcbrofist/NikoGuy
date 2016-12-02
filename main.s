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
movexy:
	sub	$sp, $sp, 12
	sw	$ra, 0($sp)
	sw	$a0, 4($sp)
	sw	$a1, 8($sp)

	lw	$s0, BOT_X
	lw	$s1, BOT_Y
	sub	$a0, $a0, $s0
	sub	$a1, $a1, $s1

	jal	sb_arctan

	sw	$v0, ANGLE
	li	$t0, 1
	sw	$t0, ANGLE_CONTROL
	
	li	$t0, 10
	sw	$t0, VELOCITY

	lw	$a0, 4($sp)
	lw	$a1, 8($sp)
	sub	$a0, $a0, $s0
	sub	$a1, $a1, $s1

	jal	euclidean_dist
	lw	$t0, TIMER
	mul	$v0, $v0, 1000
	add	$t0, $t0, $v0
	sw	$t0, TIMER

	lw	$ra, 0($sp)
	add	$sp, $sp, 4

	jr	$ra
.data
three:	.float	3.0
five:	.float	5.0
PI:	.float	3.141592
F180:	.float  180.0
	
.text

# -----------------------------------------------------------------------
# sb_arctan - computes the arctangent of y / x
# $a0 - x
# $a1 - y
# returns the arctangent
# -----------------------------------------------------------------------

sb_arctan:
	li	$v0, 0		# angle = 0;

	abs	$t0, $a0	# get absolute values
	abs	$t1, $a1
	ble	$t1, $t0, no_TURN_90	  

	## if (abs(y) > abs(x)) { rotate 90 degrees }
	move	$t0, $a1	# int temp = y;
	neg	$a1, $a0	# y = -x;      
	move	$a0, $t0	# x = temp;    
	li	$v0, 90		# angle = 90;  

no_TURN_90:
	bgez	$a0, pos_x 	# skip if (x >= 0)

	## if (x < 0) 
	add	$v0, $v0, 180	# angle += 180;

pos_x:
	mtc1	$a0, $f0
	mtc1	$a1, $f1
	cvt.s.w $f0, $f0	# convert from ints to floats
	cvt.s.w $f1, $f1
	
	div.s	$f0, $f1, $f0	# float v = (float) y / (float) x;

	mul.s	$f1, $f0, $f0	# v^^2
	mul.s	$f2, $f1, $f0	# v^^3
	l.s	$f3, three	# load 5.0
	div.s 	$f3, $f2, $f3	# v^^3/3
	sub.s	$f6, $f0, $f3	# v - v^^3/3

	mul.s	$f4, $f1, $f2	# v^^5
	l.s	$f5, five	# load 3.0
	div.s 	$f5, $f4, $f5	# v^^5/5
	add.s	$f6, $f6, $f5	# value = v - v^^3/3 + v^^5/5

	l.s	$f8, PI		# load PI
	div.s	$f6, $f6, $f8	# value / PI
	l.s	$f7, F180	# load 180.0
	mul.s	$f6, $f6, $f7	# 180.0 * value / PI

	cvt.w.s $f6, $f6	# convert "delta" back to integer
	mfc1	$t0, $f6
	add	$v0, $v0, $t0	# angle += delta

	jr 	$ra
	

# -----------------------------------------------------------------------
# euclidean_dist - computes sqrt(x^2 + y^2)
# $a0 - x
# $a1 - y
# returns the distance
# -----------------------------------------------------------------------

euclidean_dist:
	mul	$a0, $a0, $a0	# x^2
	mul	$a1, $a1, $a1	# y^2
	add	$v0, $a0, $a1	# x^2 + y^2
	mtc1	$v0, $f0
	cvt.s.w	$f0, $f0	# float(x^2 + y^2)
	sqrt.s	$f0, $f0	# sqrt(x^2 + y^2)
	cvt.w.s	$f0, $f0	# int(sqrt(...))
	mfc1	$v0, $f0
	jr	$ra

.text

## struct Puzzle {
##   int size;
##   Cell* grid;
## };
##
## struct Solution {
##   int size;
##   int assignment[81];
## };
##
## // Returns next position for assignment.
## int get_unassigned_position(const Solution* solution, const Puzzle* puzzle) {
##   int unassigned_pos = 0;
##   for (; unassigned_pos < puzzle->size * puzzle->size; unassigned_pos++) {
##     if (solution->assignment[unassigned_pos] == 0) {
##       break;
##     }
##   }
##   return unassigned_pos;
## }

.globl get_unassigned_position
get_unassigned_position:
  li    $v0, 0            # unassigned_pos = 0
  lw    $t0, 0($a1)       # puzzle->size
  mul  $t0, $t0, $t0     # puzzle->size * puzzle->size
  add   $t1, $a0, 4       # &solution->assignment[0]
get_unassigned_position_for_begin:
  bge   $v0, $t0, get_unassigned_position_return  # if (unassigned_pos < puzzle->size * puzzle->size)
  mul  $t2, $v0, 4
  add   $t2, $t1, $t2     # &solution->assignment[unassigned_pos]
  lw    $t2, 0($t2)       # solution->assignment[unassigned_pos]
  beq   $t2, 0, get_unassigned_position_return  # if (solution->assignment[unassigned_pos] == 0)
  add   $v0, $v0, 1       # unassigned_pos++
  j   get_unassigned_position_for_begin
get_unassigned_position_return:
  jr    $ra
.text

## struct Puzzle {
##   int size;
##   Cell* grid;
## };
##
## struct Solution {
##   int size;
##   int assignment[81];
## };
##
## // Checks if the solution is complete.
## int is_complete(const Solution* solution, const Puzzle* puzzle) {
##   return solution->size == puzzle->size * puzzle->size;
## }

.globl is_complete
is_complete:
  lw    $t0, 0($a0)       # solution->size
  lw    $t1, 0($a1)       # puzzle->size
  mul   $t1, $t1, $t1     # puzzle->size * puzzle->size
  move	$v0, $0
  seq   $v0, $t0, $t1
  j     $ra
.text

## struct Cage {
##   char operation;
##   int target;
##   int num_cell;
##   int* positions;
## };
##
## struct Cell {
##   int domain;
##   Cage* cage;
## };
##
## struct Puzzle {
##   int size;
##   Cell* grid;
## };
##
## // Given the assignment at current position, removes all inconsistent values
## // for cells in the same row, column, and cage.
## int forward_checking(int position, Puzzle* puzzle) {
##   int size = puzzle->size;
##   // Removes inconsistent values in the row.
##   for (int col = 0; col < size; col++) {
##     if (col != position % size) {
##       puzzle->grid[position / size * size + col].domain &=
##           ~ puzzle->grid[position].domain;
##       if (!puzzle->grid[position / size * size + col].domain) {
##         return 0;
##       }
##     }
##   }
##   // Removes inconsistent values in the column.
##   for (int row = 0; row < size; row++) {
##     if (row != position / size) {
##       puzzle->grid[row * size + position % size].domain &=
##           ~ puzzle->grid[position].domain;
##       if (!puzzle->grid[row * size + position % size].domain) {
##         return 0;
##       }
##     }
##   }
##   // Removes inconsistent values in the cage.
##   for (int i = 0; i < puzzle->grid[position].cage->num_cell; i++) {
##     int pos = puzzle->grid[position].cage->positions[i];
##     puzzle->grid[pos].domain &= get_domain_for_cell(pos, puzzle);
##     if (!puzzle->grid[pos].domain) {
##       return 0;
##     }
##   }
##   return 1;
## }

.globl forward_checking
forward_checking:
  sub   $sp, $sp, 24
  sw    $ra, 0($sp)
  sw    $a0, 4($sp)
  sw    $a1, 8($sp)
  sw    $s0, 12($sp)
  sw    $s1, 16($sp)
  sw    $s2, 20($sp)
  lw    $t0, 0($a1)     # size
  li    $t1, 0          # col = 0
fc_for_col:
  bge   $t1, $t0, fc_end_for_col  # col < size
  div   $a0, $t0
  mfhi  $t2             # position % size
  mflo  $t3             # position / size
  beq   $t1, $t2, fc_for_col_continue    # if (col != position % size)
  mul   $t4, $t3, $t0
  add   $t4, $t4, $t1   # position / size * size + col
  mul   $t4, $t4, 8
  lw    $t5, 4($a1) # puzzle->grid
  add   $t4, $t4, $t5   # &puzzle->grid[position / size * size + col].domain
  mul   $t2, $a0, 8   # position * 8
  add   $t2, $t5, $t2 # puzzle->grid[position]
  lw    $t2, 0($t2) # puzzle -> grid[position].domain
  not   $t2, $t2        # ~puzzle->grid[position].domain
  lw    $t3, 0($t4) #
  and   $t3, $t3, $t2
  sw    $t3, 0($t4)
  beq   $t3, $0, fc_return_zero # if (!puzzle->grid[position / size * size + col].domain)
fc_for_col_continue:
  add   $t1, $t1, 1     # col++
  j     fc_for_col
fc_end_for_col:
  li    $t1, 0          # row = 0
fc_for_row:
  bge   $t1, $t0, fc_end_for_row  # row < size
  div   $a0, $t0
  mflo  $t2             # position / size
  mfhi  $t3             # position % size
  beq   $t1, $t2, fc_for_row_continue
  lw    $t2, 4($a1)     # puzzle->grid
  mul   $t4, $t1, $t0
  add   $t4, $t4, $t3
  mul   $t4, $t4, 8
  add   $t4, $t2, $t4   # &puzzle->grid[row * size + position % size]
  lw    $t6, 0($t4)
  mul   $t5, $a0, 8
  add   $t5, $t2, $t5
  lw    $t5, 0($t5)     # puzzle->grid[position].domain
  not   $t5, $t5
  and   $t5, $t6, $t5
  sw    $t5, 0($t4)
  beq   $t5, $0, fc_return_zero
fc_for_row_continue:
  add   $t1, $t1, 1     # row++
  j     fc_for_row
fc_end_for_row:

  li    $s0, 0          # i = 0
fc_for_i:
  lw    $t2, 4($a1)
  mul   $t3, $a0, 8
  add   $t2, $t2, $t3
  lw    $t2, 4($t2)     # &puzzle->grid[position].cage
  lw    $t3, 8($t2)     # puzzle->grid[position].cage->num_cell
  bge   $s0, $t3, fc_return_one
  lw    $t3, 12($t2)    # puzzle->grid[position].cage->positions
  mul   $s1, $s0, 4
  add   $t3, $t3, $s1
  lw    $t3, 0($t3)     # pos
  lw    $s1, 4($a1)
  mul   $s2, $t3, 8
  add   $s2, $s1, $s2   # &puzzle->grid[pos].domain
  lw    $s1, 0($s2)
  move  $a0, $t3
  jal get_domain_for_cell
  lw    $a0, 4($sp)
  lw    $a1, 8($sp)
  and   $s1, $s1, $v0
  sw    $s1, 0($s2)     # puzzle->grid[pos].domain &= get_domain_for_cell(pos, puzzle)
  beq   $s1, $0, fc_return_zero
fc_for_i_continue:
  add   $s0, $s0, 1     # i++
  j     fc_for_i
fc_return_one:
  li    $v0, 1
  j     fc_return
fc_return_zero:
  li    $v0, 0
fc_return:
  lw    $ra, 0($sp)
  lw    $a0, 4($sp)
  lw    $a1, 8($sp)
  lw    $s0, 12($sp)
  lw    $s1, 16($sp)
  lw    $s2, 20($sp)
  add   $sp, $sp, 24
  jr    $ra
.text

## struct Cage {
##   char operation;
##   int target;
##   int num_cell;
##   int* positions;
## };
##
## struct Cell {
##   int domain;
##   Cage* cage;
## };
##
## struct Puzzle {
##   int size;
##   Cell* grid;
## };
##
## struct Solution {
##   int size;
##   int assignment[81];
## };
##
## int recursive_backtracking(Solution* solution, Puzzle* puzzle) {
##   if (is_complete(solution, puzzle)) {
##     return 1;
##   }
##   int position = get_unassigned_position(solution, puzzle);
##   for (int val = 1; val < puzzle->size + 1; val++) {
##     if (puzzle->grid[position].domain & (0x1 << (val - 1))) {
##       solution->assignment[position] = val;
##       solution->size += 1;
##       // Applies inference to reduce space of possible assignment.
##       Puzzle puzzle_copy;
##       Cell grid_copy [81]; // 81 is the maximum size of the grid.
##       puzzle_copy.grid = grid_copy;
##       clone(puzzle, &puzzle_copy);
##       puzzle_copy.grid[position].domain = 0x1 << (val - 1);
##       if (forward_checking(position, &puzzle_copy)) {
##         if (recursive_backtracking(solution, &puzzle_copy)) {
##           return 1;
##         }
##       }
##       solution->assignment[position] = 0;
##       solution->size -= 1;
##     }
##   }
##   return 0;
## }

.globl recursive_backtracking
recursive_backtracking:
  sub   $sp, $sp, 680
  sw    $ra, 0($sp)
  sw    $a0, 4($sp)     # solution
  sw    $a1, 8($sp)     # puzzle
  sw    $s0, 12($sp)    # position
  sw    $s1, 16($sp)    # val
  sw    $s2, 20($sp)    # 0x1 << (val - 1)
                        # sizeof(Puzzle) = 8
                        # sizeof(Cell [81]) = 648

  jal   is_complete
  bne   $v0, $0, recursive_backtracking_return_one
  lw    $a0, 4($sp)     # solution
  lw    $a1, 8($sp)     # puzzle
  jal   get_unassigned_position
  move  $s0, $v0        # position
  li    $s1, 1          # val = 1
recursive_backtracking_for_loop:
  lw    $a0, 4($sp)     # solution
  lw    $a1, 8($sp)     # puzzle
  lw    $t0, 0($a1)     # puzzle->size
  add   $t1, $t0, 1     # puzzle->size + 1
  bge   $s1, $t1, recursive_backtracking_return_zero  # val < puzzle->size + 1
  lw    $t1, 4($a1)     # puzzle->grid
  mul   $t4, $s0, 8     # sizeof(Cell) = 8
  add   $t1, $t1, $t4   # &puzzle->grid[position]
  lw    $t1, 0($t1)     # puzzle->grid[position].domain
  sub   $t4, $s1, 1     # val - 1
  li    $t5, 1
  sll   $s2, $t5, $t4   # 0x1 << (val - 1)
  and   $t1, $t1, $s2   # puzzle->grid[position].domain & (0x1 << (val - 1))
  beq   $t1, $0, recursive_backtracking_for_loop_continue # if (domain & (0x1 << (val - 1)))
  mul   $t0, $s0, 4     # position * 4
  add   $t0, $t0, $a0
  add   $t0, $t0, 4     # &solution->assignment[position]
  sw    $s1, 0($t0)     # solution->assignment[position] = val
  lw    $t0, 0($a0)     # solution->size
  add   $t0, $t0, 1
  sw    $t0, 0($a0)     # solution->size++
  add   $t0, $sp, 32    # &grid_copy
  sw    $t0, 28($sp)    # puzzle_copy.grid = grid_copy !!!
  move  $a0, $a1        # &puzzle
  add   $a1, $sp, 24    # &puzzle_copy
  jal   clone           # clone(puzzle, &puzzle_copy)
  mul   $t0, $s0, 8     # !!! grid size 8
  lw    $t1, 28($sp)
  
  add   $t1, $t1, $t0   # &puzzle_copy.grid[position]
  sw    $s2, 0($t1)     # puzzle_copy.grid[position].domain = 0x1 << (val - 1);
  move  $a0, $s0
  add   $a1, $sp, 24
  jal   forward_checking  # forward_checking(position, &puzzle_copy)
  beq   $v0, $0, recursive_backtracking_skip

  lw    $a0, 4($sp)     # solution
  add   $a1, $sp, 24    # &puzzle_copy
  jal   recursive_backtracking
  beq   $v0, $0, recursive_backtracking_skip
  j     recursive_backtracking_return_one # if (recursive_backtracking(solution, &puzzle_copy))
recursive_backtracking_skip:
  lw    $a0, 4($sp)     # solution
  mul   $t0, $s0, 4
  add   $t1, $a0, 4
  add   $t1, $t1, $t0
  sw    $0, 0($t1)      # solution->assignment[position] = 0
  lw    $t0, 0($a0)
  sub   $t0, $t0, 1
  sw    $t0, 0($a0)     # solution->size -= 1
recursive_backtracking_for_loop_continue:
  add   $s1, $s1, 1     # val++
  j     recursive_backtracking_for_loop
recursive_backtracking_return_zero:
  li    $v0, 0
  j     recursive_backtracking_return
recursive_backtracking_return_one:
  li    $v0, 1
recursive_backtracking_return:
  lw    $ra, 0($sp)
  lw    $a0, 4($sp)
  lw    $a1, 8($sp)
  lw    $s0, 12($sp)
  lw    $s1, 16($sp)
  lw    $s2, 20($sp)
  add   $sp, $sp, 680
  jr    $ra
.text

## int
## convert_highest_bit_to_int(int domain) {
##     int result = 0;
##     for (; domain; domain >>= 1) {
##         result++;
##     }
##     return result;
## }

.globl convert_highest_bit_to_int
convert_highest_bit_to_int:
    move  $v0, $0             # result = 0

chbti_loop:
    beq   $a0, $0, chbti_end
    add   $v0, $v0, 1         # result ++
    sra   $a0, $a0, 1         # domain >>= 1
    j     chbti_loop

chbti_end:
    jr    $ra

.globl is_single_value_domain
is_single_value_domain:
    beq    $a0, $0, isvd_zero     # return 0 if domain == 0
    sub    $t0, $a0, 1	          # (domain - 1)
    and    $t0, $t0, $a0          # (domain & (domain - 1))
    bne    $t0, $0, isvd_zero     # return 0 if (domain & (domain - 1)) != 0
    li     $v0, 1
    jr	   $ra

isvd_zero:	   
    li	   $v0, 0
    jr	   $ra
    
.globl get_domain_for_addition
get_domain_for_addition:

	sub	$sp, $sp, 20
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	sw	$s2, 12($sp)

	sw	$a0, 16($sp)
	move	$a0, $a2

	#	convert_highest_bit_to_int(domain)
	jal	convert_highest_bit_to_int

	neg	$s0, $a2
	and	$a0, $a2, $s0
	move	$s0, $v0		# $s0 = upper_bound

	#	convert_highest_bit_to_int(domain & -(domain))
	jal	convert_highest_bit_to_int
	# $v0 = lower_bound

	sub	$a1, $a1, 1		# $a1 = num_cell-1
	mul	$s1, $a1, $v0		# lower_bound * (num_cell-1)
	lw	$a0, 16($sp)
	sub	$s1, $a0, $s1		# high_bits = target - lower_bound * (num_cell-1)

	bge	$s1, $s0, gdfa_if1	# !(high_bits < upper_bound)

	li	$s2, 1
	sllv	$s2, $s2, $s1		# 1 << high_bits
	sub	$s2, $s2, 1		# (1 << high_bits)-1
	and	$a2, $a2, $s2		# domain = domain & ((1 << high_bits)-1)

gdfa_if1:
	mul	$s1, $a1, $s0		# (num_cell-1) * upper_bound
	sub	$s1, $a0, $s1		# low_bits = target - (num_cell-1) * upper_bound

	blez	$s1, gdfa_if2		# !(low_bits > 0)

	sub	$s1, $s1, 1		# low_bits-1
	srlv	$a2, $a2, $s1
	sllv	$a2, $a2, $s1		# domain = (domain >> (low_bits-1)) << (low_bits-1)

gdfa_if2:
	move	$v0, $a2		# return domain

	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	lw	$s2, 12($sp)
	add	$sp, $sp, 20
	
    # We highly recommend that you copy in our 
    # solution when it is released on Tuesday night 
    # after the late deadline for Lab7.2
    #
    # If you reach this part before Tuesday night,
    # you can paste your Lab7.2 solution here for now

    # And don't forget to delete the infinite loop :)

    jr     $ra

.globl get_domain_for_subtraction
get_domain_for_subtraction:
    
	mul	$t0, $a0, 2		# target * 2
	li	$t1, 1
	sllv	$t1, $t1, $t0		# 1 << (target * 2)
	ori	$t1, $t1, 1		# base_mask = 1 | (1 << (target * 2))
	li	$t0, 0			# mask = 0

gdfs_forloop:
	beqz	$a2, gdfs_exit		# !other_domain

	andi	$t2, $a2, 1
	beqz	$t2, gdfs_if		# !(other_domain & 1)

	srlv	$t2, $t1, $a0		# base_mask >> target
	or	$t0, $t0, $t2		# mask |= base_mask >> target

gdfs_if:

	sll	$t1, $t1, 1		# base_mask <<= 1

	srl	$a2, $a2, 1		# other_domain >>= 1
	j	gdfs_forloop

gdfs_exit:
	and	$v0, $a1, $t0		# return domain & mask

    # We highly recommend that you copy in our 
    # solution when it is released on Tuesday night 
    # after the late deadline for Lab7.2
    #
    # If you reach this part before Tuesday night,
    # you can paste your Lab7.2 solution here for now

    # And don't forget to delete the infinite loop :)

    jr     $ra


.globl get_domain_for_cell
get_domain_for_cell:
    # save registers    
    sub $sp, $sp, 36
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    sw $s5, 24($sp)
    sw $s6, 28($sp)
    sw $s7, 32($sp)

    li $t0, 0 # valid_domain
    lw $t1, 4($a1) # puzzle->grid (t1 free)
    sll $t2, $a0, 3 # position*8 (actual offset) (t2 free)
    add $t3, $t1, $t2 # &puzzle->grid[position]
    lw  $t4, 4($t3) # &puzzle->grid[position].cage
    lw  $t5, 0($t4) # puzzle->grid[posiition].cage->operation

    lw $t2, 4($t4) # puzzle->grid[position].cage->target

    move $s0, $t2   # remain_target = $s0  *!*!
    lw $s1, 8($t4) # remain_cell = $s1 = puzzle->grid[position].cage->num_cell
    lw $s2, 0($t3) # domain_union = $s2 = puzzle->grid[position].domain
    move $s3, $t4 # puzzle->grid[position].cage
    li $s4, 0   # i = 0
    move $s5, $t1 # $s5 = puzzle->grid
    move $s6, $a0 # $s6 = position
    # move $s7, $s2 # $s7 = puzzle->grid[position].domain

    bne $t5, 0, gdfc_check_else_if

    li $t1, 1
    sub $t2, $t2, $t1 # (puzzle->grid[position].cage->target-1)
    sll $v0, $t1, $t2 # valid_domain = 0x1 << (prev line comment)
    j gdfc_end # somewhere!!!!!!!!

gdfc_check_else_if:
    bne $t5, '+', gdfc_check_else

gdfc_else_if_loop:
    lw $t5, 8($s3) # puzzle->grid[position].cage->num_cell
    bge $s4, $t5, gdfc_for_end # branch if i >= puzzle->grid[position].cage->num_cell
    sll $t1, $s4, 2 # i*4
    lw $t6, 12($s3) # puzzle->grid[position].cage->positions
    add $t1, $t6, $t1 # &puzzle->grid[position].cage->positions[i]
    lw $t1, 0($t1) # pos = puzzle->grid[position].cage->positions[i]
    add $s4, $s4, 1 # i++

    sll $t2, $t1, 3 # pos * 8
    add $s7, $s5, $t2 # &puzzle->grid[pos]
    lw  $s7, 0($s7) # puzzle->grid[pos].domain

    beq $t1, $s6 gdfc_else_if_else # branch if pos == position

    

    move $a0, $s7 # $a0 = puzzle->grid[pos].domain
    jal is_single_value_domain
    bne $v0, 1 gdfc_else_if_else # branch if !is_single_value_domain()
    move $a0, $s7
    jal convert_highest_bit_to_int
    sub $s0, $s0, $v0 # remain_target -= convert_highest_bit_to_int
    addi $s1, $s1, -1 # remain_cell -= 1
    j gdfc_else_if_loop
gdfc_else_if_else:
    or $s2, $s2, $s7 # domain_union |= puzzle->grid[pos].domain
    j gdfc_else_if_loop

gdfc_for_end:
    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    jal get_domain_for_addition # $v0 = valid_domain = get_domain_for_addition()
    j gdfc_end

gdfc_check_else:
    lw $t3, 12($s3) # puzzle->grid[position].cage->positions
    lw $t0, 0($t3) # puzzle->grid[position].cage->positions[0]
    lw $t1, 4($t3) # puzzle->grid[position].cage->positions[1]
    xor $t0, $t0, $t1
    xor $t0, $t0, $s6 # other_pos = $t0 = $t0 ^ position
    lw $a0, 4($s3) # puzzle->grid[position].cage->target

    sll $t2, $s6, 3 # position * 8
    add $a1, $s5, $t2 # &puzzle->grid[position]
    lw  $a1, 0($a1) # puzzle->grid[position].domain
    # move $a1, $s7 

    sll $t1, $t0, 3 # other_pos*8 (actual offset)
    add $t3, $s5, $t1 # &puzzle->grid[other_pos]
    lw $a2, 0($t3)  # puzzle->grid[other_pos].domian

    jal get_domain_for_subtraction # $v0 = valid_domain = get_domain_for_subtraction()
    # j gdfc_end
gdfc_end:
# restore registers
    
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    lw $s5, 24($sp)
    lw $s6, 28($sp)
    lw $s7, 32($sp)
    add $sp, $sp, 36    
    jr $ra


.globl clone
clone:

    lw  $t0, 0($a0)
    sw  $t0, 0($a1)

    mul $t0, $t0, $t0
    mul $t0, $t0, 2 # two words in one grid

    lw  $t1, 4($a0) # &puzzle(ori).grid
    lw  $t2, 4($a1) # &puzzle(clone).grid

    li  $t3, 0 # i = 0;
clone_for_loop:
    bge  $t3, $t0, clone_for_loop_end
    sll $t4, $t3, 2 # i * 4
    add $t5, $t1, $t4 # puzzle(ori).grid ith word
    lw   $t6, 0($t5)

    add $t5, $t2, $t4 # puzzle(clone).grid ith word
    sw   $t6, 0($t5)
    
    addi $t3, $t3, 1 # i++
    
    j    clone_for_loop
clone_for_loop_end:

    jr  $ra

.kdata
chunkIH:	.space 8

.ktext 0x80000180
interrupt_handler:
.set noat
	move	$k1, $at
.set at
	la	$k0, chunkIH
	sw	$a0, 0($k0)
	sw	$a1, 4($k0)

interrupt_dispatch:
	mfc0	$k0, $13
	beq	$k0, $0, done

	and	$a0, $k0, ON_FIRE_MASK
	bne	$a0, $0, fire_interrupt

	and	$a0, $k0, REQUEST_PUZZLE_INT_MASK
	bne	$a0, $0, puzzle_interrupt

	and	$a0, $k0, TIMER_MASK
	bne	$a0, $0, timer_interrupt

	j	done

fire_interrupt:
	sw	$0, ON_FIRE_ACK
	lb	$a1, num_fires
	add	$a1, $a1, 1
	sb	$a1, num_fires
	sub	$a1, $a1, 1
	sll	$a1, $a1, 2
	la	$k0, fire_xy
	add	$a1, $a1, $k0
	lw	$a0, GET_FIRE_LOC
	sw	$a0, 0($a1)
	j	interrupt_dispatch

puzzle_interrupt:
	sw	$0, REQUEST_PUZZLE_ACK
	la	$k0, puzzlebit
	li	$a0, 1
	sb	$a0, 0($k0)
	j	interrupt_dispatch

timer_interrupt:
	sw	$0, TIMER_ACK
	sw	$0, VELOCITY
	li	$a0, 1
	sb	$a0, at_dest
	j	interrupt_dispatch

done:
	la	$k0, chunkIH
	lw	$a0, 0($k0)
	lw	$a1, 4($k0)
.set noat
	move	$at, $k1
.set at
	eret
