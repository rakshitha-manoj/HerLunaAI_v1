"""
HerLuna Synthetic Data Generator
Generates realistic training data for ML models.
Includes cycle logs, behavioral patterns, and labeled outputs.
"""
import numpy as np
import pandas as pd
import os
from datetime import datetime, timedelta


def generate_synthetic_data(
    n_users: int = 200,
    cycles_per_user: int = 12,
    output_dir: str = None,
):
    """
    Generate synthetic training data for phase, stress, and fatigue models.

    Creates:
    - cycle_training_data.csv: features + phase labels
    - stress_training_data.csv: behavioral features + stress labels
    - fatigue_training_data.csv: behavioral features + fatigue labels
    """
    if output_dir is None:
        output_dir = os.path.dirname(os.path.abspath(__file__))

    np.random.seed(42)

    # ── Generate cycle-based training data ────────────────────────────────
    cycle_rows = []
    for user_id in range(n_users):
        # Each user has a personalized mean cycle length (NOT fixed 28)
        mean_cycle = np.random.normal(28, 4)  # Population mean ~28, but varies
        mean_cycle = max(21, min(40, mean_cycle))  # Clamp to realistic range
        std_cycle = np.random.uniform(1, 6)  # Individual variability

        for cycle_idx in range(cycles_per_user):
            cycle_length = max(18, min(50, np.random.normal(mean_cycle, std_cycle)))
            day_in_cycle = np.random.randint(1, int(cycle_length) + 1)

            # Determine phase label based on proportional day
            fraction = day_in_cycle / cycle_length
            if fraction < 0.17:
                phase = 0  # menstrual
            elif fraction < 0.46:
                phase = 1  # follicular
            elif fraction < 0.57:
                phase = 2  # ovulatory
            else:
                phase = 3  # luteal

            # Features
            cycle_rows.append({
                "user_id": user_id,
                "cycle_length": round(cycle_length, 1),
                "day_in_cycle": day_in_cycle,
                "fraction_of_cycle": round(fraction, 4),
                "mean_cycle_length": round(mean_cycle, 1),
                "std_cycle_length": round(std_cycle, 2),
                "variability_index": round(std_cycle / mean_cycle, 4),
                "phase_label": phase,
            })

    cycle_df = pd.DataFrame(cycle_rows)
    cycle_path = os.path.join(output_dir, "cycle_training_data.csv")
    cycle_df.to_csv(cycle_path, index=False)
    print(f"  → Cycle training data: {len(cycle_df)} rows → {cycle_path}")

    # ── Generate behavioral/stress training data ──────────────────────────
    stress_rows = []
    for i in range(n_users * cycles_per_user):
        screen_time = max(0.5, np.random.normal(5.0, 3.0))
        calendar_load = max(0, int(np.random.normal(4, 3)))
        step_count = max(0, int(np.random.normal(6000, 3000)))
        screen_deviation = np.random.normal(0, 1.5)

        # Stress label: higher stress with more screen time, more events, less activity
        stress_score = (
            (screen_time / 14) * 0.3
            + (calendar_load / 10) * 0.25
            + max(0, 1 - step_count / 10000) * 0.15
            + max(0, (screen_deviation + 1) / 4) * 0.3
        )
        stress_label = 1 if stress_score > 0.5 else 0

        stress_rows.append({
            "screen_time": round(screen_time, 2),
            "calendar_load": calendar_load,
            "step_count": step_count,
            "screen_deviation": round(screen_deviation, 3),
            "stress_label": stress_label,
        })

    stress_df = pd.DataFrame(stress_rows)
    stress_path = os.path.join(output_dir, "stress_training_data.csv")
    stress_df.to_csv(stress_path, index=False)
    print(f"  → Stress training data: {len(stress_df)} rows → {stress_path}")

    # ── Generate fatigue training data ────────────────────────────────────
    fatigue_rows = []
    for i in range(n_users * cycles_per_user):
        step_count = max(0, int(np.random.normal(6000, 3000)))
        screen_time = max(0.5, np.random.normal(5.0, 3.0))
        calendar_load = max(0, int(np.random.normal(4, 3)))
        step_dev = np.random.normal(0, 0.3)
        screen_dev = np.random.normal(0, 0.3)
        calendar_dev = np.random.normal(0, 0.3)

        # Fatigue label
        fatigue_score = (
            max(0, 1 - step_count / 10000) * 0.3
            + min(1, screen_time / 12) * 0.35
            + min(1, calendar_load / 10) * 0.2
            + (abs(step_dev) + abs(screen_dev) + abs(calendar_dev)) * 0.05
        )
        fatigue_label = 1 if fatigue_score > 0.45 else 0

        fatigue_rows.append({
            "step_count": step_count,
            "screen_time": round(screen_time, 2),
            "calendar_load": calendar_load,
            "step_deviation": round(step_dev, 3),
            "screen_deviation": round(screen_dev, 3),
            "calendar_deviation": round(calendar_dev, 3),
            "fatigue_label": fatigue_label,
        })

    fatigue_df = pd.DataFrame(fatigue_rows)
    fatigue_path = os.path.join(output_dir, "fatigue_training_data.csv")
    fatigue_df.to_csv(fatigue_path, index=False)
    print(f"  → Fatigue training data: {len(fatigue_df)} rows → {fatigue_path}")

    return cycle_path, stress_path, fatigue_path


if __name__ == "__main__":
    print("Generating synthetic training data...")
    generate_synthetic_data()
    print("Done!")
