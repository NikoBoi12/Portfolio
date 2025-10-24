/**************************************************************************//**
 *
 * @file basetwo.c
 *
 * @author Tyler Roelfs
 *
 * @brief Functions that students must implement for IntegerLab to demonstrate
 * understanding of base two exponentiation and logarithms.
 *
 ******************************************************************************/
 /*
 * IntegerLab assignment and starter code (c) 2018-22 Christopher A. Bohn
 * IntegerLab solution (c) the above-named student(s)
 */
 #include "alu.h"
 /**
 * Computes a power of two, specifically, the value of 2 raised to the power of 
<code>exponent</code>.
 * foo == exponentiate(bar) \<--> bar == lg(foo). The exponent must be a non
negative value strictly less than 32.
 * @param exponent the exponent to which 2 will be raised
 * @return 2 raised to the power of <code>exponent</code>
 */
 uint32_t exponentiate(int exponent) {
    if (exponent >> 5) { return 0; }
     return 1 << (exponent & 0x1F);;
 }
 /**
 * Determines the base-two logarithm of an integer that is a power of two.
 * foo == exponentiate(bar) \<--> bar == lg(foo). The argument must be a positive 
power of two.
 * @param power_of_two the value whose logarithm will be determined
 * @return base-2 logarithm of the argument
 */
 int lg(uint32_t power_of_two) {
    int i = 0;
    if (power_of_two >> 16) {
        i |= 16;
        power_of_two >>= 16;
    }
    if (power_of_two >> 8) {
        i |= 8;
        power_of_two >>= 8;
    }
    if (power_of_two >> 4) {
        i |= 4;
        power_of_two >>= 4;
    }
    if (power_of_two >> 2) {
        i |= 2;
        power_of_two >>= 2;
    }
    if (power_of_two >> 1) {
        i |= 1;
    }
    return i;
 }