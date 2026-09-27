"""Clean and validate the undated modeled airline-loss summary."""

from pathlib import Path
import sys

# Make the shared helper module available when this file runs directly.
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from utils.helpers import (
    assert_row_preservation,
    load_raw_csv,
    print_validation_summary,
    require_categories,
    require_nonnegative,
    require_range,
    require_values,
    save_clean_csv,
    trim_text,
)


EXPECTED_COLUMNS = [
    "airline", "country", "airline_type", "estimated_loss_usd",
    "cancellations_count", "reroutes_count", "revenue_loss_pct", "region",
]


def main():
    # Step 1: load the raw file only if its columns match the expected schema.
    frame = load_raw_csv("airline_losses.csv", EXPECTED_COLUMNS)
    raw_count = len(frame)

    # Step 2: remove accidental spaces around text values.
    frame = trim_text(frame)

    # Step 3: validate the rules that are defensible from this dataset.
    require_values(frame, EXPECTED_COLUMNS)
    require_nonnegative(frame, ["estimated_loss_usd", "cancellations_count", "reroutes_count"])
    require_range(frame, "revenue_loss_pct", 0, 100)
    require_categories(frame, "airline_type", {"Cargo", "Flag Carrier", "Low Cost", "Private"})
    assert_row_preservation(raw_count, frame)

    # Step 4: write the clean file and report the validation result.
    output = save_clean_csv(frame, "airline_losses_clean.csv")
    print_validation_summary("airline_losses", raw_count, frame, output)


if __name__ == "__main__":
    main()
