#!/usr/bin/env python3
"""Fail the Flutter QA run if any called API endpoint is absent in PHP source.

Run with two source folders. Static contract only: it cannot prove deployed
server versions, database connectivity, credentials, or end-to-end semantics.
"""
from pathlib import Path
import re
import sys

if len(sys.argv) != 3:
    raise SystemExit("Usage: backend_contract_audit.py FLUTTER_LIB PHP_API_DIR")

flutter = Path(sys.argv[1])
backend = Path(sys.argv[2])
files = sorted(flutter.glob("*.dart"))
apis = sorted(backend.glob("*.php"))
if not files or not apis:
    raise SystemExit("ERROR: Flutter or backend source files are missing")

source = "\n".join(file.read_text(encoding="utf-8") for file in apis)
called = {}
expression = re.compile(
    r"(?:\bapi|widget\.api)\s*\.\s*"
    r"(?:call|callWithParams|callWithQuery|upload|photoUrl)\s*"
    r"\(\s*['\"]([a-z][a-z0-9_]*(?:&[^'\"]*)?)['\"]"
)
query = re.compile(r"\baction=([a-z][a-z0-9_]+)")
for path in files:
    dart = path.read_text(encoding="utf-8")
    for match in expression.finditer(dart):
        endpoint = match.group(1).split("&", 1)[0]
        called.setdefault(endpoint, set()).add(path.name)
    for match in query.finditer(dart):
        endpoint = match.group(1)
        called.setdefault(endpoint, set()).add(path.name)

# Certain Dart APIs are built dynamically from an authenticated route name.
# This explicit inventory is inspected in addition to statically found calls.
required = {
    "rt_rw_submit", "rt_rw_list", "rt_rw_decide", "rt_rw_reaffirm",
    "rt_rw_officer_assign", "rt_rw_officers", "rt_rw_signer_status",
    "rt_rw_signer_upload", "rt_rw_pdf",
    "civic_catalog", "civic_list", "civic_detail", "civic_submit",
    "civic_pin_set", "civic_review", "civic_pdf",
    "waris_format", "waris_stage", "waris", "waris_add_witnesses",
    "document_detail", "waris_attachment", "integrated_services_logo_upload",
    "integrated_services", "integrated_services_save",
    "v211_profile", "v211_profile_update", "public_letter_status",
}
for endpoint in required:
    called.setdefault(endpoint, set()).add("required-contract")

missing = []
for action, callers in sorted(called.items()):
    literal = re.search(r"['\"]" + re.escape(action) + r"['\"]", source)
    if literal is None:
        missing.append((action, callers))
print(f"Audit scanned {len(files)} Flutter files, {len(apis)} PHP files "
      f"and {len(called)} called or required actions.")
for action, callers in missing:
    print(f"MISSING backend route: {action} — {', '.join(sorted(callers))}")

if missing:
    raise SystemExit(f"FAIL: {len(missing)} action(s) do not appear in PHP source")
print("PASS: All scanned Flutter actions have PHP handlers or routing definitions.")
print("NOTE: This is a static code contract, not a production service test.")
