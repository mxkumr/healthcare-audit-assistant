#!/usr/bin/env python3
"""Smoke test: RuralAnalysisChart OData vs dataset calculations."""

from __future__ import annotations

import csv
import json
import sys
import urllib.request
from collections import defaultdict
from decimal import Decimal, ROUND_HALF_UP
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CSV_PATH = ROOT / "db/data/medicare-ServiceDetails.csv"
ODATA_URL = "http://localhost:4004/medicare/RuralAnalysisChart?$top=10000"

TIERS = ("Urban / Metro", "Suburban / Micro", "Rural / Isolated")
TOL = Decimal("0.02")  # allow small float drift vs OData


def money(s: str) -> Decimal:
    return Decimal(s.replace("$", "").replace(",", ""))


def tier(ruca: str) -> str:
    if not ruca or not ruca.strip():
        return "Unclassified"
    v = float(ruca)
    if 1 <= v <= 3:
        return "Urban / Metro"
    if 4 <= v <= 6:
        return "Suburban / Micro"
    if 7 <= v <= 10.3:
        return "Rural / Isolated"
    return "Unclassified"


def rnd2(x: Decimal) -> Decimal:
    return x.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)


def overclaim_rate(submitted: Decimal, rejected: Decimal) -> Decimal | None:
    if submitted <= 0:
        return None
    if rejected <= 0:
        return Decimal("0")
    rate = rejected / submitted * 100
    if rate > 100:
        return Decimal("100")
    return rnd2(rate)


def build_expected() -> dict[tuple[str, str], dict]:
    # RuralAnalysisV2Tier grain: HCPCS × HCPCS_Desc × StructuralTier
    v2: dict[tuple, dict] = defaultdict(
        lambda: {"srv": Decimal(0), "sub": Decimal(0), "paid": Decimal(0), "rej": Decimal(0)}
    )

    with CSV_PATH.open(newline="") as f:
        for row in csv.DictReader(f):
            t = tier(row["Rndrng_Prvdr_RUCA"])
            if t not in TIERS:
                continue
            srv = money(str(row["Tot_Srvcs"] or "0"))
            sub = money(row["Avg_Sbmtd_Chrg"]) * srv
            alw = money(row["Avg_Mdcr_Alowd_Amt"]) * srv
            paid = money(row["Avg_Mdcr_Pymt_Amt"]) * srv
            key = (row["HCPCS_Cd"], row["HCPCS_Desc"], t)
            b = v2[key]
            b["srv"] += srv
            b["sub"] += sub
            b["paid"] += paid
            b["rej"] += sub - alw

    # RuralAnalysisChartBase: roll up descriptions per HCPCS × tier
    base: dict[tuple[str, str], dict] = defaultdict(
        lambda: {
            "desc": None,
            "srv": Decimal(0),
            "sub": Decimal(0),
            "paid": Decimal(0),
            "rej": Decimal(0),
        }
    )
    for (code, desc, structural), m in v2.items():
        key = (code, structural)
        b = base[key]
        if b["desc"] is None or desc < b["desc"]:
            b["desc"] = desc
        b["srv"] += m["srv"]
        b["sub"] += m["sub"]
        b["paid"] += m["paid"]
        b["rej"] += m["rej"]

    # Multi-tier filter (≥2 tiers per HCPCS)
    tier_counts: dict[str, set[str]] = defaultdict(set)
    for code, structural in base:
        tier_counts[code].add(structural)
    multi = {c for c, ts in tier_counts.items() if len(ts) >= 2}

    procedure_baseline: dict[str, Decimal | None] = {}
    for code in multi:
        tot_sub = Decimal(0)
        tot_rej = Decimal(0)
        for structural in TIERS:
            m = base.get((code, structural))
            if m:
                tot_sub += m["sub"]
                tot_rej += m["rej"]
        procedure_baseline[code] = overclaim_rate(tot_sub, tot_rej)

    expected: dict[tuple[str, str], dict] = {}
    for (code, structural), m in base.items():
        if code not in multi or structural not in TIERS:
            continue
        oc = overclaim_rate(m["sub"], m["rej"])
        pb = procedure_baseline.get(code)
        if pb is None:
            dev = oc if oc is not None else None
        else:
            dev = rnd2(oc - pb) if oc is not None else None

        expected[(code, structural)] = {
            "TotalServices": int(m["srv"]),
            "TotalSubmitted": rnd2(m["sub"]),
            "TotalPaid": rnd2(m["paid"]),
            "RejectedCharges": rnd2(m["rej"]),
            "OverclaimRate": oc,
            "ProcedureBaselineRate": pb,
            "TierDeviation": dev,
            "TierCoverageCount": len(tier_counts[code]),
        }

    return expected


def fetch_odata() -> list[dict]:
    rows: list[dict] = []
    skip = 0
    page = 500
    while True:
        url = f"http://localhost:4004/medicare/RuralAnalysisChart?$top={page}&$skip={skip}"
        with urllib.request.urlopen(url, timeout=60) as resp:
            data = json.load(resp)
        batch = data["value"]
        rows.extend(batch)
        if len(batch) < page:
            break
        skip += page
    return rows


def dec(v) -> Decimal | None:
    if v is None:
        return None
    return Decimal(str(v))


def close(a: Decimal | None, b: Decimal | None) -> bool:
    if a is None and b is None:
        return True
    if a is None or b is None:
        return False
    return abs(a - b) <= TOL


def main() -> int:
    print("Rural Analysis smoke test")
    print("=" * 60)

    expected = build_expected()
    print(f"Expected rows (from CSV): {len(expected)}")

    try:
        actual_rows = fetch_odata()
    except Exception as e:
        print(f"FAIL: Could not reach OData at {ODATA_URL}")
        print(f"      {e}")
        print("      Start the app with: npx cds watch")
        return 1

    print(f"Actual rows (OData):      {len(actual_rows)}")

    actual = {
        (r["HCPCS_Code"], r["StructuralTier"]): r for r in actual_rows
    }

    missing = set(expected) - set(actual)
    extra = set(actual) - set(expected)

    failures: list[str] = []
    checked = 0

    fields = [
        "TotalServices",
        "TotalSubmitted",
        "TotalPaid",
        "RejectedCharges",
        "OverclaimRate",
        "ProcedureBaselineRate",
        "TierDeviation",
        "TierCoverageCount",
    ]

    for key, exp in sorted(expected.items()):
        code, structural = key
        if key not in actual:
            failures.append(f"MISSING OData row: {code} / {structural}")
            continue
        act = actual[key]
        checked += 1
        for field in fields:
            ev = exp[field]
            av = act[field]
            if field == "TotalServices" or field == "TierCoverageCount":
                if int(av) != int(ev):
                    failures.append(
                        f"{code}/{structural} {field}: expected {ev}, got {av}"
                    )
            else:
                if not close(dec(av), dec(ev) if ev is not None else None):
                    failures.append(
                        f"{code}/{structural} {field}: expected {ev}, got {av}"
                    )

    # Spot-check known audit examples
    spots = [
        ("J7613", "Rural / Isolated"),
        ("00732", "Rural / Isolated"),
        ("64495", "Suburban / Micro"),
    ]
    print("\nSpot checks:")
    for code, structural in spots:
        key = (code, structural)
        if key in expected and key in actual:
            e, a = expected[key], actual[key]
            ok = all(
                close(dec(a[f]), dec(e[f]) if e[f] is not None else None)
                for f in ("TotalSubmitted", "TotalPaid", "RejectedCharges", "TierDeviation")
            )
            status = "PASS" if ok else "FAIL"
            print(
                f"  [{status}] {code} {structural}: "
                f"billed={a['TotalSubmitted']} paid={a['TotalPaid']} "
                f"dev={a['TierDeviation']}%"
            )
        else:
            print(f"  [SKIP] {code} {structural}: not in both datasets")

    print("\nSummary:")
    print(f"  Rows compared:     {checked}")
    print(f"  Missing from OData: {len(missing)}")
    print(f"  Extra in OData:     {len(extra)}")
    print(f"  Field mismatches:   {len(failures)}")

    if failures:
        print("\nFirst 20 failures:")
        for line in failures[:20]:
            print(f"  - {line}")
        if len(failures) > 20:
            print(f"  ... and {len(failures) - 20} more")
        return 1

    if missing:
        print("\nMissing keys (first 10):", list(sorted(missing))[:10])
        return 1

    print("\nSMOKE TEST PASSED — OData matches CSV calculations for all rows.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
