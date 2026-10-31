"""Run gameplay integration checks with Godot; fail on script/runtime errors too."""
from pathlib import Path
import subprocess
import sys

root = Path(__file__).resolve().parents[2]
engine = sys.argv[1] if len(sys.argv) > 1 else r"C:\Godot\Godot.exe"
reports = root / "tests/progression/reports"
reports.mkdir(exist_ok=True)
(reports / ".gdignore").touch()
suites = [
    "tests/progression/audio_checks.gd",
    "tests/progression/submission_checks.gd",
    "tests/progression/player_walk_checks.gd",
    "tests/combat/beacon_defense_checks.gd",
    "tests/combat/variety_checks.gd",
    "tests/combat/melee_accuracy.gd",
    "tests/progression/animation_checks.gd",
    "tests/progression/atmosphere_checks.gd",
    "tests/combat/wanderer_checks.gd",
    "tests/combat/burst_checks.gd",
    "tests/combat/guardian_controls_checks.gd",
    "tests/combat/guardian_duel.gd",
    "tests/progression/routes.gd",
    "tests/progression/full_run.gd",
]
failed = []
for suite in suites:
    log = reports / (Path(suite).stem + ".log")
    try:
        result = subprocess.run(
            [engine, "--headless", "--path", str(root), "--script", suite,
             "--log-file", str(log)], timeout=120, capture_output=True,
        )
        output = log.read_text(encoding="utf-8") if log.exists() else "ERROR: No log"
        ok = result.returncode == 0 and "ERROR:" not in output and "FAIL " not in output
    except subprocess.TimeoutExpired:
        ok = False
        output = "ERROR: Test timed out"
    print(("PASS " if ok else "FAIL ") + suite, flush=True)
    if not ok:
        failed.append(suite)
        print(output[-6000:], flush=True)
print(f"{len(suites) - len(failed)}/{len(suites)} suites passed", flush=True)
sys.exit(bool(failed))
