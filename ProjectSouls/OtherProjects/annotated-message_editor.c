/**************************************************************************//**
 *
 * @file message_editor.c
 *
 * @author Tyler Roelfs
 *
 * @brief The message buffer, and functions to manage the user's message.
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
 #include "message_editor.h"
 #include "character_selector.h"
 #include "outputs.h"
 #define BUFFER_LENGTH (25)
 #define DISPLAY_WIDTH (16)
 volatile char message[BUFFER_LENGTH] = {0};
 volatile char *display_start;
 volatile int8_t message_index;
 void reset_message(void);
 /**
 * Initializes the message editor.
 */
 void initialize_editor(void) {
    reset_message();
 }
 /**
 * Resets the message to an empty string.
 */
 void reset_message(void) {
    message_index = 0;
    message[message_index] = '\0';
    message[message_index + 1] = '\0';
    display_start = message;
 }
 /* STUDENT CODE */
 /**
 * Replaces the character at <code>message_index</code> with a new character.
 * @param c the character that should replace the character at 
<code>message_index</code>
 */
 void replace_character(char c) {
    if (message_index < BUFFER_LENGTH - 1) {
        message[message_index] = c;
        /* DO NOT MODIFY THIS CODE */
        disable_pin_interrupts();       // disable pin interrupts, so we don't have 
to worry about the message changing
        update_display((const char *) display_start,
                       (int8_t) (message_index < DISPLAY_WIDTH ? message_index : 
(DISPLAY_WIDTH - 1)));
        enable_pin_interrupts();        // re-enable pin interrupts
    }
 }
 /**
 * Removes the last character from the message.
 * If the cursor is under a character being selected, then that is the character 
that is deleted.
 * If the cursor is under a blank, then the last character that was finalized is 
the character that is deleted.
 */
 void delete_character(void) {
    if (message[message_index] == '\0' && message_index != 0) {
        retreat_cursor();
    }
    replace_character('\0');
    reset_selector();
    /* DO NOT MODIFY THIS CODE */
    disable_pin_interrupts();
    update_display((const char *) display_start,
                   (int8_t) (message_index < DISPLAY_WIDTH ? message_index : 
(DISPLAY_WIDTH - 1)));
    enable_pin_interrupts();
 }
 /**
 * Increments <code>message_index</code>, moving the cursor forward one position.
 */
 void advance_cursor(void) {
    if (message_index < BUFFER_LENGTH - 1) {
        message_index++;
        if (message_index >= DISPLAY_WIDTH) {
            display_start = &message[message_index - DISPLAY_WIDTH + 1];
        } else {
            display_start = message;
        }
        /* DO NOT MODIFY THIS CODE */
        disable_pin_interrupts();
        update_display((const char *) display_start,
                       (int8_t)(message_index < DISPLAY_WIDTH ? message_index : 
(DISPLAY_WIDTH - 1)));
        enable_pin_interrupts();
    }
 }
 /**
 * Decrements <code>message_index</code>, moving the cursor back one position.
 */
 void retreat_cursor(void) {
    if (message_index > 0) {
        message_index--;
        if (message_index >= DISPLAY_WIDTH) {
            display_start = &message[message_index - DISPLAY_WIDTH + 1];
        } else {
            display_start = message;
        }
        /* DO NOT MODIFY THIS CODE */
        disable_pin_interrupts();
        update_display((const char *) display_start,
                       (int8_t)(message_index < DISPLAY_WIDTH ? message_index : 
(DISPLAY_WIDTH - 1)));
        enable_pin_interrupts();
    }
 }
 /**
 * Sends the message to the outputs module to be "transmitted" and resets the 
message editor.
 */
 void send_message_to_output(void) {
    /* YOU MIGHT HAVE CODE ABOVE THIS COMMENT */
    disable_pin_interrupts();   // disable pin interrupts, so we don't have to 
worry about the message changing during the transmission
    /* YOU MIGHT HAVE CODE BETWEEN THIS COMMENT AND THE NEXT COMMENT */
    transmit_message((char *)message, message_index);
    reset_message();
    //transmit_message((const char *) message, message_index);
    /* YOU MIGHT HAVE CODE BETWEEN THIS COMMENT AND THE PREVIOUS COMMENT */
    update_display((const char *) message, message_index);
    enable_pin_interrupts();
 }