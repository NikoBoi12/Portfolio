import sys
import os
import random
import string
import subprocess
import time

MUTATION_CHARS = string.printable.strip()

def delete_char(s):
    if not s: return s
    pos = random.randint(0, len(s) - 1)
    return s[:pos] + s[pos + 1:]


def insert_char(s):
    pos = random.randint(0, len(s))
    char = random.choice(MUTATION_CHARS)
    return s[:pos] + char + s[pos:]


def swap_char(s):
    if len(s) < 2: return s
    pos1, pos2 = random.sample(range(len(s)), 2)
    chars = list(s); chars[pos1], chars[pos2] = chars[pos2], chars[pos1]
    return "".join(chars)


def replace_char(s):
    if not s: return s
    pos = random.randint(0, len(s) - 1)
    char = random.choice(MUTATION_CHARS)
    return s[:pos] + char + s[pos + 1:]


def mutate(s):
    mutators = [delete_char, insert_char, swap_char, replace_char]
    return random.choice(mutators)(s)


def get_coverage(input_str, program_path, source_filename="calc.c"):
    program_dir = os.path.dirname(program_path)
    gcov_file = os.path.join(program_dir, source_filename + ".gcov")
    gcda_file = os.path.join(program_dir, source_filename.replace('.c', '.gcda'))

    if os.path.exists(gcov_file): os.remove(gcov_file)
    if os.path.exists(gcda_file): os.remove(gcda_file)

    try:
        subprocess.run([program_path, input_str], cwd=program_dir, capture_output=True, text=True, timeout=2)
    except subprocess.TimeoutExpired:
        return set()

    subprocess.run(["gcov", source_filename], cwd=program_dir, capture_output=True, text=True)

    covered_lines = set()
    if not os.path.exists(gcov_file): return set()

    with open(gcov_file, 'r') as f:
        for line in f:
            parts = line.split(':')
            if len(parts) >= 2 and not parts[0].strip().startswith('#####') and not parts[0].strip().startswith('-'):
                line_num = int(parts[1].strip())
                if line_num > 0:
                    covered_lines.add(f"{source_filename}:{line_num}")
    return covered_lines


def fuzzer(program_path, log_enabled):
    population = ["1 + 1", "10 * 2", "100 / 10", "50 - 25", "1 / 0", "abc"]
    total_coverage = set()
    trials = 0
    start_time = time.time()
    time_limit = 55

    while time.time() - start_time < time_limit:
        trials += 1

        seed = random.choice(population)
        mutated_input = mutate(seed)

        new_coverage = get_coverage(mutated_input, program_path)

        if new_coverage and not new_coverage.issubset(total_coverage):
            population.append(mutated_input)
            new_lines = new_coverage - total_coverage
            total_coverage.update(new_coverage)
            if log_enabled:
                print(f"Trial {trials}: New coverage found! Added '{mutated_input}'. New lines: {len(new_lines)}. Total lines: {len(total_coverage)}")


    population_str = ", ".join([f"'{p}'" for p in population])
    print(population_str)

    print(trials)

    print(len(total_coverage))

    sorted_coverage = sorted(list(total_coverage), key=lambda x: (x.split(':')[0], int(x.split(':')[1])))
    coverage_str = ", ".join(sorted_coverage)
    print(coverage_str)



if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 fuzzer.py /path/to/program [-log]")
        sys.exit(1)

    target_program = sys.argv[1]
    log_mode = len(sys.argv) > 2 and sys.argv[2] == "-log"
    
    fuzzer(target_program, log_mode)
