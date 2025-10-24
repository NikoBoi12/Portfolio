/**************************************************************************//**
 *
 * @file poker.c
 *
 * @author Tyler Roelfs
 *
 * @brief Functions to populate a standard 52-card deck and to print that deck.
 *      Functions to characterize a poker hand.
 *
 ******************************************************************************/
 /*
 * PokerLab assignment and starter code (c) 2018-23 Christopher A. Bohn
 * PokerLab solution (c) the above-named student
 */
 #include <stdlib.h>
 #include <stdio.h>
 #include "card.h"
 #include "poker.h"
 card_t deck[NUMBER_OF_CARDS];           // a "deck" of 52 cards
 int deck_is_populated = 0;
 /**
 * Places the 52 standard `card_t`s in `deck`.
 *
 * @post There are 52 distinct `card_t`s in `deck`.
 * @post `deck_is_populated == 1`.
 */
 void populate_deck(void) {
    deck_is_populated = 1;
    /* ADD CODE HERE TO PLACE THE 52 STANDARD CARDS IN DECK[] */
    int suit;
    int rank;
    int i = 0;
    for (suit = 0; suit < 4; ++suit) {
        for (rank = 1; rank < 14; ++rank) {
            create_card(rank, suit, &deck[i]);
            i++;
        }
    }
 }
 /**
 * Prints all 52 cars in the deck, in order.
 */
 void print_deck(void) {
    if (!deck_is_populated) {
        populate_deck();
    }
    char *s = malloc(21);
    for (int i = 0; i < NUMBER_OF_CARDS; i++) {
        printf("deck[%02d] is the %s\n", i, card_to_string(deck + i, s));
    }
}
    free(s);
 /**
 * Sorts an array of `card_t`s in-place from the least value to the greatest value.
 *
 * @post The subdeck has its initial `card_t`s, sorted from the least value to the 
greatest value.
 * 
 * @param subdeck the `card_t`s to be sorted; it might not be the full deck
 * @param size the number of cards in the subdeck
 * @return the sorted array of `card_t`s, in the same array passed as `subdeck`
 */
 card_t *sort(card_t *subdeck, int size) {
    for (int i = 0; i < size - 1; i++) {
        for (int j = i + 1; j < size; j++) {
            if (subdeck[i].value > subdeck[j].value) {
                card_t swap_card = subdeck[i];
                subdeck[i] = subdeck[j];
                subdeck[j] = swap_card;
            }
        }
    }
    return subdeck;
 }
 /**
 * Randomly selects `size_of_hand` `card_t`s and returns them sorted from the
 *      least value to the greatest value.
 *
 * @pre The destination must have space for at least `size_of_hand` `card_t`s.
 * @post The destination has `size_of_hand` `card_t`s, sorted from the least value 
to the greatest value.
 *
 * @param destination an array to hold the hand
 * @param size_of_hand the number of `card_t`s to be placed in the hand
 * @return the `destination` pointer
 */
 card_t *get_random_hand(card_t *destination, int size_of_hand) {
    if (!deck_is_populated) {
        populate_deck();
    }
    for (int i = 0; i < size_of_hand; i++) {
        int selection = rand() % 52;
        destination[i] = deck[selection];       // if this were more robust, we'd 
check for duplicates
    }
    return sort(destination, size_of_hand);
 }
 /**
 * Populates an array of `card_t`s whose indices in `deck` correspond to the
 *      elements in the `indices` argument, sorted from the least value to the
 *      greatest value.
 *
 * @pre The destination must have space for at least `size_of_hand` `card_t`s.
 * @post The destination has `size_of_hand` `card_t`s, sorted from the least value 
to the greatest value.
 *
 * @param destination an array to hold the hand
 * @param indices specifies which `card_t`s from `deck` are to be placed in the
 *      hand.
 * @param size_of_hand the number of `card_t`s to be placed in the hand
 * @return the `destination` pointer
 */
 card_t *get_specific_hand(card_t *destination, int const *indices, int 
size_of_hand) {
    if (!deck_is_populated) {
        populate_deck();
    }
    for (int i = 0; i < size_of_hand; i++) {
        destination[i] = deck[indices[i]];
    }
    return sort(destination, size_of_hand);
 }
 /**
 * Returns 1 if two of the `card_t`s in `hand` have the same value; returns 0
 *      otherwise.
 *
 * @pre `hand` must be sorted from the least value to the greatest value.
 * @note `size_of_hand` does *not* need to be 5.
 *
 * @param hand the `card_t`s to be assessed
 * @param size_of_hand the number of `card_t`s in the hand
 * @return 1 if and only if `hand` contains a "pair"
 */
 int is_pair(card_t const *hand, int size_of_hand) {
    /* STUDY THIS CODE.  WHY DOES IT PRODUCE THE INTENDED RESULT? */
    int pair = 0;
    for (int i = 0; i < size_of_hand - 1; i++) {
        pair = pair ||
               (hand[i].value == hand[i + 1].value);    // because hand is sorted, 
a pair must be two adjacent cards
    }
    return pair;
 }
 /**
 * Returns 1 if two of the `card_t`s in `hand` are a pair and two other are also
 *      a pair; returns 0 otherwise. "hand" must be sorted from the least value
 *      to the greatest value.
 *
 * @pre `hand` must be sorted from the least value to the greatest value.
 * @note `size_of_hand` does *not* need to be 5.
 *
 * @param hand the `card_t`s to be assessed
 * @param size_of_hand the number of `card_t`s in the hand
 * @return 1 if and only if `hand` contains "two pair"
 */
 int is_two_pair(card_t const *hand, int size_of_hand) {
    int number_of_pairs = 0;
    card_t const *partial_hand;
    int i = 0;
    while (i < size_of_hand - 1) {  /* RECALL THAT ARRAYS ARE POINTERS */
        partial_hand = hand + i;    /* THIS IS CHANGING THE ADDRESS IN THE 
`PARTIAL_HAND` POINTER TO ANOTHER PART OF THE ARRAY */
        if (is_pair(partial_hand, 2)) {
            number_of_pairs++;
            i += 2;
        } else {
            i++;
        }
    }
    return (number_of_pairs == 2);
 }
 /**
 * Returns 1 if three of the `card_t`s in `hand` have the same value; returns 0
 *      otherwise.
 *
 * @pre `hand` must be sorted from the least value to the greatest value.
 * @note `size_of_hand` does *not* need to be 5.
 *
 * @param hand the `card_t`s to be assessed
 * @param size_of_hand the number of `card_t`s in the hand
 * @return 1 if and only if `hand` contains "three of a kind"
 */
 int is_three_of_kind(card_t const *hand, int size_of_hand) {
    int threeOfKind = 1;
    suit_t suit = hand[0].suit;
    for (int i = 1; i < 3; i++) {
        threeOfKind = threeOfKind && (hand[i].suit == suit);
    }
    return threeOfKind;
 }
 /**
 * Returns 1 if the `card_t`s have contiguous values; returns 0 otherwise.
 *
 * @pre `hand` must be sorted from the least value to the greatest value.
 * @note `size_of_hand` does *not* need to be 5.
 *
 * @param hand the `card_t`s to be assessed
 * @param size_of_hand the number of `card_t`s in the hand
 * @return 1 if and only if `hand` contains a "straight"
 */
 int is_straight(card_t const *hand, int size_of_hand) {
    /* STUDY THIS CODE.  WHY DOES IT PRODUCE THE INTENDED RESULT? */
    int not_straight = 0;
    for (int i = 0; i < size_of_hand - 1; i++) {
        not_straight = not_straight + abs(hand[i + 1].value - hand[i].value - 1);
    }
    return !not_straight;
 }
 /**
 * Returns 1 if the `card_t`s all have the same suit; returns 0 otherwise.
 *
 * @pre `size_of_hand` does *not* need to be 5.
 *
 * @param hand the `card_t`s to be assessed
 * @param size_of_hand the number of `card_t`s in the hand
 * @return 1 if and only if `hand` contains a "flush"
 */
 int is_flush(card_t const *hand, int size_of_hand) {
    /* STUDY THIS CODE.  WHY DOES IT PRODUCE THE INTENDED RESULT? */
    int flush = 1;
    suit_t suit = hand[0].suit;
    for (int i = 1; i < size_of_hand; i++) {
        flush = flush && (hand[i].suit == suit);
    }
    return flush;
 }
 /**
 * Returns 1 if three of the `card_t`s in `hand` are three of a kind and another
 *      two are a pair; returns 0 otherwise.
 *
 * @pre `hand` must be sorted from the least value to the greatest value.
 * @note `size_of_hand` does *not* need to be 5.
 *
 * @param hand the `card_t`s to be assessed
 * @param size_of_hand the number of `card_t`s in the hand
 * @return 1 if and only if `hand` contains a "full house"
 */
 int is_full_house(card_t const *hand, int size_of_hand) {
    int number_of_pairs = 0;
    card_t const *partial_hand;
    int i = 0;
    while (i < size_of_hand - 2) {  /* RECALL THAT ARRAYS ARE POINTERS */
        partial_hand = hand + i;    /* THIS IS CHANGING THE ADDRESS IN THE 
`PARTIAL_HAND` POINTER TO ANOTHER PART OF THE ARRAY */
        if (is_full_house(partial_hand, 1)) {
            number_of_pairs++;
            i += 2;
        } else {
            i++;
        }
    }
    return (number_of_pairs == 2 && is_pair(hand, size_of_hand));
 }
 /**
 * Returns 1 if four of the `card_t`s in `hand` have the same value; returns 0
 *      otherwise.
 *
 * @pre `hand` must be sorted from the least value to the greatest value.
 * @note `size_of_hand` does *not* need to be 5.
 *
 * @param hand the `card_t`s to be assessed
 * @param size_of_hand the number of `card_t`s in the hand
 * @return 1 if and only if `hand` contains "four of a kind"
 */
 int is_four_of_kind(card_t const *hand, int size_of_hand) {
    int fourOfKind = 1;
    suit_t suit = hand[0].suit;
    for (int i = 1; i < 4; i++) {
        fourOfKind = fourOfKind && (hand[i].suit == suit);
    }
    return fourOfKind;
 }
 /**
 * Returns 1 if the `card_t`s in `hand` are both a straight and a flush; returns
 *      0 otherwise.
 *
 * @pre `hand` must be sorted from the least value to the greatest value.
 * @note `size_of_hand` does *not* need to be 5.
 *
 * @param hand the `card_t`s to be assessed
 * @param size_of_hand the number of `card_t`s in the hand
 * @return 1 if and only if `hand` contains a "straight flush"
 */
 int is_straight_flush(card_t const *hand, int size_of_hand) {
    return is_straight(hand, size_of_hand) && is_flush(hand, size_of_hand);
 }
 /**
 * Prints the `hand` and characterizes it in the best possible way.
 *
 * @pre `hand` must be sorted from the least value to the greatest value.
 * @note `size_of_hand` does *not* need to be 5.
 *
 * @param hand the `card_t`s to be assessed
 * @param size_of_hand the number of `card_t`s in the hand
 */
 void characterize_hand(card_t const *hand, int size_of_hand) {
    /* WRITE THIS FUNCTION */
    char *s = malloc(21);
    int i;
    for (i = 0; i < size_of_hand; i++) {
        printf("%s ", card_to_string(&hand[i], s), "\n");
    }
    if (is_straight_flush(hand, size_of_hand)) {
        printf("straight flush.\n");
    } else if (is_full_house(hand, size_of_hand)) {
        printf("full house.\n");
    } else if (is_flush(hand, size_of_hand)) {
        printf("flush.\n");
    } else if (is_straight(hand, size_of_hand)) {
        printf("straight.\n");
    } else if (is_three_of_kind(hand, size_of_hand)) {
        printf("three of a kind.\n");
    } else if (is_two_pair(hand, size_of_hand)) {
        printf("two pair.\n");
    } else if (is_pair(hand, size_of_hand)) {
        printf("pair.\n");
    } else {
        printf("high card.\n");
    }
 }