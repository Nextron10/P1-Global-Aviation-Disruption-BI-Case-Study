import pandas as pd

df = pd.read_csv("data/raw/airline_losses.csv")

print("\n\n\nDataset Shape:", df.shape)
print("\nColumn Names:", df.columns)

print("\nDataset Information:")
df.info()

print("\nDuplicate Records:")
duplicate_count = df.duplicated().sum()
print(duplicate_count)

print("\nMissing Values:")
missing_values = df.isnull().sum()
print(missing_values)

text_columns = df.select_dtypes(include=["object", "string"]).columns
print("\nText Columns:")
print(text_columns)

for column in text_columns:
    whitespace_count = df[column].str.strip().ne(df[column]).sum()
    print(f"{column}: {whitespace_count}")

print("\nUnique Values in Text Columns:")
for column in text_columns:
    print(f"\n{column}")
    print(df[column].unique())

print("\n Category Distribution:")
for column in text_columns:
    print(f"\n{column}")
    print(df[column].value_counts())

print("\nStatistical Summary of Numerical Columns:")
print(df.describe())

validation_summary = {
    "duplicate": duplicate_count,
    "missing_values": missing_values.sum(),
    "whitespace": 0,
}
df.to_csv("data/clean/airline_losses_clean.csv", index=False)
