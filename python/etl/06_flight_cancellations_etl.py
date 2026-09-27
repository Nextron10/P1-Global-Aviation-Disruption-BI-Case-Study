"""Clean and validate detailed simulated cancellation records."""

from pathlib import Path
import sys

# Make the shared helper module available when this file runs directly.
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from utils.helpers import (
    assert_row_preservation,
    duplicate_count,
    load_raw_csv,
    parse_dates,
    print_validation_summary,
    require_nonnegative,
    require_values,
    save_clean_csv,
    trim_text,
)


EXPECTED_COLUMNS = [
    "date", "airline", "flight_number", "origin", "destination",
    "origin_country", "destination_country", "origin_region",
    "destination_region", "aircraft_type", "passengers_affected", "reason",
]


def main():
    # Step 1: load the raw file only if its columns match the expected schema.
    frame = load_raw_csv("flight_cancellations.csv", EXPECTED_COLUMNS)
    raw_count = len(frame)

    # Step 2: trim text and convert the date column to a real date value.
    frame = parse_dates(trim_text(frame), ["date"])

    # Step 3: validate required values and passenger counts.
    require_values(frame, EXPECTED_COLUMNS)
    require_nonnegative(frame, ["passengers_affected"])

    # Step 4: report repeated flight numbers; do not delete valid dated events.
    repeated_flight_rows = duplicate_count(frame, ["flight_number"])
    assert_row_preservation(raw_count, frame)

    # Step 5: write the clean file and print the result.
    output = save_clean_csv(frame, "flight_cancellations_clean.csv", date_columns=["date"])
    print_validation_summary(
        "flight_cancellations", raw_count, frame, output,
        repeated_flight_number_rows=repeated_flight_rows,
        note="Repeated flight numbers are reported, not treated as duplicate events.",
    )


if __name__ == "__main__":
    main()
