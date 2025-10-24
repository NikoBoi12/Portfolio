/**************************************************************************//**
 *
 * @file sorted_word_entries.c
 *
 * @author Tyler Roelfs
 *
 * @brief Functions for a sorted list of word entries.
 *
 ******************************************************************************/
 /*
 * LinkedListLab assignment and starter code (c) 2021-25 Christopher A. Bohn
 * LinkedListLab solution (c) the above-named student(s)
 */
 #include <assert.h>
 #include <ctype.h>
 #include <stdio.h>
 #include <time.h>
 #include "sorted_word_entries.h"
 #include <string.h>
 /*                   *
 * ALPHABETIZE WORDS *
 *                   */
 /**
 * Makes a copy of a string, except that all uppercase letters in the original
 * word are lowercase in the copy. The original and copy are otherwise
 * identical.
 *
 * @param destination a character array with enough memory allocated to hold a
 *      copy of `word`
 * @param word the word to be copied
 * @return a pointer to `destination` 
 */
 char *word_to_lowercase(char *destination, char const *word) {
    size_t i;
    for (i = 0; word[i] != '\0'; i++) {
        destination[i] = tolower((unsigned char)word[i]);
    }
    destination[i] = '\0';
    return destination;
 }
 /**
 * Determines whether two strings are identical.
 *
 * @param word1 one of the strings to be compared
 * @param word2 the other sting to be compared
 * @return <code>true</code> if and only if every the two strings have the same
 *      length, and character in `word1` matches the corresponding character in
 *      `word2`
 */
 bool words_are_equal(const char *word1, const char *word2) {
}
    return strncmp(word1, word2, MAXIMUM_WORD_LENGTH) == 0;
 /**
 * Determines whether a string occurs earlier than another string in an
 * alphabetic sort.
 *
 * @param word1 the first string to be compared
 * @param word2 the other sting to be compared
 * @return <code>true</code> if and only if `word1` occurs alphabetically
 * earlier than `word2`
 */
 bool word1_is_earlier_than_word2(const char *word1, const char *word2) {
    return strncmp(word1, word2, MAXIMUM_WORD_LENGTH) < 0;
 }
 /**
 * Determines whether a string occurs later than another string in an
 * alphabetic sort.
 *
 * @param word1 the first string to be compared
 * @param word2 the other sting to be compared
 * @return <code>true</code> if and only if `word1` occurs alphabetically
 * later than `word2`
 */
 bool word1_is_later_than_word2(const char *word1, const char *word2) {
    return strncmp(word1, word2, MAXIMUM_WORD_LENGTH) > 0;
 }
 /*                *
 * INSERTION SORT *
 *                */
 /**
 * <p>
 * Places, or updates, a word in an alphabetically-sorted list or word entries.
 * </p><p>
 * If the word is already present in the list, then the number of occurrences
 * in its word entry is incremented. Otherwise, a word entry is created for the
 * word, and the word entry is inserted in the appropriate location in the list
 * such that alphabetic sorting is preserved.
 * </p>
 *
 * @param list the list of alphabetically-sorted words
 * @param word the word to be added or updated
 * @return a pointer to the list
 */
 list_t *insert_word(list_t *list, char const *word) {
    char lower[MAXIMUM_WORD_LENGTH + 1];
    word_to_lowercase(lower, word);
    iterator_t *i = get_iterator(list);
    word_entry_t *entry = get_word_entry(i);
    if (words_are_equal(entry->word, lower)) {
        increment_count(entry);
        return list;
    }
    word_entry_t *entry = create_word_entry(lower);
    append(list, entry);
    return list;
 }
 /*                        *
 * BUILD AND USE THE LIST *
 *                        */
 /**
 * Given the name of the book file from the user, reads the file
 * line-by-line. Under the assumption that there is exactly one word per line
 * and that all punctuation has been removed, this function builds a list of the
 * words (converted to lowercase) in alphabetical order, keeping track of how
 * many times each word occurs in the file.
 *
 * @param filename the name of the file that contains the words for the list
 * @return a pointer to the list
 */
 list_t *build_list(char const *filename) {
 //    clock_t start = clock();
    list_t *list = create_list();
    FILE *book = fopen(filename, "r");
    if (!book) {
        fprintf(stderr, "No such file: %s\n", filename);
        list = NULL;
    } else {
        char word[MAXIMUM_WORD_LENGTH + 1];
        while (fgets(word, MAXIMUM_WORD_LENGTH + 1, book)) {
            word[strlen(word) - 1] = '\0';      // eliminates the undesired newline
 character
        }
            list = insert_word(list, word);
        fclose(book);
    }
 //    clock_t stop = clock();
 //    printf("List built in %f sec\n", (double) (stop - start) / CLOCKS_PER_SEC);
    return list;
 }