import pandas as pd
import itertools
import time

def run_algorithm_2(csv_filepath, P_students, R_score):
    start_time = time.time()

    score_df = pd.read_csv(csv_filepath, index_col=0)

    passed_sets = {}

    for quiz_name in score_df.columns:
        scores = score_df[quiz_name]
        passing_students = set(scores[scores >= R_score].index)

        if len(passing_students) >= P_students:
            passed_sets[(quiz_name,)] = passing_students

    for combo_size in range(2, 5):
        prev_level_combos = list(passed_sets.keys())
        
        prev_level_combos = [c for c in prev_level_combos if len(c) == combo_size - 1]
        
        new_candidates = set(itertools.combinations(prev_level_combos, 2))
        
        for combo1, combo2 in new_candidates:
            merged_combo = tuple(sorted(set(combo1) | set(combo2)))
            
            if len(merged_combo) == combo_size:
                intersected_students = passed_sets[combo1] & passed_sets[combo2]
                
                if len(intersected_students) >= P_students:
                    passed_sets[merged_combo] = intersected_students
    
    final_results = []
    for combo, students in passed_sets.items():
        if len(combo) == 4:
            combo_string = ",".join(combo)
            student_count = len(students)
            final_results.append(f"{combo_string},{student_count}")

    end_time = time.time()
    running_time = end_time - start_time
    
    output_filename = "algorithm2_output.txt"
    with open(output_filename, "w") as f:
        f.write("Qi,Qj,Qk,Ql,count\n")
        for result in final_results:
            f.write(result + "\n")
            
    print(f"Running Time: {running_time:.4f} seconds")

if __name__ == "__main__":
    INPUT_FILE = "raw_score_dataframe.csv"

    P_THRESHOLD = 7
    R_THRESHOLD = 6
    
    run_algorithm_2(INPUT_FILE, P_THRESHOLD, R_THRESHOLD)
