"""
HerLuna ML Model Training Pipeline
Trains phase classifier, stress classifier, and fatigue/readiness model.
Uses scikit-learn with proper train/test split and cross-validation.
Saves models as .pkl files.
"""
import os
import pandas as pd
import numpy as np
import joblib
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.metrics import classification_report, accuracy_score
from sklearn.preprocessing import StandardScaler


def train_all_models(data_dir: str = None):
    """Train all three ML models and save as .pkl files."""
    if data_dir is None:
        data_dir = os.path.dirname(os.path.abspath(__file__))

    print("=" * 60)
    print("HerLuna ML Training Pipeline")
    print("=" * 60)

    # ── 1. Phase Classifier ──────────────────────────────────────────────
    print("\n[1/3] Training Phase Classifier (RandomForest)...")
    train_phase_classifier(data_dir)

    # ── 2. Stress Classifier ─────────────────────────────────────────────
    print("\n[2/3] Training Stress Classifier (LogisticRegression)...")
    train_stress_classifier(data_dir)

    # ── 3. Fatigue / Readiness Model ─────────────────────────────────────
    print("\n[3/3] Training Fatigue Model (RandomForest)...")
    train_fatigue_model(data_dir)

    print("\n" + "=" * 60)
    print("All models trained and saved successfully!")
    print("=" * 60)


def train_phase_classifier(data_dir: str):
    """Train a RandomForest phase classifier."""
    csv_path = os.path.join(data_dir, "cycle_training_data.csv")
    if not os.path.exists(csv_path):
        print(f"  ✗ Training data not found: {csv_path}")
        return

    df = pd.read_csv(csv_path)
    feature_cols = [
        "cycle_length", "day_in_cycle", "fraction_of_cycle",
        "mean_cycle_length", "std_cycle_length", "variability_index"
    ]
    X = df[feature_cols]
    y = df["phase_label"]

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )

    model = RandomForestClassifier(
        n_estimators=100,
        max_depth=10,
        random_state=42,
        class_weight="balanced",
    )
    model.fit(X_train, y_train)

    # Evaluate
    y_pred = model.predict(X_test)
    accuracy = accuracy_score(y_test, y_pred)
    print(f"  → Accuracy: {accuracy:.4f}")

    # Cross-validation
    cv_scores = cross_val_score(model, X, y, cv=5, scoring="accuracy")
    print(f"  → Cross-val accuracy: {cv_scores.mean():.4f} ± {cv_scores.std():.4f}")

    # Feature importance
    importances = dict(zip(feature_cols, model.feature_importances_))
    sorted_imp = sorted(importances.items(), key=lambda x: x[1], reverse=True)
    print(f"  → Top features: {[(f, round(v, 3)) for f, v in sorted_imp[:3]]}")

    # Save
    model_path = os.path.join(data_dir, "phase_classifier.pkl")
    joblib.dump(model, model_path)
    print(f"  → Saved: {model_path}")


def train_stress_classifier(data_dir: str):
    """Train a LogisticRegression stress classifier."""
    csv_path = os.path.join(data_dir, "stress_training_data.csv")
    if not os.path.exists(csv_path):
        print(f"  ✗ Training data not found: {csv_path}")
        return

    df = pd.read_csv(csv_path)
    feature_cols = ["screen_time", "calendar_load", "step_count", "screen_deviation"]
    X = df[feature_cols]
    y = df["stress_label"]

    # Scale features for logistic regression
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)

    X_train, X_test, y_train, y_test = train_test_split(
        X_scaled, y, test_size=0.2, random_state=42, stratify=y
    )

    model = LogisticRegression(
        max_iter=1000,
        class_weight="balanced",
        random_state=42,
    )
    model.fit(X_train, y_train)

    # Evaluate
    y_pred = model.predict(X_test)
    accuracy = accuracy_score(y_test, y_pred)
    print(f"  → Accuracy: {accuracy:.4f}")

    # Cross-validation
    cv_scores = cross_val_score(model, X_scaled, y, cv=5, scoring="accuracy")
    print(f"  → Cross-val accuracy: {cv_scores.mean():.4f} ± {cv_scores.std():.4f}")

    # Save model + scaler together
    model_path = os.path.join(data_dir, "stress_classifier.pkl")
    joblib.dump({"model": model, "scaler": scaler}, model_path)
    print(f"  → Saved: {model_path}")


def train_fatigue_model(data_dir: str):
    """Train a RandomForest fatigue/readiness model."""
    csv_path = os.path.join(data_dir, "fatigue_training_data.csv")
    if not os.path.exists(csv_path):
        print(f"  ✗ Training data not found: {csv_path}")
        return

    df = pd.read_csv(csv_path)
    feature_cols = [
        "step_count", "screen_time", "calendar_load",
        "step_deviation", "screen_deviation", "calendar_deviation"
    ]
    X = df[feature_cols]
    y = df["fatigue_label"]

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )

    model = RandomForestClassifier(
        n_estimators=100,
        max_depth=8,
        random_state=42,
        class_weight="balanced",
    )
    model.fit(X_train, y_train)

    # Evaluate
    y_pred = model.predict(X_test)
    accuracy = accuracy_score(y_test, y_pred)
    print(f"  → Accuracy: {accuracy:.4f}")

    # Cross-validation
    cv_scores = cross_val_score(model, X, y, cv=5, scoring="accuracy")
    print(f"  → Cross-val accuracy: {cv_scores.mean():.4f} ± {cv_scores.std():.4f}")

    # Feature importance
    importances = dict(zip(feature_cols, model.feature_importances_))
    sorted_imp = sorted(importances.items(), key=lambda x: x[1], reverse=True)
    print(f"  → Top features: {[(f, round(v, 3)) for f, v in sorted_imp[:3]]}")

    # Save
    model_path = os.path.join(data_dir, "fatigue_model.pkl")
    joblib.dump(model, model_path)
    print(f"  → Saved: {model_path}")


if __name__ == "__main__":
    train_all_models()
