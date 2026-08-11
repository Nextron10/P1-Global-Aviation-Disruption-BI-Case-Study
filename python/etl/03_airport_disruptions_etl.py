import pandas as pd

df = pd.read_csv("data/raw/airport_disruptions.csv")

print("\n\nDataset Shape:", df.shape)
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

whitespace_total = 0

for column in text_columns:
    whitespace_count = df[column].str.strip().ne(df[column]).sum()
    whitespace_total += whitespace_count
    print(f"{column}: {whitespace_count}")

print("\nUnique Values in Text Columns:")
for column in text_columns:
    print(f"\n{column}")
    print(df[column].unique())

print("\n Category Distribution:")
for column in text_columns:
    print(f"\n{column}")
    print(df[column].value_counts())


# Standardize leading and trailing whitespace in all text fields before analysis.
for column in text_columns:
    df[column] = df[column].str.strip()


df["date"] = pd.to_datetime(df["date"])

print("\n updated Dataset Information:")
df.info()

print("\nStatistical Summary:")
print(df.describe())

validation_summary = {
    "duplicates": duplicate_count,
    "missing_values": missing_values.sum(),
    "whitespace": whitespace_total,
}

df.to_csv("data/clean/airport_disruptions_clean.csv", index=False)
