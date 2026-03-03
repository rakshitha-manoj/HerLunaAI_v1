"""
HerLuna ML Model Evaluation
Generates confusion matrices, ROC curves, feature importance,
baseline comparison, and limitations analysis.
"""
import os
import pandas as pd
import numpy as np
import joblib
from sklearn.metrics import (
    classification_report,
    confusion_matrix,
    roc_auc_score,
    roc_curve,
    accuracy_score,
)
from sklearn.model_selection import cross_val_score
from sklearn.dummy import DummyClassifier
from sklearn.preprocessing import StandardScaler, label_binarize


def evaluate_all_models(data_dir: str = None):
    """Run full evaluation on all trained models."""
    if data_dir is None:
        data_dir = os.path.dirname(os.path.abspath(__file__))

    print("=" * 70)
    print("HerLuna ML Model Evaluation Report")
    print("=" * 70)

    # ── 1. Phase Classifier ──────────────────────────────────────────────
    print("\n" + "─" * 70)
    print("1. PHASE CLASSIFIER (RandomForest)")
    print("─" * 70)
    evaluate_phase_classifier(data_dir)

    # ── 2. Stress Classifier ─────────────────────────────────────────────
    print("\n" + "─" * 70)
    print("2. STRESS CLASSIFIER (LogisticRegression)")
    print("─" * 70)
    evaluate_stress_classifier(data_dir)

    # ── 3. Fatigue Model ─────────────────────────────────────────────────
    print("\n" + "─" * 70)
    print("3. FATIGUE MODEL (RandomForest)")
    print("─" * 70)
    evaluate_fatigue_model(data_dir)

    # ── 4. Limitations ───────────────────────────────────────────────────
    print("\n" + "─" * 70)
    print("4. LIMITATIONS AND CONSIDERATIONS")
    print("─" * 70)
    print_limitations()


def evaluate_phase_classifier(data_dir: str):
    """Evaluate the phase classifier with full metrics."""
    model_path = os.path.join(data_dir, "phase_classifier.pkl")
    csv_path = os.path.join(data_dir, "cycle_training_data.csv")

    if not os.path.exists(model_path) or not os.path.exists(csv_path):
        print("  ✗ Model or data not found. Train models first.")
        return

    model = joblib.load(model_path)
    df = pd.read_csv(csv_path)

    feature_cols = [
        "cycle_length", "day_in_cycle", "fraction_of_cycle",
        "mean_cycle_length", "std_cycle_length", "variability_index"
    ]
    X = df[feature_cols]
    y = df["phase_label"]

    y_pred = model.predict(X)
    phase_names = ["menstrual", "follicular", "ovulatory", "luteal"]

    # Classification report
    print("\n  Classification Report:")
    report = classification_report(y, y_pred, target_names=phase_names, digits=4)
    print("  " + report.replace("\n", "\n  "))

    # Confusion matrix
    print("  Confusion Matrix:")
    cm = confusion_matrix(y, y_pred)
    print(f"  {cm}")

    # ROC AUC (one-vs-rest for multiclass)
    try:
        y_proba = model.predict_proba(X)
        y_bin = label_binarize(y, classes=[0, 1, 2, 3])
        auc_scores = {}
        for i, phase in enumerate(phase_names):
            auc = roc_auc_score(y_bin[:, i], y_proba[:, i])
            auc_scores[phase] = round(auc, 4)
        print(f"\n  ROC AUC (one-vs-rest): {auc_scores}")
    except Exception as e:
        print(f"\n  ROC AUC: could not compute ({e})")

    # Feature importance
    print("\n  Feature Importance:")
    importances = dict(zip(feature_cols, model.feature_importances_))
    for feat, imp in sorted(importances.items(), key=lambda x: x[1], reverse=True):
        bar = "█" * int(imp * 40)
        print(f"    {feat:25s} {imp:.4f} {bar}")

    # Baseline comparison (most-frequent class classifier)
    baseline = DummyClassifier(strategy="most_frequent")
    baseline_scores = cross_val_score(baseline, X, y, cv=5, scoring="accuracy")
    model_scores = cross_val_score(model, X, y, cv=5, scoring="accuracy")
    print(f"\n  Baseline (majority class) accuracy: {baseline_scores.mean():.4f}")
    print(f"  Model cross-val accuracy:           {model_scores.mean():.4f}")
    print(f"  Improvement:                        +{(model_scores.mean() - baseline_scores.mean()):.4f}")


def evaluate_stress_classifier(data_dir: str):
    """Evaluate the stress classifier with full metrics."""
    model_path = os.path.join(data_dir, "stress_classifier.pkl")
    csv_path = os.path.join(data_dir, "stress_training_data.csv")

    if not os.path.exists(model_path) or not os.path.exists(csv_path):
        print("  ✗ Model or data not found. Train models first.")
        return

    saved = joblib.load(model_path)
    model = saved["model"]
    scaler = saved["scaler"]
    df = pd.read_csv(csv_path)

    feature_cols = ["screen_time", "calendar_load", "step_count", "screen_deviation"]
    X = scaler.transform(df[feature_cols])
    y = df["stress_label"]

    y_pred = model.predict(X)

    # Classification report
    print("\n  Classification Report:")
    report = classification_report(y, y_pred, target_names=["low_stress", "high_stress"], digits=4)
    print("  " + report.replace("\n", "\n  "))

    # Confusion matrix
    print("  Confusion Matrix:")
    cm = confusion_matrix(y, y_pred)
    print(f"  {cm}")

    # ROC AUC
    try:
        y_proba = model.predict_proba(X)[:, 1]
        auc = roc_auc_score(y, y_proba)
        print(f"\n  ROC AUC: {auc:.4f}")
    except Exception as e:
        print(f"\n  ROC AUC: could not compute ({e})")

    # Coefficient importance (logistic regression)
    print("\n  Feature Coefficients:")
    coefs = dict(zip(feature_cols, model.coef_[0]))
    for feat, coef in sorted(coefs.items(), key=lambda x: abs(x[1]), reverse=True):
        direction = "+" if coef > 0 else "-"
        bar = "█" * int(abs(coef) * 10)
        print(f"    {feat:25s} {direction}{abs(coef):.4f} {bar}")

    # Baseline comparison
    baseline = DummyClassifier(strategy="most_frequent")
    X_raw = df[feature_cols]
    baseline_scores = cross_val_score(baseline, X_raw, y, cv=5, scoring="accuracy")
    model_scores = cross_val_score(model, X, y, cv=5, scoring="accuracy")
    print(f"\n  Baseline accuracy:        {baseline_scores.mean():.4f}")
    print(f"  Model cross-val accuracy: {model_scores.mean():.4f}")
    print(f"  Improvement:              +{(model_scores.mean() - baseline_scores.mean()):.4f}")


def evaluate_fatigue_model(data_dir: str):
    """Evaluate the fatigue model with full metrics."""
    model_path = os.path.join(data_dir, "fatigue_model.pkl")
    csv_path = os.path.join(data_dir, "fatigue_training_data.csv")

    if not os.path.exists(model_path) or not os.path.exists(csv_path):
        print("  ✗ Model or data not found. Train models first.")
        return

    model = joblib.load(model_path)
    df = pd.read_csv(csv_path)

    feature_cols = [
        "step_count", "screen_time", "calendar_load",
        "step_deviation", "screen_deviation", "calendar_deviation"
    ]
    X = df[feature_cols]
    y = df["fatigue_label"]

    y_pred = model.predict(X)

    # Classification report
    print("\n  Classification Report:")
    report = classification_report(y, y_pred, target_names=["low_fatigue", "high_fatigue"], digits=4)
    print("  " + report.replace("\n", "\n  "))

    # Confusion matrix
    print("  Confusion Matrix:")
    cm = confusion_matrix(y, y_pred)
    print(f"  {cm}")

    # ROC AUC
    try:
        y_proba = model.predict_proba(X)[:, 1]
        auc = roc_auc_score(y, y_proba)
        print(f"\n  ROC AUC: {auc:.4f}")
    except Exception as e:
        print(f"\n  ROC AUC: could not compute ({e})")

    # Feature importance
    print("\n  Feature Importance:")
    importances = dict(zip(feature_cols, model.feature_importances_))
    for feat, imp in sorted(importances.items(), key=lambda x: x[1], reverse=True):
        bar = "█" * int(imp * 40)
        print(f"    {feat:25s} {imp:.4f} {bar}")

    # Baseline comparison
    baseline = DummyClassifier(strategy="most_frequent")
    baseline_scores = cross_val_score(baseline, X, y, cv=5, scoring="accuracy")
    model_scores = cross_val_score(model, X, y, cv=5, scoring="accuracy")
    print(f"\n  Baseline accuracy:        {baseline_scores.mean():.4f}")
    print(f"  Model cross-val accuracy: {model_scores.mean():.4f}")
    print(f"  Improvement:              +{(model_scores.mean() - baseline_scores.mean()):.4f}")


def print_limitations():
    """Print model limitations and considerations."""
    limitations = [
        "1. Models are trained on synthetic data — real-world performance may differ.",
        "2. Phase classification assumes phases are proportional to cycle length,",
        "   which is a simplification of the actual hormonal dynamics.",
        "3. Stress and fatigue classifiers use behavioral proxies (screen time,",
        "   step count) which may not capture the full picture.",
        "4. The system does NOT make medical diagnoses or predict pregnancy.",
        "5. All outputs are probabilistic — confidence scores should guide",
        "   interpretation of results.",
        "6. Model performance depends heavily on consistent user data entry.",
        "7. Individual variability means population-level patterns may not",
        "   apply to every user.",
        "8. The anomaly detection uses Z-score thresholds which may produce",
        "   false positives for users with naturally high variability.",
    ]
    for line in limitations:
        print(f"  {line}")


if __name__ == "__main__":
    evaluate_all_models()
