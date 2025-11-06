import numpy as np
import pandas as pd

# Generate a random dataframe with 30 columns and 30 rows
num_rows = 30
num_columns = 30

# Generate random values between 0 and 10
random_values = np.random.randint(0, 11, size=(num_rows, num_columns))

# Create a dataframe
df = pd.DataFrame(random_values)

# Add column names
column_names = ['Q{}'.format(i) for i in range(1, num_columns+1)]
df.columns = column_names

# Add row names
row_names = ['S{}'.format(i) for i in range(1, num_rows+1)]
df.index = row_names
df.to_csv('raw_score_dataframe.csv', sep=",", index=True, header=True)
