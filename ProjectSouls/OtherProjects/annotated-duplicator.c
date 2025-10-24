/**************************************************************************//**
 *
 * @file duplicator.c
 *
 * @author Tyler Roelfs
 *
 * @brief Functions that students must modify for DuplicatorLab to eliminate
 * race conditions without starving a thread.
 *
 ******************************************************************************/
 /*
 * DuplicatorLab assignment and starter code (c) 2022-23 Christopher A. Bohn
 * DuplicatorLab solution (c) the above-named student
 */
 #include <stdio.h>
 #include <stdbool.h>
 #include <string.h>
 #include <pthread.h>
 #include "duplicator.h"
 volatile char shared_buffer[BUFFER_SIZE] = {0};
 volatile enum {
     BUFFER_HAS_DATA, BUFFER_IS_EMPTY, FINISHED
 } status = BUFFER_IS_EMPTY;
 pthread_mutex_t mutex;
 void *read_original(void *arg) {
     FILE *source_file = (FILE *) arg;
     char local_buffer[BUFFER_SIZE];
     bool copying = true;
     while (copying) {
         pthread_mutex_lock(&mutex);
         if (status == BUFFER_IS_EMPTY) {
             if (fgets(local_buffer, BUFFER_SIZE, source_file)) {
                 memcpy((char *) shared_buffer, local_buffer, BUFFER_SIZE);
                 status = BUFFER_HAS_DATA;
                 pthread_mutex_unlock(&mutex);
             } else {
                 status = FINISHED;
                 copying = false;
                 pthread_mutex_unlock(&mutex);
             }
         } else {
            pthread_mutex_unlock(&mutex);
         }
     }
     return NULL;
 }
 void *write_copy(void *arg) {
     FILE *destination_file = (FILE *) arg;
     char local_buffer[BUFFER_SIZE];
     bool copying = true;
     while (copying) {
         pthread_mutex_lock(&mutex);
         if (status == BUFFER_HAS_DATA) {
             memcpy(local_buffer, (char *) shared_buffer, BUFFER_SIZE);
             status = BUFFER_IS_EMPTY;
             fputs(local_buffer, destination_file);
             pthread_mutex_unlock(&mutex);
         } else if (status == FINISHED) {
             copying = false;
             pthread_mutex_unlock(&mutex);
         } else {
             pthread_mutex_unlock(&mutex);
         }
     }
     return NULL;
 }
 void duplicate(FILE *source_file, FILE *destination_file) {
     pthread_t source_thread, destination_thread;
     pthread_mutex_init(&mutex, NULL);
     pthread_create(&source_thread, NULL, read_original, source_file);
     pthread_create(&destination_thread, NULL, write_copy, destination_file);
     pthread_join(source_thread, NULL);
     pthread_join(destination_thread, NULL);
     pthread_mutex_destroy(&mutex);
 }