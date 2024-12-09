import pandas as pd

# File paths
file1_path = 'C:\Users\GregorySemedo\Desktop\Script\Report\24-07-03 Review only-Marketing.csv'
file2_path = 'C:\Users\GregorySemedo\Desktop\Script\Report\Only-Marketing.csv'
output_detailed_path = 'C:\Users\GregorySemedo\Desktop\Script\Report\Compare.csv'

# Load the data
file1_data = pd.read_csv(file1_path)
file2_data = pd.read_csv(file2_path)

# Ensure all columns have consistent data types for merging
file1_data = file1_data.apply(lambda col: col.astype(str))
file2_data = file2_data.apply(lambda col: col.astype(str))

# Identify lines unique to each file
file1_unique = file1_data.merge(file2_data, how='left', indicator=True).query('_merge == "left_only"').drop('_merge', axis=1)
file2_unique = file2_data.merge(file1_data, how='left', indicator=True).query('_merge == "left_only"').drop('_merge', axis=1)

# Add context about the type of difference
file1_unique['Difference'] = 'Present in File1 only'
file2_unique['Difference'] = 'Present in File2 only'

# Combine the unique rows
detailed_differences = pd.concat([file1_unique, file2_unique], ignore_index=True)

# Export the detailed differences to a CSV
detailed_differences.to_csv(output_detailed_path, index=False)

print(f"Differences exported to: {output_detailed_path}")
