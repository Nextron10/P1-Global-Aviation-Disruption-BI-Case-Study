import sys
from pathlib import Path

import pandas as pd

sys.path.append(str(Path(__file__).resolve().parent.parent))

from utils.helpers import *

df = pd.read_csv("data/raw/conflict_events.csv")

dataset_overview(df)
duplicate_count = check_duplicates(df)
missing_values = check_missing_values(df)
text_columns, whitespace_total = check_text_columns(df)
display_unique_values(df, text_columns)
display_category_distribution(df, text_columns)

df["date"] = pd.to_datetime(df["date"])
df[["location_name", "country"]] = df["location"].str.split(",", n=1, expand=True)

df["location_name"] = df["location_name"].str.strip()
df["country"] = df["country"].str.strip()

df.drop(columns="location", inplace=True)

print("\nDataset Information after dropping 'location' column:")
df.info()

numerical_summary(df)
summary = validation_summary(duplicate_count, missing_values, whitespace_total)

df.to_csv("data/clean/conflict_events_clean.csv", index=False, encoding="utf-8-sig")
