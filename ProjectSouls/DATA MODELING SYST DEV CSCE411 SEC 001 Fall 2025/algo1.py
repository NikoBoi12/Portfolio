import pandas as pd
import itertools
import time

def run_algorithm_1(csv_filepath, P_students, R_score):
    print("--- Running Algorithm 1 (Brute-Force Method) ---")
    start_time = time.time()

    score_df = pd.read_csv(csv_filepath, index_col=0)

    quiz_names = score_df.columns
    
    combination_size = 4

    all_combinations = itertools.combinations(quiz_names, combination_size)

    successful_combinations = []

    for combo in all_combinations:
        passed_student_count = 0

        for student_scores in score_df.itertuples():
            student_passed_all = True
            
            for quiz in combo:
                if getattr(student_scores, quiz) < R_score:
                    student_passed_all = False
                    break
            
            if student_passed_all:
                passed_student_count += 1
        
        if passed_student_count >= P_students:
            combo_string = ",".join(combo)
            successful_combinations.append(f"{combo_string},{passed_student_count}")

    end_time = time.time()
    running_time = end_time - start_time

    output_filename = "algorithm1_output.txt"
    with open(output_filename, "w") as f:
        f.write("Qi,Qj,Qk,Ql,count\n")
        for result in successful_combinations:
            f.write(result + "\n")

    print(f"Running Time: {running_time:.4f} seconds")


if __name__ == "__main__":

    INPUT_FILE = "raw_score_dataframe.csv"
    
    P_THRESHOLD = 7
    
    R_THRESHOLD = 6 
    
    run_algorithm_1(INPUT_FILE, P_THRESHOLD, R_THRESHOLD)
