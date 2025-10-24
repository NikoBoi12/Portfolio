/**************************************************************************//**
 *
 * @file word_entry.c
 *
 * @author Tyler Roelfs
 *
 * @brief Structure definition and function prototypes for word entries to be
 *      used in lists for the "challenge/response" application.
 *
 ******************************************************************************/
 /*
 * LinkedListLab assignment and starter code (c) 2021-25 Christopher A. Bohn
 * LinkedListLab solution (c) the above-named student(s)
 */
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
 #include "word_entry.h"
 /**
 * Creates a `word_entry_t` that holds a copy of the word, with the number of
 * `occurrences` initially set to 0.
 *
 * @param word the word to be stored in the word entry
 * @return a pointer to the `word_entry_t` that has been created
 */
 word_entry_t *create_word_entry(char const *word) {
    word_entry_t *word_entry = malloc(sizeof(word_entry_t));
    if (!word_entry) {
        fprintf(stderr, "Failed to allocate space for new word_entry for %s. 
Returning NULL!\n", word);
    } else {
        word_entry->word = malloc(strlen(word) + 1);
        strcpy(word_entry->word, word)
        word_entry->occurrences = 0;
    }
    return word_entry;
 }
 /**
 * Releases any memory held by a `word_entry_t`.
 *
 * @param word_entry the word entry to be released
 */
 void delete_word_entry(word_entry_t *word_entry) {
    free(word_entry);
 }
 /**
 * Increases the number of occurrences of a word, stored in a `word_entry_t`.
 *
 * @param word_entry the word entry whose `occurrences` should be incremented
 */
 void increment_count(word_entry_t *word_entry) {
    if (word_entry) {
        word_entry->occurrences += 1;
    }
}
 /**
 * Obtain the number of occurrences of a word, stored in a `word_entry_t`.
 *
 * @param word_entry the `word_entry_t` to be examined
 * @return the number of occurrences
 */
 int get_count(word_entry_t const *word_entry) {
    return word_entry->occurrences;
 }
 /**
 * Obtain the word that is stored in a `word_entry_t`.
 *
 * @param word_entry the `word_entry_t` to be examined
 * @return the word
 */
 char const *get_word(word_entry_t const *word_entry) {
    return word_entry->word;
 }
 /**
 * Create a printable representation of a `word_entry_t`
 *
 * @param destination a `char` array with at least 61 bytes allocated
 * @param word_entry the word entry to be converted to a string
 * @return the `destination` array, with the string representation
 */
 char *word_entry_to_string(char *destination, word_entry_t const *word_entry) {
    if (word_entry == NULL) {
        sprintf(destination, "%7s : %s", "NULL", "NULL");
    } else {
        sprintf(destination, "%7d : %s", word_entry->occurrences, word_entry
>word);
    }
    return destination;
 }