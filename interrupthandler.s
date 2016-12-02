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

done:
	la	$k0, chunkIH
	lw	$a0, 0($k0)
	lw	$a1, 4($k0)
.set noat
	move	$at, $k1
.set at
	eret
