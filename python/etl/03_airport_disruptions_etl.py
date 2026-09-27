"""Clean and validate simulated airport-level disruption records."""

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
    "airport_name", "iata_code", "country", "region", "disruption_type",
    "severity_level", "flights_affected", "duration_hours", "date",
]


def main():
    # Step 1: load the raw file only if its columns match the expected schema.
    frame = load_raw_csv("airport_disruptions.csv", EXPECTED_COLUMNS)
    raw_count = len(frame)

    # Step 2: trim text and convert the date column to a real date value.
    frame = parse_dates(trim_text(frame), ["date"])

    # Step 3: validate required fields and reject negative measures.
    require_values(frame, EXPECTED_COLUMNS)
    require_nonnegative(frame, ["flights_affected", "duration_hours"])

    # Step 4: one IATA code must not point to different airports or countries.
    inconsistent_airports = (
        frame.groupby("iata_code", dropna=False)[["airport_name", "country"]]
        .nunique(dropna=False).gt(1).any(axis=1).sum()
    )
    if inconsistent_airports:
        raise ValueError(f"{int(inconsistent_airports)} IATA codes map inconsistently.")
    assert_row_preservation(raw_count, frame)

    # Step 5: write an ISO-date clean file and print the result.
    output = save_clean_csv(frame, "airport_disruptions_clean.csv", date_columns=["date"])
    print_validation_summary(
        "airport_disruptions", raw_count, frame, output, inconsistent_iata_mappings=0
    )


if __name__ == "__main__":
    main()
