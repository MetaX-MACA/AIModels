#!/usr/bin/env python3
"""Audit markdown model cards or READMEs for required validation information."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

REQUIRED_TERMS = ['MACA', '启动', '性能', '日志']


def audit(root: Path) -> dict[str, object]:
    files: list[dict[str, object]] = []
    for path in sorted(root.glob("**/*.md")):
        text = path.read_text(encoding="utf-8", errors="replace").lower()
        missing = [term for term in REQUIRED_TERMS if term.lower() not in text]
        if missing:
            files.append({"path": path.relative_to(root).as_posix(), "missing": missing})
    return {"file_count": len(files), "files": files}


def self_test() -> None:
    sample = Path("_model_card_audit_sample.md")
    sample.write_text("# model\nMACA\n", encoding="utf-8")
    try:
        data = audit(Path.cwd())
        assert any(item["path"] == sample.name for item in data["files"])
        print(json.dumps({"ok": True, "file_count": data["file_count"]}, ensure_ascii=False))
    finally:
        sample.unlink(missing_ok=True)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", default=".")
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        self_test()
        return 0
    print(json.dumps(audit(Path(args.root)), ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
