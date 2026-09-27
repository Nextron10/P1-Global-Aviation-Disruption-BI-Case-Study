"""Clean and validate detailed simulated reroute records."""

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
    "destination_region", "original_route", "new_route", "original_distance_km",
    "new_distance_km", "additional_distance_km", "extra_fuel_cost_usd",
    "delay_hours",
]


def main():
    # Step 1: load the raw file only if its columns match the expected schema.
    frame = load_raw_csv("flight_reroutes.csv", EXPECTED_COLUMNS)
    raw_count = len(frame)

    # Step 2: trim text and convert the date column to a real date value.
    frame = parse_dates(trim_text(frame), ["date"])

    # Step 3: validate required values and reject negative measures.
    require_values(frame, EXPECTED_COLUMNS)
    require_nonnegative(frame, [
        "original_distance_km", "new_distance_km", "additional_distance_km",
        "extra_fuel_cost_usd", "delay_hours",
    ])

    # Step 4: check the distance formula and report repeated flight numbers.
    mismatch = (
        frame["new_distance_km"]
        - frame["original_distance_km"]
        - frame["additional_distance_km"]
    ).abs() > 0.001
    if mismatch.any():
        raise ValueError(f"Distance formula mismatch in {int(mismatch.sum())} records.")

    repeated_flight_rows = duplicate_count(frame, ["flight_number"])
    assert_row_preservation(raw_count, frame)

    # Step 5: write the clean file and print the result.
    output = save_clean_csv(frame, "flight_reroutes_clean.csv", date_columns=["date"])
    print_validation_summary(
        "flight_reroutes", raw_count, frame, output,
        distance_formula_mismatches=0,
        repeated_flight_number_rows=repeated_flight_rows,
    )


if __name__ == "__main__":
    main()
