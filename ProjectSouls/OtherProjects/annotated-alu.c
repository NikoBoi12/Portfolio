/**************************************************************************//**
 *
 * @file alu.c
 *
 * @author Tyler Roelfs
 *
 * @brief Functions that students must implement for IntegerLab to demonstrate
 * understanding of boolean logic and bit-limited integer arithmetic.
 *
 ******************************************************************************/
 /*
 * IntegerLab assignment and starter code (c) 2018-24 Christopher A. Bohn
 * IntegerLab solution (c) the above-named student(s)
 */
 #include "alu.h"
 /**
 * Determines whether a bit vector, when interpreted as a two's complement signed 
integer, is negative.
 * @param value the bit vector to be evaluated
 * @return 1 if the interpreted argument is less than zero; 0 otherwise
 */
 bool is_negative(uint16_t value) {
    return (value >> 15) & 1;
 }
 /**
 * Determines whether two values are equal. Two values are considered equal if 
their bit vectors are identical.
 * @param value1 the first value for the comparison
 * @param value2 the second value for the comparison
 * @return 1 if the two arguments are equal; 0 otherwise
 */
 bool equal(uint16_t value1, uint16_t value2) {
    uint16_t bit = value1 ^ value2;
    bit |= bit >> 8;
    bit |= bit >> 4;
    bit |= bit >> 2;
    bit |= bit >> 1;
    return (bit & 1) ^ 1;
 }
 /**
 * Determines whether two values are not equal. Two values are considered equal if 
their bit vectors are identical.
 * @param value1 the first value for the comparison
 * @param value2 the second value for the comparison
 * @return 0 if the two arguments are equal; 1 otherwise
 */
 bool not_equal(uint16_t value1, uint16_t value2) {
    uint16_t bit = value1 ^ value2;
    bit |= bit >> 8;
    bit |= bit >> 4;
    bit |= bit >> 2;
    bit |= bit >> 1;
    return bit & 1;
}
 /**
 * Computes the logical inverse of the argument.
 * @param value the value to be inverted; 0 is considered <code>false</code>, and 
non-zero values are considered <code>true</code>
 * @return 1 if the argument is 0; 0 otherwise
 */
 bool logical_not(uint32_t value) {
    uint32_t bit = value;
    bit |= bit >> 16;
    bit |= bit >> 8;
    bit |= bit >> 4;
    bit |= bit >> 2;
    bit |= bit >> 1;
    return (bit & 1) ^ 1;
 }
 /**
 * Computes the logical conjunction of the arguments.
 * @param value1 the first operand for the conjunction; 0 is considered 
<code>false</code>, and non-zero values are considered <code>true</code>
 * @param value2 the second operand for the conjunction; 0 is considered 
<code>false</code>, and non-zero values are considered <code>true</code>
 * @return 1 if both arguments are <code>true</code>; 0 otherwise.
 */
 bool logical_and(uint32_t value1, uint32_t value2) {
    uint32_t bit1 = value1;
    bit1 |= bit1 >> 16;
    bit1 |= bit1 >> 8;
    bit1 |= bit1 >> 4;
    bit1 |= bit1 >> 2;
    bit1 |= bit1 >> 1;
    bit1 &= 1;
    uint32_t bit2 = value2;
    bit2 |= bit2 >> 16;
    bit2 |= bit2 >> 8;
    bit2 |= bit2 >> 4;
    bit2 |= bit2 >> 2;
    bit2 |= bit2 >> 1;
    bit2 &= 1;
    return bit1 & bit2;
 }
 /**
 * Computes the logical disjunction of the arguments.
 * @param value1 the first operand for the disjunction; 0 is considered 
<code>false</code>, and non-zero values are considered <code>true</code>
 * @param value2 the second operand for the disjunction; 0 is considered 
<code>false</code>, and non-zero values are considered <code>true</code>
 * @return 1 if either (or both) argument is <code>true</code>; 0 otherwise.
 */
 bool logical_or(uint32_t value1, uint32_t value2) {
    uint32_t bit1 = value1;
    bit1 |= bit1 >> 16;
    bit1 |= bit1 >> 8;
    bit1 |= bit1 >> 4;
    bit1 |= bit1 >> 2;
    bit1 |= bit1 >> 1;
    bit1 &= 1;
    uint32_t bit2 = value2;
    bit2 |= bit2 >> 16;
    bit2 |= bit2 >> 8;
    bit2 |= bit2 >> 4;
    bit2 |= bit2 >> 2;
    bit2 |= bit2 >> 1;
    bit2 &= 1;
    return bit1 | bit2;
 }
 /**
 * Performs binary addition for one bit position.
 * Given input bits a, b, and c_in, computes sum = a + b + c, with c_out 
(carry_out) as 0 or 1 depending on whether or
 * not the full sum fits into a single bit.
 * @param bits the <code>struct</code> with the input bits
 * @return The <code>struct</code> with the output (and input) bits
 */
 one_bit_adder_t one_bit_full_addition(one_bit_adder_t bits) {
    bits.sum = bits.a ^ bits.b ^ bits.c_in; //bit sum
    bits.c_out = (bits.a & bits.b) | (bits.b & bits.c_in) | (bits.a & 
bits.c_in); //checking and returning bits
    return bits;
 }
 /**
 * Uses 32 one-bit full adders (or, equivalently, uses 1 one-bit full adder 32 
times) to add two 32-bit integers.
 * While a carry-in bit is provided for the least-significant bit, the carry-out 
bit from the most-significant bit is
 * not preserved (as it is not needed for any part of this assignment).
 * @param value1 the first number to be added
 * @param value2 the second number to be added
 * @param initial_carry_in The carry-in bit for the least-significant bit's adder
 * @return the 32-bit sum of the arguments
 */
 uint32_t reversal(uint32_t i) { //I had to take code refrences but this is my own 
original logic just refrences other places to even understand what I was doing 
wrong I spent 4 hours on this I want to die
    i = ((i >> 1) & 0x55555555) | ((i & 0x55555555) << 1);
    i = ((i >> 2) & 0x33333333) | ((i & 0x33333333) << 2);
    i = ((i >> 4) & 0x0F0F0F0F) | ((i & 0x0F0F0F0F) << 4);
    i = ((i >> 8) & 0x00FF00FF) | ((i & 0x00FF00FF) << 8);
    i = (i >> 16) | (i << 16);
    return i;
 }
 uint32_t ripple_carry_addition(uint32_t value1, uint32_t value2, uint8_t 
initial_carry_in) {
    uint8_t carry = initial_carry_in & 1;
    uint32_t sum = 0;
    uint32_t mask = 0xFFFFFFFF;
    while (mask) {
        one_bit_adder_t bits;
        bits.a = value1 & 1;
        bits.b = value2 & 1;
        bits.c_in = carry;
        bits = one_bit_full_addition(bits);
        sum = (sum << 1) | bits.sum;
        carry = bits.c_out;
        value1 >>= 1;
        value2 >>= 1;
        mask <<= 1;
    }
    return reversal(sum); // HAHAHAHAH I FINALLY DID IT 
YEAHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
 }
 /**
 * <p>Adds two 16-bit integers. The arguments are bit vectors that can be 
interpreted either as unsigned integers or as
 * signed integers. After computing the sum, this function determines whether 
overflow occurs when the bit vectors are
 * interpreted as unsigned integers, and this function also determines whether 
overflow occurs when the bit vectors are
 * interpreted as signed integers.</p>
 *
 * <p>This function does not alter the ALU's <code>supplemental_result</code> 
field, and it sets the ALU's
 * <code>divide_by_zero</code> flag to 0.</p>
 *
 * @param augend the number to be added to
 * @param addend the number to be added to the augend
 * @return the sum in the ALU's <code>result</code> field, and the 
<code>unsigned_overflow</code> and <code>signed_overflow</code> flags set 
appropriately
 */
 alu_result_t add(uint16_t augend, uint16_t addend) {
     alu_result_t result = {};
     uint32_t sumbit = ripple_carry_addition((uint32_t)augend, (uint32_t)addend, 
0);
     result.result = (uint16_t)(sumbit & 0xFFFF);
    result.unsigned_overflow = (not_equal(sumbit >> 16, 0)) ? 1 : 0;
     uint16_t aug_sign = augend >> 15;
     uint16_t add_sign = addend >> 15;
     uint16_t sum = result.result >> 15;
     result.signed_overflow = (logical_and((equal(aug_sign, add_sign)), 
(not_equal(aug_sign, sum)))) ? 1 : 0;
     result.divide_by_zero = 0;
     return result;
 }
/**
 * <p>Subtracts two 16-bit integers. The arguments are bit vectors that can be 
interpreted either as unsigned integers
 * or as signed integers. After computing the difference, this function determines 
whether overflow occurs when the bit
 * vectors are interpreted as unsigned integers, and this function also determines 
whether overflow occurs when the bit
 * vectors are interpreted as signed integers.</p>
 *
 * <p>This function does not alter the ALU's <code>supplemental_result</code> 
field, and it sets the ALU's
 * <code>divide_by_zero</code> flag to 0.</p>
 *
 * @param menuend the number to be subtracted from
 * @param subtrahend the number to be subtracted from the menuend
 * @return the difference in the ALU's <code>result</code> field, and the 
<code>unsigned_overflow</code> and <code>signed_overflow</code> flags set 
appropriately
 */
 alu_result_t subtract(uint16_t menuend, uint16_t subtrahend) {
    alu_result_t difference = {};
    uint16_t i = ~subtrahend;
    uint32_t bit32 = ripple_carry_addition((uint32_t)i, 0, 1);
    uint32_t bit = ripple_carry_addition((uint32_t)menuend, (uint32_t)bit32, 0);
    difference.result = (uint16_t)(bit & 0xFFFF);
    difference.unsigned_overflow = (not_equal(bit32 >> 16,  0)) ? 1 : 0;
    uint16_t meu = menuend >> 15;
    uint16_t sub = subtrahend >> 15;
    uint16_t diff = difference.result >> 15;
    difference.signed_overflow = (logical_and(not_equal(meu, sub), (equal(diff, 
sub)))) ? 1 : 0;
    difference.divide_by_zero = 0;
    return difference;
 }
 /**
 * Multiplies two 16-bit integers, producing a 32-bit integer. The second argument 
<i>must</i> be zero or a power of
 * two.
 * @param value the number to be multiplied
 * @param power_of_two the number that the first is to be multiplied by
 * @return the full product of the two arguments
 */
 uint32_t multiply_by_power_of_two(uint16_t value, uint16_t power_of_two) {
    if (equal(power_of_two, 0)) {
        return 0;
    }
    uint16_t shift_amount = 0;
    uint16_t temp = power_of_two;
    while (equal((temp & 1), 0)) {
        temp >>= 1;
        shift_amount = shift_amount | 1;
    }
        shift_amount <<= 1;
    shift_amount >>= 1;
    return (uint32_t)value << shift_amount;
 }
 /**
 * <p>Multiplies two 16-bit integers. The arguments are bit vectors that are 
interpreted as unsigned integers. The lower
 * 16 bits of the full product are placed in the ALU's <code>result</code> field, 
and the upper 16 bits of the full
 * product are placed in the ALU's <code>supplemental_result</code> field.</p>
 *
 * <p>This function sets the ALU's <code>divide_by_zero</code> flag to 0 but it 
does not alter the ALU's
 * <code>unsigned_overflow</code> and <code>signed_overflow</code> flags.</p>
 *
 * @param multiplicand the number to be multiplied
 * @param multiplier the number that the first is to be multiplied by
 * @return the product in the ALU's <code>result</code> and 
<code>supplemental_result</code> fields
 */
 alu_result_t unsigned_multiply(uint16_t multiplicand, uint16_t multiplier) {
    alu_result_t product = {};
    uint32_t result = 0;
    uint32_t temp = (uint32_t)multiplicand;
    while (multiplier) {
        if (multiplier & 1) {
            result = ripple_carry_addition(result, temp, 0);
        }
        temp <<= 1;
        multiplier >>= 1;
    }
    product.result = (uint16_t)(result & 0xFFFF);
    product.supplemental_result = (uint16_t)(result >> 16);
    product.divide_by_zero = 0;
    return product;
 }
 /**
 * <p>Divides two 16-bit integers. The arguments are bit vectors that are 
interpreted as unsigned integers.</p>
 *
 * <p>The divisor <i>must</i> be zero or a power of two.</p>
 *
 * <p>If the divisor is non-zero, the quotient is placed in the ALU's 
<code>result</code> field, the modulus (or
 * remainder) is placed in the ALU's <code>supplemental_result</code> field, and 
the <code>divide_by_zero</code> flag
 * is set to 0.</p>
 *
 * <p>If the divisor is zero, the ALU's <code>divide_by_zero</code> flag is set to 
1 and no guarantees are made about
 * the contents of the <code>result</code> and <code>supplemental_result</code> 
fields.</p>
 *
 * <p>Regardless, the ALU's <code>unsigned_overflow</code> and 
<code>signed_overflow</code> flags are not altered.</p>
 *
 * @param dividend the number to be divided
 * @param divisor the number that divides the first
 * @return the ALU's <code>divide_by_zero</code> flag set appropriately, and the 
quotient in the ALU's <code>result</code> field and the remainder in the 
<code>supplemental_result</code> field when these are mathematically defined
 */
 alu_result_t unsigned_divide(uint16_t dividend, uint16_t divisor) {
    alu_result_t quotient = {};
    if (equal(divisor, 0)) {
        quotient.divide_by_zero = 1;
        return quotient;
    }
    uint16_t temp = divisor;
    uint16_t amount = 0;
    while (equal((temp & 1), 0)) {
        temp >>= 1;
        amount = ripple_carry_addition(amount, 1, 0);
    }
    if (not_equal(temp, 1)) {
        quotient.result = 0;
        quotient.supplemental_result = dividend;
        quotient.divide_by_zero = 0;
        return quotient;
    }
    quotient.result = dividend >> amount;
    quotient.supplemental_result = dividend & (divisor - 1);
    quotient.divide_by_zero = 0;
    return quotient;
 }
 /*
 * SIGNED_MULTIPLY AND SIGNED_DIVIDE ARE FOR BONUS CREDIT.
 * YOU ARE NOT REQUIRED AT ATTEMPT THEM.
 */
 /**
 * <p>Multiplies two 16-bit integers. The arguments are bit vectors that are 
interpreted as signed integers. The lower
 * 16 bits of the full product are placed in the ALU's <code>result</code> field, 
and the upper 16 bits of the full
 * product are placed in the ALU's <code>supplemental_result</code> field.</p>
 *
 * <p>This function sets the ALU's <code>divide_by_zero</code> flag to 0 but it 
does not alter the ALU's
 * <code>unsigned_overflow</code> and <code>signed_overflow</code> flags.</p>
 *
 * @param multiplicand the number to be multiplied
 * @param multiplier the number that the first is to be multiplied by
 * @return the product in the ALU's <code>result</code> and 
<code>supplemental_result</code> fields
 */
 alu_result_t signed_multiply(uint16_t multiplicand, uint16_t multiplier) {
    alu_result_t product = {};      // empty initializer to suppress uninitialized 
variable warning in the starter code
    return product;
 }
 /**
 * <p>Divides two 16-bit integers. The arguments are bit vectors that are 
interpreted as signed integers.</p>
 *
 * <p>The divisor <i>must</i> be zero or a power of two.</p>
 *
 * <p>If the divisor is non-zero, the quotient is placed in the ALU's 
<code>result</code> field, the modulus (or
 * remainder) is placed in the ALU's <code>supplemental_result</code> field, and 
the <code>divide_by_zero</code> flag
 * is set to 0.</p>
 *
 * <p>If the divisor is zero, the ALU's <code>divide_by_zero</code> flag is set to 
1 and no guarantees are made about
 * the contents of the <code>result</code> and <code>supplemental_result</code> 
fields.</p>
 *
 * <p>Regardless, the ALU's <code>unsigned_overflow</code> and 
<code>signed_overflow</code> flags are not altered.</p>
 *
 * @param dividend the number to be divided
 * @param divisor the number that divides the first
 * @return the ALU's <code>divide_by_zero</code> flag set appropriately, and the 
quotient in the ALU's <code>result</code> field and the remainder in the 
<code>supplemental_result</code> field when these are mathematically defined
 */
 alu_result_t signed_divide(uint16_t dividend, uint16_t divisor) {
    alu_result_t quotient = {};     // empty initializer to suppress uninitialized 
variable warning in the starter code
    return quotient;
 }