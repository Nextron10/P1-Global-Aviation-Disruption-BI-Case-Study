import sys
from pathlib import Path

import pandas as pd

sys.path.append(str(Path(__file__).resolve().parent.parent))

from utils.helpers import *

df = pd.read_csv("data/raw/flight_reroutes.csv")

dataset_overview(df)
duplicate_count = check_duplicates(df)
missing_values = check_missing_values(df)
text_columns, whitespace_total = check_text_columns(df)
display_unique_values(df, text_columns)
display_category_distribution(df, text_columns)

df["date"] = pd.to_datetime(df["date"])

print("\nUpdated Dataset Information:")
df.info()

numerical_summary(df)
summary = validation_summary(
    duplicate_count,
    missing_values,
    whitespace_total,
)

print("\nValidation Summary:")
print(summary)

df.to_csv(
    "data/clean/flight_reroutes_clean.csv",
    index=False,
    encoding="utf-8-sig",
)
