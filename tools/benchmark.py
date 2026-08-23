#!/usr/bin/env python3
"""Small native CLI benchmark for reproducible local performance checks."""

from __future__ import annotations

import argparse
import json
import subprocess
import tempfile
import time
from pathlib import Path


def build_log(result_count: int) -> dict:
    results = []
    for index in range(result_count):
        results.append(
            {
                "ruleId": "MB001" if index % 2 == 0 else "MB002",
                "level": "warning" if index % 2 == 0 else "note",
                "message": {"text": f"finding {index}"},
                "locations": [
                    {
                        "physicalLocation": {
                            "artifactLocation": {"uri": f"src/file{index % 50}.mbt"},
                            "region": {"startLine": index + 1, "startColumn": 1},
                        }
                    }
                ],
            }
        )
    return {
        "version": "2.1.0",
        "runs": [
            {
                "tool": {"driver": {"name": "MoonSARIF benchmark"}},
                "results": results,
            }
        ],
    }


def measure(label: str, command: list[str], cwd: Path) -> float:
    start = time.perf_counter()
    subprocess.run(command, cwd=cwd, check=True, stdout=subprocess.DEVNULL)
    elapsed = (time.perf_counter() - start) * 1000
    print(f"{label:14} {elapsed:8.2f} ms")
    return elapsed


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--results", type=int, default=1000)
    args = parser.parse_args()
    if args.results <= 0:
        raise SystemExit("--results must be positive")
    root = Path(__file__).resolve().parents[1]
    with tempfile.TemporaryDirectory(prefix="moonsarif-benchmark-") as directory:
        input_path = Path(directory) / "benchmark.sarif"
        input_path.write_text(json.dumps(build_log(args.results)), encoding="utf-8")
        print(f"MoonSARIF benchmark: {args.results} results")
        measure("validate", ["moon", "run", "cmd/main", "--", "validate", str(input_path)], root)
        measure("summary", ["moon", "run", "cmd/main", "--", "summary", str(input_path)], root)
        measure("deduplicate", ["moon", "run", "cmd/main", "--", "deduplicate", str(input_path)], root)
        measure("report", ["moon", "run", "cmd/main", "--", "report", str(input_path)], root)


if __name__ == "__main__":
    main()
