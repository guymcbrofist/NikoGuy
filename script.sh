#!/bin/bash
cat spimbot.s > main.s
cat movexy.s >> main.s
cat taylor.s >> main.s
#cat convert_highest_bit_to_int.s >> main.s
#cat get_domain_for_addition.s >> main.s
cat get_unassigned_position.s >> main.s
cat is_complete.s >> main.s
cat forward_checking.s >> main.s
#cat get_domain_for_subtraction.s >> main.s
#cat is_single_value_domain.s >> main.s
cat recursive_backtracking.s >> main.s
cat helper_functions.s >> main.s
cat interrupthandler.s >> main.s
