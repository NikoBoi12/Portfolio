/**************************************************************************//**
 *
 * @file problem1.c
 *
 * @author Tyler Roelfs
 *
 * @brief Function that students must implement for KeyboardLab to demonstrate
 *      understanding that integers can be used as characters.
 *
 ******************************************************************************/
 /*
 * KeyboardLab assignment and starter code (c) 2021-23 Christopher A. Bohn
 * KeyboardLab solution (c) the above-named student(s)
 */
 #include <stdio.h>
 #include <string.h>
 /**
 * Generates a string as though using the following lines of code,
 * but does so without using the W key or the backslash key.
 *
 * @code
 *     snprintf(destination, destination_size, "%s",
 *              "TO\tArchie\n"
 *              "RE\tI Need a Working Keyboard\n"
 *              "\n"
 *              "Please order a new keyboard for me. This one is broken.\n");
 *     return destination;
 * @endcode
 *
 * @param destination a pointer to the memory location that the string should be 
placed in
 * @param destination_size a lower bound on the memory allocated for 
<code>destination</code>
 * @return a pointer to the start of the string
 */
 char *generate_email(char *destination, size_t destination_size) {
    /* WRITE THIS FUNCTION */
    snprintf(destination, destination_size, "TO%cArchie%cRE%cI Need a %corking 
Keyboard%c%cPlease order a ne%c keyboard for me. This one is broken.%c", 0x09, 
0x0A, 0x09, 0x57, 0x0A, 0x0A, 0x77, 0x0A);
    return destination;
 }