/**************************************************************************//**
 *
 * @file lock-controller.c
 *
 * @author Tyler Roelfs
 *
 * @brief Code to implement the "combination lock" mode.
 *
 ******************************************************************************/
 /*
 * ComboLock GroupLab assignment and starter code (c) 2022-24 Christopher A. Bohn
 * ComboLock solution (c) the above-named students
 */
 #include <CowPi.h>
 #include "display.h"
 #include "lock-controller.h"
 #include "rotary-encoder.h"
 #include "servomotor.h"
 static uint8_t combination[3] __attribute__((section (".uninitialized_ram.")));
 uint8_t const *get_combination() {
    return combination;
 }
 void force_combination_reset() {
    combination[0] = 5;
    combination[1] = 10;
    combination[2] = 15;
 }
 void initialize_lock_controller() {
    force_combination_reset();
    ;
 }
 static int currentNum = 0;
 static int position = 0;
 static int combo[3] = {-1, -1, -1};
 static bool isLocked = true;
 static int cycle = 0;
 static bool test = false;
 static int i = 0;
 void reset_lock() {
    position = 0;
    combo[0] = -1;
    combo[1] = -1;
    combo[2] = -1;
    currentNum = 0;
    cycle = 0;
 }
void control_lock() {
    if (cycle == 3) {
        reset_lock();
    }
    if (isLocked) {
        cowpi_deluminate_right_led();
        cowpi_illuminate_left_led();
        rotate_full_clockwise();
    } else {
        rotate_full_counterclockwise();
        cowpi_illuminate_right_led();
        cowpi_illuminate_left_led();
        if (test) {
            if (i == 10) {
                test = false;
                i = 0;
            }
            i++;
            rotate_full_clockwise();
        } else {
            if (i == 10) {
                test = true;
                i = 0;
            }
            i++;
            rotate_full_counterclockwise();
        }
    }
    combo[position] = currentNum;
    char buffer[32];
    char first[3], second[3], third[3];
    if (combo[0] != -1)
        sprintf(first, "%02d", combo[0]);
    else
        sprintf(first, "  ");
    if (combo[1] != -1)
        sprintf(second, "%02d", combo[1]);
    else
        sprintf(second, "  ");
    if (combo[2] != -1)
        sprintf(third, "%02d", combo[2]);
    else
        sprintf(third, "  ");
    sprintf(buffer, "%s-%s-%s", first, second, third);
    display_string(3, buffer);
    int direction = get_direction();
    if (position == 0) {
        if (direction == COUNTERCLOCKWISE) {
            position = 1;
            cycle = 0;
        } else if (direction == CLOCKWISE) {
            if (currentNum + 1 == 16) {
                cycle++;
                currentNum = 0;
            } else {
                currentNum = currentNum + 1;
            }
        }
    } else if (position == 1) {
        if (direction == CLOCKWISE) {
            position = 2;
            cycle = 0;
        } else if (direction == COUNTERCLOCKWISE) {
            if (currentNum - 1 == -1) {
                currentNum = 15;
                cycle++;
            } else {
                currentNum = currentNum - 1;
            }
        }
    } else if (position == 2) {
        if (direction == COUNTERCLOCKWISE) {
            reset_lock();
        } else if (direction == CLOCKWISE) {
            if (currentNum + 1 == 16) {
                cycle++;
                currentNum = 0;
            } else {
                currentNum = currentNum + 1;
            }
        }
    }
    if (cowpi_left_button_is_pressed()) {
        if (
            combo[0] == get_combination()[0] &&
            combo[1] == get_combination()[1] &&
            combo[2] == get_combination()[2]
        ) {
            isLocked = false;
        } else {
            reset_lock();
        }
    }
 }