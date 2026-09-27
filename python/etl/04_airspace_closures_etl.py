"""Clean and validate simulated airspace-closure records."""

from pathlib import Path
import sys

# Make the shared helper module available when this file runs directly.
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from utils.helpers import (
    assert_row_preservation,
    load_raw_csv,
    parse_dates,
    print_validation_summary,
    require_nonnegative,
    require_values,
    save_clean_csv,
    trim_text,
)


EXPECTED_COLUMNS = [
    "country", "region", "closure_start_date", "closure_end_date",
    "duration_hours", "airspace_zone", "reason", "flights_affected",
]


def main():
    # Step 1: load the raw file only if its columns match the expected schema.
    frame = load_raw_csv("airspace_closures.csv", EXPECTED_COLUMNS)
    raw_count = len(frame)

    # Step 2: trim text and convert both closure fields to timestamps.
    frame = parse_dates(trim_text(frame), ["closure_start_date", "closure_end_date"])

    # Step 3: validate required fields, measures and timestamp order.
    require_values(frame, EXPECTED_COLUMNS)
    require_nonnegative(frame, ["duration_hours", "flights_affected"])
    if (frame["closure_end_date"] < frame["closure_start_date"]).any():
        raise ValueError("Closure end timestamp precedes start timestamp.")

    # Step 4: confirm that the reported duration agrees with the timestamps.
    calculated_hours = (
        frame["closure_end_date"] - frame["closure_start_date"]
    ).dt.total_seconds() / 3600
    mismatch = (calculated_hours - frame["duration_hours"]).abs() > 0.011
    if mismatch.any():
        raise ValueError(f"Duration formula mismatch in {int(mismatch.sum())} records.")
    assert_row_preservation(raw_count, frame)

    # Step 5: keep full timestamps in the clean file and print the result.
    output = save_clean_csv(
        frame, "airspace_closures_clean.csv",
        timestamp_columns=["closure_start_date", "closure_end_date"],
    )
    print_validation_summary(
        "airspace_closures", raw_count, frame, output, duration_formula_mismatches=0
    )


if __name__ == "__main__":
    main()
