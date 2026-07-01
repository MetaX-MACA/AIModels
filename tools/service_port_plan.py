#!/usr/bin/env python3
"""Allocate deterministic service ports for model-serving validation jobs."""

from __future__ import annotations

import argparse
import json

DEFAULT_SERVICES = ['qwen', 'deepseek', 'glm', 'kimi']


def allocate(services: list[str], start: int) -> list[dict[str, object]]:
    return [{"service": name, "port": start + idx, "metrics_port": start + 1000 + idx} for idx, name in enumerate(services)]


def self_test() -> None:
    rows = allocate(DEFAULT_SERVICES[:2], 30000)
    assert rows[0]["port"] == 30000
    assert rows[1]["metrics_port"] == 31001
    print(json.dumps({"ok": True, "services": len(rows)}, ensure_ascii=False))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--service", action="append", default=[])
    parser.add_argument("--start", type=int, default=30000)
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        self_test()
        return 0
    print(json.dumps(allocate(args.service or DEFAULT_SERVICES, args.start), ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
