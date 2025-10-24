
/**************************************************************************//**
 *
 * @file problem3.c
 *
 * @author Tyler Roelfs
 *
 * @brief Functions that students must implement for KeyboardLab to demonstrate
 *      understanding of integer bit representation and of bit operations
 *      (bitwise AND, bitwise OR, left-shift, and right-shift).
 *
 ******************************************************************************/
 /*
 * KeyboardLab assignment and starter code (c) 2021-23 Christopher A. Bohn
 * KeyboardLab solution (c) the above-named student(s)
 */
 #include <stdio.h>
 #include <math.h>
 /**
 * Determines whether or not a value is even, without using addition (+),
 * subtraction (-), division (/), or modulo (%)
 *
 * @param value the value to be evaluated
 * @return 1 if the argument is an even value, 0 otherwise
 */
 int is_even(int value) {
    /* WRITE THIS FUNCTION */
    return !(value & 1);
 }
 /**
 * Outputs a multiple of 10 by repeatedly applying a formula:
 * - if a number is negative then set it to 0
 * - if a positive number is even then divide it by 2
 * - if a positive number is odd then subtract 1 and
 *      multiply the difference by 5
 *
 * @note This formula is computed without without using addition (+),
 *      subtraction (-), division (/), or modulo (%).
 * @note This formula is computed without using the literal number 5,
 *      or a binary literal (i.e., 0b101)
 *
 * @param seed the initial number
 * @return the computed multiple of 10
 */
 int produce_multiple_of_ten(int seed) {
    int value = seed > 0 ? seed : 0;
    int position_of_last_digit = value > 0 ? (int) log10(value) : 0;
    char value_text[33];
    sprintf(value_text, "%d", value);
    while (value_text[position_of_last_digit] != '0') {
        int unmodified_value = value;
        if (is_even(value)) {
            /* DIVIDE BY TWO WITHOUT USING DIVISION */
            value >>= 1;
        } else {
            /* CREATE A BITMASK YOU CAN USE TO REDUCE AN ODD NUMBER'S VALUE 1 AS 
SUGGESTED IN THE ASSIGNMENT */
            int deduct_one_mask = 0xFFFFFFFE;
            /* USE THAT BITMASK TO REDUCE THE ODD-NUMBERED value BY ONE */
            /* REPLACE `;;;` WITH A SUITABLE BITWISE OPERATION */
            int difference = value & deduct_one_mask;
            /* CREATE THE VALUE 5 */
            /* REPLACE `;;;` WITH A SUITABLE BITWISE OPERATION */
            int five = (1 << 2) + (1 << 0); // 4 + 1 = 5
            /* DO NOT MODIFY THE NEXT LINE */
            value = difference * five;
        }
        if (value == unmodified_value) {
            fprintf(stderr, "Infinite loop in your produce_multiples_of_ten()!\n");
            value_text[position_of_last_digit] = '0';
        } else {
            position_of_last_digit = value > 0 ? (int) log10(value) : 0;
            sprintf(value_text, "%d", value);
        }
    }
    return value;
 }