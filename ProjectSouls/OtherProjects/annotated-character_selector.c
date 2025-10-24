/**************************************************************************//**
 *
 * @file character_selector.c
 *
 * @author Tyler Roelfs
 *
 * @brief Functions to select the message's next character
 *
 ******************************************************************************/
 /*
 * InterruptLab (c) 2021-24 Christopher A. Bohn
 * Number Pad Texter (c) 2023-24 Christopher A. Bohn
 * Number Pad Texter / InterruptLab solution (c) the above-named student(s)
 *
 * Assignment and starter code licensed under the Apache License,
 * Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0).
 */
 #include <stdint.h>
 #include "character_selector.h"
 #include "message_editor.h"
 /* CHARACTER SELECTION ARRAYS */
 #define BLANK (-1)
 #define NO_INDEX (-1)
 const char characters[][5] = {
        {'_', '0'},
        {'.', ',', '!', '?', '1'},
        {'A', 'B', 'C', '2'},
        {'D', 'E', 'F', '3'},
        {'G', 'H', 'I', '4'},
        {'J', 'K', 'L', '5'},
        {'M', 'N', 'O', '6'},
        {'P', 'Q', 'R', 'S', '7'},
        {'T', 'U', 'V', '8'},
        {'W', 'X', 'Y', 'Z', '9'}
 };
 const int8_t key_modulus[] = {2, 5, 4, 4, 4, 4, 4, 5, 4, 5};
 volatile int8_t working_key;
 volatile int8_t character_index;
 /**
 * Initializes the character selector.
 */
 void initialize_selector(void) {
    reset_selector();
 }
 /**
 * Sets <code>working_key</code> and <code>character_index</code> to values that 
indicate that there is not yet a key
 * whose character sequence is being cycled through.
 */
 void reset_selector(void) {
    working_key = BLANK;
    character_index = NO_INDEX;
 }
 /* STUDENT CODE */
 /**
 * Advances the character selector through the sequence of characters for a numeric 
key on the keypad.
 * <ul>
 * <li> If no character sequence has yet been established, then the 
<code>key_face</code> argument will establish the
 *      sequence to cycle through, and the character selection will begin with the 
first character in
 *      <code>key_face</code>'s sequence.
 * <li> If the <code>key_face</code> argument corresponds to the sequence that has 
been cycled through, then the
 *      character selector will advance to the next character in the sequence (or 
the first in the sequence if the
 *      previous character was the last one in the sequence).
 * <li> If the <code>key_face</code> argument corresponds to a different sequence 
than that which has been cycled
 *      through, then the previous character will be finalized, and a new character 
update_displaylection will begin with the first
 *      character in <code>key_face</code>'s sequence.
 * </ul>
 * @param key_face indicates which character sequence to cycle through
 */
 void update_character(char key_face) {
    int current_button = key_face - '0';
    if (current_button >= 0 && current_button <= 9) {
        if (working_key == current_button) {
            character_index++;
            if (key_modulus[current_button] < character_index+1) {
                character_index = 0;
            }
        } else if (working_key != current_button && working_key != BLANK) {
            finalize_character();
            character_index = 0;
        } else {
            character_index = 0;
        }
        working_key = current_button;
        char character = characters[current_button][character_index];
        replace_character(character);
    }
 }
/**
 * Ends the selection of the current character, making it a permanent part of the 
message (unless later deleted)
 * and instructs the message editor to prepare for the next character selection.
 */
 void finalize_character(void) {
    if (working_key != BLANK) {
        reset_selector();
        advance_cursor();
    }
 }