import pandas as pd

# ==========================
# Dataset Overview
# ==========================


def dataset_overview(df):
    """Display the dataset shape, column names and data types."""

    print("\nDataset Shape:", df.shape)
    print("\nColumn Names:", df.columns)

    print("\nDataset Information:")
    df.info()


# ==========================
# Validation Checks
# ==========================


def check_duplicates(df):
    """Check for duplicate records and return the total count."""

    duplicate_count = df.duplicated().sum()

    print("\nDuplicate Records:")
    print(duplicate_count)

    return duplicate_count


def check_missing_values(df):
    """Check for missing values and return the result."""

    missing_values = df.isnull().sum()

    print("\nMissing Values:")
    print(missing_values)

    return missing_values


def check_text_columns(df):
    """Identify text columns and check for leading/trailing whitespace."""

    text_columns = df.select_dtypes(include=["object", "string"]).columns

    print("\nText Columns:")
    print(text_columns)

    whitespace_total = 0

    for column in text_columns:
        whitespace_count = df[column].str.strip().ne(df[column]).sum()
        whitespace_total += whitespace_count

        print(f"{column}: {whitespace_count}")

    return text_columns, whitespace_total


# ==========================
# Exploratory Validation
# ==========================


def display_unique_values(df, text_columns):
    """Display all unique values in each text column."""

    print("\nUnique Values in Text Columns:")

    for column in text_columns:
        print(f"\n{column}")
        print(df[column].unique())


def display_category_distribution(df, text_columns):
    """Display category frequencies for each text column."""

    print("\nCategory Distribution:")

    for column in text_columns:
        print(f"\n{column}")
        print(df[column].value_counts())


# ==========================
# Numerical and Validation Summary
# ==========================


def numerical_summary(df):
    """Display descriptive statistics for numerical and datetime columns."""

    numeric_df = df.select_dtypes(include=["number", "datetime"])

    if numeric_df.empty:
        print("\nNo numerical or datetime columns available.")
    else:
        print("\nStatistical Summary:")
        print(numeric_df.describe())


def validation_summary(duplicates, missing_values, whitespace):
    """Show and return a summary of validation checks."""
    return {
        "duplicates": int(duplicates),
        "missing_values": int(missing_values.sum()),
        "whitespace": int(whitespace),
    }
