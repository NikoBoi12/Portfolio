/**************************************************************************//**
 *
 * @file number_builder.c
 *
 * @author Tyler Roelfs
 *
 * @brief Code to demonstrate "building" a number by polling inputs.
 *
 ******************************************************************************/
 /*
 * PollingLab assignment and starter code (c) 2021-24 Christopher A. Bohn
 * PollingLab solution (c) the above-named student(s)
 */
 #include <CowPi.h>
 #include "display.h"
 #include "number_builder.h"
 #include "io_functions.h"
 void display_overflow_message(void);
 void print_two_blank_lines(void);
 void print_number(int32_t number);
 int32_t process_digit(int32_t old_number, uint8_t digit);
 bool overflow_occurred(int32_t old_number, int32_t new_number);
 typedef enum {
    NOT_PRESSED, RESPOND_TO_PRESS, PRESSED, RESPOND_TO_RELEASE
 } input_states_t;
 void initialize_number_system(void) {
    record_build_timestamp(__FILE__, __DATE__, __TIME__);
    print_two_blank_lines();                                                // 
requirement 7
 }
 uint32_t keyPressTime;
 uint32_t buttonPressTime;
 uint8_t lastKeyPressed;
 static uint32_t number = 0;
 void build_number(void) {
    // Req 1:     left switch to left = left justified; left switch to right = 
right justified
    // Reg 2, 6:  toggling switches has well-defined behavior only when it doesn't 
require immediate attention
    // Req 3, 4:  right switch to left = decimal input
    // Req 3, 5:  right switch to right = hexadecimal input
    // Req 7:     display initially blank
    // Req 8:     decimal output on first row; hexadecimal output on second row
    // Req 9, 10: keypress illuminates right LED 500ms; buttonpress illuminates 
left LED 500ms -- note that 500ms = 500,000us
    // Req 11:    building numbers
    //        a, k                - 32-bit signed integer with overflow
    //        b, c, d, f, g, h, i - formatting
    //        e                   - left button negates
    //        j                   - right button clears display & sets number to 0
    // Req 12:    respond only once to each distinct press
    // Req 13:    responsiveness
    static input_states_t keypad_state = NOT_PRESSED;
    static input_states_t left_button_state = NOT_PRESSED;
    static input_states_t right_button_state = NOT_PRESSED;
    uint8_t isKeypadPressed = get_keypress();
    bool isRightButtonPressed = right_button_is_pressed();
    bool isLeftButtonPressed = left_button_is_pressed();
    uint32_t timeSinceLastButtonPress = 0;
    uint32_t timeSinceLastKeyPadPress = 0;
    timeSinceLastButtonPress = (get_microseconds() - buttonPressTime);
    timeSinceLastKeyPadPress = (get_microseconds() - keyPressTime);
    if (keypad_state == NOT_PRESSED ) {
        if (isKeypadPressed < 16) {
             keypad_state = RESPOND_TO_PRESS;
             lastKeyPressed = isKeypadPressed;
             keyPressTime = get_microseconds();
        }
    } else if (keypad_state == RESPOND_TO_PRESS) {
        if (overflow_occurred(number, lastKeyPressed)) {
            display_overflow_message();
        } else {
            number = process_digit(number, lastKeyPressed);
            print_number(number);
        }
        keypad_state = PRESSED;
    } else if (keypad_state == PRESSED) {
        lastKeyPressed = 0xff;
        keypad_state = NOT_PRESSED;
    } else {
        lastKeyPressed = 0xff;
        keypad_state = NOT_PRESSED;
    }
    if (right_button_state == NOT_PRESSED ) {
        if (isRightButtonPressed) {
            right_button_state = RESPOND_TO_PRESS;
            buttonPressTime = get_microseconds();
        }
    } else if (right_button_state == RESPOND_TO_PRESS) {
        right_button_state = PRESSED;
        number = 0;
        print_two_blank_lines();
    } else if (right_button_state == PRESSED) {
        right_button_state = NOT_PRESSED;
    } else {
        right_button_state = NOT_PRESSED;
    }
    if (left_button_state == NOT_PRESSED ) {
        if (isLeftButtonPressed) {
            left_button_state = RESPOND_TO_PRESS;
            buttonPressTime = get_microseconds();
        }
    } else if (left_button_state == RESPOND_TO_PRESS) {
        number = -number;
        print_number(number);
        left_button_state = PRESSED;
    } else if (left_button_state == PRESSED) {
        left_button_state = NOT_PRESSED;
    } else {
        left_button_state = NOT_PRESSED;
    }
    if (timeSinceLastButtonPress < 500000) {    
        set_left_led(true);
    } else {
        set_left_led(false);
    }
    if (timeSinceLastKeyPadPress < 500000) {
        set_right_led(true);
    } else {
        set_right_led(false);
    }
 }
 void print_two_blank_lines(void) {
    display_string(0, "");
    display_string(1, "");   
}
 void display_overflow_message(void) {
    display_string(0, "Too Big!");
    display_string(1, "Too Big!");
 }
 void print_number(int32_t number) {
    char buffer[32];
    if (left_switch_is_in_left_position()) {
        snprintf(buffer, sizeof(buffer), "%-20ld", number);
        display_string(0, buffer);
        snprintf(buffer, sizeof(buffer), "%#-20lx", (long)number);
        display_string(1, buffer);
    } else {
        snprintf(buffer, sizeof(buffer), "%20ld", number);
        display_string(0, buffer);
        snprintf(buffer, sizeof(buffer), "%#20lx", (long)number);
        display_string(1, buffer);
    }
 }
 int32_t process_digit(int32_t old_number, uint8_t digit) {
    if (right_switch_is_in_left_position()) { //Decimal
        if (digit > 9) {return old_number;}
        if (old_number < 0) {
            return (10 * old_number - digit);
        }
        return (10 * old_number + digit);
    } else { //Hex
        return (16 * old_number + digit);
    }
    return 0;
 }
 bool overflow_occurred(int32_t old_number, int32_t new_number) {
    if (right_switch_is_in_left_position()) {
        if (old_number > INT32_MAX / 10 || old_number < INT32_MIN / 10) {
            return true;
        }
        //int32_t after_multiplication = old_number * 10;
        //if ((old_number >= 0 && new_number < after_multiplication) ||
        //    (old_number <  0 && new_number > after_multiplication)) {
        //    return true;
       // }
    } else {
        if ((uint32_t)old_number < 0x10000000) {
            return false;
        }
        if (old_number > INT32_MAX / 16 || old_number < INT32_MIN / 16) {
            return true;
        }
        //int32_t after_multiplication = old_number * 16;
        //if ((old_number >= 0 && new_number < after_multiplication) ||
        //    (old_number <  0 && new_number > after_multiplication)) {
        //    return true;
        //}
    }
    return false;
 }