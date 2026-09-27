"""Clean and validate the undated modeled airline daily-estimate table."""

from pathlib import Path
import sys

# Make the shared helper module available when this file runs directly.
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from utils.helpers import (
    assert_row_preservation,
    load_raw_csv,
    print_validation_summary,
    require_nonnegative,
    require_values,
    save_clean_csv,
    standardize_airline_names,
    trim_text,
)


EXPECTED_COLUMNS = [
    "airline", "country", "estimated_daily_loss_usd", "cancelled_flights",
    "rerouted_flights", "additional_fuel_cost_usd", "passengers_impacted",
]


def main():
    # Step 1: load the raw file only if its columns match the expected schema.
    frame = load_raw_csv("airline_losses_estimate.csv", EXPECTED_COLUMNS)
    raw_count = len(frame)

    # Step 2: trim text and apply the three documented airline-name aliases.
    frame = standardize_airline_names(trim_text(frame))

    # Step 3: validate required and nonnegative values, then preserve all rows.
    require_values(frame, EXPECTED_COLUMNS)
    require_nonnegative(frame, EXPECTED_COLUMNS[2:])
    assert_row_preservation(raw_count, frame)

    # Step 4: write the clean file and report exactly what was standardized.
    output = save_clean_csv(frame, "airline_losses_estimate_clean.csv")
    print_validation_summary(
        "airline_losses_estimate", raw_count, frame, output,
        aliases_applied="PIA; Saudia; Swiss International",
    )


if __name__ == "__main__":
    main()
