.text

## int convert_highest_bit_to_int(int domain) {
##   int result = 0;
##   for (; domain; domain >>= 1) {
##     result ++;
##   }
##   return result;
## }

.globl convert_highest_bit_to_int
convert_highest_bit_to_int:
    move  $v0, $0   	      # result = 0

chbti_loop:
    beq   $a0, $0, chbti_end
    add   $v0, $v0, 1         # result ++
    sra   $a0, $a0, 1         # domain >>= 1
    j     chbti_loop

chbti_end:
    jr	  $ra
