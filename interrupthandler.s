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

	and	$a0, $k0, MAX_GROWTH_INT_MASK
	bne	$a0, $0, max_growth_interrupt

	and	$a0, $k0, REQUEST_PUZZLE_INT_MASK
	bne	$a0, $0, puzzle_interrupt

	and	$a0, $k0, TIMER_MASK
	bne	$a0, $0, timer_interrupt

	j	done

fire_interrupt:
	sw	$0, ON_FIRE_ACK
	lw	$a1, firesstruct
	add	$a1, $a1, 1
	la	$a0, firesstruct
	add	$a0, $a0, $a1
	sw	$a1, firesstruct
	lw	$a1, GET_FIRE_LOC
	sw	$a1, 0($a0)
	j	interrupt_dispatch

max_growth_interrupt:
	sw	$0, MAX_GROWTH_ACK
	li	$a0, 1
	sw	$a0, max_plant
	j	interrupt_dispatch

puzzle_interrupt:
	sw	$0, REQUEST_PUZZLE_ACK
	li	$a0, 1
	sw	$a0, have_puzzle
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
