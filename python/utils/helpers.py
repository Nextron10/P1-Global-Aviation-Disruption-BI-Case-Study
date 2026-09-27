"""Small shared helpers used by the seven ETL scripts.

The functions in this file only handle repeated technical work such as locating
files, checking schemas and writing UTF-8 CSV files. Dataset-specific business
rules remain visible in each ETL script.
"""

from pathlib import Path

import pandas as pd


REPO_ROOT = Path(__file__).resolve().parents[2]
RAW_DIR = REPO_ROOT / "data" / "raw"
CLEAN_DIR = REPO_ROOT / "data" / "clean"


def load_raw_csv(filename, expected_columns):
    """Load one UTF-8 source file and reject unexpected schema drift."""
    path = RAW_DIR / filename
    frame = pd.read_csv(path, encoding="utf-8")
    actual_columns = list(frame.columns)
    if actual_columns != expected_columns:
        raise ValueError(
            f"Unexpected schema for {filename}. "
            f"Expected {expected_columns}; found {actual_columns}."
        )
    return frame


def trim_text(frame):
    """Trim leading and trailing whitespace without changing null values."""
    text_columns = frame.select_dtypes(include=["object", "string"]).columns
    for column in text_columns:
        frame[column] = frame[column].map(
            lambda value: value.strip() if isinstance(value, str) else value
        )
    return frame


def standardize_airline_names(frame):
    """Apply only the three documented aliases used across financial tables."""
    aliases = {
        "PIA": "Pakistan International Airlines",
        "Saudia": "Saudi Arabian Airlines",
        "Swiss International": "Swiss International Air Lines",
    }
    frame["airline"] = frame["airline"].replace(aliases)
    return frame


def parse_dates(frame, columns):
    """Parse required date/timestamp fields strictly."""
    for column in columns:
        frame[column] = pd.to_datetime(frame[column], errors="raise")
    return frame


def require_values(frame, columns):
    """Reject nulls in fields that define the dataset's documented grain."""
    missing = frame[columns].isna().sum()
    if int(missing.sum()) != 0:
        raise ValueError(f"Required-field nulls found: {missing[missing > 0].to_dict()}")


def require_nonnegative(frame, columns):
    """Reject negative values in count, duration, distance and cost fields."""
    invalid = {column: int((frame[column] < 0).sum()) for column in columns}
    invalid = {column: count for column, count in invalid.items() if count}
    if invalid:
        raise ValueError(f"Negative values found: {invalid}")


def require_range(frame, column, minimum, maximum):
    """Reject values outside an inclusive documented range."""
    invalid = (~frame[column].between(minimum, maximum, inclusive="both")).sum()
    if invalid:
        raise ValueError(
            f"{column} contains {int(invalid)} values outside {minimum}..{maximum}."
        )


def require_categories(frame, column, allowed):
    """Reject undocumented categorical values while allowing schema drift to surface."""
    unexpected = sorted(set(frame[column].dropna().unique()) - allowed)
    if unexpected:
        raise ValueError(f"Unexpected values in {column}: {unexpected}")


def duplicate_count(frame, subset=None):
    """Return duplicate-row or repeated-candidate-key count for reporting."""
    return int(frame.duplicated(subset=subset, keep=False).sum())


def assert_row_preservation(raw_count, clean_frame):
    """Ensure cleaning has neither removed nor added source records."""
    if len(clean_frame) != raw_count:
        raise ValueError(
            f"Row preservation failed: raw={raw_count}, clean={len(clean_frame)}."
        )


def save_clean_csv(frame, filename, date_columns=None, timestamp_columns=None):
    """Write a deterministic UTF-8 clean file with ISO dates and timestamps."""
    output = frame.copy()
    for column in date_columns or []:
        output[column] = output[column].dt.strftime("%Y-%m-%d")
    for column in timestamp_columns or []:
        output[column] = output[column].dt.strftime("%Y-%m-%d %H:%M:%S")
    CLEAN_DIR.mkdir(parents=True, exist_ok=True)
    path = CLEAN_DIR / filename
    output.to_csv(path, index=False, encoding="utf-8", lineterminator="\n")
    return path


def print_validation_summary(dataset, raw_count, frame, output_path, **diagnostics):
    """Print a concise, comparable result for each standalone ETL run."""
    print(f"[{dataset}] validation passed")
    print(f"  rows: raw={raw_count}, clean={len(frame)}")
    print(f"  columns: {len(frame.columns)}")
    print(f"  exact duplicate rows: {int(frame.duplicated().sum())}")
    print(f"  output: {output_path.relative_to(REPO_ROOT)}")
    for label, value in diagnostics.items():
        print(f"  {label}: {value}")
