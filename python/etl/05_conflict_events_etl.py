"""Clean conflict context and retain source locations after trimming spaces."""

from pathlib import Path
import sys

# Make the shared helper module available when this file runs directly.
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from utils.helpers import (
    assert_row_preservation,
    load_raw_csv,
    parse_dates,
    print_validation_summary,
    require_values,
    save_clean_csv,
    trim_text,
)


EXPECTED_COLUMNS = [
    "date", "event_type", "event_description", "location", "severity",
    "aviation_impact",
]


def main():
    # Step 1: load the raw file only if its columns match the expected schema.
    frame = load_raw_csv("conflict_events.csv", EXPECTED_COLUMNS)
    raw_count = len(frame)

    # Step 2: trim text, parse the date and validate the source fields.
    frame = parse_dates(trim_text(frame), ["date"])
    require_values(frame, EXPECTED_COLUMNS)

    # Step 3: retain the original location before deriving location and country.
    frame["source_location"] = frame["location"]
    split_location = frame["location"].str.split(",", n=1, expand=True)
    frame["location_name"] = split_location[0].str.strip()
    frame["country"] = split_location[1].str.strip() if split_location.shape[1] > 1 else None
    frame.loc[frame["country"].eq(""), "country"] = None

    # Step 4: put the final clean columns in the documented order.
    frame = frame[[
        "date", "event_type", "event_description", "source_location",
        "location_name", "country", "severity", "aviation_impact",
    ]]
    null_country_count = int(frame["country"].isna().sum())
    if null_country_count != 42:
        raise ValueError(
            f"Expected 42 unresolved/non-country locations; found {null_country_count}."
        )
    assert_row_preservation(raw_count, frame)

    # Step 5: write the clean file without inventing missing countries.
    output = save_clean_csv(frame, "conflict_events_clean.csv", date_columns=["date"])
    print_validation_summary(
        "conflict_events", raw_count, frame, output,
        unresolved_or_non_country_locations=null_country_count,
    )


if __name__ == "__main__":
    main()
