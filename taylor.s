.data
three:	.float	3.0
five:	.float	5.0
seven:  .float  7.0
nine:   .float  9.0
eleven: .float  11.0
thirteen: .float 13.0
fifteen: .float  15.0
svnteen: .float 17.0
PI:	.float	3.14159265359
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
	l.s	$f3, three	# load 3.0
	div.s 	$f3, $f2, $f3	# v^^3/3
	sub.s	$f6, $f0, $f3	# v - v^^3/3

	mul.s	$f4, $f1, $f2	# v^^5
	l.s	$f5, five	# load 5.0
	div.s 	$f5, $f4, $f5	# v^^5/5
	add.s	$f6, $f6, $f5	# value = v - v^^3/3 + v^^5/5

	mul.s	$f7, $f1, $f4	# v^^7
	l.s	$f8, seven	# load 7.0
	div.s 	$f8, $f7, $f8	# v^^7/7
	sub.s	$f6, $f6, $f8	# value = v - v^^3/3 + v^^5/5 - v^^7/7

	mul.s	$f10, $f1, $f7	# v^^9
	l.s	$f11, nine	# load 9.0
	div.s 	$f11, $f10, $f11	# v^^9/9
	add.s	$f6, $f6, $f11	# value = v - v^^3/3 + v^^5/5 - v^^7/7 + v^^9/9

	mul.s	$f12, $f1, $f10	# v^^11
	l.s	$f13, eleven	# load 11.0
	div.s 	$f13, $f12, $f13	# v^^11/11
	sub.s	$f6, $f6, $f13	# value = v - v^^3/3 + v^^5/5 - v^^7/7 + v^^9/9 - v^^11/11

	mul.s	$f14, $f1, $f12	# v^^13
	l.s	$f15, thirteen	# load 13.0
	div.s 	$f15, $f14, $f15	# v^^13/13
	add.s	$f6, $f6, $f15	# value = v - v^^3/3 + v^^5/5 - v^^7/7 + v^^9/9 - v^^13/13

	mul.s	$f16, $f1, $f14	# v^^13
	l.s	$f17, fifteen	# load 13.0
	div.s 	$f17, $f16, $f17	# v^^13/13
	sub.s	$f6, $f6, $f17	# value = v - v^^3/3 + v^^5/5 - v^^7/7 + v^^9/9 - v^^13/13

	mul.s	$f18, $f1, $f16	# v^^13
	l.s	$f19, svnteen	# load 13.0
	div.s 	$f19, $f18, $f19	# v^^13/13
	add.s	$f6, $f6, $f19	# value = v - v^^3/3 + v^^5/5 - v^^7/7 + v^^9/9 - v^^13/13

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

