import numpy as np

FLOW_MAP = {
    "L": 1,
    "M": 2,
    "H": 3
}

def encode_flow(flow_logs):
    encoded = []
    for cycle in flow_logs:
        encoded_cycle = [FLOW_MAP[day] for day in cycle]
        encoded.append(encoded_cycle)
    return encoded


def extract_cycle_features(cycle_lengths):
    arr = np.array(cycle_lengths)
    return {
        "mean": float(np.mean(arr)),
        "std": float(np.std(arr)),
        "count": int(len(arr))
    }

def extract_period_features(period_durations):
    """
    input: list[int]
    output: dict
    """
    arr = np.array(period_durations)

    return {
        "mean": float(np.mean(arr)),
        "std": float(np.std(arr))
    }
