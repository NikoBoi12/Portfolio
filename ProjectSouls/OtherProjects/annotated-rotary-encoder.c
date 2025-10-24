/**************************************************************************//**
 *
 * @file rotary-encoder.c
 *
 * @author Tyler Roelfs
 *
 * @brief Code to determine the direction that a rotary encoder is turning.
 *
 ******************************************************************************/
 /*
 * ComboLock GroupLab assignment and starter code (c) 2022-24 Christopher A. Bohn
 * ComboLock solution (c) the above-named students
 */
 #include <CowPi.h>
 #include "interrupt_support.h"
 #include "rotary-encoder.h"
 #define A_WIPER_PIN         (16)
 #define B_WIPER_PIN         (A_WIPER_PIN + 1)
 typedef enum {
    HIGH_HIGH, HIGH_LOW, LOW_LOW, LOW_HIGH, UNKNOWN
 } rotation_state_t;
 static rotation_state_t volatile state;
 static direction_t volatile direction = STATIONARY;
 static int volatile clockwise_count = 0;
 static int volatile counterclockwise_count = 0;
 static cowpi_ioport_t volatile *ioport = (cowpi_ioport_t *) (0xD0000000);
 static void handle_quadrature_interrupt();
 static cowpi_ioport_t volatile *ioport;
 void initialize_rotary_encoder() {
    cowpi_set_pullup_input_pins((1 << A_WIPER_PIN) | (1 << B_WIPER_PIN));
    state = HIGH_HIGH;
    register_pin_ISR((1 << A_WIPER_PIN) | (1 << B_WIPER_PIN), 
handle_quadrature_interrupt);
 }
 uint8_t get_quadrature() {
    uint8_t quadrature = ((ioport->input & (3 << A_WIPER_PIN)) >> A_WIPER_PIN);
    return quadrature;
 }
 char *count_rotations(char *buffer) {
    sprintf(buffer, "CW:%-5dCCW:%-5d", clockwise_count, counterclockwise_count);
    return buffer;
 }
 direction_t get_direction() {
    direction_t newDirection = direction;
    direction = STATIONARY;
    return newDirection;
 }
 static void handle_quadrature_interrupt() {
    static rotation_state_t last_state = UNKNOWN;
    rotation_state_t newState = state;
    uint8_t quadrature = get_quadrature();
    if (state == HIGH_HIGH) {
        if (quadrature == 0b10) {
            newState = HIGH_LOW;
        } else if (quadrature == 0b01) {
            newState = LOW_HIGH;
        }
    } else if (state == HIGH_LOW) {
        if (quadrature == 0b00 && last_state == HIGH_HIGH) {
            direction = CLOCKWISE;
            clockwise_count++;
            newState = LOW_LOW;
        } else if (quadrature == 0b11) {
            newState = HIGH_HIGH;
        }
    } else if (state == LOW_LOW) {
        if (quadrature == 0b01) {
            newState = LOW_HIGH;
        } else if (quadrature == 0b10) {
            newState = HIGH_LOW;
        }
    } else if (state == LOW_HIGH) {
        if (quadrature == 0b11) {
            newState = HIGH_HIGH;
        } else if (quadrature == 0b00 && last_state == HIGH_HIGH) {
            direction = COUNTERCLOCKWISE;
            counterclockwise_count++;
            newState = LOW_LOW;
        }
    }
    last_state = state;
    state = newState;
 }